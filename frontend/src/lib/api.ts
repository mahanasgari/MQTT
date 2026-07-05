import type {
  SendOtpRequest,
  SendOtpResponse,
  VerifyOtpRequest,
  TokenResponse,
  RefreshTokenRequest,
  HouseholdCreate,
  HouseholdListResponse,
  HouseholdResponse,
  HouseholdUpdate,
  DeviceListResponse,
  DeviceResponse,
  DeviceUpdate,
  DeviceFullStateResponse,
  DeviceEventListResponse,
  SharedUserListResponse,
  DeviceControlRequest,
  StatusResponse,
  ShareCreate,
  ShareListResponse,
  ShareUpdate,
  DeviceRegisterRequest,
  ProvisionPairingTokenRequest,
  PairingTokenResponse,
  DeviceLinkRequest,
} from "@/types";
import { localizedLoginPath } from "@/lib/locale";

const BASE_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000/v1";

export class ApiError extends Error {
  status: number;
  detail: string;
  constructor(status: number, detail: string) {
    super(detail);
    this.name = "ApiError";
    this.status = status;
    this.detail = detail;
  }
}

async function tryRefresh(): Promise<boolean> {
  const refreshToken = localStorage.getItem("refresh_token");
  if (!refreshToken) return false;
  try {
    const res = await fetch(`${BASE_URL}/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refresh_token: refreshToken } as RefreshTokenRequest),
    });
    if (!res.ok) return false;
    const data: TokenResponse = await res.json();
    localStorage.setItem("access_token", data.access_token);
    localStorage.setItem("refresh_token", data.refresh_token);
    return true;
  } catch {
    return false;
  }
}

async function request<T>(
  method: string,
  path: string,
  body?: unknown,
  skipAuth = false,
): Promise<T> {
  const url = `${BASE_URL}${path}`;
  const headers: Record<string, string> = { "Content-Type": "application/json" };

  if (!skipAuth) {
    const token = localStorage.getItem("access_token");
    if (token) headers["Authorization"] = `Bearer ${token}`;
  }

  const opts: RequestInit = { method, headers };
  if (body !== undefined) opts.body = JSON.stringify(body);

  let res = await fetch(url, opts);

  if (res.status === 401 && !skipAuth) {
    const refreshed = await tryRefresh();
    if (refreshed) {
      headers["Authorization"] = `Bearer ${localStorage.getItem("access_token")}`;
      res = await fetch(url, { ...opts, headers });
    } else {
      localStorage.clear();
      window.location.href = localizedLoginPath();
      throw new ApiError(401, "Session expired");
    }
  }

  if (!res.ok) {
    let detail = `HTTP ${res.status}`;
    try {
      const err = await res.json();
      detail = err.detail || err.message || detail;
    } catch {
      /* ignore */
    }
    throw new ApiError(res.status, detail);
  }

  if (res.status === 204) return undefined as T;
  return res.json();
}

export const api = {
  get<T>(path: string, skipAuth = false): Promise<T> {
    return request<T>("GET", path, undefined, skipAuth);
  },
  post<T>(path: string, body?: unknown, skipAuth = false): Promise<T> {
    return request<T>("POST", path, body, skipAuth);
  },
  patch<T>(path: string, body?: unknown): Promise<T> {
    return request<T>("PATCH", path, body);
  },
  del<T>(path: string): Promise<T> {
    return request<T>("DELETE", path);
  },

  // ---- Auth ----
  sendOtp(data: SendOtpRequest) {
    return api.post<SendOtpResponse>("/auth/send-otp", data, true);
  },
  verifyOtp(data: VerifyOtpRequest) {
    return api.post<TokenResponse>("/auth/verify-otp", data, true);
  },
  refresh(data: RefreshTokenRequest) {
    return api.post<TokenResponse>("/auth/refresh", data, true);
  },

  // ---- Households ----
  listHouseholds() {
    return api.get<HouseholdListResponse>("/households");
  },
  getHousehold(id: string) {
    return api.get<HouseholdResponse>(`/households/${id}`);
  },
  createHousehold(data: HouseholdCreate) {
    return api.post<HouseholdResponse>("/households", data);
  },
  updateHousehold(id: string, data: HouseholdUpdate) {
    return api.patch<StatusResponse>(`/households/${id}`, data);
  },
  deleteHousehold(id: string) {
    return api.del<StatusResponse>(`/households/${id}`);
  },

  // ---- Devices ----
  listDevices(params?: { household_id?: string; linked?: boolean }) {
    const qs = new URLSearchParams();
    if (params?.household_id) qs.set("household_id", params.household_id);
    if (params?.linked !== undefined) qs.set("linked", String(params.linked));
    const q = qs.toString();
    return api.get<DeviceListResponse>(`/devices${q ? `?${q}` : ""}`);
  },
  getDevice(id: string) {
    return api.get<DeviceResponse>(`/devices/${id}`);
  },
  getDeviceState(id: string) {
    return api.get<DeviceFullStateResponse>(`/devices/${id}/state`);
  },
  updateDevice(id: string, data: DeviceUpdate) {
    return api.patch<StatusResponse>(`/devices/${id}`, data);
  },
  controlDevice(id: string, data: DeviceControlRequest) {
    return api.patch<StatusResponse>(`/devices/${id}/control`, data);
  },
  getDeviceEvents(
    id: string,
    params?: { limit?: number; offset?: number; from?: string; to?: string },
  ) {
    const qs = new URLSearchParams();
    if (params?.limit) qs.set("limit", String(params.limit));
    if (params?.offset) qs.set("offset", String(params.offset));
    if (params?.from) qs.set("from", params.from);
    if (params?.to) qs.set("to", params.to);
    const q = qs.toString();
    return api.get<DeviceEventListResponse>(`/devices/${id}/events${q ? `?${q}` : ""}`);
  },
  getDeviceShares(id: string) {
    return api.get<SharedUserListResponse>(`/devices/${id}/shares`);
  },
  deleteDevice(id: string) {
    return api.del<StatusResponse>(`/devices/${id}`);
  },
  createPairingToken(data: ProvisionPairingTokenRequest) {
    return api.post<PairingTokenResponse>("/devices/pairing-token", data);
  },
  registerDevice(data: DeviceRegisterRequest) {
    return api.post<DeviceResponse>("/devices/register", data);
  },
  linkDevice(id: string, data: DeviceLinkRequest) {
    return api.patch<StatusResponse>(`/devices/${id}/link`, data);
  },

  // ---- Admin ----
  adminStats() {
    return api.get<import("@/types").AdminStatsResponse>("/admin/stats");
  },
  adminListUsers(params?: { limit?: number; offset?: number }) {
    const qs = new URLSearchParams();
    if (params?.limit) qs.set("limit", String(params.limit));
    if (params?.offset) qs.set("offset", String(params.offset));
    const q = qs.toString();
    return api.get<import("@/types").AdminUserListResponse>(`/admin/users${q ? `?${q}` : ""}`);
  },
  adminListDevices(params?: { serial?: string; limit?: number; offset?: number }) {
    const qs = new URLSearchParams();
    if (params?.serial) qs.set("serial", params.serial);
    if (params?.limit) qs.set("limit", String(params.limit));
    if (params?.offset) qs.set("offset", String(params.offset));
    const q = qs.toString();
    return api.get<import("@/types").AdminDeviceListResponse>(`/admin/devices${q ? `?${q}` : ""}`);
  },
  adminCreateDevice(data: import("@/types").AdminDeviceCreateRequest) {
    return api.post<DeviceResponse>("/admin/devices", data);
  },
  adminUpdateDevice(id: string, data: import("@/types").AdminDeviceUpdateRequest) {
    return api.patch<DeviceResponse>(`/admin/devices/${id}`, data);
  },
  adminListHouseholds(params?: { limit?: number; offset?: number }) {
    const qs = new URLSearchParams();
    if (params?.limit) qs.set("limit", String(params.limit));
    if (params?.offset) qs.set("offset", String(params.offset));
    const q = qs.toString();
    return api.get<import("@/types").AdminHouseholdListResponse>(`/admin/households${q ? `?${q}` : ""}`);
  },
  adminCreatePairingToken(data: import("@/types").AdminPairingTokenRequest) {
    return api.post<PairingTokenResponse>("/admin/pairing-token", data);
  },
  adminListEvents(params?: { limit?: number; offset?: number }) {
    const qs = new URLSearchParams();
    if (params?.limit) qs.set("limit", String(params.limit));
    if (params?.offset) qs.set("offset", String(params.offset));
    const q = qs.toString();
    return api.get<import("@/types").AdminEventListResponse>(`/admin/events${q ? `?${q}` : ""}`);
  },

  // ---- Shares ----
  createShare(data: ShareCreate) {
    return api.post<import("@/types").ShareResponse>("/shares", data);
  },
  listMyShares() {
    return api.get<ShareListResponse>("/shares");
  },
  listIncomingShares() {
    return api.get<ShareListResponse>("/shares/incoming");
  },
  updateShare(id: string, data: ShareUpdate) {
    return api.patch<import("@/types").ShareResponse>(`/shares/${id}`, data);
  },
  revokeShare(id: string) {
    return api.del<StatusResponse>(`/shares/${id}`);
  },
};
