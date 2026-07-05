"use client";

import { useEffect, useState, useCallback } from "react";
import { Link } from "@/i18n/navigation";
import { useTranslations } from "next-intl";
import { api, ApiError } from "@/lib/api";
import { Card } from "@/components/ui/Card";
import { Spinner } from "@/components/ui/Spinner";
import { ErrorMessage } from "@/components/ui/ErrorMessage";
import { Button } from "@/components/ui/Button";
import type { ShareResponse } from "@/types";

export default function IncomingSharesPage() {
  const t = useTranslations("shares");
  const tc = useTranslations("common");
  const [shares, setShares] = useState<ShareResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [actionLoading, setActionLoading] = useState<string | null>(null);

  const scopeLabel = useCallback(
    (scope: string, scopeId: string): { text: string; href?: string } => {
      const short = scopeId.length > 8 ? `${scopeId.slice(0, 8)}…` : scopeId;
      const label = scope === "device" ? t("scopeDevice") : t("scopeHousehold");
      if (scope === "device") {
        return { text: `${label} · ${short}`, href: `/devices/${scopeId}` };
      }
      return { text: `${label} · ${short}` };
    },
    [t],
  );

  const statusLabel = (status: string) => {
    if (status === "accepted") return t("statusAccepted");
    if (status === "pending") return t("statusPending");
    if (status === "declined") return t("statusDeclined");
    return status;
  };

  const fetchShares = async () => {
    setLoading(true);
    setError("");
    try {
      const res = await api.listIncomingShares();
      setShares(res.shares);
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("loadFailed"));
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchShares();
  }, []);

  const handleAction = async (shareId: string, status: "accepted" | "declined") => {
    setActionLoading(shareId);
    setError("");
    try {
      await api.updateShare(shareId, { status });
      fetchShares();
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("actionFailed"));
    } finally {
      setActionLoading(null);
    }
  };

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold text-gray-900">{t("incoming")}</h1>
        <Link href="/shares">
          <Button variant="secondary">{t("myShares")}</Button>
        </Link>
      </div>

      {error && <ErrorMessage message={error} />}

      {loading ? (
        <div className="flex justify-center py-12">
          <Spinner className="h-8 w-8" />
        </div>
      ) : shares.length === 0 ? (
        <Card className="text-center py-12">
          <p className="text-gray-500 text-sm">{t("emptyIncoming")}</p>
          <p className="text-xs text-gray-400 mt-1">{t("emptyIncomingHint")}</p>
          <Link href="/dashboard">
            <Button variant="secondary" className="mt-4">{t("goDashboard")}</Button>
          </Link>
        </Card>
      ) : (
        <div className="overflow-x-auto rounded-xl border bg-white shadow-sm">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b bg-gray-50 text-left">
                <th className="px-4 py-3 font-medium text-gray-500">{t("item")}</th>
                <th className="px-4 py-3 font-medium text-gray-500">{t("permission")}</th>
                <th className="px-4 py-3 font-medium text-gray-500">{t("status")}</th>
                <th className="px-4 py-3 font-medium text-gray-500">{t("actions")}</th>
              </tr>
            </thead>
            <tbody>
              {shares.map((s) => {
                const scope = scopeLabel(s.scope, s.scope_id);
                return (
                  <tr key={s.id} className="border-b last:border-0 hover:bg-gray-50">
                    <td className="px-4 py-3 text-sm">
                      {scope.href ? (
                        <Link href={scope.href} className="text-blue-600 hover:underline">
                          {scope.text}
                        </Link>
                      ) : (
                        <span className="text-gray-600">{scope.text}</span>
                      )}
                    </td>
                    <td className="px-4 py-3 capitalize">{s.permission}</td>
                    <td className="px-4 py-3">
                      <span
                        className={`inline-block rounded-full px-2 py-0.5 text-xs font-medium ${
                          s.status === "accepted"
                            ? "bg-green-50 text-green-700"
                            : s.status === "pending"
                              ? "bg-yellow-50 text-yellow-700"
                              : "bg-gray-50 text-gray-500"
                        }`}
                      >
                        {statusLabel(s.status)}
                      </span>
                    </td>
                    <td className="px-4 py-3">
                      {s.status === "pending" ? (
                        <div className="flex gap-2">
                          <Button
                            variant="primary"
                            size="sm"
                            loading={actionLoading === s.id}
                            onClick={() => handleAction(s.id, "accepted")}
                          >
                            {t("accept")}
                          </Button>
                          <Button
                            variant="danger"
                            size="sm"
                            loading={actionLoading === s.id}
                            onClick={() => handleAction(s.id, "declined")}
                          >
                            {t("decline")}
                          </Button>
                        </div>
                      ) : (
                        <span className="text-xs text-gray-400">{t("done")}</span>
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
