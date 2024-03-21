extern crate reqwest;
use serde::{Deserialize, Serialize};
use std::{env, fs, error::Error};

// Структура для чтения конфигурационного файла
#[derive(Debug, Deserialize)]
struct Config {
    admins: Vec<i64>,
    users: Vec<i64>,
    token: String,
}

// Для сериализации сообщений, отправляемых в Telegram
#[derive(Serialize)]
struct SendMessage {
    chat_id: i64,
    text: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    // Загрузка конфигурации
    let config_path = env::var("CONFIG_FILE").unwrap_or("config.json".to_string());
    let config_contents = fs::read_to_string(config_path)?;
    let config: Config = serde_json::from_str(&config_contents)?;

    let telegram_token = config.token;

    // Считываем аргументы командной строки
    let notify = env::args().nth(1).expect("Expected 'users' or 'admins'");
    let message_text = env::args().nth(2).expect("Expected message text");

    // Создаем HTTP-клиент
    let client = reqwest::Client::new();

    // Определяем, кому отправлять сообщения, и отправляем их
    match notify.as_str() {
        "users" => {
            for user_id in &config.users {
                send_message(&client, &telegram_token, *user_id, &message_text).await?;
            }
        },
        "admins" => {
            for admin_id in &config.admins {
                send_message(&client, &telegram_token, *admin_id, &message_text).await?;
            }
        },
        _ => eprintln!("Unknown argument. Expected 'users' or 'admins'."),
    }

    Ok(())
}

// Функция для отправки сообщений
async fn send_message(
    client: &reqwest::Client,
    token: &str,
    chat_id: i64,
    message: &str,
) -> Result<(), Box<dyn Error>> {
    let url = format!("https://api.telegram.org/bot{}/sendMessage", token);

    // Создание сообщения
    let message = SendMessage {
        chat_id,
        text: message.to_string(),
    };

    // Отправка POST-запроса
    let response = client.post(&url)
        .json(&message)
        .send()
        .await?;

    // Проверяем успешность запроса (опционально)
    if response.status().is_success() {
        println!("Message sent to {}", chat_id);
    } else {
        eprintln!("Failed to send message to {}: {:?}", chat_id, response.text().await?);
    }

    Ok(())
}
