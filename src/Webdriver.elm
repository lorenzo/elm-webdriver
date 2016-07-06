module Webdriver
    exposing
        ( Model
        , Step
        , Msg(..)
        , basicOptions
        , init
        , update
        , open
        , visit
        , click
        , close
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

@docs basicOptions, init, update, Model, Msg, Step
@docs open, visit, click, close, end, switchToFrame

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

import Webdriver.LowLevel as Wd exposing (Error, Browser, Options)
import Task exposing (Task, perform)


type alias Selector =
    String


{-| The valid actions that can be executed in the browser
-}
type Step
    = Visit String
    | Click Selector
    | AppendValue String String
    | ClearValue String
    | SetValue Selector String
    | SelectByValue Selector String
    | SelectByIndex Selector Int
    | SelectByText Selector String
    | Submit Selector
    | WaitForExist Selector Int
    | WaitForNotExist Selector Int
    | WaitForVisible Selector Int
    | WaitForNotVisible Selector Int
    | WaitForValue Selector Int
    | WaitForNoValue Selector Int
    | WaitForSelected Selector Int
    | WaitForNotSelected Selector Int
    | WaitForText Selector Int
    | WaitForNoText Selector Int
    | WaitForEnabled Selector Int
    | WaitForNotEnabled Selector Int
    | WaitForDebug
    | Pause Int
    | ScrollTo Selector Int Int
    | Scroll Int Int
    | SavePagecreenshot String
    | SwitchFrame Int
    | TriggerClick Selector
    | Close
    | End


{-| The internal messages passed in this module
-}
type Msg
    = Start Options
    | Initiated Wd.Browser
    | Process
    | OnError Wd.Error


{-| The model used by this module to represent its state
-}
type alias Model =
    ( Maybe Wd.Browser, List Step )


{-| Initializes a model with the give list of steps to perform
-}
init : List Step -> Model
init actions =
    ( Nothing, actions )


{-| Initializes the browser session and executes the steps as provided
in the model.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( _, Start options ) ->
            ( model, perform OnError Initiated (Wd.open options |> Task.map (\( _, b ) -> b)) )

        ( ( _, actions ), Initiated browser ) ->
            ( ( Just browser, actions ), perform OnError (always Process) (Task.succeed ()) )

        ( ( Just browser, End :: rest ), Process ) ->
            ( ( Nothing, [] ), process End browser )

        ( ( Just browser, [] ), Process ) ->
            ( ( Nothing, [] ), process End browser )

        ( ( Just browser, action :: rest ), Process ) ->
            ( ( Just browser, rest ), process action browser )

        ( ( Just browser, actions ), OnError error ) ->
            let
                message =
                    handleError error
            in
                ( ( Nothing, actions ), Wd.end browser |> toCmd )

        ( _, _ ) ->
            ( model, Cmd.none )


handleError : Wd.Error -> String
handleError error =
    case error of
        Wd.ConnectionError { message } ->
            Debug.log "Could not connect to server" message

        Wd.MissingElement { message, selector } ->
            Debug.log "The element you are trying to reach is missing" message

        Wd.UnreachableElement { message, selector } ->
            Debug.log "The element you are trying to reach is not visible" message

        Wd.FailedElementPrecondition { message, selector } ->
            Debug.log "You were waiting for an element, but it is not as you expected" message

        Wd.UnknownError { message } ->
            Debug.log "Oops, something wrong happened" message


(&>) : Task x y -> Task x z -> Task x z
(&>) t1 t2 =
    t1 `Task.andThen` \_ -> t2


autoWait : Selector -> Wd.Browser -> Task Wd.Error ()
autoWait selector browser =
    Wd.waitForVisible selector 2000 browser


inputAutoWait : Selector -> Wd.Browser -> Task Wd.Error ()
inputAutoWait selector browser =
    autoWait selector browser
        &> Wd.waitForEnabled selector 2000 browser


process : Step -> Wd.Browser -> Cmd Msg
process action browser =
    case action of
        Visit url ->
            Wd.url url browser
                |> toCmd

        Click selector ->
            autoWait selector browser
                &> Wd.click selector browser
                |> toCmd

        SetValue selector value ->
            inputAutoWait selector browser
                &> Wd.setValue selector value browser
                |> toCmd

        AppendValue selector value ->
            inputAutoWait selector browser
                &> Wd.appendValue selector value browser
                |> toCmd

        ClearValue selector ->
            inputAutoWait selector browser
                &> Wd.clearValue selector browser
                |> toCmd

        SelectByValue selector value ->
            inputAutoWait selector browser
                &> Wd.selectByValue selector value browser
                |> toCmd

        SelectByIndex selector index ->
            inputAutoWait selector browser
                &> Wd.selectByIndex selector index browser
                |> toCmd

        SelectByText selector text ->
            inputAutoWait selector browser
                &> Wd.selectByText selector text browser
                |> toCmd

        Submit selector ->
            Wd.submitForm selector browser
                |> toCmd

        WaitForExist selector timeout ->
            Wd.waitForExist selector timeout browser
                |> toCmd

        WaitForNotExist selector timeout ->
            Wd.waitForNotExist selector timeout browser
                |> toCmd

        WaitForVisible selector timeout ->
            Wd.waitForVisible selector timeout browser
                |> toCmd

        WaitForNotVisible selector timeout ->
            Wd.waitForNotVisible selector timeout browser
                |> toCmd

        WaitForValue selector timeout ->
            Wd.waitForValue selector timeout browser
                |> toCmd

        WaitForNoValue selector timeout ->
            Wd.waitForNoValue selector timeout browser
                |> toCmd

        WaitForSelected selector timeout ->
            Wd.waitForSelected selector timeout browser
                |> toCmd

        WaitForNotSelected selector timeout ->
            Wd.waitForNotSelected selector timeout browser
                |> toCmd

        WaitForText selector timeout ->
            Wd.waitForText selector timeout browser
                |> toCmd

        WaitForNoText selector timeout ->
            Wd.waitForNoText selector timeout browser
                |> toCmd

        WaitForEnabled selector timeout ->
            Wd.waitForEnabled selector timeout browser
                |> toCmd

        WaitForNotEnabled selector timeout ->
            Wd.waitForNotEnabled selector timeout browser
                |> toCmd

        WaitForDebug ->
            Wd.debug browser
                |> toCmd

        Pause timeout ->
            Wd.pause timeout browser
                |> toCmd

        Scroll x y ->
            Wd.scrollWindow x y browser
                |> toCmd

        ScrollTo selector x y ->
            Wd.scrollToElementOffset selector x y browser
                |> toCmd

        SavePagecreenshot filename ->
            Wd.savePageScreenshot filename browser
                |> toCmd

        SwitchFrame index ->
            Wd.switchToFrame index browser
                |> toCmd

        TriggerClick selector ->
            Wd.triggerClick selector browser
                |> toCmd

        End ->
            Wd.end browser
                |> toCmd

        Close ->
            Wd.close browser
                |> toCmd


toCmd : Task Error a -> Cmd Msg
toCmd =
    perform OnError (always Process)


{-| Bare minimum options for running selenium
-}
basicOptions : Options
basicOptions =
    { desiredCapabilities =
        { browserName = "firefox"
        }
    }


{-| Opens a new Browser window.
-}
open : Options -> Msg
open options =
    Start options


{-| Visit a url
-}
visit : String -> Step
visit url =
    Visit url


{-| Click on an element using a selector
-}
click : String -> Step
click selector =
    Click selector


{-| Close the current browser window
-}
close : Step
close =
    Close


{-| Fills in the specified input with the given value

    setValue "#email" "foo@bar.com"
-}
setValue : String -> String -> Step
setValue selector value =
    SetValue selector value


{-| Appends the given string to the specified input's current value

    setValue "#email" "foo"
    addValue "#email" "@bar.com"
-}
appendValue : String -> String -> Step
appendValue selector value =
    AppendValue selector value


{-| Clears the value of the specified input field

    clearValue "#email"
-}
clearValue : String -> Step
clearValue selector =
    ClearValue selector


{-| Selects the option in the dropdown using the option index
-}
selectByIndex : String -> Int -> Step
selectByIndex selector index =
    SelectByIndex selector index


{-| Selects the option in the dropdown using the option value
-}
selectByValue : String -> String -> Step
selectByValue selector value =
    SelectByValue selector value


{-| Selects the option in the dropdown using the option visible text
-}
selectByText : String -> String -> Step
selectByText selector text =
    SelectByText selector text


{-| Submits the form with the given selector
-}
submitForm : String -> Step
submitForm selector =
    Submit selector


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be present within the DOM
-}
waitForExist : String -> Int -> Step
waitForExist selector timeout =
    WaitForExist selector timeout


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be present absent from the DOM
-}
waitForNotExist : String -> Int -> Step
waitForNotExist selector ms =
    WaitForNotExist selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be visible.
