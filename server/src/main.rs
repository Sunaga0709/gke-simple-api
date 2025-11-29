use axum::Router;
use axum::extract::{Json, State};
use axum::response::IntoResponse;
use axum::routing::get;
use chrono::Utc;
use serde::Serialize;
use tokio::net::TcpListener;
use tokio::signal;

use std::sync::Arc;

#[tokio::main(flavor = "multi_thread")]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let port = std::env::var("PORT").unwrap_or("7878".to_string());
    let host_name = std::env::var("HOSTNAME").unwrap_or("unknown".to_string());
    let pod_ip = std::env::var("POD_IP").unwrap_or("unknown".to_string());
    let node_name = std::env::var("NODE_NAME").unwrap_or("unknown".to_string());
    let sample_env = std::env::var("SAMPLE_ENV").unwrap_or("unknown".to_string());
    let sample_secret = std::env::var("SAMPLE_SECRET").unwrap_or("unknown".to_string());
    let start_at = Utc::now().to_string();

    let handler = Arc::new(Handler {
        host_name,
        pod_ip,
        port: port.clone(),
        node_name,
        sample_env,
        sample_secret,
        start_at,
    });
    let router = Router::new()
        .route("/healthcheck", get(healthcheck))
        .route("/", get(simple_handler))
        .with_state(handler);
    let listener = TcpListener::bind(format!("0.0.0.0:{}", port))
        .await
        .unwrap();

    axum::serve(listener, router)
        .with_graceful_shutdown(shutdown_signal())
        .await
        .unwrap();

    Ok(())
}

async fn shutdown_signal() {
    let ctrl_c = async {
        signal::ctrl_c()
            .await
            .expect("failed to install Ctrl+C handler");
    };

    #[cfg(unix)]
    let terminate = async {
        signal::unix::signal(signal::unix::SignalKind::terminate())
            .expect("failed to install signal handler")
            .recv()
            .await;
    };

    #[cfg(not(unix))]
    let terminate = std::future::pending::<()>();

    tokio::select! {
        _ = ctrl_c => {},
        _ = terminate => {},
    }

    eprintln!("shutdown signal received");
}

#[derive(Clone, Debug, Serialize)]
struct HealthcheckResponse {
    message: String,
}

async fn healthcheck() -> impl IntoResponse {
    Json(HealthcheckResponse {
        message: "ok".to_string(),
    })
}

#[derive(Clone, Debug)]
struct Handler {
    host_name: String,
    pod_ip: String,
    port: String,
    node_name: String,
    sample_env: String,
    sample_secret: String,
    start_at: String,
}

async fn simple_handler(state: State<Arc<Handler>>) -> impl IntoResponse {
    Json(SimpleResponse {
        host_name: state.host_name.clone(),
        pod_ip: state.pod_ip.clone(),
        port: state.port.clone(),
        node_name: state.node_name.clone(),
        sample_env: state.sample_env.clone(),
        sample_secret: state.sample_secret.clone(),
        start_at: state.start_at.clone(),
        version: "v2".to_string(),
    })
}

#[derive(Clone, Debug, Serialize)]
struct SimpleResponse {
    host_name: String,
    pod_ip: String,
    port: String,
    node_name: String,
    sample_env: String,
    sample_secret: String,
    start_at: String,
    version: String,
}
