port module Webdriver.Runner
    exposing
        ( Model
        , Run
        , Msg
        , describe
        , group
        , begin
        , update
        )

{-| Allows you to execute a list list of steps or a group of these steps and get a summary
of each of the runs.

## Types

@docs Model, Run, Msg

## Creating runs and groups of runs

In order to run a list of steps you need to give the a name. You can also group multiple of them
inside groups.

@docs describe, group

## Kicking it off

@docs begin, update

-}

import Dict exposing (Dict)
import Expect
import String
import Time exposing (Time)
import Task
import Webdriver as W exposing (..)
import Webdriver.Assert exposing (..)


{-| The model used for concurrently running multiple lists of steps
-}
type alias Model =
    { options : W.Options
    , runs : Run
    , sessions : Dict String W.Model
    , startTimes : Dict String Time
    , summary : Summary
    }


type alias Summary =
    { output : String, passed : Int, failed : Int }


type alias SingleRun =
    List Step


{-| A Run can be either a single list of Step to execute in the browser or
a group of these lists. Groups can be nested arbitrarily.
-}
type Run
    = Group String (List Run)
    | Run String SingleRun


{-| Describes with a name a list of steps to be executed

    describe "Login smoke test" [...]
-}
describe : String -> SingleRun -> Run
describe name list =
    Run name list


{-| Groups a list Runs under the same name

    group "All Smoke Tests"
        [ describe "Login Tests" [...]
        , describe "Signup Tests" [...]
        ]
-}
group : String -> List Run -> Run
group name list =
    Group name list


{-| The Messages this module can process
-}
type Msg
    = Begin
    | StartRun String (Cmd W.Msg) Time
    | StopRun String Summary Time
    | DriverMsg String W.Msg


{-| Creates a new empty Model.

    initModel browserOptions (describe "All Tests" [...])
-}
initModel : Options -> Run -> Model
initModel options runs =
    { runs = runs
    , options = options
    , sessions = Dict.empty
    , summary = { output = "", passed = 0, failed = 0 }
    , startTimes = Dict.empty
    }


{-| Creates the initial `update` state out of the browser options and
a Run suite. This is usually the function you will call to feed your
main program.

    begin browserOptions (describe "All Tests" [...])
-}
begin : Options -> Run -> ( Model, Cmd Msg )
begin options steps =
    update Begin (initModel options steps)


