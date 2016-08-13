#Webdriver.Runner

 Allows you to execute a list list of steps or a group of these steps and get a summary
of each of the runs. This module acts as a test suite runner, but can be resused for any
other purpose as it will just run each of the steps at a time and report back the status
using a port and through the Summary type alias.

## Types

```elm
type alias Model = 
  { options : Webdriver.Options , runs : Webdriver.Runner.Run , sessions : Dict.Dict String Webdriver.Process.Model , initTimes : Dict.Dict String Time.Time , startTimes : Dict.Dict String Time.Time , statuses : Dict.Dict String Webdriver.Runner.RunStatus , summaries : Dict.Dict String Webdriver.Runner.Summary , summary : Webdriver.Runner.Summary }
```

The model used for concurrently running multiple lists of steps

---
```elm
type Run
    = Run
```

A Run can be either a single list of Step to execute in the browser or
a group of these lists. Groups can be nested arbitrarily.

---
```elm
type Msg
    = Msg
    | StartRun String
    | StartedRun String
    | StopRun String
    | DriverMsg String
```

The Messages this module can process

---
```elm
type alias Flags = 
  { filter : Maybe.Maybe String }
```

Custom options to be set to the runner, such as filtering tests
by name:

    - filter: A string to match against the run name. Only matching runs will execute.

---
```elm
type alias RunStatus = 
  { failed : Bool, total : Int, remaining : Int, nextStep : String }
```

Represents the current status of a single run.

---
```elm
type alias Summary = 
  { output : String , passed : Int , failed : Int , screenshots : List String }
```

Represents the final result of a single run or a group of runs.

---


## Creating runs and groups of runs

In order to run a list of steps you need to give the a name. You can also group multiple of them
inside groups.

```elm
describe : String -> Webdriver.Runner.SingleRun -> Webdriver.Runner.Run
```

Describes with a name a list of steps to be executed

    describe "Login smoke test" [...]

---
```elm
group : String -> List Webdriver.Runner.Run -> Webdriver.Runner.Run
```

Groups a list Runs under the same name

    group "All Smoke Tests"
        [ describe "Login Tests" [...]
        , describe "Signup Tests" [...]
        ]

---


## Kicking it off

```elm
begin : Webdriver.Options
    -> Webdriver.Runner.Run
    -> Webdriver.Runner.Flags
    -> ( Webdriver.Runner.Model, Platform.Cmd.Cmd Webdriver.Runner.Msg )
```

Creates the initial `update` state out of the browser options and
a Run suite. This is usually the function you will call to feed your
main program.

    begin flags browserOptions (describe "All Tests" [...])

---
```elm
update : Webdriver.Runner.Msg
    -> Webdriver.Runner.Model
    -> ( Webdriver.Runner.Model, Platform.Cmd.Cmd Webdriver.Runner.Msg )
```

Starts the browser sessions and executes all the steps. Finally, it displays a sumamry
of the run with the help of a port.

---




---

#Webdriver

 A library to interface with Webdriver.io and produce commands to control a browser
usin selenium.

The functions exposed in this module are commands that produce no result brack from the
browser.

## Basics

```elm
basicOptions : Webdriver.Options
```

Bare minimum options for running selenium

---
```elm
type alias Options = 
  Webdriver.LowLevel.Options
```

Driver options

---
```elm
type alias Step = 
  Webdriver.Step.Step
```

The valid actions that can be executed in the browser

---
```elm
stepName : Webdriver.Step -> String
```

Returns the human readable name of the step

    stepName (click "a") === "Click on <a>"

---
```elm
withName : String -> Webdriver.Step -> Webdriver.Step
```

Gives a new human readable name to an existing step

    click ".login"
        |> withName "Enter the private zone"

---


## Simple Browser Control

```elm
visit : String -> Webdriver.Step
```

Visit a url

---
```elm
click : String -> Webdriver.Step
```

Click on an element using a selector

---
```elm
moveTo : String -> Webdriver.Step
```

Moves the mouse to the middle of the specified element

