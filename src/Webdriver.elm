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
        , selectByIndex
        , selectByValue
        , selectByText
        , submitForm
        )

{-| A library to interface with Webdriver.io and produce commands

@docs basicOptions, init, update, Model, Msg, Action
@docs open, visit, click, close, setValue, submitForm
@docs selectByIndex, selectByValue, selectByText
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
    | SetValue Selector String
    | SelectByValue Selector String
    | SelectByIndex Selector Int
    | SelectByText Selector String
    | Submit Selector
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

        ( _, _ ) ->
            ( model, Cmd.none )


process : Action -> Wd.Browser -> Cmd Msg
process action browser =
    case action of
        Visit url ->
            Wd.url url browser
                |> toCmd

        Click selector ->
            Wd.click selector browser
                |> toCmd

        SetValue selector value ->
            Wd.setValue selector value browser
                |> toCmd

        SelectByValue selector value ->
            Wd.selectByValue selector value browser
                |> toCmd

        SelectByIndex selector index ->
            Wd.selectByIndex selector index browser
                |> toCmd

        SelectByText selector text ->
            Wd.selectByText selector text browser
                |> toCmd

        Submit selector ->
            Wd.submitForm selector browser
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


{-| Fills in the specified input with the give value

    setValue "#email" "foo@bar.com" OnError Success browser
-}
setValue : String -> String -> Action
setValue selector value =
    SetValue selector value


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
