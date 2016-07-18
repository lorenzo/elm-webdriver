port module Main exposing (..)

import Html
import Html.App as App
import Webdriver as W exposing (..)
import Webdriver.Assert exposing (..)
import Webdriver.Runner as R exposing (..)
import Expect


main : Program Never
main =
    App.program
        { init = begin basicOptions <| group "Find in Google" [ searchElm, searchHackerNews ]
        , update = R.update
        , view = \_ -> Html.text ""
        , subscriptions = always Sub.none
        }


firstLink' =
    "#rso > div:nth-child(1) > div:nth-child(1) > div > h3 > a"


searchElm : Run
searchElm =
    describe "Finding Elm Lang in Google"
        [ visit "https://google.com"
        , title <| Expect.equal "this will fail!"
        , elementCount "input[name='q']" <| Expect.atLeast 1
        , setValue "input[name='q']" "Elm lang"
        , elementText firstLink' <| Expect.equal "Elm is the best"
        , click firstLink'
        , pause 1000
        , title <| Expect.equal "home"
        ]


searchHackerNews : Run
searchHackerNews =
    describe "Finding hacker news in Google"
        [ visit "https://google.com"
        , title <| Expect.equal "Google"
        , elementCount "input[name='q']" <| Expect.atLeast 1
        , setValue "input[name='q']" "Hacker News"
        , elementText firstLink' <| Expect.equal "Hacker News"
        , click firstLink'
        , pause 1000
        , title <| Expect.equal "home"
        ]
