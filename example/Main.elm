port module Main exposing (..)

import Html
import Html.App as App
import Webdriver as W exposing (..)


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


type Msg
    = NoOp
    | Webdriver W.Msg


initModel : Model
initModel =
    { session = init actions
    }


actions : List Step
actions =
    [ visit "https://bownty.dk/go/62964387"
    , click "#tilbudibyen_c1_right_box_bottom_btn_buy"
    , click "//*[@id=\"header_buttons_box\"]/div[3]/div/button"
    , setValue "#login_username" "jon"
    , appendValue "#login_username" "@gmail.com"
    , setValue "#login_password" "tib251"
    , submitForm ".loginForm"
    , visit "http://tilbudibyen.dk/basket"
    , setValue "#firstname" "Jon"
    , setValue "#lastname" "Snow"
    , setValue "#address_number" "5"
    , setValue "#postal_code" "2300"
    , setValue "#mobile" "31755599"
    , close
    ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Webdriver action ->
            let
                ( session, next ) =
                    W.update action model.session
            in
                ( { model | session = session }, Cmd.map Webdriver next )

        NoOp ->
            ( model, Cmd.none )



-- PORTS


port begin : (String -> msg) -> Sub msg


subscriptions : model -> Sub Msg
subscriptions _ =
    begin (always <| Webdriver (open basicOptions))
