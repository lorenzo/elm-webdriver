module Tests exposing (all)

import Webdriver as W exposing (..)
import Webdriver.Assert exposing (..)
import Webdriver.Runner as R exposing (Run, group, describe)
import Expect


all : Run
all =
    group "All Tests" [ searchElm, searchHackerNews ]


firstLink : String
firstLink =
    "#rso > div:nth-child(1) > div:nth-child(1) > div > h3 > a"


searchElm : Run
searchElm =
    describe "Finding Elm Lang in Google"
        [ visit "https://google.com"
        , title <| Expect.equal "this will fail!"
        , elementCount "input[name='q']" <| Expect.atLeast 1
        , setValue "input[name='q']" "Elm lang"
        , elementText firstLink <| Expect.equal "Elm is the best"
        , click firstLink
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
        , elementText firstLink <| Expect.equal "Hacker News"
        , click firstLink
        , pause 1000
        , title <| Expect.equal "home"
        ]
