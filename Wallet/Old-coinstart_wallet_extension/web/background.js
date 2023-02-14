// 定义颜色
let color = '#3aa757';

// 后台监听事件消息
// 如果manifest.json未配置 action.default_popup，点击扩展按钮会触发此事件
chrome.action.onClicked.addListener(function (tab) {
     console.log("You are on tab:" + tab.id);
    chrome.action.setTitle({ tabId: tab.id, title: "You are on tab:" + tab.id });
});


// 后台监听事件消息
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {

     console.log("on message", message);


    let requestType = message.type;

    switch (requestType) {
        // 检测是否是扩展开启状态
        case "checkFlag":
            sendResponse({ "runtime": true });
            break;

        // 开始学习
        case "startRun":
            sendResponse({ "complete": 1 });
            break;

        case "show":
            sendResponse({ "runtime": true });
             break;
    }
});


// 插件安装监听事件
chrome.runtime.onInstalled.addListener(() => {

    console.log("chrome extension is install.");

    chrome.storage.sync.set({ color });
     console.log('插件默认颜色为: %c #3aa757', `color: ${color}`);
});


// For simple requests:
chrome.runtime.onMessageExternal.addListener(
  function(request, sender, sendResponse) {
  console.log("chrome1.");
    if (sender.id == blocklistedExtension)
      return;  // don't allow this extension access
    else if (request.getTargetData)
      sendResponse({targetData: targetData});
    else if (request.activateLasers) {
      var success = activateLasers();
      sendResponse({activateLasers: success});
    }
  });

// For long-lived connections:
chrome.runtime.onConnectExternal.addListener(function(port) {
  port.onMessage.addListener(function(msg) {
  console.log("chrome2");
    // See other examples for sample onMessage handlers.
  });
});