"use client";

import { useEffect, useState } from "react";
import { Link, useRouter } from "@/i18n/navigation";
import { useTranslations } from "next-intl";
import { api, ApiError } from "@/lib/api";
import { Card } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { ErrorMessage } from "@/components/ui/ErrorMessage";
import type { HouseholdResponse } from "@/types";

type Step = "serial" | "token" | "link" | "done";

const STEPS: Step[] = ["serial", "token", "link", "done"];

export default function AddDevicePage() {
  const t = useTranslations("addDevice");
  const tc = useTranslations("common");
  const router = useRouter();
  const [step, setStep] = useState<Step>("serial");
  const [serial, setSerial] = useState("");
  const [token, setToken] = useState("");
  const [name, setName] = useState("");
  const [deviceId, setDeviceId] = useState("");
  const [households, setHouseholds] = useState<HouseholdResponse[]>([]);
  const [householdId, setHouseholdId] = useState("");
  const [newHousehold, setNewHousehold] = useState("");
  const [loading, setLoading] = useState(false);
  const [localLoading, setLocalLoading] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    api.listHouseholds().then((res) => {
      setHouseholds(res.households);
      if (res.households.length === 1) {
        setHouseholdId(res.households[0].id);
      }
    }).catch(() => {});
  }, []);

  const normalizedSerial = serial.trim().toUpperCase();

  const stepLabel = (s: Step) => {
    if (s === "serial") return t("stepSerial");
    if (s === "token") return t("stepToken");
    if (s === "link") return t("stepLink");
    return t("stepDone");
  };

  const handleLocalTest = async () => {
    setLocalLoading(true);
    setError("");
    try {
      await api.createLocalTestDevice({ name: t("title") });
      router.push("/dashboard");
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("registerFailed"));
    } finally {
      setLocalLoading(false);
    }
  };

  const handleCreateToken = async () => {
    if (!normalizedSerial) return;
    setLoading(true);
    setError("");
    try {
      const res = await api.createPairingToken({ serial: normalizedSerial });
      setToken(res.token);
      setStep("token");
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("tokenFailed"));
    } finally {
      setLoading(false);
    }
  };

  const handleRegister = async () => {
    if (!normalizedSerial || !token.trim()) return;
    setLoading(true);
    setError("");
    try {
      const device = await api.registerDevice({
        serial: normalizedSerial,
        token: token.trim(),
        name: name.trim() || undefined,
      });
      setDeviceId(device.id);
      setStep("link");
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("registerFailed"));
    } finally {
      setLoading(false);
    }
  };

  const handleLink = async () => {
    let targetHouseholdId = householdId;

    if (!targetHouseholdId && newHousehold.trim()) {
      setLoading(true);
      setError("");
      try {
        const created = await api.createHousehold({ name: newHousehold.trim() });
        targetHouseholdId = created.id;
      } catch (e) {
        setError(e instanceof ApiError ? e.detail : t("householdFailed"));
        setLoading(false);
        return;
      }
    }

    if (!targetHouseholdId) {
      setError(t("householdRequired"));
      return;
    }

    setLoading(true);
    setError("");
    try {
      await api.linkDevice(deviceId, {
        household_id: targetHouseholdId,
        name: name.trim() || undefined,
      });
      setStep("done");
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("linkFailed"));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-lg mx-auto flex flex-col gap-6">
      <div>
        <Link href="/devices" className="text-sm text-blue-600 hover:underline">
          {t("back")}
        </Link>
        <h1 className="text-xl font-semibold text-gray-900 mt-2">{t("title")}</h1>
        <p className="text-sm text-gray-500 mt-1">{t("subtitle")}</p>
      </div>

      <div className="flex gap-2 text-xs text-gray-500">
        {STEPS.map((s, i) => (
          <span
            key={s}
            className={
              step === s
                ? "font-semibold text-blue-700"
                : i < STEPS.indexOf(step)
                  ? "text-green-600"
                  : ""
            }
          >
            {i + 1}. {stepLabel(s)}
          </span>
        ))}
      </div>

      {error && <ErrorMessage message={error} />}

      <Card className="flex flex-col gap-4">
        {step === "serial" && (
          <>
            <Input
              label={t("serial")}
              placeholder={t("serialPlaceholder")}
              value={serial}
              onChange={(e) => setSerial(e.target.value)}
            />
            <Input
              label={t("name")}
              placeholder={t("namePlaceholder")}
              value={name}
              onChange={(e) => setName(e.target.value)}
            />
            <Button
              onClick={handleCreateToken}
              loading={loading}
              disabled={!normalizedSerial}
            >
              {t("getToken")}
            </Button>
          </>
        )}

        {step === "token" && (
          <>
            <p className="text-sm text-gray-600">
              {t("serialLabel")}: <span className="font-mono font-medium">{normalizedSerial}</span>
            </p>
            <Input
              label={t("token")}
              value={token}
              onChange={(e) => setToken(e.target.value)}
              readOnly={!!token}
            />
            <p className="text-xs text-gray-500">{t("tokenHint")}</p>
            <div className="flex gap-2">
              <Button variant="secondary" onClick={() => setStep("serial")}>
                {tc("back")}
              </Button>
              <Button onClick={handleRegister} loading={loading} disabled={!token.trim()}>
                {t("register")}
              </Button>
            </div>
          </>
        )}

        {step === "link" && (
          <>
            <p className="text-sm text-gray-600">{t("linkHint")}</p>
            {households.length > 0 ? (
              <div className="flex flex-col gap-1.5">
                <label className="text-sm font-medium text-gray-700">{t("household")}</label>
                <select
                  value={householdId}
                  onChange={(e) => setHouseholdId(e.target.value)}
                  className="rounded-lg border border-gray-300 px-3 py-2 text-sm outline-none focus:ring-2 focus:ring-blue-500/40"
                >
                  <option value="">{t("selectHousehold")}</option>
                  {households.map((h) => (
                    <option key={h.id} value={h.id}>
                      {h.name}
                    </option>
                  ))}
                </select>
              </div>
            ) : (
              <Input
                label={t("createHousehold")}
                placeholder={t("namePlaceholder")}
                value={newHousehold}
                onChange={(e) => setNewHousehold(e.target.value)}
              />
            )}
            <Button onClick={handleLink} loading={loading}>
              {t("linkToHousehold")}
            </Button>
          </>
        )}

        {step === "done" && (
          <div className="text-center py-4">
            <p className="text-lg font-semibold text-gray-900">{t("success")}</p>
            <p className="text-sm text-gray-500 mt-2">{t("successHint")}</p>
            <div className="flex gap-2 justify-center mt-6">
              <Button variant="secondary" onClick={() => router.push("/devices")}>
                {t("viewDevices")}
              </Button>
              <Button onClick={() => router.push("/dashboard")}>
                {t("goDashboard")}
              </Button>
            </div>
          </div>
        )}
      </Card>

      <p className="text-xs text-gray-400 text-center">
        {t("wifiHint")}{" "}
        <Link href="/guide" className="text-blue-600 hover:underline">
          {t("setupGuide")}
        </Link>
      </p>

      <Card className="flex flex-col gap-3">
        <p className="text-sm text-gray-700">{t("localTestHint")}</p>
        <Button variant="secondary" loading={localLoading} onClick={handleLocalTest}>
          {t("localTest")}
        </Button>
      </Card>
    </div>
  );
}
