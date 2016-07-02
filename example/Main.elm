port module Main exposing (..)

import Html
import Html.App as App
import Webdriver as Wd exposing (open, visit, click)
import Webdriver.LowLevel exposing (basicOptions)


main : Program Never
main =
    App.program
        { init = "" ! []
        , update = update
        , view = \_ -> Html.text "it works!"
        , subscriptions = subscriptions
        }


type alias Model =
    String


type Msg
    = NoOp
    | Start
    | Opened String
    | BeginFlow String
    | OnError String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "foo" msg of
        Start ->
            ( model, open basicOptions Opened )

        Opened id ->
            ( id, visit id "https://bownty.dk" BeginFlow )

        BeginFlow _ ->
            ( model, Cmd.none )

        OnError message ->
            ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )



-- PORTS


port begin : (String -> msg) -> Sub msg


subscriptions : model -> Sub Msg
subscriptions _ =
    begin (always Start)
