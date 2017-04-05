port module Main exposing (..)

import Webdriver as W exposing (..)
import Webdriver.Assert exposing (..)
import Webdriver.Runner as R exposing (WebdriverRunner, Run, PortEvent, run, group, describe)
import Expect

port emit : PortEvent -> Cmd msg

main : WebdriverRunner
main =
    run emit basicOptions <| group "Find in Google" [ searchElm, searchHackerNews ]


firstLink_ : String
firstLink_ =
    "#rso > div:nth-child(1) > div:nth-child(1) > div > h3 > a"


searchElm : Run
searchElm =
    describe "Finding Elm Lang in Google"
        [ visit "https://google.com"
        , title <| Expect.equal "this will fail!"
        , elementCount "input[name='q']" <| Expect.atLeast 1
        , setValue "input[name='q']" "Elm lang"
        , elementText firstLink_ <| Expect.equal "Elm is the best"
        , click firstLink_
        , pause 1000 |> withScreenshot True
        , title <| Expect.equal "home"
        ]


searchHackerNews : Run
searchHackerNews =
    describe "Finding hacker news in Google"
        [ visit "https://google.com"
        , title <| Expect.equal "Google"
        , elementCount "input[name='q']" <| Expect.atLeast 1
        , setValue "input[name='q']" "Hacker News"
        , elementText firstLink_ <| Expect.equal "Hacker News"
        , click firstLink_
        , pause 1000
        , title <| Expect.equal "home"
        ]
