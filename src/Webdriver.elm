module Webdriver
    exposing
        ( Model
        , Action
        , Msg(..)
        , basicOptions
        , init
        , update
        , open
        , visit
        , click
        , close
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
        )

{-| A library to interface with Webdriver.io and produce commands

@docs basicOptions, init, update, Model, Msg, Action
@docs open, visit, click, close, setValue, appendValue, clearValue, submitForm
@docs selectByIndex, selectByValue, selectByText

# Waiting
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
-}

import Webdriver.LowLevel as Wd exposing (Error, Browser, Options)
import Task exposing (Task, perform)


type alias Selector =
    String


{-| The valid actions that can be executed in the browser
-}
type Action
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
    | Close


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
    ( Maybe Wd.Browser, List Action )


{-| Initializes a model with the give list of steps to perform
-}
init : List Action -> Model
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

        ( ( Just browser, action :: rest ), Process ) ->
            ( ( Just browser, rest ), process action browser )

        ( ( Just browser, actions ), OnError error ) ->
            let
                message =
                    handleError error
            in
                ( ( Nothing, actions ), Wd.close browser |> toCmd )

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


process : Action -> Wd.Browser -> Cmd Msg
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
visit : String -> Action
visit url =
    Visit url


{-| Click on an element using a selector
-}
click : String -> Action
click selector =
    Click selector


{-| Close the current browser window
-}
close : Action
close =
    Close


{-| Fills in the specified input with the given value

    setValue "#email" "foo@bar.com"
-}
setValue : String -> String -> Action
setValue selector value =
    SetValue selector value


{-| Appends the given string to the specified input's current value

    setValue "#email" "foo"
    addValue "#email" "@bar.com"
-}
appendValue : String -> String -> Action
appendValue selector value =
    AppendValue selector value


{-| Clears the value of the specified input field

    clearValue "#email"
-}
clearValue : String -> Action
clearValue selector =
    ClearValue selector


{-| Selects the option in the dropdown using the option index
-}
selectByIndex : String -> Int -> Action
selectByIndex selector index =
    SelectByIndex selector index


{-| Selects the option in the dropdown using the option value
-}
selectByValue : String -> String -> Action
selectByValue selector value =
    SelectByValue selector value


{-| Selects the option in the dropdown using the option visible text
-}
selectByText : String -> String -> Action
selectByText selector text =
    SelectByText selector text


{-| Submits the form with the given selector
-}
submitForm : String -> Action
submitForm selector =
    Submit selector


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be present within the DOM
-}
waitForExist : String -> Int -> Action
waitForExist selector timeout =
    WaitForExist selector timeout


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be present absent from the DOM
-}
waitForNotExist : String -> Int -> Action
waitForNotExist selector ms =
    WaitForNotExist selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be visible.
-}
waitForVisible : String -> Int -> Action
waitForVisible selector ms =
    WaitForVisible selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be invisible.
-}
waitForNotVisible : String -> Int -> Action
waitForNotVisible selector ms =
    WaitForNotVisible selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be have a value.
-}
waitForValue : String -> Int -> Action
waitForValue selector ms =
    WaitForValue selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to have no value.
-}
waitForNoValue : String -> Int -> Action
waitForNoValue selector ms =
    WaitForNoValue selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be selected.
-}
waitForSelected : String -> Int -> Action
waitForSelected selector ms =
    WaitForSelected selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to not be selected.
-}
waitForNotSelected : String -> Int -> Action
waitForNotSelected selector ms =
    WaitForNotSelected selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be have some text.
-}
waitForText : String -> Int -> Action
waitForText selector ms =
    WaitForText selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to have no text.
-}
waitForNoText : String -> Int -> Action
waitForNoText selector ms =
    WaitForNoText selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be enabled.
-}
waitForEnabled : String -> Int -> Action
waitForEnabled selector ms =
    WaitForEnabled selector ms


{-| Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be disabled.
-}
waitForNotEnabled : String -> Int -> Action
waitForNotEnabled selector ms =
    WaitForNotEnabled selector ms