---
```elm
moveToWithOffset : String
    -> Int
    -> Int
    -> Webdriver.Step
```

Moves the mouse to the middle of the specified element. This function
takes two integers (offsetX and offsetY).

If offsetX has a value, move relative to the top-left corner of the element on the X axis
If offsetY has a value, move relative to the top-left corner of the element on the Y axis

---
```elm
close : Webdriver.Step
```

Close the current browser window

---
```elm
end : Webdriver.Step
```

Ends the browser session

---
```elm
switchToFrame : Int -> Webdriver.Step
```

Makes any future actions happen inside the frame specified by its index

---


## Forms

```elm
setValue : String -> String -> Webdriver.Step
```

Fills in the specified input with the given value

    setValue "#email" "foo@bar.com"

---
```elm
appendValue : String -> String -> Webdriver.Step
```

Appends the given string to the specified input's current value

    setValue "#email" "foo"
    addValue "#email" "@bar.com"

---
```elm
clearValue : String -> Webdriver.Step
```

Clears the value of the specified input field

    clearValue "#email"

---
```elm
submitForm : String -> Webdriver.Step
```

Submits the form with the given selector

---
```elm
selectByIndex : String -> Int -> Webdriver.Step
```

Selects the option in the dropdown using the option index

---
```elm
selectByValue : String -> String -> Webdriver.Step
```

Selects the option in the dropdown using the option value

---
```elm
selectByText : String -> String -> Webdriver.Step
```

Selects the option in the dropdown using the option visible text

---


## Waiting For Elements

```elm
waitForExist : String -> Int -> Webdriver.Step
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be present within the DOM

---
```elm
waitForNotExist : String -> Int -> Webdriver.Step
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be present absent from the DOM

---
```elm
waitForVisible : String -> Int -> Webdriver.Step
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be visible.

---
```elm
waitForNotVisible : String -> Int -> Webdriver.Step
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be invisible.

---
```elm
waitForText : String -> Int -> Webdriver.Step
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be have some text.

---
```elm
waitForNoText : String -> Int -> Webdriver.Step
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to have no text.

---
```elm
pause : Int -> Webdriver.Step
```

Pauses the browser session for the given milliseconds

---


## Waiting For Form Elements

```elm
waitForValue : String -> Int -> Webdriver.Step
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be have a value.

---
```elm
waitForNoValue : String -> Int -> Webdriver.Step
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to have no value.

---
```elm
waitForSelected : String -> Int -> Webdriver.Step
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be selected.

---
```elm
waitForNotSelected : String -> Int -> Webdriver.Step
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to not be selected.

---
```elm
waitForEnabled : String -> Int -> Webdriver.Step
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be enabled.

---
```elm
waitForNotEnabled : String -> Int -> Webdriver.Step
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be disabled.

---


## Debugging

```elm
waitForDebug : Webdriver.Step
```

Stops the running queue and gives you time to jump into the browser and
check the state of your application (e.g. using the dev tools). Once you are done
go to the command line and press Enter.

---


## Scrolling

```elm
scrollToElement : Webdriver.Selector -> Webdriver.Step
```

Scrolls the window to the element specified in the selector

---
```elm
scrollToElementOffset : Webdriver.Selector
    -> Int
    -> Int
    -> Webdriver.Step
```

Scrolls the window to the element specified in the selector and then scrolls
the given amount of pixels as offset from such element

---
```elm
scrollWindow : Int -> Int -> Webdriver.Step
```

Scrolls the window to the absolute coordinate (x, y) position provided in pixels

---


## Cookies

```elm
setCookie : String -> String -> Webdriver.Step
```

Set the value for a cookie

---
```elm
deleteCookie : String -> Webdriver.Step
```

Deletes a cookie by name

---


## Screenshots

```elm
savePageScreenshot : String -> Webdriver.Step
```

Takes a screenshot of the whole page and saves it to a file

---
```elm
withScreenshot : Bool -> Webdriver.Step -> Webdriver.Step
```

Toggles the automatic screenshot capturing after executing the step.
By default no screenshots are taken.

    click ".login"
        |> withScreenshot True

---


