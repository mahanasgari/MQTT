from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    DATABASE_URL: str = "postgresql+asyncpg://smartplug:smartplug@localhost:5433/smartplug"
    SECRET_KEY: str = "change-me"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    ENVIRONMENT: str = "development"
    CORS_ORIGINS: str = "*"
    LOG_LEVEL: str = "INFO"
    APP_VERSION: str = "0.1.0"

    MQTT_BROKER_HOST: str = "localhost"
    MQTT_BROKER_PORT: int = 1883
    MQTT_CLIENT_ID: str = "smartplug-backend"
    MQTT_USERNAME: str = ""
    MQTT_PASSWORD: str = ""
    MQTT_RECONNECT_DELAY_MIN: int = 1
    MQTT_RECONNECT_DELAY_MAX: int = 60

    OTP_LENGTH: int = 6
    OTP_EXPIRE_SECONDS: int = 300
    OTP_RETRY_AFTER_SECONDS: int = 60

    REQUIRE_PREREGISTERED_SERIAL: bool = False
    PAIRING_TOKEN_PROVISION_TTL_HOURS: int = 24

    PLATFORM_ADMIN_PHONES: str = ""


settings = Settings()
