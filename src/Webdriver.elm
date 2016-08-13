module Webdriver
    exposing
        ( Step
        , Options
        , stepName
        , withName
        , withScreenshot
        , basicOptions
        , visit
        , click
        , close
        , moveTo
        , moveToWithOffset
        , end
        , setValue
        , appendValue
        , clearValue
        , selectByIndex
        , selectByValue
        , selectByText
        , submitForm
        , waitForExist
        , waitForNotExist
        , waitForVisible
        , waitForNotVisible
        , waitForValue
        , waitForNoValue
        , waitForSelected
        , waitForNotSelected
        , waitForText
        , waitForNoText
        , waitForEnabled
        , waitForNotEnabled
        , waitForDebug
        , setCookie
        , deleteCookie
        , pause
        , scrollToElement
        , scrollToElementOffset
        , scrollWindow
        , savePageScreenshot
        , switchToFrame
        , triggerClick
        )

{-| A library to interface with Webdriver.io and produce commands to control a browser
usin selenium.

The functions exposed in this module are commands that produce no result brack from the
browser.

## Basics

@docs basicOptions, Options, Step, stepName, withName

## Simple Browser Control

@docs visit, click, moveTo, moveToWithOffset, close, end, switchToFrame

## Forms

@docs setValue, appendValue, clearValue, submitForm, selectByIndex, selectByValue, selectByText

## Waiting For Elements

@docs waitForExist, waitForNotExist, waitForVisible, waitForNotVisible, waitForText, waitForNoText, pause

## Waiting For Form Elements

@docs  waitForValue, waitForNoValue, waitForSelected, waitForNotSelected, waitForEnabled, waitForNotEnabled

## Debugging

@docs waitForDebug

## Scrolling

@docs scrollToElement, scrollToElementOffset, scrollWindow

## Cookies

@docs setCookie, deleteCookie

## Screenshots

@docs savePageScreenshot, withScreenshot

## Custom

@docs triggerClick
-}

import Webdriver.LowLevel as Wd exposing (Error, Browser)
import Webdriver.Step exposing (..)


{-| The valid actions that can be executed in the browser
-}
type alias Step =
    Webdriver.Step.Step


{-| Driver options
-}
type alias Options =
    Wd.Options


type alias Selector =
    String


{-| Returns the human readable name of the step

    stepName (click "a") === "Click on <a>"
-}
stepName : Step -> String
stepName =
    Webdriver.Step.stepName


{-| Gives a new human readable name to an existing step

    click ".login"
        |> withName "Enter the private zone"
-}
withName : String -> Step -> Step
withName =
    Webdriver.Step.withName


{-| Toggles the automatic screenshot capturing after executing the step.
By default no screenshots are taken.

    click ".login"
        |> withScreenshot True
-}
withScreenshot : Bool -> Step -> Step
withScreenshot =
    Webdriver.Step.withScreenshot


{-| Bare minimum options for running selenium
-}
basicOptions : Options
basicOptions =
    { desiredCapabilities =
        { browserName = "firefox"
        }
    }


toUnitStep : String -> UnitStep -> Step
toUnitStep name =
    ReturningUnit (initMeta name)


{-| Visit a url
-}
visit : String -> Step
visit url =
    Visit url
        |> toUnitStep ("Visit " ++ url)


{-| Click on an element using a selector
-}
click : String -> Step
click selector =
    Click selector
        |> toUnitStep ("Click <" ++ selector ++ ">")


{-| Moves the mouse to the middle of the specified element
-}
moveTo : String -> Step
moveTo selector =
    MoveTo selector
        |> toUnitStep ("Move the mouse to <" ++ selector ++ ">")


{-| Moves the mouse to the middle of the specified element. This function
takes two integers (offsetX and offsetY).

If offsetX has a value, move relative to the top-left corner of the element on the X axis
If offsetY has a value, move relative to the top-left corner of the element on the Y axis
-}
moveToWithOffset : String -> Int -> Int -> Step
moveToWithOffset selector xOffset yOffset =
    MoveToWithOffset selector xOffset yOffset
        |> toUnitStep
            ("Move the mouse to <"
                ++ selector
                ++ "> with offset ("
                ++ (toString xOffset)
                ++ ","
                ++ (toString yOffset)
                ++ ")"
            )


