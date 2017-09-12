module Webdriver.Runner
    exposing
        ( Model
        , Run
        , Msg(..)
        , Flags
        , RunStatus
        , Summary
        , WebdriverRunner
        , PortEvent
        , run
        , describe
        , group
        )

{-| Allows you to execute a list list of steps or a group of these steps and get a summary
of each of the runs. This module acts as a test suite runner, but can be reused for any
other purpose as it will just run each of the steps at a time and report back the status
using a port and through the Summary type alias.


## Types

@docs Model, Run, Msg, Flags, RunStatus, Summary, WebdriverRunner, PortEvent


## Creating runs and groups of runs

In order to run a list of steps you need to give the a name. You can also group multiple of them
inside groups.

@docs describe, group


## Kicking it off

@docs run

-}

import Dict exposing (Dict)
import Expect
import Time exposing (Time)
import Task
import Tuple exposing (first, second)
import Json.Encode as Encode
import Webdriver as W exposing (..)
import Webdriver.Assert exposing (..)
import Webdriver.Process as P exposing (Model, OutMsg(..), StepResult(..))


-- Required to prevent a bug in elm  0.18

import Json.Decode


{-| The events send through the port
-}
type alias PortEvent =
    { name : String, value : Encode.Value }


type alias Emitter evt msg =
    evt -> Cmd msg


type alias ExternalEmitter =
    Emitter PortEvent Msg


type alias InternalEmitter =
    Emitter Event Msg


type Event
    = Status (List ( String, RunStatus ))
    | StatusUpdate (List ( String, RunStatus ))
    | Screenshots String (List String)
    | Log String Summary
    | Exit Summary


toPort : Event -> PortEvent
toPort event =
    case event of
        Status list ->
            list
                |> List.map (\( name, sts ) -> Encode.object [ ( "name", Encode.string name ), ( "value", encodeRunStatus sts ) ])
                |> Encode.list
                |> PortEvent "status"

        StatusUpdate list ->
            list
                |> List.map (\( name, sts ) -> Encode.object [ ( "name", Encode.string name ), ( "value", encodeRunStatus sts ) ])
                |> Encode.list
                |> PortEvent "statusUpdate"

        Screenshots runName screenshots ->
            [ ( "name", Encode.string runName ), ( "shots", Encode.list <| List.map Encode.string screenshots ) ]
                |> Encode.object
                |> PortEvent "screenshots"

        Log runName summary ->
            [ ( "name", Encode.string runName ), ( "value", encodeSummary summary ) ]
                |> Encode.object
                |> PortEvent "log"

        Exit summary ->
            PortEvent "exit" (encodeSummary summary)


{-| The model used for concurrently running multiple lists of steps
-}
type alias Model =
    { options : W.Options
    , runs : Run
    , sessions : Dict String P.Model
    , initTimes : Dict String Time
    , startTimes : Dict String Time
    , statuses : Dict String RunStatus
    , summaries : Dict String Summary
    , summary : Summary
    }


{-| Represents the current status of a single run.
-}
type alias RunStatus =
    { failed : Bool
    , total : Int
    , remaining : Int
    , nextStep : String
    }


encodeRunStatus : RunStatus -> Encode.Value
encodeRunStatus status =
    Encode.object
        [ ( "failed", Encode.bool status.failed )
        , ( "total", Encode.int status.total )
        , ( "remaining", Encode.int status.remaining )
        , ( "nextStep", Encode.string status.nextStep )
        ]


{-| Represents the final result of a single run or a group of runs.
-}
type alias Summary =
    { output : String
    , passed : Int
    , failed : Int
    , screenshots : List String
    }


encodeSummary : Summary -> Encode.Value
encodeSummary summary =
    Encode.object
        [ ( "output", Encode.string summary.output )
        , ( "passed", Encode.int summary.passed )
        , ( "failed", Encode.int summary.failed )
        , ( "screenshots", Encode.list <| List.map Encode.string summary.screenshots )
        ]


type alias SingleRun =
    List Step


{-| A Run can be either a single list of Step to execute in the browser or
a group of these lists. Groups can be nested arbitrarily.
-}
type Run
    = Group String (List Run)
    | Run String SingleRun


{-| Custom options to be set to the runner, such as filtering tests
by name:

    - filter: A string to match against the run name. Only matching runs will execute.

-}
type alias Flags =
    { filter : Maybe String
    }


{-| Describes programs created by this module. To be used as the main function signature
-}
type alias WebdriverRunner =
    Platform.Program Flags Model Msg


