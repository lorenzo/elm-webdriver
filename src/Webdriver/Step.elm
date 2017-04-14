module Webdriver.Step
    exposing
        ( Step(..)
        , UnitStep(..)
        , MaybeStep(..)
        , StringStep(..)
        , BoolStep(..)
        , GeometryStep(..)
        , IntStep(..)
        , stepName
        , withName
        , withScreenshot
        , initMeta
        , getCookie
        , cookieExists
        , cookieNotExists
        , getUrl
        , getAttribute
        , getCssProperty
        , getElementHTML
        , getPageHTML
        , getText
        , getTitle
        , getValue
        , elementExists
        , elementEnabled
        , elementVisible
        , elementVisibleWithinViewport
        , optionIsSelected
        , getElementSize
        , getElementPosition
        , getElementViewPosition
        , countElements
        )

import Expect
import Task exposing (Task)
import Webdriver.LowLevel as Wd


type alias Selector =
    String


type alias Name =
    String


type alias Expectation =
    Expect.Expectation


type alias Meta =
    { name : String
    , withScreenshot : Bool
    }


{-| The valid actions that can be executed in the browser
-}
type Step
    = ReturningUnit Meta UnitStep
    | BranchMaybe Meta MaybeStep (Maybe String -> List Step)
    | BranchString Meta StringStep (String -> List Step)
    | BranchBool Meta BoolStep (Bool -> List Step)
    | BranchGeometry Meta GeometryStep (( Int, Int ) -> List Step)
    | BranchInt Meta IntStep (Int -> List Step)
    | BranchTask Meta (Task Never (List Step))
    | BranchWebdriver Meta (Wd.Browser -> Task Wd.Error (List Step))
    | AssertionMaybe Meta MaybeStep (Maybe String -> Expectation)
    | AssertionString Meta StringStep (String -> Expectation)
    | AssertionBool Meta BoolStep (Bool -> Expectation)
    | AssertionGeometry Meta GeometryStep (( Int, Int ) -> Expectation)
    | AssertionInt Meta IntStep (Int -> Expectation)
    | AssertionTask Meta (Task Never Expectation)
    | AssertionWebdriver Meta (Wd.Browser -> Task Wd.Error Expectation)


type UnitStep
    = Visit String
    | Click Selector
    | MoveTo Selector
    | MoveToWithOffset Selector Int Int
    | AppendValue String String
    | ClearValue String
    | SetValue Selector String
    | SelectByValue Selector String
    | SelectByIndex Selector Int
    | SelectByText Selector String
    | SelectByAttribute Selector String String
    | SetCookie String String
    | DeleteCookie String
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
    | WindowResize Int Int
    | Keys (List Wd.Key)

type StringStep
    = GetUrl
    | GetHtml String
    | GetSource
    | GetTitle
    | GetText String
    | GetValue String


type MaybeStep
    = GetAttribute Selector String
    | GetCookie String
    | GetCss Selector String


type BoolStep
    = CookieExists String
    | CookieNotExists String
    | ElementExists String
    | ElementEnabled String
    | ElementVisible String
    | ElementViewportVisible String
    | OptionSelected String


type GeometryStep
    = GetElementPosition Selector
    | GetElementViewPosition Selector
    | GetElementSize Selector


type IntStep
    = CountElements Selector


initMeta : String -> Meta
initMeta name =
    { name = name, withScreenshot = False }


getMetaProperty : (Meta -> a) -> Step -> a
getMetaProperty getter step =
    case step of
        ReturningUnit meta _ ->
            getter meta

        BranchMaybe meta _ _ ->
            getter meta

        BranchString meta _ _ ->
            getter meta

        BranchBool meta _ _ ->
            getter meta

        BranchGeometry meta _ _ ->
            getter meta

        BranchInt meta _ _ ->
            getter meta

        BranchTask meta _ ->
            getter meta

        BranchWebdriver meta _ ->
            getter meta

        AssertionMaybe meta _ _ ->
            getter meta

        AssertionString meta _ _ ->
            getter meta

        AssertionBool meta _ _ ->
            getter meta

        AssertionGeometry meta _ _ ->
            getter meta

        AssertionInt meta _ _ ->
            getter meta

        AssertionTask meta _ ->
            getter meta

        AssertionWebdriver meta _ ->
            getter meta


