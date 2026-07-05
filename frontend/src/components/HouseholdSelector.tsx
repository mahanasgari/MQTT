"use client";

import { useEffect, useState } from "react";
import { api } from "@/lib/api";
import type { HouseholdResponse } from "@/types";

interface HouseholdSelectorProps {
  selectedId: string | undefined;
  onChange: (id: string | undefined) => void;
  includeAll?: boolean;
}

export function HouseholdSelector({
  selectedId,
  onChange,
  includeAll = true,
}: HouseholdSelectorProps) {
  const [households, setHouseholds] = useState<HouseholdResponse[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api
      .listHouseholds()
      .then((res) => setHouseholds(res.households))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <select className="rounded-lg border border-gray-300 px-3 py-2 text-sm bg-white" disabled>
        <option>Loading...</option>
      </select>
    );
  }

  return (
    <select
      value={selectedId || ""}
      onChange={(e) => onChange(e.target.value || undefined)}
      className="rounded-lg border border-gray-300 px-3 py-2 text-sm bg-white focus:ring-2 focus:ring-blue-500/40 focus:border-blue-500 outline-none"
    >
      {includeAll && <option value="">All households</option>}
      {households.map((h) => (
        <option key={h.id} value={h.id}>
          {h.name} ({h.role})
        </option>
      ))}
    </select>
  );
}