## Custom

```elm
triggerClick : String -> Webdriver.Step
```

Programatically trigger a click in the elements specified in the selector.
This exists because some pages hijack in an odd way mouse click, and in order to test
the behavior, it needs to be manually triggered.

---



---

#Webdriver.Assert

 Allows to run assertions on the current state of the browser session and
page contents.

Assertions are automatically named out of the type of the operation to perform, but
can also be given custom names.

## Types

```elm
type alias Expectation = 
  Expect.Expectation
```

An expectation is either a pass or a fail, with a descriptive
name of the fact that was asserted.

---


## Cookies

```elm
cookie : String
    -> (String -> Webdriver.Assert.Expectation)
    -> Webdriver.Step.Step
```

Asserts the value of a cookie. If the cookie does not exists the assertion
will automatically fail.

    cookie "user" <| Expect.equal "jon snow"

---
```elm
cookieExists : String -> Webdriver.Step.Step
```

Asserts that a cookie exists.

    cookieExists "user"

---
```elm
cookieNotExists : String -> Webdriver.Step.Step
```

Asserts that a cookie has not been set.

    cookieNotExists "user"

---


## Page properties

```elm
url : (String -> Webdriver.Assert.Expectation) -> Webdriver.Step.Step
```

Asserts the value of the current url.

    url <| Expect.equal "https://google.com"

---
```elm
pageHTML : (String -> Webdriver.Assert.Expectation) -> Webdriver.Step.Step
```

Asserts the html source of the current page.

    pageHTML <|
        String.contains "Saved successfully" >> Expect.true "Expected a success message"

---
```elm
title : (String -> Webdriver.Assert.Expectation) -> Webdriver.Step.Step
```

Asserts the title tag of the current page.

    tile <| Expect.equal "This is the page title"

---
```elm
elementCount : String
    -> (Int -> Webdriver.Assert.Expectation)
    -> Webdriver.Step.Step
```

Assets the number of elements matching a selector

    elementCount "#loginForm input" <| Expect.atLeast 2

---


## Element properties

```elm
attribute : String
    -> String
    -> (String -> Webdriver.Assert.Expectation)
    -> Webdriver.Step.Step
```

Asserts the value of an attribute for a given element. Only one element may be matched by the selector.
If the attribute is not present in the element, the assertion will automatically fail.

    attribute "input.username" "autocomplete" <| Expect.equal "off"

---
```elm
css : String
    -> String
    -> (String -> Webdriver.Assert.Expectation)
    -> Webdriver.Step.Step
```

Asserts the value of a css property for a given element. Only one element may be matched by the selector.
If the attribute is not present in the element, the assertion will automatically fail.

    css "input.username" "color" <| Expect.equal "#000000"

---
```elm
elementHTML : String
    -> (String -> Webdriver.Assert.Expectation)
    -> Webdriver.Step.Step
```

Asserts the HTML of an element. Only one element may be matched by the selector.

    elementHTML "#username" <| Expect.equal "<input id='username' value='jon' />"

---
```elm
elementText : String
    -> (String -> Webdriver.Assert.Expectation)
    -> Webdriver.Step.Step
```

Asserts the text node of an element. Only one element may be matched by the selector.

    elementText "p.intro" <| Expect.equal "Welcome to the site!"

---
```elm
exists : String -> Webdriver.Step.Step
```

Asserts that an element exists in the page. Only one element may be matched by the selector.

    exists "h1.logo"

---


## Element Dimensions and Position

```elm
elementSize : String
    -> (( Int, Int ) -> Webdriver.Assert.Expectation)
    -> Webdriver.Step.Step
```

Asserts the size (width, height) of an element. Only one element may be matched by the selector.

    elementSize ".logo" <| (fst >> Expect.equal 100)

---
```elm
elementPosition : String
    -> (( Int, Int ) -> Webdriver.Assert.Expectation)
    -> Webdriver.Step.Step
```

Asserts the position (x, y) of an element. Only one element may be matched by the selector.

    elementPosition ".logo" <| (snd >> Expect.atLeast 330)

