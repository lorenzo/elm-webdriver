port module Main exposing (..)

import Html
import Html.App as App
import Webdriver as W exposing (..)
import Webdriver.Assert exposing (..)
import String
import Dict exposing (Dict)
import Expect


main : Program Never
main =
    App.program
        { init = begin basicOptions [ actions, actions2 ]
        , update = update
        , view = \_ -> Html.text "it works!"
        , subscriptions = always Sub.none
        }


type alias Model =
    { options : W.Options
    , runs : List (List Step)
    , sessions : Dict Int W.Model
    }


type alias Summary =
    { output : String, passed : Int, failed : Int }


type Msg
    = Begin
    | EmitLog Summary
    | DriverMsg Int W.Msg


initModel : Options -> List (List Step) -> Model
initModel options runs =
    { runs = runs
    , options = options
    , sessions = Dict.empty
    }


begin options steps =
    update Begin (initModel options steps)


actions : List Step
actions =
    [ visit "https://google.com"
    , title <| Expect.equal "this will fail!"
    , elementCount "input[name='q']" <| Expect.atLeast 1
    , setValue "input[name='q']" "Elm lang"
    , elementText "#rso > div:nth-child(1) > div:nth-child(1) > div > h3 > a" <|
        Expect.equal "Elm is the best"
    , click "#rso > div:nth-child(1) > div:nth-child(1) > div > h3 > a"
    , pause 2000
    , title <|
        Expect.equal "home"
    ]


actions2 : List Step
actions2 =
    [ visit "https://google.com"
    , title <| Expect.equal "Google"
    , elementCount "input[name='q']" <| Expect.atLeast 1
    , setValue "input[name='q']" "Hacker News"
    , elementText "#rso > div:nth-child(1) > div:nth-child(1) > div > h3 > a" <|
        Expect.equal "Hacker News"
    , click "#rso > div:nth-child(1) > div:nth-child(1) > div > h3 > a"
    , pause 2000
    , title <|
        Expect.equal "home"
    ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Begin ->
            dispatchTests model

        DriverMsg i action ->
            case Dict.get i model.sessions of
                Just subModel ->
                    delegateMessage i action subModel model

                _ ->
                    ( model, Cmd.none )

        EmitLog output ->
            ( model, printLog output )


dispatchTests model =
    let
        dispatchHelper ( i, steps ) ( model', msgs ) =
            let
                ( wModel, wMsg ) =
                    W.update (open model.options) (init steps)
            in
                ( { model' | sessions = Dict.insert i wModel model'.sessions }
                , (Cmd.map (DriverMsg i) wMsg) :: msgs
                )

        nextState =
            model.runs
                |> List.indexedMap (,)
                |> List.foldr (dispatchHelper) ( model, [] )
    in
        ( fst nextState, Cmd.batch (snd nextState) )


delegateMessage i action subModel thisModel =
    case action of
        W.Finish ->
            update
                (EmitLog <| collectLog subModel)
                { thisModel | sessions = Dict.remove i thisModel.sessions }

        _ ->
            let
                ( session, next ) =
                    W.update action subModel
            in
                ( { thisModel | sessions = Dict.insert i session thisModel.sessions }, Cmd.map (DriverMsg i) next )


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
            summary


fromExpectation : String -> Expectation -> Summary -> Summary
fromExpectation description expectation summary =
    case Expect.getFailure expectation of
        Nothing ->
            { summary
                | output = summary.output ++ "✅  " ++ description
                , passed = summary.passed + 1
            }

        Just { given, message } ->
            let
                heading =
                    "❌  " ++ description ++ "\n\n"

                prefix =
                    if String.isEmpty given then
                        heading
                    else
                        heading ++ given ++ "\n\n"

                newOutput =
                    "\n\n" ++ (prefix ++ indentLines message) ++ "\n"
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



-- PORTS


port printLog : Summary -> Cmd msg
