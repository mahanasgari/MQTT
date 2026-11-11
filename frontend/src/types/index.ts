// --------------- Auth ---------------
export interface SendOtpRequest {
  phone: string;
}
export interface SendOtpResponse {
  expires_in_seconds: number;
  retry_after_seconds: number;
}
export interface VerifyOtpRequest {
  phone: string;
  code: string;
}
export interface TokenResponse {
  access_token: string;
  refresh_token: string;
  expires_in: number;
}
export interface RefreshTokenRequest {
  refresh_token: string;
}

// --------------- Households ---------------
export interface HouseholdCreate {
  name: string;
  timezone?: string;
}
export interface HouseholdUpdate {
  name?: string;
  timezone?: string;
}
export interface HouseholdResponse {
  id: string;
  name: string;
  timezone: string;
  role: string;
  device_count: number;
  created_at: string;
}
export interface HouseholdListResponse {
  households: HouseholdResponse[];
}

// --------------- Devices ---------------
export interface DeviceStateResponse {
  power: string;
  connectivity: string;
  last_changed_at: string;
  last_seen_at: string;
}
export interface DeviceFullStateResponse extends DeviceStateResponse {
  voltage: number | null;
  current: number | null;
  power_consumption: number | null;
}
export interface DeviceResponse {
  id: string;
  serial: string;
  name: string | null;
  household_id: string | null;
  firmware_version: string | null;
  state: DeviceStateResponse | null;
  created_at: string;
}
export interface DeviceListResponse {
  devices: DeviceResponse[];
}
export interface DeviceUpdate {
  name?: string;
}
export interface DeviceRegisterRequest {
  serial: string;
  token: string;
  name?: string;
}
export interface ProvisionPairingTokenRequest {
  household_id?: string;
  serial?: string;
}
export interface DeviceLinkRequest {
  household_id: string;
  name?: string;
}
export interface DeviceControlRequest {
  command: string;
  value: string;
}
export interface DeviceSimulateRequest {
  power?: string;
  connectivity?: string;
}
export interface LocalTestDeviceRequest {
  name?: string;
  household_id?: string;
}
export interface StatusResponse {
  status: string;
}

export interface DeviceEventResponse {
  id: string;
  device_id: string;
  type: string;
  initiator: string;
  initiator_id: string | null;
  metadata: Record<string, unknown> | null;
  occurred_at: string;
}
export interface DeviceEventListResponse {
  events: DeviceEventResponse[];
  total: number;
}

// --------------- Shares ---------------
export interface ShareCreate {
  target_phone: string;
  scope: string;
  scope_id: string;
  permission: string;
}
export interface ShareResponse {
  id: string;
  grantee_phone: string;
  scope: string;
  scope_id: string;
  permission: string;
  status: string;
  created_at: string;
}
export interface ShareListResponse {
  shares: ShareResponse[];
}
export interface ShareUpdate {
  status: string;
}
export interface SharedUserResponse {
  id: string;
  grantee_phone: string;
  permission: string;
  status: string;
  created_at: string;
}
export interface SharedUserListResponse {
  shares: SharedUserResponse[];
}

// --------------- WebSocket ---------------
export interface WsMessage {
  type: string;
  device_id?: string;
  device_ids?: string[];
  data?: Record<string, unknown>;
  message?: string;
}

// --------------- Pairing Token ---------------
export interface PairingTokenResponse {
  id: string;
  token: string;
  status: string;
  expires_at: string;
}

// --------------- Admin ---------------
export interface AdminStatsResponse {
  users: number;
  households: number;
  devices: number;
  devices_online: number;
  devices_linked: number;
}
export interface AdminUserResponse {
  id: string;
  phone: string;
  display_name: string | null;
  is_platform_admin: boolean;
  created_at: string;
}
export interface AdminUserListResponse {
  users: AdminUserResponse[];
  total: number;
}
export interface AdminDeviceListResponse {
  devices: DeviceResponse[];
  total: number;
}
export interface AdminHouseholdResponse {
  id: string;
  name: string;
  timezone: string;
  member_count: number;
  device_count: number;
  created_at: string;
}
export interface AdminHouseholdListResponse {
  households: AdminHouseholdResponse[];
  total: number;
}
export interface AdminDeviceCreateRequest {
  serial: string;
  name?: string;
  model?: string;
  mac?: string;
}
export interface AdminDeviceUpdateRequest {
  name?: string;
  household_id?: string;
  unlink?: boolean;
  soft_delete?: boolean;
}
export interface AdminPairingTokenRequest {
  serial?: string;
  household_id?: string;
}
export interface AdminEventListResponse {
  events: DeviceEventResponse[];
  total: number;
}
