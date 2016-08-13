# Elm Webdriver

Remote control a browser with selenium, in Elm!

This can be used as a testing suite or you can utilize the exposed
API for adapting it to your own use case.

## Quick Start

Since this package contains a `Native` module (some javascript), this cannot be published in
packages.elm-lang.org. Instead, you need to install it using npm. Do this at the root of your
Elm project, where the `elm-package.json` file is:

```
npm install elm-webdriver
```

You are now ready to copy some skeleton tests into your project folder:

```
node_modules/.bin/elm-webdriver init
```

This will create a new folder `webdriver-tests`. Change to that folder, where you will see a `Main.elm`
and a `Tests.elm` file. You can add your tests to `Tests.elm` without having to touch anything else!

If you need to use modules from your project, make sure you also add all the dependencies from the main
`elm-package.json` into `webdriver-tests/elm-package.json`. Rember to keep those in sync.

You are now ready to run your tests:

```
cd webdriver-tests
../node_modules/.bin/elm-webdriver
```

You can also filter tests by name:

```
../node_modules/.bin/elm-webdriver --filter "Some Test Name"
```

## API

Check the [API Docs](Api.md)
