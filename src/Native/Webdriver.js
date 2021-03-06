var _lorenzo$elm_webdriver$Native_Webdriver = function() {
  var path = require('path');
  var fs = require('fs');
  var webdriverio = requireWebdriverio(process.cwd());

  var nativeBinding = _elm_lang$core$Native_Scheduler.nativeBinding;
  var succeed = _elm_lang$core$Native_Scheduler.succeed;
  var fail = _elm_lang$core$Native_Scheduler.fail;
  var tuple2 = _elm_lang$core$Native_Utils.Tuple2;
  var unit = {ctor: '_Tuple0'};
  var arrayFromList = _elm_lang$core$Native_List.toArray;

	function requireWebdriverio(cwd) {
		try {
			fs.accessSync(path.join(cwd, 'node_modules'));
			return require(path.resolve(cwd, 'node_modules', 'webdriverio'));
		} catch (e) {
			var lastSlashIndex = cwd.lastIndexOf('/');
      if (e.code === 'MODULE_NOT_FOUND' || lastSlashIndex === 0) {
        throw e;
			}
			var previousDir = cwd.slice(0, lastSlashIndex);
      return requireWebdriverio(previousDir);
		}
	}

  function catchPromise(callback, context, promise) {
      return promise.catch(function (error) {
        handleError(error, callback, context);
      });
  }

  function unitReturningExecute(callback, promise, context) {
      return catchPromise(callback, context, promise.then(function () {
        callback(succeed(unit));
      }));
  }

  function arity1ReturningExecute(callback, promise, context) {
      return catchPromise(callback, context, promise.then(function (a) {
        callback(succeed(a));
      }));
  }

  function maybeReturningExecute(callback, promise, context) {
      return catchPromise(callback, context, promise.then(function (a) {
        if (a !== null && typeof a === "object" && 'value' in a) {
          a = a.value;
        }

        if (a === null) {
          callback(succeed(_elm_lang$core$Maybe$Nothing));
        } else {
          callback(succeed(_elm_lang$core$Maybe$Just(a)));
        }
      }));
  }

  function open(options) {
    return nativeBinding(function (callback) {
      webdriverio.remote(options).init().then(function (browser) {
        callback(succeed(tuple2(browser.sessionId, this)));
      });
    });
  }

  function url(address, client) {
    return nativeBinding(function (callback) {
      var promise = client
        .url(address)
        .catch(function (error) {
          callback(fail({
            ctor: 'ConnectionError',
            _0: {
              errorType: error.type,
              message: error.message,
            },
            _1: error.screenshot,
          }));
        })
        unitReturningExecute(callback, promise, {});
    });
  }

  function click(selector, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.click(selector), {selector: selector});
    });
  }

  function moveToObjectWithOffset(selector, x, y, client) {
    if (x.ctor === "Nothing") {
      x = undefined;
    } else {
      x = x._0;
    }

    if (y.ctor === "Nothing") {
      y = undefined;
    } else {
      y = y._0;
    }

    return nativeBinding(function (c) {
      unitReturningExecute(c, client.moveToObject(selector, x, y), {selector: selector});
    });
  }

  function close(client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.close(), {});
    });
  }

  function debug(client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.debug(), {});
    });
  }

  function setValue(selector, value, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.setValue(selector, value), {selector: selector});
    });
  }

  function addValue(selector, value, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.addValue(selector, value), {selector: selector});
    });
  }

  function clearElement(selector, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.clearElement(selector), {selector: selector});
    });
  }

  function selectByIndex(selector, index, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.selectByIndex(selector, index), {selector: selector});
    });
  }

  function selectByValue(selector, value, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.selectByValue(selector, value), {selector: selector});
    });
  }

  function selectByText(selector, text, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.selectByVisibleText(selector, text), {selector: selector});
    });
  }

  function selectByAttribute(selector, attribute, value, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.selectByAttribute(selector, attribute, value), {selector: selector});
    });
  }

  function submitForm(selector, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.submitForm(selector), {selector: selector});
    });
  }

  function waitForExist(selector, ms, reverse, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.waitForExist(selector, ms, reverse), {selector: selector});
    });
  }

  function waitForVisible(selector, ms, reverse, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.waitForVisible(selector, ms, reverse), {selector: selector});
    });
  }

  function waitForText(selector, ms, reverse, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.waitForText(selector, ms, reverse), {selector: selector});
    });
  }


  function waitForSelected(selector, ms, reverse, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.waitForSelected(selector, ms, reverse), {selector: selector});
    });
  }

  function waitForValue(selector, ms, reverse, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.waitForValue(selector, ms, reverse), {selector: selector});
    });
  }

  function waitForEnabled(selector, ms, reverse, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.waitForEnabled(selector, ms, reverse), {selector: selector});
    });
  }

  function end(client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.end(), {});
    });
  }

  function pause(ms, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.pause(ms), {});
    });
  }

  function scrollToElement(selector, offsetX, offsetY, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.scroll(selector, x, y), {selector: selector});
    });
  }

  function scrollWindow(x, y, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.scroll(x, y), {});
    });
  }

  function pageScreenshot(client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.saveScreenshot().then(function (screenshot) {
        return screenshot.value;
      }), {});
    });
  }

  function savePageScreenshot(file, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.saveScreenshot(file), {});
    });
  }

  function viewportScreenshot(client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.screenshot().then(function (screenshot) {
        return screenshot.value;
      }), {});
    });
  }


  function frame(index, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.frame(index), {});
    });
  }

  function back(client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.back(), {});
    });
  }

  function forward(client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.forward(), {});
    });
  }

  function getUrl(client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.getUrl(), {});
    });
  }

  function getCookie(name, client) {
    return nativeBinding(function (c) {
      maybeReturningExecute(c, client.getCookie(name), {});
    });
  }

  function setCookie(name, value, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.setCookie({name: name, value: value}), {});
    });
  }

  function deleteCookie(name, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.deleteCookie(name), {});
    });
  }

  function getAttribute(selector, name, client) {
    return nativeBinding(function (c) {
      maybeReturningExecute(c, client.getAttribute(selector, name), {selector: selector});
    });
  }

  function getCssProperty(selector, name, client) {
    return nativeBinding(function (c) {
      maybeReturningExecute(c, client.getCssProperty(selector, name), {selector: selector});
    });
  }

  function getHTML(selector, client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.getHTML(selector), {selector: selector});
    });
  }

  function getSource(client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.getSource(), {});
    });
  }

  function getTitle(client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.getTitle(), {});
    });
  }

  function getText(selector, client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.getText(selector), {selector: selector});
    });
  }

  function getValue(selector, client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.getValue(selector), {selector: selector});
    });
  }

  function isExisting(selector, client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.isExisting(selector), {selector: selector});
    });
  }

  function isEnabled(selector, client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.isEnabled(selector), {selector: selector});
    });
  }

  function isVisible(selector, client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.isVisible(selector), {selector: selector});
    });
  }

  function isSelected(selector, client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.isSelected(selector), {selector: selector});
    });
  }

  function isVisibleWithinViewport(selector, client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.isVisibleWithinViewport(selector), {selector: selector});
    });
  }

  function triggerClick(selector, client) {
    return nativeBinding(function (c) {
      var promise = client.selectorExecute(selector, function (elements) {
        for (var i = 0; i < elements.length; i++) {
          elements[i].click();
        }
      });
      unitReturningExecute(c, promise, {selector: selector});
    });
  }

  function getElementSize(selector, client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.getElementSize(selector), {selector: selector});
    });
  }

  function getLocation(selector, client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.getLocation(selector), {selector: selector});
    });
  }

  function getLocationInView(selector, client) {
    return nativeBinding(function (c) {
      arity1ReturningExecute(c, client.getLocationInView(selector), {selector: selector});
    });
  }

  function countElements(selector, client) {
    return nativeBinding(function (c) {
      var promise = client.selectorExecute(selector, function (elements) {
        return elements.length;
      });
      arity1ReturningExecute(c, promise, {selector: selector});
    });
  }

  function customCommand(name, args, client) {
    return nativeBinding(function (c) {
      if (typeof client[name]  === "undefined") {
        return handleError({type: "InvalidCommand", "message" : "Unknown custom command: < " + name + " >"}, c,  {});
      }

      arity1ReturningExecute(c, client[name].call(client, args), {});
    });
  }

  function executeScriptArity0(script, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.execute(script), {});
    });
  }

  function chooseFile(selector, localPath, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.chooseFile(selector, localPath), {selector: selector});
    });
  }

  function buttonUp(button, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.buttonUp(button), {});
    });
  }

  function buttonDown(button, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.buttonDown(button), {});
    });
  }

  function windowResize(width, height, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.windowHandleSize({width: width, height: height}), {});
    });
  }

  function keys(keys, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.keys(arrayFromList(keys)), {});
    });
  }

  function handleError(error, callback, context) {
    var tag = {
      ctor: "UnknownError",
      _0: {
        errorType: error.type,
        message: error.message
      }
    };

    switch (error.type) {
        case "NoSuchElement" :
            tag.ctor = "MissingElement";
            context.selector = context.selector || "";
            break;

        case "WaitUntilTimeoutError" :
            tag.ctor = "FailedElementPrecondition";
            context.selector = context.selector || "";
            break;
        case "RuntimeError" :
            if (error.message.indexOf("Element is not clickable") === 0) {
              tag.ctor = "UnreachableElement";
            }
            context.selector = context.selector || "";
            tag._0.screenshot = error.screenshot;

        case "InvalidCommand" :
            tag.ctor = error.type;
    }

    tag._0 = Object.assign(tag._0, context);
    callback(fail(tag));
  }

  return {
    open: open,
    url: F2(url),
    click: F2(click),
    moveToObjectWithOffset: F4(moveToObjectWithOffset),
    close: close,
    debug: debug,
    setValue: F3(setValue),
    addValue: F3(addValue),
    clearValue: F2(clearElement),
    selectByIndex: F3(selectByIndex),
    selectByValue: F3(selectByValue),
    selectByText: F3(selectByText),
    selectByAttribute: F4(selectByAttribute),
    submitForm: F2(submitForm),
    setCookie: F3(setCookie),
    deleteCookie: F2(deleteCookie),
    waitForExist: F4(waitForExist),
    waitForValue: F4(waitForValue),
    waitForSelected: F4(waitForSelected),
    waitForText: F4(waitForText),
    waitForVisible: F4(waitForVisible),
    waitForEnabled: F4(waitForEnabled),
    end: end,
    pause: F2(pause),
    scrollToElement: F4(scrollToElement),
    scrollWindow: F3(scrollWindow),
    viewportScreenshot: viewportScreenshot,
    pageScreenshot: pageScreenshot,
    savePageScreenshot: F2(savePageScreenshot),
    frame: F2(frame),
    triggerClick: F2(triggerClick),
    back: back,
    forward: forward,
    getUrl: getUrl,
    getCookie: F2(getCookie),
    getAttribute: F3(getAttribute),
    getCssProperty: F3(getCssProperty),
    getHTML: F2(getHTML),
    getSource: getSource,
    getTitle: getTitle,
    getText: F2(getText),
    getValue: F2(getValue),
    isExisting: F2(isExisting),
    isEnabled: F2(isEnabled),
    isVisible: F2(isVisible),
    isVisibleWithinViewport: F2(isVisibleWithinViewport),
    isSelected: F2(isSelected),
    getElementSize: F2(getElementSize),
    getLocation: F2(getLocation),
    getLocationInView: F2(getLocationInView),
    countElements: F2(countElements),
    customCommand: F3(customCommand),
    executeScriptArity0: F2(executeScriptArity0),
    chooseFile: F3(chooseFile),
    buttonUp: F2(buttonUp),
    buttonDown: F2(buttonDown),
    windowResize: F3(windowResize),
    keys: F2(keys)
  };
}();