{-| Starts the browser sessions and executes all the steps. Finally, it displays a sumamry
of the run with the help of a port.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Begin ->
            dispatchTests model

        StartRun i cmd startTime ->
            let
                newStartTimes =
                    Dict.insert i startTime model.startTimes
            in
                ( { model | startTimes = newStartTimes }, Cmd.map (DriverMsg i) cmd )

        DriverMsg i action ->
            case Dict.get i model.sessions of
                Just subModel ->
                    delegateMessage i action subModel model

                _ ->
                    ( model, Cmd.none )

        StopRun runName summary stopTime ->
            let
                startTime =
                    model.startTimes
                        |> Dict.get runName
                        |> Maybe.withDefault stopTime

                ellapsed =
                    (stopTime - startTime) / Time.second

                outputWithTime =
                    { summary | output = summary.output ++ "Took " ++ (toString ellapsed) ++ "s." }

                firstTime default =
                    getFirstRunTime model.startTimes default

                terminate =
                    if Dict.isEmpty model.sessions then
                        exit <| exitOutput model.summary (firstTime stopTime) stopTime
                    else
                        Cmd.none
            in
                ( model, Cmd.batch [ printLog ( runName, outputWithTime ), terminate ] )


dispatchTests : Model -> ( Model, Cmd Msg )
dispatchTests model =
    let
        nextState =
            model.runs
                |> flattenRuns []
                |> List.indexedMap (,)
                |> List.foldr (dispatchHelper model.options) ( model, [] )
    in
        ( fst nextState, Cmd.batch (snd nextState) )


{-| Compacts a list of named steps into an already provided Model and list of commands.
This is used to build a single model and a single list of commands to dispatch out of
a list of steps to run.
-}
dispatchHelper : W.Options -> ( Int, ( String, SingleRun ) ) -> ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
dispatchHelper options ( i, ( name, steps ) ) ( model, msgs ) =
    let
        key =
            (toString i) ++ " - " ++ name

        ( wModel, wMsg ) =
            W.update (open options) (init steps)

        newSessions =
            Dict.insert key wModel model.sessions

        dispatchCommand =
            Time.now
                |> Task.map (StartRun key wMsg)
                |> Task.perform identity identity
    in
        ( { model | sessions = newSessions }, dispatchCommand :: msgs )


flattenRuns : List ( String, SingleRun ) -> Run -> List ( String, SingleRun )
flattenRuns result suite =
    case suite of
        Group name runs ->
            runs
                |> List.map (flattenRuns [])
                |> List.concat
                |> List.map (\( singleName, steps ) -> ( name ++ " / " ++ singleName, steps ))
                |> List.append result

        Run name steps ->
            ( name, steps ) :: result


delegateMessage : String -> W.Msg -> W.Model -> Model -> ( Model, Cmd Msg )
delegateMessage runName action subModel thisModel =
    case action of
        W.Finish ->
            let
                newSummary =
                    collectLog subModel

                summary =
                    thisModel.summary

                updatedSummary =
                    { summary
                        | passed = summary.passed + newSummary.passed
                        , failed = summary.failed + newSummary.failed
                    }

                remainingSessions =
                    Dict.remove runName thisModel.sessions

                newModel =
                    { thisModel | sessions = remainingSessions, summary = updatedSummary }

                command =
                    Time.now
                        |> Task.map (StopRun runName newSummary)
                        |> Task.perform identity identity
            in
                ( newModel, command )

        _ ->
            let
                ( session, next ) =
                    W.update action subModel

                newSessions =
                    Dict.insert runName session thisModel.sessions
            in
                ( { thisModel | sessions = newSessions }, Cmd.map (DriverMsg runName) next )


collectLog : W.Model -> Summary
collectLog ( _, expectations, _ ) =
    expectations
        |> List.filterMap identity
        |> List.reverse
        |> toOutput { output = "", passed = 0, failed = 0 }


toOutput : Summary -> List StepResult -> Summary
toOutput summary expectations =
    case expectations of
        (StepResult desc x) :: xs ->
            toOutput (fromExpectation desc x summary) xs

        [] ->
            { summary | output = summary.output ++ "\n\n" }


fromExpectation : String -> Expectation -> Summary -> Summary
fromExpectation description expectation summary =
    case Expect.getFailure expectation of
        Nothing ->
            { summary
                | output = summary.output ++ "✅  " ++ description ++ "\n"
                , passed = summary.passed + 1
            }

        Just { given, message } ->
            let
                heading =
                    "❌  " ++ description ++ "\n"

                prefix =
                    if String.isEmpty given then
                        heading
                    else
                        heading ++ given ++ "\n"

                newOutput =
                    (prefix ++ indentLines message) ++ "\n"
            in
                { output = summary.output ++ newOutput
                , failed = summary.failed + 1
                , passed = summary.passed
                }


indentLines : String -> String
indentLines str =
    str
        |> String.split "\n"
        |> List.map ((++) "    ")
        |> String.join "\n"


getFirstRunTime : Dict String Time -> Time -> Time
getFirstRunTime startTimes default =
    startTimes
        |> Dict.toList
        |> List.map snd
        |> List.minimum
        |> Maybe.withDefault default


exitOutput : Summary -> Time -> Time -> Summary
exitOutput summary startTime endTime =
    let
        statusWord =
            if summary.failed > 0 then
                "Failed: " ++ (toString summary.failed) ++ " assertions failed, "
            else
                "OK. "

        ellapsed =
            (endTime - startTime) / Time.second

        epilog =
            (toString summary.passed) ++ " assertions passed. Took " ++ (toString ellapsed) ++ "s in total."
    in
        { summary | output = "\n\n" ++ statusWord ++ epilog }


never : Never -> a
never a =
    never a



-- PORTS


port printLog : ( String, Summary ) -> Cmd msg


port exit : Summary -> Cmd msg
