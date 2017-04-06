port module Main exposing (..)

import Webdriver as W exposing (..)
import Webdriver.Assert exposing (..)
import Webdriver.Runner as R exposing (WebdriverRunner, Run, PortEvent, run)
import Expect
import Tests

port emit : PortEvent -> Cmd msg

main : WebdriverRunner
main =
    run emit basicOptions Tests.all
