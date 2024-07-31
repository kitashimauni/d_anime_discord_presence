const GETINFO_INTERVAL = 500;

const TITLE_CLASS_NAME = "pauseInfoTxt1";
const EPISODES_CLASS_NAME = "pauseInfoTxt2";
const TIME_CLASS_NAME = "time";
const TIME_ID_NAME = "#time";
const VIDEO_TAG_NAME = "video";

function getInfo() {
    let data = new Object();

    // playing?
    const videoElement = document.getElementsByTagName(VIDEO_TAG_NAME)[0];
    if (!videoElement) {
        console.log("Couldn't get playing status");
    } else {
        data.playing = !Boolean(videoElement.paused);
    }

    // title and episodes
    const titleElement = document.getElementsByClassName(TITLE_CLASS_NAME)[0];
    const episodeElement = document.getElementsByClassName(EPISODES_CLASS_NAME)[0];
    const timeElement = document.getElementsByClassName(TIME_CLASS_NAME)[0];
    if (!titleElement || !episodeElement || !timeElement) {
        console.log("Couldn't get title or eipsodes or time");
    } else {
        const title = titleElement.textContent;
        const episodes = episodeElement.textContent;
        const time = timeElement.querySelector(TIME_ID_NAME).textContent;
        data.title = title + " " + episodes;
        data.time = time;
    }

    data.connection = true;

    // return data
    return data;
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
    chrome.runtime.sendMessage({
        "playing": false,
        "title": "",
        "time": "",
        "connection": false
    }, (response) => true)
});