"use client";

import { useEffect, useState, useCallback, useRef } from "react";
import { Link } from "@/i18n/navigation";
import { useTranslations } from "next-intl";
import { api, ApiError } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { useDeviceWebSocket } from "@/lib/ws";
import { Card } from "@/components/ui/Card";
import { Spinner } from "@/components/ui/Spinner";
import { ErrorMessage } from "@/components/ui/ErrorMessage";
import { Button } from "@/components/ui/Button";
import { HouseholdSelector } from "@/components/HouseholdSelector";
import { DashboardDeviceCard } from "@/components/DashboardDeviceCard";
import type { HouseholdResponse, DeviceResponse, DeviceEventResponse } from "@/types";

const EVENT_COLORS: Record<string, string> = {
  power_on: "bg-green-100 text-green-800",
  power_off: "bg-red-100 text-red-800",
  device_online: "bg-blue-100 text-blue-800",
  device_offline: "bg-orange-100 text-orange-800",
  provisioned: "bg-purple-100 text-purple-800",
  linked: "bg-indigo-100 text-indigo-800",
};

const POLL_INTERVAL = 30000;
const RECENT_EVENT_COUNT = 3;
const MAX_EVENT_DEVICES = 10;
const SHOWN_EVENTS = 5;

interface EnrichedEvent extends DeviceEventResponse {
  deviceName: string;
}

