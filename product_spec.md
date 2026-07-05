# Product Specification — Smart Plug Platform

## 1. Overview
Commercial IoT smart-plug platform. Customers buy physical smart plugs, register them via phone number, and control them through a mobile app (Flutter) or web dashboard (Next.js). System must support multiple device models, multiple households per customer, and shared access.

## 2. Target users
- **Customer**: owns one or more devices, registered by phone number
- **Sharee**: granted access to a device by a customer (also phone-number identified)

## 3. Entities

| Entity | Description |
|---|---|
| User | Person identified by phone number. Can own households and devices. |
| Household | Logical grouping of devices under one roof. A user may have 1+ households. |
| Device | A physical smart plug. Belongs to one household. Has a unique serial number (from factory). |
| SharePermission | Grants a phone number access to a household or device. |

## 4. Features (v1)

### Device provisioning
1. User creates account via phone OTP.
2. User puts plug in AP mode (existing firmware behavior).
3. App connects to plug's AP, sends home WiFi credentials.
4. Plug connects to home WiFi and cloud MQTT.
5. Plug registers with backend (serial → device record).
6. User links plug to their household.

### Device control
- ON / OFF toggle via app or web.
- Future extensibility: scheduled ON/OFF, automations (rule engine).

### Real-time state
- Device reports: `power_state` (ON/OFF), `connectivity` (online/offline), `last_changed_at` (UTC).
- State pushed via MQTT → backend → WebSocket to clients.
- State also available via REST.

### Event history
Immutable log of every state transition:
- `power_on`, `power_off`
- `device_online`, `device_offline`
- Stored with timestamp, includes initiator (user, device, or system).

### Sharing
- Share a device or household with another phone number.
- Permission levels: `view` (read state), `control` (send commands), `admin` (manage shares).
- Revocable at any time.

## 5. Non-goals (explicitly excluded in v1)
- Email/password or social auth
- Firmware OTA updates (handled by existing firmware)
- Billing, subscription, or payment integration
- Third-party integrations (Alexa, Google Home, HomeKit)
- Device groups, scenes, or routines
- Analytics dashboards

## 6. Future (explicitly deferred)
- Scheduled / timer commands
- Rule-based automation engine
- Multi-protocol gateway (Zigbee, Z-Wave)
- Energy monitoring
- OTA firmware management
