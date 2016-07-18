module Webdriver
    exposing
        ( Step
        , Options
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
        , pause
        , scrollToElement
        , scrollToElementOffset
        , scrollWindow
        , savePageScreenshot
        , switchToFrame
        , triggerClick
        )

{-| A library to interface with Webdriver.io and produce commands

@docs basicOptions, Options, Step

## Basic Control

@docs visit, click, moveTo, moveToWithOffset, close, end, switchToFrame

## Forms

@docs setValue, appendValue, clearValue, submitForm
@docs selectByIndex, selectByValue, selectByText

## Waiting
@docs waitForExist
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
    , pause

## Debugging

@docs waitForDebug

## Scrolling

@docs scrollToElement
    , scrollToElementOffset
    , scrollWindow

## Screenshots

@docs savePageScreenshot

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


{-| Bare minimum options for running selenium
-}
basicOptions : Options
basicOptions =
    { desiredCapabilities =
        { browserName = "firefox"
        }
    }


{-| Visit a url
-}
visit : String -> Step
visit url =
    Visit url
        |> ReturningUnit


{-| Click on an element using a selector
-}
click : String -> Step
click selector =
    Click selector
        |> ReturningUnit


{-| Moves the mouse to the middle of the specified element
-}
moveTo : String -> Step
moveTo selector =
    MoveTo selector
        |> ReturningUnit


{-| Moves the mouse to the middle of the specified element. This function
takes two integers (offsetX and offsetY).

If offsetX has a value, move relative to the top-left corner of the element on the X axis
If offsetY has a value, move relative to the top-left corner of the element on the Y axis
-}
moveToWithOffset : String -> Int -> Int -> Step
moveToWithOffset selector xOffset yOffset =
    MoveToWithOffset selector xOffset yOffset
        |> ReturningUnit


{-| Close the current browser window
-}
close : Step
close =
    Close
        |> ReturningUnit


{-| Fills in the specified input with the given value

    setValue "#email" "foo@bar.com"
-}
setValue : String -> String -> Step
setValue selector value =
    SetValue selector value
        |> ReturningUnit


{-| Appends the given string to the specified input's current value

    setValue "#email" "foo"
    addValue "#email" "@bar.com"
-}
appendValue : String -> String -> Step
appendValue selector value =
    AppendValue selector value
        |> ReturningUnit


{-| Clears the value of the specified input field

    clearValue "#email"
-}
clearValue : String -> Step
clearValue selector =
    ClearValue selector
        |> ReturningUnit


{-| Selects the option in the dropdown using the option index
-}
selectByIndex : String -> Int -> Step
selectByIndex selector index =
    SelectByIndex selector index
        |> ReturningUnit


{-| Selects the option in the dropdown using the option value
-}
selectByValue : String -> String -> Step
selectByValue selector value =
    SelectByValue selector value
        |> ReturningUnit


{-| Selects the option in the dropdown using the option visible text
-}
selectByText : String -> String -> Step
selectByText selector text =
    SelectByText selector text
        |> ReturningUnit


{-| Submits the form with the given selector
-}
submitForm : String -> Step
submitForm selector =
    Submit selector
        |> ReturningUnit


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be present within the DOM
-}
waitForExist : String -> Int -> Step
waitForExist selector timeout =
    WaitForExist selector timeout
        |> ReturningUnit


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be present absent from the DOM
-}
waitForNotExist : String -> Int -> Step
waitForNotExist selector ms =
    WaitForNotExist selector ms
        |> ReturningUnit


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be visible.
-}
waitForVisible : String -> Int -> Step
waitForVisible selector ms =
    WaitForVisible selector ms
        |> ReturningUnit


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be invisible.
-}
waitForNotVisible : String -> Int -> Step
waitForNotVisible selector ms =
    WaitForNotVisible selector ms
        |> ReturningUnit


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be have a value.
-}
waitForValue : String -> Int -> Step
waitForValue selector ms =
    WaitForValue selector ms
        |> ReturningUnit


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to have no value.
-}
waitForNoValue : String -> Int -> Step
waitForNoValue selector ms =
    WaitForNoValue selector ms
        |> ReturningUnit


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be selected.
-}
waitForSelected : String -> Int -> Step
waitForSelected selector ms =
    WaitForSelected selector ms
        |> ReturningUnit


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to not be selected.
-}
waitForNotSelected : String -> Int -> Step
waitForNotSelected selector ms =
    WaitForNotSelected selector ms
        |> ReturningUnit


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be have some text.
-}
waitForText : String -> Int -> Step
waitForText selector ms =
    WaitForText selector ms
        |> ReturningUnit


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to have no text.
-}
waitForNoText : String -> Int -> Step
waitForNoText selector ms =
    WaitForNoText selector ms
        |> ReturningUnit


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be enabled.
-}
waitForEnabled : String -> Int -> Step
waitForEnabled selector ms =
    WaitForEnabled selector ms
        |> ReturningUnit


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be disabled.
-}
waitForNotEnabled : String -> Int -> Step
waitForNotEnabled selector ms =
    WaitForNotEnabled selector ms
        |> ReturningUnit


{-| Ends the browser session
-}
end : Step
end =
    End
        |> ReturningUnit


{-| Pauses the browser session for the given milliseconds
-}
pause : Int -> Step
pause ms =
    Pause ms
        |> ReturningUnit


{-| Scrolls the window to the element specified in the selector
-}
scrollToElement : Selector -> Step
scrollToElement selector =
    ScrollTo selector 0 0
        |> ReturningUnit


{-| Scrolls the window to the element specified in the selector and then scrolls
the given amount of pixels as offset from such element
-}
scrollToElementOffset : Selector -> Int -> Int -> Step
scrollToElementOffset selector x y =
    ScrollTo selector x y
        |> ReturningUnit


{-| Scrolls the window to the absolute coordinate (x, y) position provided in pixels
-}
scrollWindow : Int -> Int -> Step
scrollWindow x y =
    Scroll x y
        |> ReturningUnit


{-| Takes a screenshot of the whole page and saves it to a file
-}
savePageScreenshot : String -> Step
savePageScreenshot filename =
    SavePagecreenshot filename
        |> ReturningUnit


{-| Makes any future actions happen inside the frame specified by its index
-}
switchToFrame : Int -> Step
switchToFrame index =
    SwitchFrame index
        |> ReturningUnit


{-| Programatically trigger a click in the elements specified in the selector.
This exists because some pages hijack in an odd way mouse click, and in order to test
the behavior, it needs to be manually triggered.
-}
triggerClick : String -> Step
triggerClick selector =
    TriggerClick selector
        |> ReturningUnit


{-| Stops the running queue and gives you time to jump into the browser and
check the state of your application (e.g. using the dev tools). Once you are done
go to the command line and press Enter.
-}
waitForDebug : Step
waitForDebug =
    WaitForDebug
        |> ReturningUnit
