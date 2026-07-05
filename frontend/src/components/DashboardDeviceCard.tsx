"use client";

import Link from "next/link";
import { useState } from "react";
import { StateBadge } from "./StateBadge";
import type { DeviceResponse } from "@/types";

interface DashboardDeviceCardProps {
  device: DeviceResponse;
  wsState?: Record<string, unknown> | null;
  onToggle: (deviceId: string, newPower: string) => Promise<void>;
}

function relativeTime(iso: string): string {
  const diff = Date.now() - new Date(iso).getTime();
  const sec = Math.floor(diff / 1000);
  if (sec < 60) return `${sec}s ago`;
  const min = Math.floor(sec / 60);
  if (min < 60) return `${min}m ago`;
  const hr = Math.floor(min / 60);
  if (hr < 24) return `${hr}h ago`;
  const day = Math.floor(hr / 24);
  return `${day}d ago`;
}

export function DashboardDeviceCard({
  device,
  wsState,
  onToggle,
}: DashboardDeviceCardProps) {
  const [toggling, setToggling] = useState(false);

  const connectivity =
    (wsState?.connectivity as string) || device.state?.connectivity || "offline";
  const power =
    (wsState?.power as string) || device.state?.power || "off";
  const lastChanged = device.state?.last_changed_at;

  const handleToggle = async (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    const next = power === "on" ? "off" : "on";
    setToggling(true);
    try {
      await onToggle(device.id, next);
    } finally {
      setToggling(false);
    }
  };

  return (
    <Link href={`/devices/${device.id}`}>
      <div className="rounded-xl border bg-white p-4 shadow-sm hover:shadow-md transition-shadow cursor-pointer flex flex-col gap-2">
        <div className="flex items-start justify-between">
          <div className="min-w-0 flex-1">
            <h3 className="font-medium text-gray-900 truncate text-sm">
              {device.name || device.serial}
            </h3>
            <p className="text-xs text-gray-500 mt-0.5 font-mono truncate">
              {device.serial}
            </p>
          </div>
          <StateBadge connectivity={connectivity} />
        </div>

        <div className="flex items-center justify-between mt-1">
          <button
            onClick={handleToggle}
            disabled={toggling}
            className={`relative inline-flex h-7 w-12 shrink-0 items-center rounded-full transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500/40 ${
              power === "on"
                ? "bg-yellow-400"
                : "bg-gray-200"
            } ${toggling ? "opacity-60" : ""}`}
          >
            <span
              className={`inline-block h-5 w-5 transform rounded-full bg-white shadow-sm ring-0 transition-transform ${
                power === "on" ? "translate-x-6" : "translate-x-1"
              }`}
            />
          </button>

          <span
            className={`text-xs font-medium ${
              power === "on" ? "text-yellow-700" : "text-gray-400"
            }`}
          >
            {toggling ? "..." : power === "on" ? "ON" : "OFF"}
          </span>
        </div>

        {lastChanged && (
          <p className="text-xs text-gray-400 mt-0.5">
            Changed {relativeTime(lastChanged)}
          </p>
        )}
      </div>
    </Link>
  );
}
