"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";
import { api, ApiError } from "@/lib/api";
import { Card } from "@/components/ui/Card";
import { Spinner } from "@/components/ui/Spinner";
import type { AdminUserResponse } from "@/types";

export default function AdminUsersPage() {
  const t = useTranslations("admin");
  const [users, setUsers] = useState<AdminUserResponse[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.adminListUsers({ limit: 100 })
      .then((r) => setUsers(r.users))
      .catch(() => {})
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
      <h1 className="text-xl font-semibold">{t("users")}</h1>
      <Card padding={false}>
        <table className="w-full text-sm">
          <thead className="border-b bg-gray-50">
            <tr>
              <th className="text-start p-3">{t("phone")}</th>
              <th className="text-start p-3">Name</th>
              <th className="text-start p-3">{t("role")}</th>
              <th className="text-start p-3">Created</th>
            </tr>
          </thead>
          <tbody>
            {users.map((u) => (
              <tr key={u.id} className="border-b last:border-0">
                <td className="p-3 font-mono">{u.phone}</td>
                <td className="p-3">{u.display_name || "—"}</td>
                <td className="p-3">{u.is_platform_admin ? "✓" : "—"}</td>
                <td className="p-3 text-gray-500">{new Date(u.created_at).toLocaleDateString()}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Card>
    </div>
  );
}
