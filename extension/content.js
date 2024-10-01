const GETINFO_INTERVAL = 500;

const TITLE_CLASS_NAME = "pauseInfoTxt1";
const EPISODES_CLASS_NAME = "pauseInfoTxt2";
const TIME_CLASS_NAME = "time";
const TIME_ID_NAME = "#time";
const VIDEO_TAG_NAME = "video";

const TYPE_STOPPED = 0;
const TYPE_PLAYING = 1;
let type_now = TYPE_STOPPED;

let is_displayed = false;
let prev_time = null;

// generateUUID
const UUID = crypto.randomUUID()


function getInfo() {
    let data = new Object();
    data.uuid = UUID;
    data.data = new Object();

    // playing?
    const videoElement = document.getElementsByTagName(VIDEO_TAG_NAME)[0];
    if (!videoElement) {
        console.log("Couldn't get playing status");
        data.type = 0;
        return data;
    } else {
        let playing = !Boolean(videoElement.paused);
        if (type_now === TYPE_STOPPED && playing) {
            type_now = TYPE_PLAYING;
            data.type = 2;
            return data;
        } else if (type_now === TYPE_PLAYING && !playing) {
            type_now = TYPE_STOPPED;
            data.type = 4;
            is_displayed = false;
            return data;
        } else if (type_now === TYPE_STOPPED && !playing) {
            return null;
        }
    }
    
    // title and episodes
    data.type = 3;
    const titleElement = document.getElementsByClassName(TITLE_CLASS_NAME)[0];
    const episodeElement = document.getElementsByClassName(EPISODES_CLASS_NAME)[0];
    const timeElement = document.getElementsByClassName(TIME_CLASS_NAME)[0];
    if (!titleElement || !episodeElement || !timeElement) {
        console.log("Couldn't get title or eipsodes or time");
    } else {
        const title = titleElement.textContent;
        const episodes = episodeElement.textContent;
        const time = timeElement.querySelector(TIME_ID_NAME).textContent;
        const time_splited = time.split(" / ");
        if (time_splited[0].split(":").length === 2) {
            time_splited[0] = "00:" + time_splited[0];
        }

        data.is_displayed = is_displayed;
        data.data.title = title;
        data.data.episodes = episodes;
        data.data.current_time = time_splited[0];
        data.data.total_duration = time_splited[1];

        if (!prev_time) {
            is_displayed = true;
        } else {
            [hours, minutes, seconds] = prev_time.split(":").map(Number);
            prev_sec = hours * 3600 + minutes * 60 + seconds;
            [hours, minutes, seconds] = data.data.current_time.split(":").map(Number);
            now_sec = hours * 3600 + minutes * 60 + seconds;
            if (Math.abs(now_sec - prev_sec) > 3) {
                is_displayed = false;
            } else {
                is_displayed = true;
            }
        }
        prev_time = data.data.current_time;
    }
    
    return data;
}

// send message to background
const sendMessage = () => {
    let data = getInfo();
    if (!data) {
        console.log("here");
        return; 
    }
    chrome.runtime.sendMessage(data, (response) => true);
}

// sendMessage per 1 second
setInterval(sendMessage, GETINFO_INTERVAL);

// register to background.js
window.addEventListener("load", () => {
    chrome.runtime.sendMessage({
        "type": 1,
        "uuid": UUID,
    }, (response) => true);
})

// remove from background.js
window.addEventListener("beforeunload", () => {
    chrome.runtime.sendMessage({
        "type": 5,
        "uuid": UUID,
    }, (response) => true);
});