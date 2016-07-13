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
import Webdriver.Step exposing (..)
import Task exposing (Task, perform)
import Expect exposing (pass, fail)


{-| The internal messages passed in this module
-}
type Msg
    = Start Options
    | Initiated Wd.Browser
    | Process (Maybe Expectation)
    | ProcessBranch (List Step)
    | OnError Wd.Error
    | Finish


{-| The valid actions that can be executed in the browser
-}
type alias Step =
    Webdriver.Step.Step


type alias Selector =
    String


type alias Expectation =
    Expect.Expectation


{-| The model used by this module to represent its state
-}
type alias Model =
    ( Maybe Wd.Browser, List (Maybe Expectation), List Step )


{-| Initializes a model with the give list of steps to perform
-}
init : List (Step) -> Model
init actions =
    ( Nothing, [], actions )


{-| Initializes the browser session and executes the steps as provided
in the model.
-}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( model, msg ) of
        ( _, Start options ) ->
            ( model, perform OnError Initiated (Wd.open options |> Task.map (\( _, b ) -> b)) )

        ( ( _, exs, actions ), Initiated browser ) ->
            update (Process Nothing) ( Just browser, exs, actions )

        ( ( Just browser, exs, (ReturningUnit End) :: rest ), Process previousExpect ) ->
            ( ( Nothing, previousExpect :: exs, [] ), finishSession browser )

        -- Automatically ending the session on last step
        ( ( Just browser, exs, [] ), Process previousExpect ) ->
            ( ( Nothing, previousExpect :: exs, [] ), finishSession browser )

        ( ( Just browser, exs, action :: rest ), Process previousExpect ) ->
            ( ( Just browser, previousExpect :: exs, rest ), process action browser )

        ( ( Just browser, exs, actions ), OnError error ) ->
            let
                message =
                    fail <| errorMessage error
            in
                -- Automatically ending the session on error
                update (Process <| Just message) ( Just browser, exs, [] )

        -- Processing a branch means that we need to process the branch actions and the continue with the normal
        -- processing
        ( ( Just browser, exs, actions ), ProcessBranch (action :: rest) ) ->
            ( ( Just browser, exs, List.append rest actions ), process action browser )

        ( _, _ ) ->
            ( model, Cmd.none )


errorMessage : Wd.Error -> String
errorMessage error =
    case error of
        Wd.ConnectionError { message } ->
            "Could not connect to server: " ++ message

        Wd.MissingElement { message, selector } ->
            "The element you are trying to reach is missing. " ++ message

        Wd.UnreachableElement { message, selector } ->
            "The element you are trying to reach is not visible. " ++ message

        Wd.TooManyElements { message, selector } ->
            message

        Wd.FailedElementPrecondition { message, selector } ->
            "You were waiting for an element, but it is not as you expected. " ++ message

        Wd.UnknownError { message } ->
            "Oops, something wrong happened. " ++ message


finishSession : Wd.Browser -> Cmd Msg
finishSession browser =
    Wd.end browser
        |> perform (always Finish) (always Finish)


(&>) : Task x y -> Task x z -> Task x z
(&>) t1 t2 =
    t1 `Task.andThen` \_ -> t2


autoWait : Selector -> Wd.Browser -> Task Wd.Error ()
autoWait selector browser =
    Wd.waitForVisible selector 5000 browser


existAutoWait : Selector -> Wd.Browser -> Task Wd.Error ()
existAutoWait selector browser =
    Wd.waitForExist selector 5000 browser


inputAutoWait : Selector -> Wd.Browser -> Task Wd.Error ()
inputAutoWait selector browser =
    autoWait selector browser
        &> Wd.waitForEnabled selector 5000 browser


validateSelector : Selector -> Wd.Browser -> Task Wd.Error ()
validateSelector selector browser =
    Wd.countElements selector browser
        `Task.andThen`
            (\count ->
                if count > 1 then
                    Task.fail
                        (Wd.TooManyElements
                            { errorType = "TooManyElements"
                            , message = "The selector returned " ++ (toString count) ++ " elements, excpecting 1"
                            , selector = selector
                            }
                        )
                else
                    Task.succeed ()
            )