-}
waitForVisible : String -> Int -> Step
waitForVisible selector ms =
    WaitForVisible selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be invisible.
-}
waitForNotVisible : String -> Int -> Step
waitForNotVisible selector ms =
    WaitForNotVisible selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be have a value.
-}
waitForValue : String -> Int -> Step
waitForValue selector ms =
    WaitForValue selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to have no value.
-}
waitForNoValue : String -> Int -> Step
waitForNoValue selector ms =
    WaitForNoValue selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be selected.
-}
waitForSelected : String -> Int -> Step
waitForSelected selector ms =
    WaitForSelected selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to not be selected.
-}
waitForNotSelected : String -> Int -> Step
waitForNotSelected selector ms =
    WaitForNotSelected selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be have some text.
-}
waitForText : String -> Int -> Step
waitForText selector ms =
    WaitForText selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to have no text.
-}
waitForNoText : String -> Int -> Step
waitForNoText selector ms =
    WaitForNoText selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be enabled.
-}
waitForEnabled : String -> Int -> Step
waitForEnabled selector ms =
    WaitForEnabled selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be disabled.
-}
waitForNotEnabled : String -> Int -> Step
waitForNotEnabled selector ms =
    WaitForNotEnabled selector ms


{-| Ends the browser session
-}
end : Step
end =
    End