export default function DashboardPage() {
  const t = useTranslations("dashboard");
  const tc = useTranslations("common");
  const te = useTranslations("errors");
  const { user } = useAuth();
  const [households, setHouseholds] = useState<HouseholdResponse[]>([]);
  const [selectedHousehold, setSelectedHousehold] = useState<string | undefined>();
  const [devices, setDevices] = useState<DeviceResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [showCreate, setShowCreate] = useState(false);
  const [creatingLocal, setCreatingLocal] = useState(false);
  const [newName, setNewName] = useState("");
  const [recentEvents, setRecentEvents] = useState<EnrichedEvent[]>([]);
  const [eventsLoading, setEventsLoading] = useState(false);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const deviceIds = devices.map((d) => d.id);
  const { connected, states } = useDeviceWebSocket(deviceIds);

  const relativeTime = useCallback(
    (iso: string): string => {
      const diff = Date.now() - new Date(iso).getTime();
      const sec = Math.floor(diff / 1000);
      if (sec < 60) return t("timeAgo", { value: sec });
      const min = Math.floor(sec / 60);
      if (min < 60) return t("timeAgoMin", { value: min });
      const hr = Math.floor(min / 60);
      if (hr < 24) return t("timeAgoHr", { value: hr });
      const day = Math.floor(hr / 24);
      return t("timeAgoDay", { value: day });
    },
    [t],
  );

  const fetchData = useCallback(async () => {
    setError("");
    try {
      const [hRes, dRes] = await Promise.all([
        api.listHouseholds(),
        api.listDevices({ household_id: selectedHousehold }),
      ]);
      setHouseholds(hRes.households);
      setDevices(dRes.devices);
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : te("loadFailed"));
    } finally {
      setLoading(false);
    }
  }, [selectedHousehold, te]);

  const fetchRecentEvents = useCallback(async (currentDevices: DeviceResponse[]) => {
    const slice = currentDevices.slice(0, MAX_EVENT_DEVICES);
    if (slice.length === 0) {
      setRecentEvents([]);
      return;
    }
    setEventsLoading(true);
    try {
      const results = await Promise.allSettled(
        slice.map((d) => api.getDeviceEvents(d.id, { limit: RECENT_EVENT_COUNT })),
      );
      const all: EnrichedEvent[] = [];
      results.forEach((r, i) => {
        if (r.status === "fulfilled") {
          const name = slice[i].name || slice[i].serial;
          for (const ev of r.value.events) {
            all.push({ ...ev, deviceName: name });
          }
        }
      });
      all.sort((a, b) => new Date(b.occurred_at).getTime() - new Date(a.occurred_at).getTime());
      setRecentEvents(all.slice(0, SHOWN_EVENTS));
    } finally {
      setEventsLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  useEffect(() => {
    if (!loading && devices.length > 0) {
      fetchRecentEvents(devices);
    }
  }, [devices, loading, fetchRecentEvents]);

  useEffect(() => {
    intervalRef.current = setInterval(() => {
      fetchData();
    }, POLL_INTERVAL);
    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
    };
  }, [fetchData]);

  const handleToggle = useCallback(
    async (deviceId: string, newPower: string) => {
      setDevices((prev) =>
        prev.map((d) =>
          d.id === deviceId && d.state
            ? { ...d, state: { ...d.state, power: newPower } }
            : d,
        ),
      );
      try {
        await api.controlDevice(deviceId, { command: "power", value: newPower });
      } catch {
        fetchData();
      }
    },
    [fetchData],
  );

  const handleCreateLocalTest = async () => {
    setCreatingLocal(true);
    setError("");
    try {
      await api.createLocalTestDevice({
        name: t("localTestDevice"),
        household_id: selectedHousehold,
      });
      await fetchData();
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : te("loadFailed"));
    } finally {
      setCreatingLocal(false);
    }
  };

  const handleCreateHousehold = async () => {
    if (!newName.trim()) return;
    try {
      await api.createHousehold({ name: newName.trim() });
      setNewName("");
      setShowCreate(false);
      fetchData();
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("createFailed"));
    }
  };

  const onlineCount = devices.filter(
    (d) => (states[d.id]?.connectivity || d.state?.connectivity) === "online",
  ).length;

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-semibold text-gray-900">{t("title")}</h1>
          <p className="text-sm text-gray-500 mt-1">
            {t("welcome", { phone: user?.phone ?? "" })}
          </p>
        </div>
        {connected && (
          <span className="hidden sm:inline-flex items-center gap-1.5 text-xs text-green-700 bg-green-50 rounded-full px-3 py-1">
            <span className="h-1.5 w-1.5 rounded-full bg-green-500" />
            {tc("live")}
          </span>
        )}
      </div>

      {error && <ErrorMessage message={error} onRetry={fetchData} />}

      <div className="grid grid-cols-3 gap-3 sm:gap-4">
        <Card className="text-center sm:text-left">
          <p className="text-xs sm:text-sm text-gray-500">{t("total")}</p>
          <p className="text-xl sm:text-2xl font-semibold mt-0.5">{devices.length}</p>
        </Card>
        <Card className="text-center sm:text-left">
          <p className="text-xs sm:text-sm text-gray-500">{t("online")}</p>
          <p className="text-xl sm:text-2xl font-semibold mt-0.5 text-green-600">
            {onlineCount}
          </p>
        </Card>
        <Card className="text-center sm:text-left">
          <p className="text-xs sm:text-sm text-gray-500">{t("households")}</p>
          <p className="text-xl sm:text-2xl font-semibold mt-0.5">{households.length}</p>
        </Card>
      </div>

      <div className="flex items-center justify-between gap-3 flex-wrap">
        <div className="flex items-center gap-3">
          <HouseholdSelector
            selectedId={selectedHousehold}
            onChange={setSelectedHousehold}
          />
        </div>
        <div className="flex items-center gap-2">
          <Button variant="secondary" size="sm" onClick={() => setShowCreate(!showCreate)}>
            {showCreate ? tc("cancel") : t("addHousehold")}
          </Button>
          <Button
            variant="secondary"
            size="sm"
            loading={creatingLocal}
            onClick={handleCreateLocalTest}
            title={t("localTestHint")}
          >
            {t("localTestDevice")}
          </Button>
          <Link href="/devices">
            <Button variant="ghost" size="sm">{t("allDevices")}</Button>
          </Link>
        </div>
      </div>

      {showCreate && (
        <Card className="flex items-end gap-3">
          <div className="flex-1">
            <label className="text-sm font-medium text-gray-700 block mb-1">
              {t("householdName")}
            </label>
            <input
              value={newName}
              onChange={(e) => setNewName(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && handleCreateHousehold()}
              placeholder={t("householdPlaceholder")}
              className="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-500/40 focus:border-blue-500"
            />
          </div>
          <Button onClick={handleCreateHousehold}>{tc("create")}</Button>
        </Card>
      )}

      {loading ? (
        <div className="flex justify-center py-12">
          <Spinner className="h-8 w-8" />
        </div>
      ) : devices.length === 0 ? (
        <Card className="text-center py-12">
          <p className="text-gray-500">{t("noDevices")}</p>
          <p className="text-sm text-gray-400 mt-1">{t("noDevicesHint")}</p>
          <Link href="/devices/add">
            <Button className="mt-4">{t("addDevice")}</Button>
          </Link>
          <Button
            variant="secondary"
            className="mt-3"
            loading={creatingLocal}
            onClick={handleCreateLocalTest}
          >
            {t("localTestDevice")}
          </Button>
          <p className="text-xs text-gray-400 mt-2">{t("localTestHint")}</p>
          <Link href="/guide" className="block mt-3 text-sm text-blue-600 hover:underline">
            {t("readGuide")}
          </Link>
        </Card>
      ) : (
        <section>
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-sm font-semibold text-gray-700 uppercase tracking-wide">
              {t("devicesSection")}
            </h2>
            {connected && (
              <span className="sm:hidden text-xs text-green-600">{tc("live")}</span>
            )}
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {devices.map((d) => (
              <DashboardDeviceCard
                key={d.id}
                device={d}
                wsState={states[d.id] || null}
                onToggle={handleToggle}
              />
            ))}
          </div>
        </section>
      )}

      {!loading && devices.length > 0 && (
        <section>
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-sm font-semibold text-gray-700 uppercase tracking-wide">
              {t("recentEvents")}
            </h2>
            <Link href={devices.length > 0 ? `/devices/${devices[0].id}/events` : "#"}>
              <Button variant="ghost" size="sm">{t("viewAll")}</Button>
            </Link>
          </div>

          {eventsLoading && recentEvents.length === 0 ? (
            <Card className="flex justify-center py-6">
              <Spinner />
            </Card>
          ) : recentEvents.length === 0 ? (
            <Card className="text-center py-6">
              <p className="text-sm text-gray-400">{t("noEvents")}</p>
            </Card>
          ) : (
            <Card padding={false}>
              {recentEvents.map((ev, i) => (
                <div
                  key={ev.id}
                  className={`flex items-center gap-3 px-4 py-3 ${
                    i < recentEvents.length - 1 ? "border-b" : ""
                  }`}
                >
                  <span
                    className={`shrink-0 rounded-md px-2 py-0.5 text-xs font-medium ${
                      EVENT_COLORS[ev.type] || "bg-gray-100 text-gray-700"
                    }`}
                  >
                    {ev.type}
                  </span>
                  <span className="text-sm text-gray-700 min-w-0 truncate flex-1">
                    {ev.deviceName}
                  </span>
                  <span className="text-xs text-gray-400 shrink-0">
                    {relativeTime(ev.occurred_at)}
                  </span>
                </div>
              ))}
            </Card>
          )}
        </section>
      )}
    </div>
  );
}