convertAssertion : (a -> Expectation) -> Task Wd.Error a -> Cmd Msg
convertAssertion assert task =
    task
        |> Task.map (assert >> Just)
        |> Task.perform OnError Process


process : Step -> Wd.Browser -> Cmd Msg
process action browser =
    let
        command =
            case Debug.log "processing" action of
                AssertionString step assert ->
                    processStringStep step browser
                        |> convertAssertion assert

                AssertionMaybe step assert ->
                    processMaybeStep step browser
                        |> convertAssertion assert

                AssertionGeometry step assert ->
                    processGeometryStep step browser
                        |> convertAssertion assert

                AssertionBool step assert ->
                    processBoolStep step browser
                        |> convertAssertion assert

                AssertionInt step assert ->
                    processIntStep step browser
                        |> convertAssertion assert

                ReturningUnit step ->
                    processStep step browser
                        |> toCmd

                BranchMaybe step decider ->
                    processMaybeStep step browser
                        |> performBranch decider

                BranchString step decider ->
                    processStringStep step browser
                        |> performBranch decider

                BranchBool step decider ->
                    processBoolStep step browser
                        |> performBranch decider

                BranchGeometry step decider ->
                    processGeometryStep step browser
                        |> performBranch decider

                BranchInt step decider ->
                    processIntStep step browser
                        |> performBranch decider
    in
        command


performBranch : (a -> List Step) -> Task Error a -> Cmd Msg
performBranch decider task =
    task
        |> Task.map (resolveBranch decider)
        |> Task.perform OnError identity


resolveBranch : (a -> List Step) -> a -> Msg
resolveBranch decider value =
    case decider value of
        [] ->
            Process (Just pass)

        list ->
            ProcessBranch list


processStringStep : StringStep -> Wd.Browser -> Task Error String
processStringStep step browser =
    case step of
        GetUrl ->
            Wd.getUrl browser

        GetHtml selector ->
            existAutoWait selector browser
                &> validateSelector selector browser
                &> Wd.getElementHTML selector browser

        GetSource ->
            Wd.getPageHTML browser

        GetTitle ->
            Wd.getTitle browser

        GetText selector ->
            existAutoWait selector browser
                &> validateSelector selector browser
                &> Wd.getText selector browser

        GetValue selector ->
            existAutoWait selector browser
                &> validateSelector selector browser
                &> Wd.getValue selector browser


processMaybeStep : MaybeStep -> Wd.Browser -> Task Error (Maybe String)
processMaybeStep step browser =
    case step of
        GetCookie name ->
            Wd.getCookie name browser

        GetAttribute selector name ->
            existAutoWait selector browser
                &> validateSelector selector browser
                &> Wd.getAttribute selector name browser

        GetCss selector name ->
            existAutoWait selector browser
                &> validateSelector selector browser
                &> Wd.getCssProperty selector name browser


processBoolStep : BoolStep -> Wd.Browser -> Task Error Bool
processBoolStep step browser =
    case step of
        CookieExists name ->
            Wd.cookieExists name browser

        CookieNotExists name ->
            Wd.cookieExists name browser
                |> Task.map not

        ElementExists selector ->
            Wd.elementExists selector browser

        ElementEnabled selector ->
            existAutoWait selector browser
                &> Wd.elementEnabled selector browser

        ElementVisible selector ->
            existAutoWait selector browser
                &> Wd.elementVisible selector browser

        ElementViewportVisible selector ->
            existAutoWait selector browser
                &> Wd.elementVisibleWithinViewport selector browser

        OptionSelected selector ->
            existAutoWait selector browser
                &> Wd.optionIsSelected selector browser


