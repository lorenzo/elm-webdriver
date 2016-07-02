var webdriverio = require('webdriverio');

var _lorenzo$webdriver$Native_Webdriver = function() {

  var nativeBinding = _elm_lang$core$Native_Scheduler.nativeBinding;
  var succeed = _elm_lang$core$Native_Scheduler.succeed;
  var fail = _elm_lang$core$Native_Scheduler.fail;
  var tuple2 = _elm_lang$core$Native_Utils.Tuple2;

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
    return nativeBinding(function (callback) {
      client.click(selector).then(function (a) {
        callback(succeed("a"));
      })
      .catch(function (error) {
        handleError(error, callback, {selector: selector});
        client.close();
      })
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
    click: F2(click)
  };
}();
