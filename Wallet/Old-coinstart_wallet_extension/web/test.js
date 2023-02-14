chrome.runtime.sendMessage({ type: "show" }, (response) => {
    if (response && response.hasOwnProperty("runtime")) {
        if (response.runtime) {
            console.log("send show success!");
            console.log(response);
        }
    }
});

