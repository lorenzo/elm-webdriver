port module Main exposing (..)

import Webdriver as W exposing (..)
import Webdriver.Assert exposing (..)
import Webdriver.Runner as R exposing (WebdriverRunner, Run, run)
import Expect
import Tests


main : WebdriverRunner
main =
    run basicOptions Tests.all
