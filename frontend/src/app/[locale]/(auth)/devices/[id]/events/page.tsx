"use client";

import { useEffect, useState, useCallback } from "react";
import { useParams } from "next/navigation";
import { useTranslations } from "next-intl";
import { api, ApiError } from "@/lib/api";
import { Spinner } from "@/components/ui/Spinner";
import { ErrorMessage } from "@/components/ui/ErrorMessage";
import { Button } from "@/components/ui/Button";
import type { DeviceEventResponse } from "@/types";

const EVENT_COLORS: Record<string, string> = {
  power_on: "bg-green-100 text-green-800",
  power_off: "bg-red-100 text-red-800",
  device_online: "bg-blue-100 text-blue-800",
  device_offline: "bg-orange-100 text-orange-800",
  provisioned: "bg-purple-100 text-purple-800",
  linked: "bg-indigo-100 text-indigo-800",
};

export default function DeviceEventsPage() {
  const t = useTranslations("deviceEvents");
  const params = useParams();
  const deviceId = params.id as string;

  const [events, setEvents] = useState<DeviceEventResponse[]>([]);
  const [total, setTotal] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [offset, setOffset] = useState(0);
  const limit = 20;

  const fetchEvents = useCallback(async (newOffset = 0) => {
    setLoading(true);
    setError("");
    try {
      const res = await api.getDeviceEvents(deviceId, {
        limit,
        offset: newOffset,
      });
      setEvents(res.events);
      setTotal(res.total);
      setOffset(newOffset);
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("loadFailed"));
    } finally {
      setLoading(false);
    }
  }, [deviceId, limit]);

  useEffect(() => {
    fetchEvents();
  }, [deviceId, fetchEvents]);

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-xl font-semibold text-gray-900">{t("title")}</h1>
          <p className="text-sm text-gray-500 mt-1">
            {t("eventCount", { total })}
          </p>
        </div>
        <Button variant="secondary" size="sm" onClick={() => fetchEvents(0)}>
          {t("refresh")}
        </Button>
      </div>

      {error && (
        <ErrorMessage
          message={error}
          onRetry={() => fetchEvents(offset)}
        />
      )}

      {loading && events.length === 0 ? (
        <div className="flex justify-center py-12">
          <Spinner className="h-8 w-8" />
        </div>
      ) : events.length === 0 ? (
        <div className="text-center py-12 text-gray-400 text-sm">
          {t("noEventsRecorded")}
        </div>
      ) : (
        <div className="overflow-x-auto rounded-xl border bg-white shadow-sm">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b bg-gray-50 text-left">
                <th className="px-4 py-3 font-medium text-gray-500">{t("type")}</th>
                <th className="px-4 py-3 font-medium text-gray-500">{t("colInitiator")}</th>
                <th className="px-4 py-3 font-medium text-gray-500">{t("colTimestamp")}</th>
              </tr>
            </thead>
            <tbody>
              {events.map((ev) => (
                <tr key={ev.id} className="border-b last:border-0 hover:bg-gray-50">
                  <td className="px-4 py-3">
                    <span
                      className={`inline-block rounded-md px-2 py-0.5 text-xs font-medium ${
                        EVENT_COLORS[ev.type] || "bg-gray-100 text-gray-700"
                      }`}
                    >
                      {ev.type}
                    </span>
                  </td>
                  <td className="px-4 py-3 text-gray-600 capitalize">
                    {ev.initiator}
                  </td>
                  <td className="px-4 py-3 text-gray-500 whitespace-nowrap">
                    {new Date(ev.occurred_at).toLocaleString()}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {total > limit && (
        <div className="flex items-center justify-between">
          <Button
            variant="secondary"
            size="sm"
            disabled={offset === 0}
            onClick={() => fetchEvents(Math.max(0, offset - limit))}
          >
            {t("previous")}
          </Button>
          <span className="text-xs text-gray-400">
            {t("pagination", {
              from: offset + 1,
              to: Math.min(offset + limit, total),
              total,
            })}
          </span>
          <Button
            variant="secondary"
            size="sm"
            disabled={offset + limit >= total}
            onClick={() => fetchEvents(offset + limit)}
          >
            {t("next")}
          </Button>
        </div>
      )}
    </div>
  );
}
