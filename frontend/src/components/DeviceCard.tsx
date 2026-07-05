import Link from "next/link";
import { StateBadge, PowerBadge } from "./StateBadge";
import type { DeviceResponse } from "@/types";

interface DeviceCardProps {
  device: DeviceResponse;
}

export function DeviceCard({ device }: DeviceCardProps) {
  return (
    <Link href={`/devices/${device.id}`}>
      <div className="rounded-xl border bg-white p-5 shadow-sm hover:shadow-md transition-shadow cursor-pointer flex flex-col gap-2">
        <div className="flex items-start justify-between">
          <div className="min-w-0">
            <h3 className="font-medium text-gray-900 truncate">
              {device.name || device.serial}
            </h3>
            <p className="text-xs text-gray-500 mt-0.5 font-mono">
              {device.serial}
            </p>
          </div>
          {device.state && <StateBadge connectivity={device.state.connectivity} />}
        </div>

        <div className="flex items-center gap-2 mt-1">
          {device.state && <PowerBadge power={device.state.power} />}
          {device.household_id && (
            <span className="text-xs text-gray-400">Linked</span>
          )}
        </div>

        <div className="text-xs text-gray-400 mt-1">
          {device.firmware_version && <>v{device.firmware_version} &middot; </>}
          {new Date(device.created_at).toLocaleDateString()}
        </div>
      </div>
    </Link>
  );
}
