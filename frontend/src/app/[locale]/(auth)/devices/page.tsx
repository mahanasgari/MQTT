"use client";

import { useEffect, useState, useCallback } from "react";
import { Link } from "@/i18n/navigation";
import { useTranslations } from "next-intl";
import { api, ApiError } from "@/lib/api";
import { Card } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { Spinner } from "@/components/ui/Spinner";
import { ErrorMessage } from "@/components/ui/ErrorMessage";
import { HouseholdSelector } from "@/components/HouseholdSelector";
import { DeviceCard } from "@/components/DeviceCard";
import type { DeviceResponse } from "@/types";

export default function DevicesPage() {
  const t = useTranslations("devices");
  const [devices, setDevices] = useState<DeviceResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [selectedHousehold, setSelectedHousehold] = useState<
    string | undefined
  >();

  const fetchDevices = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const res = await api.listDevices({
        household_id: selectedHousehold,
      });
      setDevices(res.devices);
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("loadFailed"));
    } finally {
      setLoading(false);
    }
  }, [selectedHousehold, t]);

  useEffect(() => {
    fetchDevices();
  }, [selectedHousehold, fetchDevices]);

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold text-gray-900">{t("title")}</h1>
        <div className="flex items-center gap-2">
          <Link href="/devices/add">
            <Button size="sm">{t("addDevice")}</Button>
          </Link>
          <HouseholdSelector
            selectedId={selectedHousehold}
            onChange={setSelectedHousehold}
          />
        </div>
      </div>

      {error && <ErrorMessage message={error} onRetry={fetchDevices} />}

      {loading ? (
        <div className="flex justify-center py-12">
          <Spinner className="h-8 w-8" />
        </div>
      ) : devices.length === 0 ? (
        <Card className="text-center py-12">
          <p className="text-gray-500">{t("noDevices")}</p>
          <p className="text-sm text-gray-400 mt-1">
            {selectedHousehold
              ? t("noDevicesHousehold")
              : t("noDevicesHint")}
          </p>
          <Link href="/devices/add">
            <Button className="mt-4">{t("addDevice")}</Button>
          </Link>
          <Link href="/guide" className="block mt-3 text-sm text-blue-600 hover:underline">
            {t("readGuide")}
          </Link>
        </Card>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {devices.map((d) => (
            <DeviceCard key={d.id} device={d} />
          ))}
        </div>
      )}
    </div>
  );
}
