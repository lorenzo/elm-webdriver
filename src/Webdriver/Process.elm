module Webdriver.Process
    exposing
        ( Model
        , Msg
        , OutMsg(..)
        , StepResult(..)
        , init
        , open
        , update
        , process
        )

import Webdriver.LowLevel as Wd exposing (Error, Browser)
import Webdriver.Step exposing (..)
import Task exposing (Task, attempt)
import Tuple exposing (second)
import Expect exposing (fail)


{-| The internal messages passed in this module
-}
type Msg
    = Start Options
    | Initiated Wd.Browser
    | Process StepResult
    | ProcessBranch StepResult (List Step)
    | OnError String Wd.Error (Maybe Screenshot)
    | Finish


{-| A message any parent module can read to track progress
-}
type OutMsg
    = Spawned
    | Progress Int StepResult String
    | Finalized
    | None


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


type alias Expectation =
    Expect.Expectation


type alias Screenshot =
    String


type alias Meta =
    { name : String
    , withScreenshot : Bool
    }


{-| The result of running a test step
-}
type StepResult
    = StepResult String { expectation : Maybe Expectation, screenshot : Maybe Screenshot }


{-| The model used by this module to represent its state
-}
type alias Model =
    ( Maybe Wd.Browser, List Step )


{-| Initializes a model with the give list of steps to perform
-}
init : List (Step) -> Model
init actions =
    ( Nothing, actions )


{-| Opens a new Browser window.
-}
open : Options -> Msg
open options =
    Start options


{-| Initializes the browser session and executes the steps as provided
in the model.
-}
update : Msg -> Model -> ( Model, Cmd Msg, OutMsg )
update msg model =
    case ( model, msg ) of
        ( _, Start options ) ->
            ( model, startSession options, None )

        ( ( _, actions ), Initiated browser ) ->
            let
                newModel =
                    ( Just browser, actions )

                command =
                    Task.succeed (StepResult "Begin session" { expectation = Nothing, screenshot = Nothing })
                        |> Task.perform Process
            in
                ( newModel, command, Spawned )

        ( ( Just browser, (ReturningUnit meta End) :: rest ), Process previousStep ) ->
            ( ( Nothing, [] ), finishSession browser, Progress 0 previousStep meta.name )

        -- Automatically ending the session on last step
        ( ( Just browser, [] ), Process previousStep ) ->
            ( ( Nothing, [] ), finishSession browser, Progress 0 previousStep "End Session" )

        ( ( Just browser, action :: rest ), Process previousStep ) ->
            let
                outMsg =
                    Progress (List.length rest) previousStep (stepName action)

                newModel =
                    ( Just browser, rest )
            in
                ( newModel, process action browser, outMsg )

        ( ( Just browser, actions ), OnError actionDesc error screenshot ) ->
            let
                message =
                    StepResult actionDesc
                        { expectation = Just (fail (errorMessage error))
                        , screenshot = screenshot
                        }

                newMessage =
                    Process message
            in
                -- Stop processing actions. The browser state is not reliable
                update newMessage ( Just browser, [] )

        -- We need to process the branch actions and the continue with the rest of the process
        ( ( Just browser, actions ), ProcessBranch previousStep (action :: rest) ) ->
            let
                newSteps =
                    List.append rest actions

                outMsg =
                    Progress (List.length newSteps) previousStep (stepName action)

                newModel =
                    ( Just browser, newSteps )
            in
                ( newModel, process action browser, outMsg )

        ( ( _, actions ), Finish ) ->
            ( ( Nothing, [] ), Cmd.none, Finalized )

        ( _, _ ) ->
            ( model, Cmd.none, None )


errorMessage : Wd.Error -> String
errorMessage error =
    case error of
        Wd.ConnectionError { message } ->
            "Could not connect to server:\n\n" ++ message

        Wd.MissingElement { message, selector } ->
            "The element you are trying to reach the element <" ++ selector ++ ">, but  it is missing.\n\n" ++ message

        Wd.UnreachableElement { message, selector } ->
            "The element you are trying to reach the element <" ++ selector ++ ">, but it is not visible.\n\n" ++ message

        Wd.TooManyElements { message } ->
            message

        Wd.FailedElementPrecondition { message, selector } ->
            "Tried to use the selector <" ++ selector ++ ">, but it is not valid.\n\n" ++ message

        Wd.UnknownError { message } ->
            "Oops, something wrong happened.\n\n" ++ message

        Wd.InvalidCommand { message } ->
            message

        Wd.Never ->
            ""


startSession : Options -> Cmd Msg
startSession options =
    Wd.open options
        |> Task.map (\( _, browser ) -> Initiated browser)
        |> Task.mapError (\error -> OnError "Connecting to Selenium Server" error Nothing)
        |> attempt toMessage


finishSession : Wd.Browser -> Cmd Msg
finishSession browser =
    Wd.end browser
        |> Task.map (always Finish)
        |> Task.mapError (always Finish)
        |> attempt toMessage


(&>) : Task x y -> Task x z -> Task x z
(&>) t1 t2 =
    t1 |> Task.andThen (\_ -> t2)


