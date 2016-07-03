port module Main exposing (..)

import Html
import Html.App as App
import Webdriver as Wd exposing (open, visit, click, close, setValue)
import Webdriver.LowLevel as W exposing (basicOptions)
import Task


main : Program Never
main =
    App.program
        { init = ( Nothing, actions ) ! []
        , update = update
        , view = \_ -> Html.text "it works!"
        , subscriptions = subscriptions
        }


type alias Model =
    ( Maybe W.Browser, List Action )


type Msg
    = NoOp
    | Start
    | Opened W.Browser
    | Process
    | OnError W.Error


type Action
    = Visit String
    | Click String
    | SetValue String String
    | Close


actions =
    [ Visit "https://bownty.dk"
    , SetValue "#signUpOverlay .email" "foo@bar.com"
    , Click "#signUpOverlay > div > button"
    , Close
    ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( _, Start ) ->
            ( model, open basicOptions OnError Opened )

        ( ( _, actions ), Opened browser ) ->
            ( ( Just browser, actions ), Task.perform (always NoOp) (always Process) (Task.succeed ()) )

        ( ( Just browser, action :: rest ), Process ) ->
            ( ( Just browser, rest ), process action browser )

        ( _, _ ) ->
            ( model, Cmd.none )


process action browser =
    case action of
        Visit url ->
            visit url OnError (always Process) browser

        Click selector ->
            click selector OnError (always Process) browser

        SetValue selector value ->
            setValue selector value OnError (always Process) browser

        Close ->
            close OnError (always Process) browser



-- PORTS


port begin : (String -> msg) -> Sub msg


subscriptions : model -> Sub Msg
subscriptions _ =
    begin (always Start)
