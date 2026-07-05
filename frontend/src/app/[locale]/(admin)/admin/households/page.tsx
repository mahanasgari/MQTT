"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";
import { api } from "@/lib/api";
import { Card } from "@/components/ui/Card";
import { Spinner } from "@/components/ui/Spinner";
import type { AdminHouseholdResponse } from "@/types";

export default function AdminHouseholdsPage() {
  const t = useTranslations("admin");
  const [households, setHouseholds] = useState<AdminHouseholdResponse[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.adminListHouseholds({ limit: 100 })
      .then((r) => setHouseholds(r.households))
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
      <h1 className="text-xl font-semibold">{t("households")}</h1>
      <Card padding={false}>
        <table className="w-full text-sm">
          <thead className="border-b bg-gray-50">
            <tr>
              <th className="text-start p-3">Name</th>
              <th className="text-start p-3">{t("members")}</th>
              <th className="text-start p-3">{t("deviceCount")}</th>
              <th className="text-start p-3">Timezone</th>
            </tr>
          </thead>
          <tbody>
            {households.map((h) => (
              <tr key={h.id} className="border-b last:border-0">
                <td className="p-3 font-medium">{h.name}</td>
                <td className="p-3">{h.member_count}</td>
                <td className="p-3">{h.device_count}</td>
                <td className="p-3 text-gray-500">{h.timezone}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Card>
    </div>
  );
}
