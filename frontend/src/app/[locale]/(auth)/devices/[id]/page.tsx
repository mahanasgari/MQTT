"use client";

import { useEffect, useState, useCallback } from "react";
import { useParams } from "next/navigation";
import { Link } from "@/i18n/navigation";
import { useTranslations } from "next-intl";
import { api, ApiError } from "@/lib/api";
import { useDeviceWebSocket } from "@/lib/ws";
import { Card } from "@/components/ui/Card";
import { Spinner } from "@/components/ui/Spinner";
import { ErrorMessage } from "@/components/ui/ErrorMessage";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { PowerToggle } from "@/components/PowerToggle";
import { StateBadge } from "@/components/StateBadge";
import type { DeviceResponse, DeviceFullStateResponse } from "@/types";

export default function DeviceDetailPage() {
  const t = useTranslations("deviceDetail");
  const tc = useTranslations("common");
  const params = useParams();
  const deviceId = params.id as string;

  const [device, setDevice] = useState<DeviceResponse | null>(null);
  const [fullState, setFullState] = useState<DeviceFullStateResponse | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [renaming, setRenaming] = useState(false);
  const [simulating, setSimulating] = useState(false);
  const [newName, setNewName] = useState("");

  const { connected, states } = useDeviceWebSocket([deviceId]);
  const wsState = states[deviceId];
  const livePower =
    typeof wsState?.power === "string" ? wsState.power : undefined;
  const liveConnectivity =
    typeof wsState?.connectivity === "string"
      ? wsState.connectivity
      : undefined;

  const fetchDevice = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const [dRes, sRes] = await Promise.all([
        api.getDevice(deviceId),
        api.getDeviceState(deviceId).catch(() => null),
      ]);
      setDevice(dRes);
      setFullState(sRes);
      setNewName(dRes.name || "");
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("loadFailed"));
    } finally {
      setLoading(false);
    }
  }, [deviceId, t]);

  useEffect(() => {
    if (deviceId) fetchDevice();
  }, [deviceId, fetchDevice]);

  const handleSimulate = async (connectivity: "online" | "offline") => {
    setSimulating(true);
    setError("");
    try {
      const updated = await api.simulateDevice(deviceId, {
        connectivity,
        power: power === "on" ? "on" : "off",
      });
      setDevice(updated);
      if (updated.state) {
        setFullState((prev) =>
          prev
            ? {
                ...prev,
                power: updated.state!.power,
                connectivity: updated.state!.connectivity,
                last_seen_at: updated.state!.last_seen_at,
              }
            : prev,
        );
      }
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("simulateFailed"));
    } finally {
      setSimulating(false);
    }
  };

  const handleRename = async () => {
    if (!newName.trim()) return;
    setRenaming(true);
    try {
      await api.updateDevice(deviceId, { name: newName.trim() });
      setDevice((prev) => (prev ? { ...prev, name: newName.trim() } : prev));
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("renameFailed"));
    } finally {
      setRenaming(false);
    }
  };

  const connectedState = liveConnectivity || device?.state?.connectivity || "offline";
  const power = livePower || fullState?.power || device?.state?.power || "off";
  const voltage = fullState?.voltage;
  const current = fullState?.current;
  const powerConsumption = fullState?.power_consumption;

  if (loading) {
    return (
      <div className="flex justify-center py-12">
        <Spinner className="h-8 w-8" />
      </div>
    );
  }

  if (error) {
    return <ErrorMessage message={error} onRetry={fetchDevice} />;
  }

  if (!device) return null;

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-semibold text-gray-900">
            {device.name || device.serial}
          </h1>
          <p className="text-sm text-gray-500 font-mono mt-0.5">
            {device.serial}
          </p>
        </div>
        <div className="flex items-center gap-2">
          {connected && (
            <span className="text-xs text-green-600 bg-green-50 px-2 py-0.5 rounded-full">
              {tc("live")}
            </span>
          )}
          <StateBadge connectivity={connectedState} />
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <Card className="lg:col-span-2 flex flex-col gap-6">
          <div className="flex items-center justify-center py-4">
            <PowerToggle
              deviceId={deviceId}
              currentPower={power}
              onToggle={(newPower) => {
                setFullState((prev) =>
                  prev ? { ...prev, power: newPower } : prev,
                );
              }}
            />
          </div>

          {voltage !== null && voltage !== undefined && (
            <div className="grid grid-cols-3 gap-4">
              <div className="text-center">
                <p className="text-xs text-gray-500">{t("voltage")}</p>
                <p className="text-lg font-semibold">{voltage.toFixed(1)}V</p>
              </div>
              <div className="text-center">
                <p className="text-xs text-gray-500">{t("current")}</p>
                <p className="text-lg font-semibold">
                  {current ? `${current.toFixed(2)}A` : "—"}
                </p>
              </div>
              <div className="text-center">
                <p className="text-xs text-gray-500">{t("power")}</p>
                <p className="text-lg font-semibold">
                  {powerConsumption
                    ? `${powerConsumption.toFixed(1)}W`
                    : "—"}
                </p>
              </div>
            </div>
          )}

          {fullState && (
            <div className="text-xs text-gray-400 text-center">
              {t("lastSeen", { time: new Date(fullState.last_seen_at).toLocaleString() })}
            </div>
          )}
        </Card>

        <div className="flex flex-col gap-4">
          <Card>
            <h3 className="text-sm font-medium text-gray-900 mb-2">{t("simulateOnline")}</h3>
            <p className="text-xs text-gray-500 mb-3">{t("localTestHint")}</p>
            <div className="flex gap-2">
              <Button
                size="sm"
                loading={simulating}
                onClick={() => handleSimulate("online")}
              >
                {t("simulateOnline")}
              </Button>
              <Button
                variant="secondary"
                size="sm"
                loading={simulating}
                onClick={() => handleSimulate("offline")}
              >
                {t("simulateOffline")}
              </Button>
            </div>
          </Card>
          <Card>
            <h3 className="text-sm font-medium text-gray-900 mb-3">{t("settings")}</h3>
            <div className="flex flex-col gap-3">
              <Input
                label={tc("name")}
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
              />
              <Button
                onClick={handleRename}
                loading={renaming}
                variant="secondary"
                size="sm"
              >
                {tc("rename")}
              </Button>
            </div>
          </Card>

          <Card>
            <h3 className="text-sm font-medium text-gray-900 mb-3">{t("quickLinks")}</h3>
            <div className="flex flex-col gap-2">
              <Link href={`/devices/${deviceId}/events`}>
                <Button variant="ghost" size="sm" className="w-full justify-start">
                  {t("eventHistory")}
                </Button>
              </Link>
              <Link href={`/devices/${deviceId}/shares`}>
                <Button variant="ghost" size="sm" className="w-full justify-start">
                  {t("shareAccess")}
                </Button>
              </Link>
            </div>
          </Card>
        </div>
      </div>
    </div>
  );
}
