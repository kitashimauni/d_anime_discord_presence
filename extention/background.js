let isNativeConnected = false;
let port = {};

function assertNative() {
    if (!isNativeConnected) {
        if (port.disconnect) port.disconnect();
        port = chrome.runtime.connectNative("com.dadp.discord.presence");
        isNativeConnected = true;
        port.onDisconnect.addListener(() => {
            if (chrome.runtime.lastError) {
                isNativeConnected = false;
                console.log("Couldn't connect to native app");
                console.log(chrome.runtime.lastError);
            }
            console.log("Disconnect")
        })
    }
}

chrome.runtime.onMessage.addListener((data) => {
    console.log("get message");
    console.log(data);
    if (!isNativeConnected) assertNative();
    if (isNativeConnected) {
        port.postMessage(data);
        if (!data.connection) {
            port.disconnect();
            isNativeConnected = false
        }
    }
    return true;
})