use std::io::{self, BufReader, Read};

use serde::Deserialize;
use serde_json::Result;
use discord_sdk::{self as ds};
use tokio;
use tracing_subscriber::fmt::writer::BoxMakeWriter;

const APP_ID: ds::AppId = 1267357061495128074;

#[derive(Deserialize, Debug)]
struct PresenceData{
    playing: bool,
    title: String,
    connection: bool,
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
    let mut displayed = false;

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
        
        if !data.connection {
            break;
        }
        if data.playing { 
            let rp = ds::activity::ActivityBuilder::default()
                .state(&data.title);
        
            tracing::info!(
                "updated activity: {:?}",
                client.discord.update_activity(rp).await
            );

            displayed = true;
        } else if !data.playing && displayed {
            tracing::info!(
                "cleared activity: {:?}",
                client.discord.clear_activity().await
            );

            displayed = false;
        }
    }

    tracing::info!(
        "cleared activity: {:?}",
        client.discord.clear_activity().await
    );
    
    client.discord.disconnect().await;

    Ok(())
}