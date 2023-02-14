
function injectDappInterface() {
  const script = document.createElement("script");
  const url = chrome.runtime.getURL("coinstart.js");
  script.setAttribute("src", url);
  script.setAttribute("type", "module");
  const container = document.head || document.documentElement;
  container.insertBefore(script, container.firstElementChild);
}


(function () {
  'use strict';

  (async () => {
    console.log(233);
    console.log(chrome.tabs);
    injectDappInterface();

  })().catch(console.error);

})();
