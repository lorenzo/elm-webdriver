var webdriverio = require('webdriverio');

var _lorenzo$webdriver$Native_Webdriver = function() {

  var nativeBinding = _elm_lang$core$Native_Scheduler.nativeBinding;
  var succeed = _elm_lang$core$Native_Scheduler.succeed;
  var fail = _elm_lang$core$Native_Scheduler.fail;
  var tuple2 = _elm_lang$core$Native_Utils.Tuple2;
  var unit = {ctor: '_Tuple0'};

  function unitReturningExecute(callback, promise, context) {
      promise.then(function (a) {
        callback(succeed(unit));
      })
      .catch(function (error) {
        handleError(error, callback, context);
      });
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
      client.url(address).getUrl()
        .then(function (url) {
          callback(succeed(url));
        })
        .catch(function (error) {
          client.close();
          callback(fail({
            ctor: 'ConnectionError',
            _0: {
              errorType: error.type,
              message: error.message,
            },
            _1: error.screenshot,
          }));
        })
    });
  }

  function click(selector, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.click(selector), {selector: selector});
    });
  }

  function close(client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.close(), {});
    });
  }


  function setValue(selector, value, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.setValue(selector, value), {selector: selector});
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

  function submitForm(selector, client) {
    return nativeBinding(function (c) {
      unitReturningExecute(c, client.submitForm(selector), {selector: selector});
    });
  }

  function handleError(error, callback, context) {
    var tag = {
      ctor: 'UnknownError',
      _0: {
        errorType: error.type,
        message: error.message
      }
    };

    switch (error.type) {
        case "NoSuchElement" :
            tag.ctor = 'MissingElement';
            tag._0 = Object.assign(tag._0, context);
            break;
        case "RuntimeError" :
            if (error.message.indexOf("Element is not clickable") === 0) {
              tag.ctor = 'UnreachableElement';
            }
            tag._0.screenshot = error.screenshot;
            tag._0 = Object.assign(tag._0, context);
    }

    callback(fail(tag));
  }

  return {
    open: open,
    url: F2(url),
    click: F2(click),
    close: close,
    setValue: F3(setValue),
    selectByIndex: F3(selectByIndex),
    selectByValue: F3(selectByValue),
    selectByText: F3(selectByText),
    submitForm: F2(submitForm),
  };
}();
