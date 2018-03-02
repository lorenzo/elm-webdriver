module Tests exposing (all)

import Webdriver as W exposing (..)
import Webdriver.Assert exposing (..)
import Webdriver.Runner as R exposing (Run, group, describe)
import Expect


all : Run
all =
    group "All Tests" [ searchElm ]


firstLink : String
firstLink =
    "#rso > div:nth-child(1) > div:nth-child(1) > div > h3 > a"


searchElm : Run
searchElm =
    describe "Finding Elm Lang in Google"
        [ visit "https://google.com"
        , title <| Expect.equal "Google"
        , elementCount "input[name='q']" <| Expect.atLeast 1
        , setValue "input[name='q']" "Elm lang"
        , waitForExist firstLink 2000
        , elementText firstLink <| Expect.equal "Elm"
        , click firstLink_
        , pause 1000 |> withScreenshot True
        , title <| Expect.equal "home"
        ]
