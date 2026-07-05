"use client";

import { useEffect, useState, useRef, useCallback } from "react";
import { useParams } from "next/navigation";
import { useTranslations } from "next-intl";
import { api, ApiError } from "@/lib/api";
import { isValidE164, formatPhoneError } from "@/lib/validation";
import { Card } from "@/components/ui/Card";
import { Spinner } from "@/components/ui/Spinner";
import { ErrorMessage } from "@/components/ui/ErrorMessage";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import type { SharedUserResponse } from "@/types";

const CONFIRM_TIMEOUT = 5000;

export default function DeviceSharesPage() {
  const t = useTranslations("deviceShares");
  const ts = useTranslations("shares");
  const tc = useTranslations("common");
  const params = useParams();
  const deviceId = params.id as string;

  const [shares, setShares] = useState<SharedUserResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [showForm, setShowForm] = useState(false);
  const [targetPhone, setTargetPhone] = useState("");
  const [phoneError, setPhoneError] = useState<string | null>(null);
  const [permission, setPermission] = useState("control");
  const [submitting, setSubmitting] = useState(false);
  const [revokingId, setRevokingId] = useState<string | null>(null);
  const [confirmId, setConfirmId] = useState<string | null>(null);
  const confirmTimer = useRef<ReturnType<typeof setTimeout> | null>(null);

  const permLabel = (p: string) => {
    if (p === "view") return t("permView");
    if (p === "control") return t("permControl");
    if (p === "admin") return t("permAdmin");
    return p;
  };

  const permDesc = (p: string) => {
    if (p === "view") return t("permViewDesc");
    if (p === "control") return t("permControlDesc");
    if (p === "admin") return t("permAdminDesc");
    return "";
  };

  const statusLabel = (status: string) => {
    if (status === "accepted") return ts("statusAccepted");
    if (status === "pending") return ts("statusPending");
    if (status === "declined") return ts("statusDeclined");
    return status;
  };

  const fetchShares = useCallback(async () => {
    setLoading(true);
    setError("");
    try {
      const res = await api.getDeviceShares(deviceId);
      setShares(res.shares);
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("loadFailed"));
    } finally {
      setLoading(false);
    }
  }, [deviceId, t]);

  useEffect(() => {
    if (deviceId) fetchShares();
  }, [deviceId, fetchShares]);

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

  const handlePhoneChange = (value: string) => {
    setTargetPhone(value);
    if (value.trim()) {
      const err = formatPhoneError(value);
      setPhoneError(err);
    } else {
      setPhoneError(t("phoneRequired"));
    }
  };

  const handleCreate = async () => {
    const err = formatPhoneError(targetPhone);
    if (err) {
      setPhoneError(err);
      return;
    }
    setSubmitting(true);
    setError("");
    try {
      await api.createShare({
        target_phone: targetPhone.trim(),
        scope: "device",
        scope_id: deviceId,
        permission,
      });
      setTargetPhone("");
      setPhoneError(null);
      setShowForm(false);
      fetchShares();
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("createFailed"));
    } finally {
      setSubmitting(false);
    }
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
        <div>
          <h1 className="text-xl font-semibold text-gray-900">{t("title")}</h1>
          <p className="text-sm text-gray-500 mt-1">{t("subtitle")}</p>
        </div>
        <Button onClick={() => setShowForm(!showForm)}>
          {showForm ? tc("cancel") : t("addShare")}
        </Button>
      </div>

      {error && <ErrorMessage message={error} />}

      {showForm && (
        <Card className="flex flex-col gap-4">
          <Input
            label={t("phone")}
            type="tel"
            placeholder={t("phoneHint")}
            value={targetPhone}
            error={phoneError ?? undefined}
            onChange={(e) => handlePhoneChange(e.target.value)}
            onKeyDown={(e) => e.key === "Enter" && handleCreate()}
          />
          <div className="flex flex-col gap-1.5">
            <label className="text-sm font-medium text-gray-700">
              {t("permission")}
            </label>
            <div className="flex gap-4">
              {(["view", "control", "admin"] as const).map((p) => (
                <label key={p} className="flex items-center gap-1.5 text-sm">
                  <input
                    type="radio"
                    name="permission"
                    value={p}
                    checked={permission === p}
                    onChange={() => setPermission(p)}
                    className="accent-blue-600"
                  />
                  {permLabel(p)}
                </label>
              ))}
            </div>
            <p className="text-xs text-gray-400 mt-1">{permDesc(permission)}</p>
          </div>
          <Button
            onClick={handleCreate}
            loading={submitting}
            disabled={!isValidE164(targetPhone)}
          >
            {t("sendInvitation")}
          </Button>
        </Card>
      )}

      {loading ? (
        <div className="flex justify-center py-12">
          <Spinner className="h-8 w-8" />
        </div>
      ) : shares.length === 0 ? (
        <Card className="text-center py-12">
          <p className="text-gray-500 text-sm">{t("emptyTitle")}</p>
          <p className="text-xs text-gray-400 mt-1">{t("emptyHint")}</p>
          {!showForm && (
            <Button variant="secondary" className="mt-4" onClick={() => setShowForm(true)}>
              {t("addShare")}
            </Button>
          )}
        </Card>
      ) : (
        <div className="overflow-x-auto rounded-xl border bg-white shadow-sm">
          <table className="w-full text-sm">
            <thead>
              <tr className="border-b bg-gray-50 text-left">
                <th className="px-4 py-3 font-medium text-gray-500">{t("colPhone")}</th>
                <th className="px-4 py-3 font-medium text-gray-500">{t("permission")}</th>
                <th className="px-4 py-3 font-medium text-gray-500">{t("colStatus")}</th>
                <th className="px-4 py-3 font-medium text-gray-500">{t("colActions")}</th>
              </tr>
            </thead>
            <tbody>
              {shares.map((s) => (
                <tr key={s.id} className="border-b last:border-0 hover:bg-gray-50">
                  <td className="px-4 py-3 font-mono text-sm max-w-[200px] truncate" title={s.grantee_phone}>
                    {s.grantee_phone}
                  </td>
                  <td className="px-4 py-3">{permLabel(s.permission)}</td>
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
                    {confirmId === s.id ? (
                      <div className="flex items-center gap-1.5">
                        <span className="text-xs text-red-600 font-medium">
                          {ts("revokeConfirm")}
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
                        onClick={(e) => { e.stopPropagation(); requestConfirm(s.id); }}
                      >
                        {ts("revoke")}
                      </Button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