{-| Close the current browser window
-}
close : Step
close =
    Close
        |> toUnitStep "Close the window"


{-| Fills in the specified input with the given value

    setValue "#email" "foo@bar.com"
-}
setValue : String -> String -> Step
setValue selector value =
    SetValue selector value
        |> toUnitStep ("Set the value '" ++ value ++ "' to <" ++ selector ++ ">")


{-| Appends the given string to the specified input's current value

    setValue "#email" "foo"
    addValue "#email" "@bar.com"
-}
appendValue : String -> String -> Step
appendValue selector value =
    AppendValue selector value
        |> toUnitStep ("Append the value '" ++ value ++ "' to <" ++ selector ++ ">")


{-| Clears the value of the specified input field

    clearValue "#email"
-}
clearValue : String -> Step
clearValue selector =
    ClearValue selector
        |> toUnitStep ("Clear the value of <" ++ selector ++ ">")


{-| Selects the option in the dropdown using the option index
-}
selectByIndex : String -> Int -> Step
selectByIndex selector index =
    SelectByIndex selector index
        |> toUnitStep ("Select the option with index '" ++ (toString index) ++ "' in <" ++ selector ++ ">")


{-| Selects the option in the dropdown using the option value
-}
selectByValue : String -> String -> Step
selectByValue selector value =
    SelectByValue selector value
        |> toUnitStep ("Select the option with value '" ++ value ++ "' in <" ++ selector ++ ">")


{-| Selects the option in the dropdown using the option visible text
-}
selectByText : String -> String -> Step
selectByText selector text =
    SelectByText selector text
        |> toUnitStep ("Select the option with visible text '" ++ text ++ "' in <" ++ selector ++ ">")


{-| Submits the form with the given selector
-}
submitForm : String -> Step
submitForm selector =
    Submit selector
        |> toUnitStep ("Submit the form <" ++ selector ++ ">")


{-| Set the value for a cookie
-}
setCookie : String -> String -> Step
setCookie name value =
    SetCookie name value
        |> toUnitStep ("Set the cookie '" ++ name ++ "' with value '" ++ value ++ "'")


{-| Deletes a cookie by name
-}
deleteCookie : String -> Step
deleteCookie name =
    DeleteCookie name
        |> toUnitStep ("Delete the cookie '" ++ name ++ "'")


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be present within the DOM
-}
waitForExist : String -> Int -> Step
waitForExist selector timeout =
    WaitForExist selector timeout
        |> toUnitStep ("Wait " ++ (toSeconds timeout) ++ " for <" ++ selector ++ "> to be present")


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be present absent from the DOM
-}
waitForNotExist : String -> Int -> Step
waitForNotExist selector timeout =
    WaitForNotExist selector timeout
        |> toUnitStep ("Wait " ++ (toSeconds timeout) ++ "s for <" ++ selector ++ "> to be absent")


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be visible.
-}
waitForVisible : String -> Int -> Step
waitForVisible selector timeout =
    WaitForVisible selector timeout
        |> toUnitStep ("Wait " ++ (toSeconds timeout) ++ "s for <" ++ selector ++ "> to be visible")


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be invisible.
-}
waitForNotVisible : String -> Int -> Step
waitForNotVisible selector timeout =
    WaitForNotVisible selector timeout
        |> toUnitStep ("Wait " ++ (toSeconds timeout) ++ "s for <" ++ selector ++ "> to be not visible")


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be have a value.
-}
waitForValue : String -> Int -> Step
waitForValue selector timeout =
    WaitForValue selector timeout
        |> toUnitStep ("Wait " ++ (toSeconds timeout) ++ "s for <" ++ selector ++ "> to have a value")


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to have no value.
-}
waitForNoValue : String -> Int -> Step
waitForNoValue selector timeout =
    WaitForNoValue selector timeout
        |> toUnitStep ("Wait " ++ (toSeconds timeout) ++ "s for <" ++ selector ++ "> to have no value")


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be selected.
-}
waitForSelected : String -> Int -> Step
waitForSelected selector timeout =
    WaitForSelected selector timeout
        |> toUnitStep ("Wait " ++ (toSeconds timeout) ++ "s for <" ++ selector ++ "> to be selected")


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to not be selected.
-}
waitForNotSelected : String -> Int -> Step
waitForNotSelected selector timeout =
    WaitForNotSelected selector timeout
        |> toUnitStep ("Wait " ++ (toSeconds timeout) ++ "s for <" ++ selector ++ "> to not be selected")


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be have some text.
-}
waitForText : String -> Int -> Step
waitForText selector timeout =
    WaitForText selector timeout
        |> toUnitStep ("Wait " ++ (toSeconds timeout) ++ "s for <" ++ selector ++ "> to have text")


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to have no text.
-}
waitForNoText : String -> Int -> Step
waitForNoText selector timeout =
    WaitForNoText selector timeout
        |> toUnitStep ("Wait " ++ (toSeconds timeout) ++ "s for <" ++ selector ++ "> to have no text")


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be enabled.
-}
waitForEnabled : String -> Int -> Step
waitForEnabled selector timeout =
    WaitForEnabled selector timeout
        |> toUnitStep ("Wait " ++ (toSeconds timeout) ++ "s for <" ++ selector ++ "> to be enabled")


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be disabled.
-}
waitForNotEnabled : String -> Int -> Step
waitForNotEnabled selector timeout =
    WaitForNotEnabled selector timeout
        |> toUnitStep ("Wait " ++ (toSeconds timeout) ++ "s for <" ++ selector ++ "> to not be enabled")


