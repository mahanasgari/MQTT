# Database Schema

**Engine**: PostgreSQL 15+
**Encoding**: UTF-8 (Unicode everywhere)

## Tables

### `users`

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `UUID` | PK, default `gen_random_uuid()` | |
| `phone` | `VARCHAR(20)` | UNIQUE, NOT NULL | E.164 format |
| `display_name` | `VARCHAR(100)` | | |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `deleted_at` | `TIMESTAMPTZ` | | Soft delete |

Index: `(phone)` UNIQUE.

### `otp_codes`

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `UUID` | PK | |
| `phone` | `VARCHAR(20)` | NOT NULL | |
| `code` | `VARCHAR(6)` | NOT NULL | |
| `expires_at` | `TIMESTAMPTZ` | NOT NULL | 5 min TTL |
| `used` | `BOOLEAN` | NOT NULL, default `false` | |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |

Index: `(phone, expires_at DESC)` — rate limiting lookups.

### `households`

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `UUID` | PK | |
| `name` | `VARCHAR(100)` | NOT NULL | |
| `timezone` | `VARCHAR(50)` | NOT NULL, default `'UTC'` | IANA tz |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `deleted_at` | `TIMESTAMPTZ` | | Soft delete |

### `household_members`

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `UUID` | PK | |
| `household_id` | `UUID` | FK → `households(id)` ON DELETE CASCADE | |
| `user_id` | `UUID` | FK → `users(id)` ON DELETE CASCADE | |
| `role` | `VARCHAR(20)` | NOT NULL, default `'admin'` | `admin` \| `member` |
| `joined_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |

Unique: `(household_id, user_id)`

### `devices`

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `UUID` | PK | |
| `serial` | `VARCHAR(50)` | UNIQUE, NOT NULL | Factory serial |
| `mac` | `VARCHAR(17)` | | MAC address |
| `device_type` | `VARCHAR(30)` | | e.g. `smart_plug` |
| `model` | `VARCHAR(50)` | | e.g. `SP-100` |
| `firmware_version` | `VARCHAR(20)` | | Reported by device |
| `name` | `VARCHAR(100)` | | User-given name |
| `household_id` | `UUID` | FK → `households(id)` ON DELETE SET NULL | Null until linked |
| `provisioned_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | First MQTT connect |
| `linked_at` | `TIMESTAMPTZ` | | When user links to household |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `deleted_at` | `TIMESTAMPTZ` | | Soft delete |

Index: `(serial)` UNIQUE.

### `device_states`

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `device_id` | `UUID` | PK, FK → `devices(id)` ON DELETE CASCADE | 1:1 with device |
| `power` | `VARCHAR(4)` | NOT NULL, default `'off'` | `on` \| `off` |
| `connectivity` | `VARCHAR(10)` | NOT NULL, default `'offline'` | `online` \| `offline` |
| `last_changed_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `last_seen_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | Last MQTT activity |
| `voltage` | `FLOAT` | | Future energy monitoring |
| `current` | `FLOAT` | | Future energy monitoring |
| `power_consumption` | `FLOAT` | | Watts, future monitoring |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |

### `device_events`

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `UUID` | PK | |
| `device_id` | `UUID` | FK → `devices(id)` ON DELETE CASCADE | |
| `type` | `VARCHAR(30)` | NOT NULL | See event types |
| `initiator` | `VARCHAR(20)` | NOT NULL | `user` \| `device` \| `system` |
| `initiator_id` | `UUID` | | User UUID if initiator=user |
| `metadata` | `JSONB` | | Arbitrary extra data |
| `occurred_at` | `TIMESTAMPTZ` | NOT NULL | Device-reported timestamp |

Indexes:
- `(device_id, occurred_at DESC)` — time-series queries
- `(occurred_at)` — global time-range scans

Event types: `power_on`, `power_off`, `device_online`, `device_offline`, `provisioned`, `linked`, `unlinked`

### `share_permissions`

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `UUID` | PK | |
| `granted_by` | `UUID` | FK → `users(id)` | |
| `grantee_phone` | `VARCHAR(20)` | NOT NULL | Phone of sharee |
| `grantee_user_id` | `UUID` | FK → `users(id)` NULL | Resolved when sharee registers |
| `scope` | `VARCHAR(20)` | NOT NULL | `household` \| `device` |
| `scope_id` | `UUID` | NOT NULL | Household or device UUID |
| `permission` | `VARCHAR(20)` | NOT NULL | `view` \| `control` \| `admin` |
| `status` | `VARCHAR(20)` | NOT NULL, default `'pending'` | `pending` \| `accepted` \| `declined` \| `revoked` |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `deleted_at` | `TIMESTAMPTZ` | | Soft delete |

Index: `(grantee_phone, status)` — incoming shares lookup.