---
```elm
elementViewPosition : String
    -> (( Int, Int ) -> Webdriver.Assert.Expectation)
    -> Webdriver.Step.Step
```

Asserts the position (x, y) of an element relative to the viewport.
Only one element may be matched by the selector.

    elementViewPosition ".logo" <| (snd >> Expect.atLeast 330)

---
```elm
visible : String -> Webdriver.Step.Step
```

Asserts that an element to be visible anywhere in the page. Only one element may be matched by the selector.

    enabled "#username"

---
```elm
visibleWithinViewport : String -> Webdriver.Step.Step
```

Asserts that an element to be visible within the viewport. Only one element may be matched by the selector.

    enabled "#username"

---


## Form Elements

```elm
inputValue : String
    -> (String -> Webdriver.Assert.Expectation)
    -> Webdriver.Step.Step
```

Asserts the value of an input element. Only one element may be matched by the selector.

    inputValue "#username" <| Expect.equal "jon_snow"

---
```elm
inputEnabled : String -> Webdriver.Step.Step
```

Asserts that an element exists in the page.  Only one element may be matched by the selector.

    enabled "#username"

---
```elm
optionSelected : String -> Webdriver.Step.Step
```

Asserts that a select option is selected. Only one element may be matched by the selector.

    optionSelected "[value=\"foo\"]"

---


## Custom Assertions

```elm
task : String -> Task.Task Basics.Never Webdriver.Assert.Expectation -> Webdriver.Step.Step
```

Asserts the result of performing a Task

    task "Check custom assertion" (Task.succeed "My value" `Expect.equal` "My Value")

---
```elm
driverCommand : String
    -> (Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error a)
    -> (a -> Webdriver.Assert.Expectation)
    -> Webdriver.Step.Step
```

