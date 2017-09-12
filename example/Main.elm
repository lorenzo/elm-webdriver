port module Main exposing (..)

import Webdriver as W exposing (..)
import Webdriver.Assert exposing (..)
import Webdriver.Runner as R exposing (WebdriverRunner, Run, PortEvent, run, group, describe)
import Expect


port emit : PortEvent -> Cmd msg


main : WebdriverRunner
main =
    run emit basicOptions <| group "Find in DuckDuckGo" [ searchElm, searchHackerNews ]


firstLink_ : String
firstLink_ =
    "#r1-0 > div:nth-child(1) > h2:nth-child(1) > a:nth-child(1)"


searchElm : Run
searchElm =
    describe "Finding Elm Lang in DuckDuckGo"
        [ visit "https://duckduckgo.com/"
        , title <| Expect.equal "DuckDuckGo"
        , elementCount "input[name='q']" <| Expect.atLeast 1
        , setValue "input[name='q']" "Elm lang"
        , click "#search_button_homepage"
        , waitForExist firstLink_ 2000
        , elementText firstLink_ <| Expect.equal "Elm"
        , click firstLink_
        , pause 1000 |> withScreenshot True
        , title <| Expect.equal "home"
        ]


{-| This test will fail un purpose, so you can see how the errors are displayed
-}
searchHackerNews : Run
searchHackerNews =
    describe "Finding HackerNews in DuckDuckGo"
        [ visit "https://duckduckgo.com/"
        , title <| Expect.equal "This is not the real title"
        , elementCount "input[name='q']" <| Expect.atLeast 1
        , setValue "input[name='q']" "Hacker News"
        , click "#search_button_homepage"
        , waitForExist firstLink_ 2000
        , elementText firstLink_ <| Expect.equal "Not the real title"
        , click firstLink_
        , pause 1000 |> withScreenshot True
        , title <| Expect.equal "Hacker News"
        ]