{-| Ends the browser session
-}
end : Step
end =
    End
        |> toUnitStep "End the session"


{-| Pauses the browser session for the given milliseconds
-}
pause : Int -> Step
pause ms =
    Pause ms
        |> toUnitStep ("Pause the exexution for " ++ (toSeconds ms))


{-| Scrolls the window to the element specified in the selector
-}
scrollToElement : Selector -> Step
scrollToElement selector =
    ScrollTo selector 0 0
        |> toUnitStep ("Scroll to <" ++ selector ++ ">")


{-| Scrolls the window to the element specified in the selector and then scrolls
the given amount of pixels as offset from such element
-}
scrollToElementOffset : Selector -> Int -> Int -> Step
scrollToElementOffset selector x y =
    ScrollTo selector x y
        |> toUnitStep ("Scroll to <" ++ selector ++ "> with offset (" ++ (toString x) ++ "," ++ (toString y) ++ ")")


{-| Scrolls the window to the absolute coordinate (x, y) position provided in pixels
-}
scrollWindow : Int -> Int -> Step
scrollWindow x y =
    Scroll x y
        |> toUnitStep ("Scroll to (" ++ (toString x) ++ "," ++ (toString y) ++ ")")


{-| Takes a screenshot of the whole page and saves it to a file
-}
savePageScreenshot : String -> Step
savePageScreenshot filename =
    SavePagecreenshot filename
        |> toUnitStep "Save page screenshot"


{-| Makes any future actions happen inside the frame specified by its index
-}
switchToFrame : Int -> Step
switchToFrame index =
    SwitchFrame index
        |> toUnitStep ("Switch to frame <" ++ (toString index) ++ ">")


{-| Programatically trigger a click in the elements specified in the selector.
This exists because some pages hijack in an odd way mouse click, and in order to test
the behavior, it needs to be manually triggered.
-}
triggerClick : String -> Step
triggerClick selector =
    TriggerClick selector
        |> toUnitStep ("Trigger a JS click for <" ++ selector ++ ">")


{-| Stops the running queue and gives you time to jump into the browser and
check the state of your application (e.g. using the dev tools). Once you are done
go to the command line and press Enter.
-}
waitForDebug : Step
waitForDebug =
    WaitForDebug
        |> toUnitStep "Wait for user to debug in browser"


toSeconds : Int -> String
toSeconds ms =
    (toString <| toFloat ms / 1000) ++ "s"