Asserts the result of executing a LowLevel Webdriver task. This allows you to create
custom sequences of tasks to be executed directly in the webdriver, maybe after getting
values from other tasks.

    driverCommand "Custom cookie check"
        (Wd.getCookie "user")
        (Maybe.map (Expect.equal "2") >> Maybe.withDefault (Expect.fail "Cookie is missing")

---
```elm
sequenceCommands : String
    -> List (Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error a)
    -> (List a -> Webdriver.Assert.Expectation)
    -> Webdriver.Step.Step
```

Asserts the result of executing a list of LowLevel Webdriver task. This allows you to create
custom sequences of tasks to be executed directly in the webdriver, maybe after getting
values from other tasks.

    driverCommand "Custom cookie check"
        [Wd.getCookie "user", Wd.getCookie "legacy_user"]
        (Maybe.oneOf >> Maybe.map (Expec.equal "2) >> Maybe.withDefault (Expect.fail "Cookie is missing"))

---




---

#Webdriver.Branch

 Enables you to conditionally execute a list of steps depending on the current
state of the browser.

You can use this module to create logic branches and loops in the execution of your run.

## Cookies

```elm
ifCookie : String
    -> (Maybe.Maybe String -> List Webdriver.Step.Step)
    -> Webdriver.Step.Step
```

Executes the list of steps the passed function returns depending
on the value of the specified cookie

---
```elm
ifCookieExists : String -> List Webdriver.Step.Step -> Webdriver.Step.Step
```

Executes the provided list of steps if the specified cookie exists

---
```elm
ifCookieNotExists : String -> List Webdriver.Step.Step -> Webdriver.Step.Step
```

Executes the provided list of steps if the specified cookie does not exist

---


## Page properties

```elm
ifUrl : (String -> List Webdriver.Step.Step) -> Webdriver.Step.Step
```

Executes the list of steps the passed function returns depending
on the current url

---
```elm
ifPageHTML : (String -> List Webdriver.Step.Step) -> Webdriver.Step.Step
```

Executes the list of steps the passed function returns depending
on the current page source

---
```elm
ifTitle : (String -> List Webdriver.Step.Step) -> Webdriver.Step.Step
```

Executes the list of steps the passed function returns depending
on the current page title

---
```elm
ifElementCount : String
    -> (Int -> List Webdriver.Step.Step)
    -> Webdriver.Step.Step
```

Executes the list of steps the passed function returns depending
on the number of elements returned by the selector

---


## Element properties

```elm
ifAttribute : String
    -> String
    -> (Maybe.Maybe String -> List Webdriver.Step.Step)
    -> Webdriver.Step.Step
```

Executes the list of steps the passed function returns depending
on the value of the specified attribute in the given element

---
```elm
ifCss : String
    -> String
    -> (Maybe.Maybe String -> List Webdriver.Step.Step)
    -> Webdriver.Step.Step
```

Executes the list of steps the passed function returns depending
on the value of the specified css attribute in the given element

---
```elm
ifElementHTML : String
    -> (String -> List Webdriver.Step.Step)
    -> Webdriver.Step.Step
```

Executes the list of steps the passed function returns depending
on the value of the HTMl for the given element

---
```elm
ifText : String
    -> (String -> List Webdriver.Step.Step)
    -> Webdriver.Step.Step
```

Executes the list of steps the passed function returns depending
on the value of the text node of the given element

---
```elm
ifExists : String -> List Webdriver.Step.Step -> Webdriver.Step.Step
```

Executes the list of steps if the specified element exists in the DOM

---
```elm
ifNotExist : String -> List Webdriver.Step.Step -> Webdriver.Step.Step
```

Executes the list of steps if the specified element does not exist in the DOM

---
```elm
ifVisible : String -> List Webdriver.Step.Step -> Webdriver.Step.Step
```

Executes the list of steps if element is visible

---
```elm
ifNotVisible : String -> List Webdriver.Step.Step -> Webdriver.Step.Step
```

Executes the list of steps if element is not visible

---


## Element Dimensions and Position

```elm
ifElementSize : String
    -> (( Int, Int ) -> List Webdriver.Step.Step)
    -> Webdriver.Step.Step
```

Executes the list of steps the passed function returns depending
on the size (width, height) of the element

---
```elm
ifElementPosition : String
    -> (( Int, Int ) -> List Webdriver.Step.Step)
    -> Webdriver.Step.Step
```

Executes the list of steps the passed function returns depending
on the location (x, y) of the element

---
```elm
ifElementViewPosition : String
    -> (( Int, Int ) -> List Webdriver.Step.Step)
    -> Webdriver.Step.Step
```

Executes the list of steps the passed function returns depending
on the location (x, y) of the element relative to the current viewport

---
```elm
ifVisibleWithinViewport : String -> List Webdriver.Step.Step -> Webdriver.Step.Step
```

Executes the list of steps if the element is visible within the viewport

---
```elm
ifNotVisibleWithinViewport : String -> List Webdriver.Step.Step -> Webdriver.Step.Step
```

Executes the list of steps if the element is not visible within the viewport

---


## Form Element Properties

```elm
ifValue : String
    -> (String -> List Webdriver.Step.Step)
    -> Webdriver.Step.Step
```

Executes the list of steps the passed function returns depending
on the value of the specified input field

---
```elm
ifEnabled : String -> List Webdriver.Step.Step -> Webdriver.Step.Step
```

Executes the list of steps if the input element is enabled

---
```elm
ifNotEnabled : String -> List Webdriver.Step.Step -> Webdriver.Step.Step
```

Executes the list of steps if the input element is not enabled

---
```elm
ifOptionIsSelected : String -> List Webdriver.Step.Step -> Webdriver.Step.Step
```

Executes the list of steps if the option in the select box is selected

---
```elm
ifNotOptionIsSelected : String -> List Webdriver.Step.Step -> Webdriver.Step.Step
```

Executes the list of steps if the option in the select box is not selected

---


## Custom branch logic

```elm
ifTask : Task.Task Basics.Never (List Webdriver.Step.Step) -> Webdriver.Step.Step
```

Executes the list of steps returned as the result of performing a Task

---
```elm
ifDriverCommand : (Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error a)
    -> (a -> List Webdriver.Step.Step)
    -> Webdriver.Step.Step
```

Executes the list of steps resulting of executing a LowLevel Webdriver task. This allows you to create
custom sequences of tasks to be executed directly in the webdriver, maybe after getting
values from other tasks.

---
```elm
ifSequenceCommands : String
    -> List (Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error a)
    -> (List a -> List Webdriver.Step.Step)
    -> Webdriver.Step.Step
```

Executes the list of steps that result of executing a list of LowLevel Webdriver task. This allows you to create custom sequences of tasks to be executed directly in the webdriver, maybe after getting
values from other tasks.

    ifSequenceCommands "Custom cookie check"
        [Wd.getCookie "user", Wd.getCookie "legacy_user"]
        (\ (c :: lc :: []) -> [ setValue "#someInput" c, setValue "#anotherInput" lc ] )

---




---

#Webdriver.LowLevel

 Offers access to the webdriver.io js library

## Types

```elm
type Error
    = Error
    | MissingElement Webdriver.LowLevel.ErrorDetails (Webdriver.LowLevel.WithSelector {})
    | UnreachableElement Webdriver.LowLevel.ErrorDetails (Webdriver.LowLevel.WithScreenshot (Webdriver.LowLevel.WithSelector {}))
    | TooManyElements Webdriver.LowLevel.ErrorDetails (Webdriver.LowLevel.WithSelector {})
    | FailedElementPrecondition Webdriver.LowLevel.ErrorDetails (Webdriver.LowLevel.WithSelector {})
    | UnknownError Webdriver.LowLevel.ErrorDetails (Webdriver.LowLevel.WithScreenshot {})
    | InvalidCommand Webdriver.LowLevel.ErrorDetails {}
    | Never 
```

Possible errors

---
```elm
type Browser
    = Browser
```

Represents a Browser Window

---
```elm
type alias Options = 
  { desiredCapabilities : Webdriver.LowLevel.Capabilities }
```

Options for selenium

---
```elm
type alias Capabilities = 
  { browserName : String }
```

Browser capabilities

---


## Navigation

```elm
open : Webdriver.LowLevel.Options -> Task.Task Webdriver.LowLevel.Error ( String, Webdriver.LowLevel.Browser )
```

Opens a new browser window

---
```elm
url : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Visits the given url.

---
```elm
click : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Clicks the element after finding it with the given selector.

---
```elm
moveTo : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Moves the mouse to the middle of the specified element

---
```elm
moveToWithOffset : String
    -> Maybe.Maybe Int
    -> Maybe.Maybe Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Moves the mouse to the middle of the specified element. This function
takes two integers (offsetX and offsetY).

If offsetX has a value, move relative to the top-left corner of the element on the X axis
If offsetY has a value, move relative to the top-left corner of the element on the Y axis

---
```elm
close : Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Closes the current browser window

---
```elm
end : Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Ends the browser session

---
```elm
switchToFrame : Int -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Makes any future actions happen inside the frame specified by its index

---


# Forms

```elm
selectByIndex : String
    -> Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Selects the option in the dropdown using the option index

---
```elm
selectByValue : String
    -> String
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Selects the option in the dropdown using the option value

---
```elm
selectByText : String
    -> String
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Selects the option in the dropdown using the option visible text

---
```elm
setValue : String
    -> String
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Fills in the specified input with a value

---
```elm
appendValue : String
    -> String
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Appends to an input's value

---
```elm
clearValue : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Clears the value of the given input

---
```elm
submitForm : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Submits the form with the given selector

---


## History

```elm
back : Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Goes back in the browser history

---
```elm
forward : Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Goes forward in the browser history

---


## Waiting

```elm
waitForExist : String
    -> Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be present within the DOM

---
```elm
waitForNotExist : String
    -> Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be present absent from the DOM

---
```elm
waitForVisible : String
    -> Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be visible.

---
```elm
waitForNotVisible : String
    -> Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be invisible.

---
```elm
waitForValue : String
    -> Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be have a value.

---
```elm
waitForNoValue : String
    -> Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to have no value.

---
```elm
waitForSelected : String
    -> Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be selected.

---
```elm
waitForNotSelected : String
    -> Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to not be selected.

---
```elm
waitForText : String
    -> Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be have some text.

---
```elm
waitForNoText : String
    -> Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to have no text.

---
```elm
waitForEnabled : String
    -> Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be enabled.

---
```elm
waitForNotEnabled : String
    -> Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Wait for an element (selected by css selector) for the provided amount of
    milliseconds to be disabled.

---
```elm
pause : Int -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Pauses the browser session for the given milliseconds

---


## Scrolling

```elm
scrollToElement : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Scrolls the window to the element specified in the selector

---
```elm
scrollToElementOffset : String
    -> Int
    -> Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Scrolls the window to the element specified in the selector and then scrolls
the given amount of pixels as offset from such element

---
```elm
scrollWindow : Int
    -> Int
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Scrolls the window to the absolute coordinate (x, y) position provided in pixels

---


## Screenshots

```elm
pageScreenshot : Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error String
```

Takes a screenshot of the whole page and returns a base64 encoded png

---
```elm
savePageScreenshot : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Takes a screenshot of the whole page and saves it to a file

---
```elm
viewportScreenshot : Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error String
```

Takes a screenshot of the current viewport and returns a base64 encoded png

---


## Utilities

```elm
countElements : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error Int
```

Returns the count of elements matching the provided selector

---
```elm
triggerClick : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Programatically trigger a click in the elements specified in the selector.
This exists because some pages hijack in an odd way mouse click, and in order to test
the behavior, it needs to be manually triggered.

---


## Debugging

```elm
debug : Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Stops the running queue and gives you time to jump into the browser and
check the state of your application (e.g. using the dev tools). Once you are done
go to the command line and press Enter.

---


## Page properties

```elm
getUrl : Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error String
```

Returns the url for the current browser window

---
```elm
getPageHTML : Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error String
```

Returns the page HTML

---
```elm
getTitle : Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error String
```

Returns the current window title

---


## Element properties

```elm
getAttribute : String
    -> String
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error (Maybe.Maybe String)
```

Returns the value for the given attribute in the specified element by selector

---
```elm
getCssProperty : String
    -> String
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error (Maybe.Maybe String)
```

Returns the value for the given attribute in the specified element by selector

---
```elm
getElementSize : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error { width : Int, height : Int }
```

Returns the size of the give element

---
```elm
getElementHTML : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error String
```

Returns the HTML for the given element

---
```elm
getElementPosition : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error { x : Int, y : Int }
```

Returns the element's location on a page

---
```elm
getElementViewPosition : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error { x : Int, y : Int }
```

Determine an element’s location on the screen once it has been scrolled into view.

---
```elm
getText : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error String
```

Returns the text node for the given element

---
```elm
getValue : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error String
```

Returns the input element's current value

---
```elm
elementExists : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error Bool
```

Returns true if the element exists in the DOM

---
```elm
elementVisible : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error Bool
```

Returns true if the input element is visible

---
```elm
elementVisibleWithinViewport : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error Bool
```

Returns true if the input element is visible

---
```elm
elementEnabled : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error Bool
```

Returns true if the input element is enabled

---
```elm
optionIsSelected : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error Bool
```

Returns true if the select option specified in the element selector is selected

---


## Cokies

```elm
getCookie : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error (Maybe.Maybe String)
```

Returns the cookie value for the given cookie name

---
```elm
cookieExists : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error Bool
```

Returns true if the specified cookie is present

---
```elm
setCookie : String
    -> String
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error ()
```

Sets the value of a cookie

---
```elm
deleteCookie : String -> Webdriver.LowLevel.Browser -> Task.Task Webdriver.LowLevel.Error ()
```

Sets the value of a cookie

---


## Custom

```elm
customCommand : String
    -> List Json.Encode.Value
    -> Webdriver.LowLevel.Browser
    -> Task.Task Webdriver.LowLevel.Error Json.Encode.Value
```

Allows you to execute an arbitrary command in the client by a name. The return value
of the comand coms as a Json.Encode.Value.

    customCommand "windowHandleSize" [JE.string "dc30381e-e2f3-9444-8bf3-12cc44e8372a"] browser
