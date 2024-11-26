use std::io::{self, BufReader, Read};

use chrono::{Duration, Local};
use serde::Deserialize;
use serde_json::Result;
use discord_sdk::{self as ds,};
use tokio;
use tracing_subscriber::fmt::writer::BoxMakeWriter;

const APP_ID: ds::AppId = 1267357061495128074;
const UPDATE_MESSAGE: &str = "3";
const CLAER_MESSAGE: &str = "4";
const DISCONNECT_MESSAGE: &str = "5";

#[derive(Deserialize, Debug)]
struct PresenceData{
    message_type: String,
    title: String,
    episodes: String,
    current_time: String,
    total_duration: String,
}

struct Client{
    discord: ds::Discord,
    user: ds::user::User,
    wheel: ds::wheel::Wheel,
}

async fn make_client() -> Client {
    tracing_subscriber::fmt()
        .compact()
        .with_max_level(tracing::Level::TRACE)
        .with_writer(BoxMakeWriter::new(std::io::stderr))
        .init();

    let (wheel, handler) = ds::wheel::Wheel::new(Box::new(|err| {
        tracing::error!(error = ?err, "encountered an error");
    }));

    let mut user = wheel.user();

    let discord = ds::Discord::new(
        ds::DiscordApp::PlainId(APP_ID),
        ds::Subscriptions::ACTIVITY, 
        Box::new(handler))
        .expect("unable to create discord client");

    tracing::info!("waiting for handshake...");
    user.0.changed().await.unwrap();

    let user = match &*user.0.borrow() {
        ds::wheel::UserState::Connected(user) => user.clone(),
        ds::wheel::UserState::Disconnected(err) => panic!("failed to connect Discord {}", err),
    };

    tracing::info!("connected to Discord, local user is {:#?}", user);

    Client {
        discord,
        user,
        wheel,
    }
}

fn parse_time_string(time_str: &str) -> Duration {
    // Split time_str into hours, minutes, seconds
    let parts: Vec<&str> = time_str.split(':').collect();
    
    // Handle different time formats (HH:MM:SS or MM:SS)
    let (hours, minutes, seconds) = match parts.len() {
        3 => (
            parts[0].parse::<i64>().unwrap_or(0), // hours
            parts[1].parse::<i64>().unwrap_or(0), // minutes
            parts[2].parse::<i64>().unwrap_or(0), // seconds
        ),
        _ => (0, 0, 0), // default to zero if format is invalid
    };
    
    // Create a Duration from the parsed values
    Duration::seconds(hours * 3600 + minutes * 60 + seconds)
}

#[tokio::main]
async fn main() -> Result<()>{
    // Make client
    let client = make_client().await;
    
    let mut activity_events = client.wheel.activity();

    tokio::task::spawn(async move {
        while let Ok(ae) = activity_events.0.recv().await {
            tracing::info!(event = ?ae, "received activity event");
        }
    });

    let stdin = io::stdin();
    let mut reader = BufReader::new(stdin.lock());

    loop {
        // read JSON length
        let mut length_buffer = [0u8; 4];
        if reader.read_exact(&mut length_buffer).is_err() {
            break;
        }
        let data_length = u32::from_le_bytes(length_buffer) as usize;
        
        // read JSON data
        let mut json_buffer = vec![0u8; data_length];
        let _ = reader.read_exact(&mut json_buffer);
        
        let input = String::from_utf8(json_buffer).expect("Invalid UTF-8 data");
        
        let data: PresenceData = serde_json::from_str(&input).expect("Invalid JSON data");

        if data.message_type == CLAER_MESSAGE {
            tracing::info!(
                "cleared activity: {:?}",
                client.discord.clear_activity().await
            );
            continue;
        } else if data.message_type == DISCONNECT_MESSAGE {
            break;
        } else if data.message_type == UPDATE_MESSAGE {
            let rp = ds::activity::ActivityBuilder::default()
                .assets(
                    ds::activity::Assets::default().large("presence_icon", Some("Watching anime")),
                )
                .kind(ds::activity::ActivityKind::Watching)
                .details(&data.title)
                .state(format!("{} / {}", &data.episodes, &data.total_duration))
                .start_timestamp((Local::now() - parse_time_string(&data.current_time)).timestamp());
    
            tracing::info!(
                "updated activity: {:?}",
                client.discord.update_activity(rp).await
            );
        }
    }

    tracing::info!(
        "cleared activity: {:?}",
        client.discord.clear_activity().await
    );
    
    client.discord.disconnect().await;

    Ok(())
}