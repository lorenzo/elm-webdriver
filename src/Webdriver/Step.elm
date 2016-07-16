module Webdriver.Step
    exposing
        ( Step(..)
        , UnitStep(..)
        , MaybeStep(..)
        , StringStep(..)
        , BoolStep(..)
        , GeometryStep(..)
        , IntStep(..)
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


type alias Selector =
    String


type alias Expectation =
    Expect.Expectation


{-| The valid actions that can be executed in the browser
-}
type Step
    = ReturningUnit UnitStep
    | BranchMaybe MaybeStep (Maybe String -> List Step)
    | BranchString StringStep (String -> List Step)
    | BranchBool BoolStep (Bool -> List Step)
    | BranchGeometry GeometryStep (( Int, Int ) -> List Step)
    | BranchInt IntStep (Int -> List Step)
    | AssertionMaybe String MaybeStep (Maybe String -> Expectation)
    | AssertionString String StringStep (String -> Expectation)
    | AssertionBool String BoolStep (Bool -> Expectation)
    | AssertionGeometry String GeometryStep (( Int, Int ) -> Expectation)
    | AssertionInt String IntStep (Int -> Expectation)


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
