port module Main exposing (..)

import Webdriver as W exposing (..)
import Webdriver.Assert exposing (..)
import Webdriver.Runner as R exposing (WebdriverRunner, Run, PortEvent, run, group, describe)
import Expect

port emit : PortEvent -> Cmd msg

main : WebdriverRunner
main =
    run emit basicOptions <| group "Find in Google" [ searchElm ]

firstLink_ : String
firstLink_ =
  "div.g:nth-child(1) > div:nth-child(1) > h3:nth-child(1) > a:nth-child(1)"

searchElm : Run
searchElm =
    describe "Finding Elm Lang in Google"
        [ visit "https://google.com"
        , title <| Expect.equal "Google"
        , elementCount "input[name='q']" <| Expect.atLeast 1
        , setValue "input[name='q']" "Elm lang"
        , waitForExist firstLink_ 2000
        , elementText firstLink_ <| Expect.equal "Elm"
        , click firstLink_
        , pause 1000 |> withScreenshot True
        , title <| Expect.equal "home"
        ]