(#>) : Task x y -> Task x z -> Task x ( y, z )
(#>) t1 t2 =
    Task.map2 (,) t1 t2


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
        |> Task.andThen
            (\count ->
                if count > 1 then
                    Task.fail
                        (Wd.TooManyElements
                            { errorType = "TooManyElements"
                            , message = "The selector returned " ++ (toString count) ++ " elements, expecting 1"
                            , selector = selector
                            }
                        )
                else
                    Task.succeed ()
            )


autoScreenshot : Wd.Browser -> Meta -> (a -> Maybe Expectation) -> Task Wd.Error a -> Task Wd.Error ( a, StepResult )
autoScreenshot browser meta toExpectation task =
    if meta.withScreenshot then
        task
            #> Wd.viewportScreenshot browser
            |> Task.map
                (\( res, screenshot ) ->
                    ( res
                    , StepResult meta.name { expectation = toExpectation res, screenshot = Just screenshot }
                    )
                )
    else
        task
            |> Task.map
                (\res ->
                    ( res
                    , StepResult meta.name { expectation = toExpectation res, screenshot = Nothing }
                    )
                )


screenshotOnError : Wd.Browser -> String -> Task Wd.Error a -> Task Msg a
screenshotOnError browser desc task =
    task
        |> Task.onError
            (\error ->
                Wd.viewportScreenshot browser
                    |> Task.onError (\error -> Task.fail (OnError desc error Nothing))
                    |> Task.andThen (\screenshot -> Task.fail (OnError desc error (Just screenshot)))
            )


convertAssertion : Wd.Browser -> Meta -> (a -> Expectation) -> Task Wd.Error a -> Cmd Msg
convertAssertion browser meta assert task =
    task
        |> autoScreenshot browser meta (assert >> Just)
        |> screenshotOnError browser meta.name
        |> Task.map second
        |> Task.map Process
        |> attempt toMessage


process : Step -> Wd.Browser -> Cmd Msg
process action browser =
    let
        command =
            case action of
                AssertionString desc step assert ->
                    processStringStep step browser
                        |> convertAssertion browser desc assert

                AssertionMaybe desc step assert ->
                    processMaybeStep step browser
                        |> convertAssertion browser desc assert

                AssertionGeometry desc step assert ->
                    processGeometryStep step browser
                        |> convertAssertion browser desc assert

                AssertionBool desc step assert ->
                    processBoolStep step browser
                        |> convertAssertion browser desc assert

                AssertionInt desc step assert ->
                    processIntStep step browser
                        |> convertAssertion browser desc assert

                AssertionTask meta task ->
                    task
                        |> Task.mapError (\_ -> Wd.Never)
                        |> autoScreenshot browser meta (Just)
                        |> screenshotOnError browser meta.name
                        |> Task.map second
                        |> Task.map Process
                        |> attempt toMessage

                AssertionWebdriver meta task ->
                    task browser
                        |> autoScreenshot browser meta Just
                        |> screenshotOnError browser meta.name
                        |> Task.map second
                        |> Task.map Process
                        |> attempt toMessage

                ReturningUnit meta step ->
                    processStep step browser
                        |> autoScreenshot browser meta (always Nothing)
                        |> screenshotOnError browser meta.name
                        |> Task.map second
                        |> Task.map Process
                        |> attempt toMessage

                BranchMaybe meta step decider ->
                    processMaybeStep step browser
                        |> performBranch meta browser decider

                BranchString meta step decider ->
                    processStringStep step browser
                        |> performBranch meta browser decider

                BranchBool meta step decider ->
                    processBoolStep step browser
                        |> performBranch meta browser decider

                BranchGeometry meta step decider ->
                    processGeometryStep step browser
                        |> performBranch meta browser decider

                BranchInt meta step decider ->
                    processIntStep step browser
                        |> performBranch meta browser decider

                BranchTask meta task ->
                    task
                        |> Task.mapError (\_ -> Wd.Never)
                        |> autoScreenshot browser meta (always Nothing)
                        |> screenshotOnError browser meta.name
                        |> Task.map (resolveBranch identity)
                        |> attempt toMessage

                BranchWebdriver meta task ->
                    task browser
                        |> autoScreenshot browser meta (always Nothing)
                        |> screenshotOnError browser meta.name
                        |> Task.map (resolveBranch identity)
                        |> attempt toMessage
    in
        command


performBranch : Meta -> Wd.Browser -> (a -> List Step) -> Task Error a -> Cmd Msg
performBranch meta browser decider task =
    task
        |> autoScreenshot browser meta (always Nothing)
        |> screenshotOnError browser meta.name
        |> Task.map (resolveBranch decider)
        |> Task.attempt toMessage


resolveBranch : (a -> List Step) -> ( a, StepResult ) -> Msg
resolveBranch decider ( value, stepResult ) =
    case decider value of
        [] ->
            Process stepResult

        list ->
            ProcessBranch stepResult list


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

        MoveTo selector ->
            validateSelector selector browser
                &> autoWait selector browser
                &> Wd.moveTo selector browser

        MoveToWithOffset selector x y ->
            validateSelector selector browser
                &> autoWait selector browser
                &> Wd.moveToWithOffset selector (Just x) (Just y) browser

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

        SelectByAttribute selector attr value ->
            validateSelector selector browser
                &> inputAutoWait selector browser
                &> Wd.selectByAttribute selector attr value browser

        Submit selector ->
            validateSelector selector browser
                &> Wd.submitForm selector browser

        SetCookie name value ->
            Wd.setCookie name value browser

        DeleteCookie name ->
            Wd.deleteCookie name browser

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

        WindowResize width height ->
            Wd.windowResize width height browser


toMessage : Result Msg Msg -> Msg
toMessage task =
    case task of
        Err msg ->
            msg

        Ok msg ->
            msg
