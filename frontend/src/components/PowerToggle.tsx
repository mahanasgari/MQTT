"use client";

import { useState } from "react";
import { api } from "@/lib/api";

interface PowerToggleProps {
  deviceId: string;
  currentPower: string;
  onToggle?: (newPower: string) => void;
}

export function PowerToggle({ deviceId, currentPower, onToggle }: PowerToggleProps) {
  const [loading, setLoading] = useState(false);
  const [localPower, setLocalPower] = useState(currentPower);
  const power = localPower || currentPower;
  const isOn = power === "on";

  const handleToggle = async () => {
    const next = isOn ? "off" : "on";
    setLoading(true);
    try {
      await api.controlDevice(deviceId, { command: "power", value: next });
      setLocalPower(next);
      onToggle?.(next);
    } catch (e) {
      console.error("Toggle failed", e);
    } finally {
      setLoading(false);
    }
  };

  return (
    <button
      onClick={handleToggle}
      disabled={loading}
      className={`relative w-28 h-28 rounded-full flex items-center justify-center text-lg font-semibold transition-all shadow-lg ${
        isOn
          ? "bg-yellow-400 text-yellow-900 shadow-yellow-200/50 hover:bg-yellow-500"
          : "bg-gray-200 text-gray-500 hover:bg-gray-300"
      } ${loading ? "opacity-60 cursor-wait" : "cursor-pointer"}`}
    >
      {loading ? (
        <svg className="animate-spin h-8 w-8" viewBox="0 0 24 24" fill="none">
          <circle
            className="opacity-25"
            cx="12"
            cy="12"
            r="10"
            stroke="currentColor"
            strokeWidth="4"
          />
          <path
            className="opacity-75"
            fill="currentColor"
            d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
          />
        </svg>
      ) : (
        <span>{isOn ? "ON" : "OFF"}</span>
      )}
    </button>
  );
}
