"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";
import { api } from "@/lib/api";
import { Card } from "@/components/ui/Card";
import { Spinner } from "@/components/ui/Spinner";
import type { DeviceEventResponse } from "@/types";

export default function AdminEventsPage() {
  const t = useTranslations("admin");
  const [events, setEvents] = useState<DeviceEventResponse[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.adminListEvents({ limit: 50 })
      .then((r) => setEvents(r.events))
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="flex justify-center py-12">
        <Spinner className="h-8 w-8" />
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-4">
      <h1 className="text-xl font-semibold">{t("events")}</h1>
      <Card padding={false}>
        <table className="w-full text-sm">
          <thead className="border-b bg-gray-50">
            <tr>
              <th className="text-start p-3">{t("colType")}</th>
              <th className="text-start p-3">{t("colDevice")}</th>
              <th className="text-start p-3">{t("colInitiator")}</th>
              <th className="text-start p-3">{t("colTime")}</th>
            </tr>
          </thead>
          <tbody>
            {events.map((e) => (
              <tr key={e.id} className="border-b last:border-0">
                <td className="p-3">{e.type}</td>
                <td className="p-3 text-xs font-mono">{e.device_id}</td>
                <td className="p-3">{e.initiator}</td>
                <td className="p-3 text-gray-500">
                  {new Date(e.occurred_at).toLocaleString()}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </Card>
    </div>
  );
}