setMetaProperty : (Meta -> Meta) -> Step -> Step
setMetaProperty setter step =
    case step of
        ReturningUnit meta a ->
            ReturningUnit (setter meta) a

        BranchMaybe meta a b ->
            BranchMaybe (setter meta) a b

        BranchString meta a b ->
            BranchString (setter meta) a b

        BranchBool meta a b ->
            BranchBool (setter meta) a b

        BranchGeometry meta a b ->
            BranchGeometry (setter meta) a b

        BranchInt meta a b ->
            BranchInt (setter meta) a b

        BranchTask meta a ->
            BranchTask (setter meta) a

        BranchWebdriver meta a ->
            BranchWebdriver (setter meta) a

        AssertionMaybe meta a b ->
            AssertionMaybe (setter meta) a b

        AssertionString meta a b ->
            AssertionString (setter meta) a b

        AssertionBool meta a b ->
            AssertionBool (setter meta) a b

        AssertionGeometry meta a b ->
            AssertionGeometry (setter meta) a b

        AssertionInt meta a b ->
            AssertionInt (setter meta) a b

        AssertionTask meta a ->
            AssertionTask (setter meta) a

        AssertionWebdriver meta a ->
            AssertionWebdriver (setter meta) a


{-| Returns the human readable name of the step
-}
stepName : Step -> String
stepName step =
    getMetaProperty .name step


{-| Gives a new human readable name to an existing step
-}
withName : String -> Step -> Step
withName name step =
    setMetaProperty (\meta -> { meta | name = name }) step


{-| Make the step take a screenshot immediately after it is executed successfully
-}
withScreenshot : Bool -> Step -> Step
withScreenshot enable step =
    setMetaProperty (\meta -> { meta | withScreenshot = enable }) step


{-| Returns the value of a cookie by name
-}
getCookie : String -> MaybeStep
getCookie name =
    GetCookie name


{-| Returns true if a cookie exists
-}
cookieExists : String -> BoolStep
cookieExists name =
    CookieExists name


{-| Returns false if a cookie exists
-}
cookieNotExists : String -> BoolStep
cookieNotExists name =
    CookieNotExists name


{-| Returns the current window URL
-}
getUrl : StringStep
getUrl =
    GetUrl


{-| Returns a specific attribute form the element
-}
getAttribute : Selector -> String -> MaybeStep
getAttribute selector name =
    GetAttribute selector name


{-| Returns a specific attribute form the element
-}
getCssProperty : Selector -> String -> MaybeStep
getCssProperty selector name =
    GetCss selector name


{-| Returns the HTML for an element
-}
getElementHTML : Selector -> StringStep
getElementHTML selector =
    GetHtml selector


{-| Returns the page HTML
-}
getPageHTML : StringStep
getPageHTML =
    GetSource


{-| Returns the page title
-}
getTitle : StringStep
getTitle =
    GetTitle


{-| Returns the concatenation of all text nodes for the element
-}
getText : Selector -> StringStep
getText selector =
    GetText selector


{-| Returns the value for the given input
-}
getValue : Selector -> StringStep
getValue selector =
    GetValue selector


{-| Returns whether or not an element exists in the page
-}
elementExists : Selector -> BoolStep
elementExists selector =
    ElementExists selector


{-| Returns whether or not an input is enabled
-}
elementEnabled : Selector -> BoolStep
elementEnabled selector =
    ElementEnabled selector


{-| Returns whether or not an element is visible
-}
elementVisible : Selector -> BoolStep
elementVisible selector =
    ElementVisible selector


{-| Returns whether or not an element is visible within
the viewport
-}
elementVisibleWithinViewport : Selector -> BoolStep
elementVisibleWithinViewport selector =
    ElementViewportVisible selector


{-| Returns whether or not an select option is currently selected
-}
optionIsSelected : Selector -> BoolStep
optionIsSelected selector =
    OptionSelected selector


{-| Returns the size for the given element
-}
getElementSize : Selector -> GeometryStep
getElementSize selector =
    GetElementSize selector


{-| Returns the coordinates for the given element
-}
getElementPosition : Selector -> GeometryStep
getElementPosition selector =
    GetElementPosition selector


{-| Returns the coordinates for the given element
relative to the current viewport.
-}
getElementViewPosition : Selector -> GeometryStep
getElementViewPosition selector =
    GetElementViewPosition selector


{-| Returns the number of elements matching the provided selector
-}
countElements : Selector -> IntStep
countElements selector =
    CountElements selector