{-| Runs all the webdriver steps and displays the results
-}
run : ExternalEmitter -> Options -> Run -> WebdriverRunner
run emitter options steps =
    let
        emit =
            toPort >> emitter
    in
        Platform.programWithFlags
            { init = begin emit options steps
            , update = update emit
            , subscriptions = always Sub.none
            }


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
    = Begin Flags
    | StartRun String (Cmd P.Msg) Time
    | StartedRun String Time
    | StopRun String Summary Time
    | DriverMsg String P.Msg
    | Done Summary


{-| Creates a new empty Model.

    initModel browserOptions (describe "All Tests" [...])

-}
initModel : Options -> Run -> Model
initModel options runs =
    { runs = runs
    , options = options
    , sessions = Dict.empty
    , summaries = Dict.empty
    , summary = newSummary
    , initTimes = Dict.empty
    , startTimes = Dict.empty
    , statuses = Dict.empty
    }


newSummary : Summary
newSummary =
    { output = "", passed = 0, failed = 0, screenshots = [] }


initStatus : Int -> RunStatus
initStatus total =
    { failed = False
    , total = total
    , remaining = total
    , nextStep = "Waiting for start"
    }


{-| Creates the initial `update` state out of the browser options and
a Run suite. This is usually the function you will call to feed your
main program.

    begin flags browserOptions (describe "All Tests" [...])

-}
begin : InternalEmitter -> Options -> Run -> Flags -> ( Model, Cmd Msg )
begin emit options steps flags =
    update emit (Begin flags) (initModel options steps)


{-| Starts the browser sessions and executes all the steps. Finally, it displays a sumamry
of the run with the help of a port.
-}
update : InternalEmitter -> Msg -> Model -> ( Model, Cmd Msg )
update emit msg model =
    case msg of
        Begin flags ->
            dispatchTests emit flags.filter model

        StartRun i cmd initTime ->
            let
                newInitTimes =
                    Dict.insert i initTime model.initTimes
            in
                ( { model | initTimes = newInitTimes }, Cmd.map (DriverMsg i) cmd )

        StartedRun i startTime ->
            let
                newStartTimes =
                    Dict.insert i startTime model.startTimes
            in
                ( { model | startTimes = newStartTimes }, Cmd.none )

        DriverMsg i action ->
            case Dict.get i model.sessions of
                Just subModel ->
                    delegateMessage emit i action subModel model

                _ ->
                    ( model, Cmd.none )

        StopRun runName summary stopTime ->
            let
                getTime property =
                    (property model)
                        |> Dict.get runName
                        |> Maybe.withDefault stopTime

                startTime =
                    getTime .startTimes

                initTime =
                    getTime .initTimes

                waitTime =
                    (startTime - initTime) / Time.second

                ellapsed =
                    (stopTime - startTime) / Time.second

                took =
                    "Took " ++ (toString ellapsed) ++ "s. "

                wait =
                    "Waited " ++ (toString waitTime) ++ "s for dispatch"

                outputWithTime =
                    { summary | output = summary.output ++ took ++ wait }

                firstTime default =
                    getFirstRunTime model.startTimes default

                terminate =
                    if Dict.isEmpty model.sessions then
                        Task.succeed (exitOutput model.summary (firstTime stopTime) stopTime)
                            |> Task.perform Done
                    else
                        Cmd.none
            in
                ( model, Cmd.batch [ emit <| Log runName outputWithTime, terminate ] )

        Done summary ->
            model ! [ emit <| Exit summary ]


dispatchTests : InternalEmitter -> Maybe String -> Model -> ( Model, Cmd Msg )
dispatchTests emit filterString model =
    let
        filter =
            filterString
                |> Maybe.map String.contains
                |> Maybe.withDefault (always True)

        nextState =
            model.runs
                |> flattenRuns []
                |> List.filter (first >> filter)
                |> List.indexedMap (,)
                |> List.foldr (dispatchHelper model.options) ( model, [] )

        newModel =
            first nextState

        statuses =
            newModel.statuses
                |> Dict.toList
    in
        ( newModel, Cmd.batch <| (emit <| Status statuses) :: (second nextState) )