### `pairing_tokens`

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `UUID` | PK | |
| `device_id` | `UUID` | FK → `devices(id)` ON DELETE SET NULL | Resolved after device connects |
| `token` | `VARCHAR(128)` | UNIQUE, NOT NULL | One-time-use pairing secret |
| `status` | `VARCHAR(20)` | NOT NULL, default `'pending'` | `pending` \| `used` \| `expired` |
| `expires_at` | `TIMESTAMPTZ` | NOT NULL | TTL for the pairing window |
| `used_at` | `TIMESTAMPTZ` | | When token was consumed |
| `metadata` | `JSONB` | | WiFi creds (encrypted), app version, etc. |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |

Purpose: Tracks the AP-based provisioning flow. App generates token before sending WiFi creds to device; device presents it when connecting to cloud to prove it owns the provisioning session.

### `device_network_config`

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `UUID` | PK | |
| `device_id` | `UUID` | FK → `devices(id)` ON DELETE CASCADE, UNIQUE | |
| `ip_address` | `VARCHAR(45)` | | IPv4 or IPv6 |
| `mac_address` | `VARCHAR(17)` | | |
| `wifi_ssid` | `VARCHAR(100)` | | Connected SSID |
| `wifi_rssi` | `INTEGER` | | Signal strength in dBm |
| `gateway_ip` | `VARCHAR(45)` | | |
| `firmware_version` | `VARCHAR(20)` | | Last reported version |
| `last_seen_at` | `TIMESTAMPTZ` | | Last MQTT activity |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |

Purpose: Live network metadata for the device. Updated on each MQTT birth message or state report.

### `automation_rules` (future)

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `UUID` | PK | |
| `home_id` | `UUID` | FK → `households(id)` ON DELETE CASCADE | |
| `name` | `VARCHAR(100)` | NOT NULL | |
| `enabled` | `BOOLEAN` | NOT NULL, default `true` | |
| `trigger_type` | `VARCHAR(50)` | NOT NULL | `schedule` \| `device_state` \| `time` |
| `trigger_config` | `JSONB` | NOT NULL | Rule-specific trigger params |
| `action_type` | `VARCHAR(50)` | NOT NULL | `control_device` \| `notification` |
| `action_config` | `JSONB` | NOT NULL | Rule-specific action params |
| `created_by` | `UUID` | FK → `users(id)` | |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `deleted_at` | `TIMESTAMPTZ` | | Soft delete |

Index: `(home_id)` — list rules for a household.

### `schedules` (future)

| Column | Type | Constraints | Notes |
|---|---|---|---|
| `id` | `UUID` | PK | |
| `device_id` | `UUID` | FK → `devices(id)` ON DELETE CASCADE | |
| `enabled` | `BOOLEAN` | NOT NULL, default `true` | |
| `cron_expression` | `VARCHAR(100)` | NOT NULL | e.g. `0 8 * * *` |
| `action` | `VARCHAR(10)` | NOT NULL | `on` \| `off` \| `toggle` |
| `timezone` | `VARCHAR(50)` | NOT NULL, default `'UTC'` | |
| `created_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `updated_at` | `TIMESTAMPTZ` | NOT NULL, default `NOW()` | |
| `deleted_at` | `TIMESTAMPTZ` | | Soft delete |

Index: `(device_id)` — list schedules for a device.

## Entity Relationships

```
users 1──N household_members N──1 households
users 1──N share_permissions
users 1──N device_events (initiator)
users 1──N automation_rules (creator)

households 1──N devices
households 1──N household_members
households 1──N share_permissions (via scope)
households 1──N automation_rules

devices 1──1 device_states
devices 1──N device_events
devices 1──1 device_network_config
devices 1──N pairing_tokens
devices 1──N share_permissions (via scope)
devices 1──N schedules
```

## Notes
- All timestamps are `TIMESTAMPTZ` (PostgreSQL timezone-aware).
- Soft delete (`deleted_at`) on: `users`, `households`, `devices`, `share_permissions`, `automation_rules`, `schedules`.
- No soft delete on: `otp_codes` (short-lived), `household_members` (cascade-managed), `device_states` (1:1 current state), `device_events` (immutable log), `pairing_tokens` (status lifecycle), `device_network_config` (latest snapshot).
- Device events are append-only, never mutated after insert.
- `device_states` is the current (materialized) view; `device_events` is the full history.
- Rate limiting on OTP uses `(phone, expires_at DESC)` index; cleanup job deletes expired rows periodically.
- `automation_rules` and `schedules` are schema-only placeholders for future features.
- The ORM attribute for `device_events.metadata` and `pairing_tokens.metadata` is `payload` (to avoid SQLAlchemy reserved name conflict). The database column name remains `metadata`.
