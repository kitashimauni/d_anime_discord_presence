const GETINFO_INTERVAL = 1000

const TITLE_CLASS_NAME = "pauseInfoTxt1";
const EPISODES_CLASS_NAME = "pauseInfoTxt2";
const VIDEO_TAG_NAME = "video";

function getInfo() {
    let data = new Object();

    // playing?
    const videoElement = document.getElementsByTagName(VIDEO_TAG_NAME)[0];
    if (!videoElement) {
        console.log("Couldn't get playing status");
    } else {
        data.playing = !Boolean(videoElement.paused)
    }

    // title and episodes
    const titleElement = document.getElementsByClassName(TITLE_CLASS_NAME)[0];
    const episodeElement = document.getElementsByClassName(EPISODES_CLASS_NAME)[0];
    if (!titleElement || !episodeElement) {
        console.log("Couldn't get title or eipsodes");
    } else {
        const title = titleElement.textContent;
        const episodes = episodeElement.textContent;
        data.title = title + " " + episodes
    }

    data.connection = true;

    // return data
    return data
}

// send message to background
const sendMessage = () => {
    let data = getInfo();
    chrome.runtime.sendMessage(data, (response) => true);
}

// sendMessage per 1 second
setInterval(sendMessage, GETINFO_INTERVAL);

// disconnect when close tab
window.addEventListener("beforeunload", () => {
    chrome.runtime.sendMessage({"playing": false, "title": "", "connection": false}, (response) => true);
})