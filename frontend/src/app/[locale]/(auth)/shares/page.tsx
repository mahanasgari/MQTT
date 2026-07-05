"use client";

import { useEffect, useState, useRef, useCallback } from "react";
import { Link } from "@/i18n/navigation";
import { useTranslations } from "next-intl";
import { api, ApiError } from "@/lib/api";
import { Card } from "@/components/ui/Card";
import { Spinner } from "@/components/ui/Spinner";
import { ErrorMessage } from "@/components/ui/ErrorMessage";
import { Button } from "@/components/ui/Button";
import type { ShareResponse } from "@/types";

const CONFIRM_TIMEOUT = 5000;

export default function MySharesPage() {
  const t = useTranslations("shares");
  const tc = useTranslations("common");
  const [shares, setShares] = useState<ShareResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [revokingId, setRevokingId] = useState<string | null>(null);
  const [confirmId, setConfirmId] = useState<string | null>(null);
  const confirmTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

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

  const fetchShares = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const res = await api.listMyShares();
      setShares(res.shares);
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("loadFailed"));
    } finally {
      setLoading(false);
    }
  }, [t]);

  useEffect(() => {
    fetchShares();
  }, [fetchShares]);

  const clearConfirm = useCallback(() => {
    setConfirmId(null);
    if (confirmTimer.current) {
      clearTimeout(confirmTimer.current);
      confirmTimer.current = null;
    }
  }, []);

  const requestConfirm = (shareId: string) => {
    clearConfirm();
    setConfirmId(shareId);
    confirmTimer.current = setTimeout(clearConfirm, CONFIRM_TIMEOUT);
  };

  const handleRevoke = async (shareId: string) => {
    setRevokingId(shareId);
    clearConfirm();
    try {
      await api.revokeShare(shareId);
      fetchShares();
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("revokeFailed"));
    } finally {
      setRevokingId(null);
    }
  };

  return (
    <div className="flex flex-col gap-6">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-semibold text-gray-900">{t("title")}</h1>
        <Link href="/shares/incoming">
          <Button variant="secondary">{t("incoming")}</Button>
        </Link>
      </div>

      {error && <ErrorMessage message={error} onRetry={fetchShares} />}

      {loading ? (
        <div className="flex justify-center py-12">
          <Spinner className="h-8 w-8" />
        </div>
      ) : shares.length === 0 ? (
        <Card className="text-center py-12">
          <p className="text-gray-500 text-sm">{t("emptyOutgoing")}</p>
          <p className="text-xs text-gray-400 mt-1">{t("emptyOutgoingHint")}</p>
          <Link href="/devices">
            <Button variant="secondary" className="mt-4">
              {t("browseDevices")}
            </Button>
          </Link>
        </Card>
      ) : (
        <div className="overflow-x-auto rounded-xl border bg-white shadow-sm">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b bg-gray-50 text-left">
                <th className="px-4 py-3 font-medium text-gray-500">{t("grantee")}</th>
                <th className="px-4 py-3 font-medium text-gray-500">{t("scope")}</th>
                <th className="px-4 py-3 font-medium text-gray-500">{t("permission")}</th>
                <th className="px-4 py-3 font-medium text-gray-500">{t("status")}</th>
                <th className="px-4 py-3 font-medium text-gray-500">{t("created")}</th>
                <th className="px-4 py-3 font-medium text-gray-500">{t("actions")}</th>
              </tr>
            </thead>
            <tbody>
              {shares.map((s) => {
                const scope = scopeLabel(s.scope, s.scope_id);
                return (
                  <tr key={s.id} className="border-b last:border-0 hover:bg-gray-50">
                    <td className="px-4 py-3 font-mono text-sm max-w-[160px] truncate" title={s.grantee_phone}>
                      {s.grantee_phone}
                    </td>
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
                    <td className="px-4 py-3 text-gray-500 whitespace-nowrap text-xs">
                      {new Date(s.created_at).toLocaleDateString()}
                    </td>
                    <td className="px-4 py-3">
                      {confirmId === s.id ? (
                        <div className="flex items-center gap-1.5">
                          <span className="text-xs text-red-600 font-medium">
                            {t("revokeConfirm")}
                          </span>
                          <Button
                            variant="danger"
                            size="sm"
                            loading={revokingId === s.id}
                            onClick={() => handleRevoke(s.id)}
                          >
                            {tc("yes")}
                          </Button>
                          <Button variant="ghost" size="sm" onClick={clearConfirm}>
                            {tc("no")}
                          </Button>
                        </div>
                      ) : (
                        <Button
                          variant="danger"
                          size="sm"
                          loading={revokingId === s.id}
                          onClick={() => requestConfirm(s.id)}
                        >
                          {t("revoke")}
                        </Button>
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