{-| Compacts a list of named steps into an already provided Model and list of commands.
This is used to build a single model and a single list of commands to dispatch out of
a list of steps to run.
-}
dispatchHelper : W.Options -> ( Int, ( String, SingleRun ) ) -> ( Model, List (Cmd Msg) ) -> ( Model, List (Cmd Msg) )
dispatchHelper options ( i, ( name, steps ) ) ( model, msgs ) =
    let
        key =
            (toString i) ++ " - " ++ name

        ( wModel, wMsg, _ ) =
            P.update (P.open options) (P.init steps)

        newSessions =
            Dict.insert key wModel model.sessions

        status =
            initStatus (List.length steps)

        newStatuses =
            Dict.insert key status model.statuses

        newSummaries =
            Dict.insert key newSummary model.summaries

        dispatchCommand =
            Time.now
                |> Task.map (StartRun key wMsg)
                |> Task.perform identity
    in
        ( { model
            | sessions = newSessions
            , statuses = newStatuses
            , summaries = newSummaries
          }
        , dispatchCommand :: msgs
        )


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


delegateMessage : InternalEmitter -> String -> P.Msg -> P.Model -> Model -> ( Model, Cmd Msg )
delegateMessage emit runName action subModel thisModel =
    let
        ( session, next, progressMessage ) =
            P.update action subModel

        subCommand =
            Cmd.map (DriverMsg runName) next

        newSessions =
            Dict.insert runName session thisModel.sessions

        updatedModel =
            { thisModel | sessions = newSessions }

        ( newModel, reportCommands ) =
            case progressMessage of
                Spawned ->
                    ( updatedModel
                    , Time.now
                        |> Task.map (StartedRun runName)
                        |> Task.perform identity
                    )

                Progress remaining result nextStep ->
                    updateStatus emit runName updatedModel remaining result nextStep

                None ->
                    ( updatedModel, Cmd.none )

                Finalized ->
                    endSummary emit runName updatedModel subModel
    in
        ( newModel, Cmd.batch [ reportCommands, subCommand ] )


updateStatus : InternalEmitter -> String -> Model -> Int -> StepResult -> String -> ( Model, Cmd Msg )
updateStatus emit runName thisModel remaining result nextStep =
    let
        summaries =
            Dict.update runName (Maybe.map (updateSummary result)) thisModel.summaries

        failed =
            Dict.get runName summaries
                |> Maybe.map .failed
                |> Maybe.withDefault 0

        updater status =
            { status
                | remaining = remaining
                , failed = status.failed || failed > 0
                , nextStep = nextStep
            }

        newStatuses =
            Dict.update runName (Maybe.map updater) thisModel.statuses

        newModel =
            { thisModel | statuses = newStatuses, summaries = summaries }
    in
        ( newModel, emit <| StatusUpdate (Dict.toList newStatuses) )


endSummary : InternalEmitter -> String -> Model -> P.Model -> ( Model, Cmd Msg )
endSummary emit runName thisModel subModel =
    let
        runSummary =
            Dict.get runName thisModel.summaries
                |> Maybe.withDefault newSummary

        summary =
            thisModel.summary

        updatedSummary =
            { summary
                | passed = summary.passed + runSummary.passed
                , failed = summary.failed + runSummary.failed
            }

        remainingSessions =
            Dict.remove runName thisModel.sessions

        remainingSummaries =
            Dict.remove runName thisModel.summaries

        newModel =
            { thisModel
                | sessions = remainingSessions
                , summary = updatedSummary
                , summaries = remainingSummaries
            }

        signalStop =
            Time.now
                |> Task.map (StopRun runName runSummary)
                |> Task.perform identity

        persistScreenshots =
            emit <| Screenshots runName runSummary.screenshots
    in
        ( newModel, Cmd.batch [ signalStop, persistScreenshots ] )


updateSummary : StepResult -> Summary -> Summary
updateSummary (StepResult description { expectation, screenshot }) summary =
    case ( expectation, screenshot ) of
        ( Just ex, Nothing ) ->
            fromResult description ex [] summary

        ( Just ex, Just s ) ->
            fromResult description ex [ s ] summary

        ( Nothing, Just s ) ->
            { summary | screenshots = List.append summary.screenshots [ s ] }

        _ ->
            summary


fromResult : String -> Expectation -> List String -> Summary -> Summary
fromResult description expectation screenshots summary =
    case Expect.getFailure expectation of
        Nothing ->
            { summary
                | output = summary.output ++ "✅  " ++ description ++ "\n"
                , passed = summary.passed + 1
                , screenshots = List.append summary.screenshots screenshots
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
                { summary
                    | output = summary.output ++ newOutput
                    , failed = summary.failed + 1
                    , screenshots = List.append summary.screenshots screenshots
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
        |> List.map second
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
