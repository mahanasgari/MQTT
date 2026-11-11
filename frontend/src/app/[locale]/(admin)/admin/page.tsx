"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";
import { api, ApiError } from "@/lib/api";
import { Card } from "@/components/ui/Card";
import { Spinner } from "@/components/ui/Spinner";
import type { AdminStatsResponse } from "@/types";

export default function AdminDashboardPage() {
  const t = useTranslations("admin");
  const [stats, setStats] = useState<AdminStatsResponse | null>(null);
  const [error, setError] = useState("");

  useEffect(() => {
    api.adminStats()
      .then(setStats)
      .catch((e) => setError(e instanceof ApiError ? e.detail : "Failed"));
  }, []);

  if (!stats && !error) {
    return (
      <div className="flex justify-center py-12">
        <Spinner className="h-8 w-8" />
      </div>
    );
  }

  if (error) return <p className="text-red-600">{error}</p>;

  const cards = [
    { label: t("totalUsers"), value: stats!.users },
    { label: t("totalHouseholds"), value: stats!.households },
    { label: t("totalDevices"), value: stats!.devices },
    { label: t("onlineDevices"), value: stats!.devices_online },
    { label: t("linkedDevices"), value: stats!.devices_linked },
  ];

  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-xl font-semibold">{t("stats")}</h1>
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-4">
        {cards.map((c) => (
          <Card key={c.label} className="text-center">
            <p className="text-xs text-gray-500">{c.label}</p>
            <p className="text-2xl font-semibold mt-1">{c.value}</p>
          </Card>
        ))}
      </div>
    </div>
  );
}