processGeometryStep : GeometryStep -> Wd.Browser -> Task Error ( Int, Int )
processGeometryStep step browser =
    case step of
        GetElementSize selector ->
            existAutoWait selector browser
                &> validateSelector selector browser
                &> Wd.getElementSize selector browser
                |> Task.map (\{ width, height } -> ( width, height ))

        GetElementPosition selector ->
            existAutoWait selector browser
                &> validateSelector selector browser
                &> Wd.getElementPosition selector browser
                |> Task.map (\{ x, y } -> ( x, y ))

        GetElementViewPosition selector ->
            existAutoWait selector browser
                &> validateSelector selector browser
                &> Wd.getElementViewPosition selector browser
                |> Task.map (\{ x, y } -> ( x, y ))


processIntStep : IntStep -> Wd.Browser -> Task Error Int
processIntStep step browser =
    case step of
        CountElements selector ->
            Wd.countElements selector browser


processStep : UnitStep -> Wd.Browser -> Task Error ()
processStep step browser =
    case step of
        Visit url ->
            Wd.url url browser

        Click selector ->
            validateSelector selector browser
                &> autoWait selector browser
                &> Wd.click selector browser

        SetValue selector value ->
            inputAutoWait selector browser
                &> validateSelector selector browser
                &> Wd.setValue selector value browser

        AppendValue selector value ->
            validateSelector selector browser
                &> inputAutoWait selector browser
                &> Wd.appendValue selector value browser

        ClearValue selector ->
            validateSelector selector browser
                &> inputAutoWait selector browser
                &> Wd.clearValue selector browser

        SelectByValue selector value ->
            validateSelector selector browser
                &> inputAutoWait selector browser
                &> Wd.selectByValue selector value browser

        SelectByIndex selector index ->
            validateSelector selector browser
                &> inputAutoWait selector browser
                &> Wd.selectByIndex selector index browser

        SelectByText selector text ->
            validateSelector selector browser
                &> inputAutoWait selector browser
                &> Wd.selectByText selector text browser

        Submit selector ->
            validateSelector selector browser
                &> Wd.submitForm selector browser

        WaitForExist selector timeout ->
            Wd.waitForExist selector timeout browser

        WaitForNotExist selector timeout ->
            Wd.waitForNotExist selector timeout browser

        WaitForVisible selector timeout ->
            Wd.waitForVisible selector timeout browser

        WaitForNotVisible selector timeout ->
            Wd.waitForNotVisible selector timeout browser

        WaitForValue selector timeout ->
            Wd.waitForValue selector timeout browser

        WaitForNoValue selector timeout ->
            Wd.waitForNoValue selector timeout browser

        WaitForSelected selector timeout ->
            Wd.waitForSelected selector timeout browser

        WaitForNotSelected selector timeout ->
            Wd.waitForNotSelected selector timeout browser

        WaitForText selector timeout ->
            Wd.waitForText selector timeout browser

        WaitForNoText selector timeout ->
            Wd.waitForNoText selector timeout browser

        WaitForEnabled selector timeout ->
            Wd.waitForEnabled selector timeout browser

        WaitForNotEnabled selector timeout ->
            Wd.waitForNotEnabled selector timeout browser

        WaitForDebug ->
            Wd.debug browser

        Pause timeout ->
            Wd.pause timeout browser

        Scroll x y ->
            Wd.scrollWindow x y browser

        ScrollTo selector x y ->
            Wd.scrollToElementOffset selector x y browser

        SavePagecreenshot filename ->
            Wd.savePageScreenshot filename browser

        SwitchFrame index ->
            Wd.switchToFrame index browser

        TriggerClick selector ->
            Wd.triggerClick selector browser

        End ->
            Wd.end browser

        Close ->
            Wd.close browser


toCmd : Task Error a -> Cmd Msg
toCmd =
    perform OnError (always <| Process Nothing)


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
        |> ReturningUnit


{-| Click on an element using a selector
-}
click : String -> Step
click selector =
    Click selector
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
