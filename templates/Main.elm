port module Main exposing (..)

import Html
import Html.App as App
import Webdriver as W exposing (basicOptions)
import Webdriver.Runner as R exposing (begin, update)
import Tests


main : Program R.Flags
main =
    App.programWithFlags
        { init = begin basicOptions Tests.all
        , update = R.update
        , view = \_ -> Html.text ""
        , subscriptions = always Sub.none
        }