{-| Pauses the browser session for the given milliseconds
-}
pause : Int -> Step
pause ms =
    Pause ms


{-| Scrolls the window to the element specified in the selector
-}
scrollToElement : Selector -> Step
scrollToElement selector =
    ScrollTo selector 0 0


{-| Scrolls the window to the element specified in the selector and then scrolls
the given amount of pixels as offset from such element
-}
scrollToElementOffset : Selector -> Int -> Int -> Step
scrollToElementOffset selector x y =
    ScrollTo selector x y


{-| Scrolls the window to the absolute coordinate (x, y) position provided in pixels
-}
scrollWindow : Int -> Int -> Step
scrollWindow x y =
    Scroll x y


{-| Takes a screenshot of the whole page and saves it to a file
-}
savePageScreenshot : String -> Step
savePageScreenshot filename =
    SavePagecreenshot filename


{-| Makes any future actions happen inside the frame specified by its index
-}
switchToFrame : Int -> Step
switchToFrame index =
    SwitchFrame index


{-| Programatically trigger a click in the elements specified in the selector.
This exists because some pages hijack in an odd way mouse click, and in order to test
the behavior, it needs to be manually triggered.
-}
triggerClick : String -> Step
triggerClick selector =
    TriggerClick selector


{-| Stops the running queue and gives you time to jump into the browser and
check the state of your application (e.g. using the dev tools). Once you are done
go to the command line and press Enter.
-}
waitForDebug : Step
waitForDebug =
    WaitForDebug
