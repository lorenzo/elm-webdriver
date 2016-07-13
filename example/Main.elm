port module Main exposing (..)

import Html
import Html.App as App
import Webdriver as W exposing (..)
import Webdriver.Branch exposing (ifElementCount)
import Webdriver.Assert exposing (..)
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


type Msg
    = EmitLog (List Expectation)
    | Webdriver W.Msg


initModel : Model
initModel =
    { session = init actions
    }


actions : List Step
actions =
    [ visit "https://bownty.dk/go/62964387"
    , pause 5000
    , title <| Expect.equal "this will fail!"
    , click "#tilbudibyen_c1_right_box_bottom_btn_buy"
    , ifCookieExists "subscribed_nn" closePopup
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

        EmitLog expectations ->
            let
                log =
                    Debug.log "Result" expectations
            in
                ( model, Cmd.none )


collectLog : W.Model -> List Expectation
collectLog ( _, expectations, _ ) =
    expectations
        |> List.filterMap identity
        |> List.reverse



-- PORTS


port begin : (String -> msg) -> Sub msg


subscriptions : model -> Sub Msg
subscriptions _ =
    begin (always <| Webdriver (open basicOptions))
