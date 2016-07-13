port module Main exposing (..)

import Html
import Html.App as App
import Webdriver as W exposing (..)
import Webdriver.Branch exposing (ifElementCount)
import Webdriver.Assert exposing (..)
import String
import Expect


main : Program Never
main =
    App.program
        { init = initModel ! []
        , update = update
        , view = \_ -> Html.text "it works!"
        , subscriptions = subscriptions
        }


type alias Model =
    { session : W.Model
    }


type alias Summary =
    { output : String, passed : Int, failed : Int }


type Msg
    = EmitLog Summary
    | Webdriver W.Msg


initModel : Model
initModel =
    { session = init actions
    }


actions : List Step
actions =
    [ visit "https://google.com"
    , title <| Expect.equal "this will fail!"
    , elementCount "input" <| Expect.atLeast 1
    , setValue "input[name='q']" "Elm lang"
    , elementText "#rso > div:nth-child(1) > div:nth-child(1) > div > h3 > a" <| Expect.equal "Elm is the best"
    , click "#rso > div:nth-child(1) > div:nth-child(1) > div > h3 > a"
    , pause 5000
    ]


closePopup : Int -> List Step
closePopup total =
    let
        a =
            Debug.log "size" total
    in
        []


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Webdriver action ->
            case action of
                W.Finish ->
                    update (EmitLog <| collectLog model.session) model

                _ ->
                    let
                        ( session, next ) =
                            W.update action model.session
                    in
                        ( { model | session = session }, Cmd.map Webdriver next )

        EmitLog output ->
            ( model, printLog output )


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


port begin : (String -> msg) -> Sub msg


port printLog : Summary -> Cmd msg


subscriptions : model -> Sub Msg
subscriptions _ =
    begin (always <| Webdriver (open basicOptions))
