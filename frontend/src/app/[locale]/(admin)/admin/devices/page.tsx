"use client";

import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";
import { api } from "@/lib/api";
import { Card } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Spinner } from "@/components/ui/Spinner";
import type { DeviceResponse } from "@/types";

export default function AdminDevicesPage() {
  const t = useTranslations("admin");
  const tc = useTranslations("common");
  const [devices, setDevices] = useState<DeviceResponse[]>([]);
  const [loading, setLoading] = useState(true);
  const [serial, setSerial] = useState("");
  const [seedSerial, setSeedSerial] = useState("");
  const [tokenSerial, setTokenSerial] = useState("");
  const [createdToken, setCreatedToken] = useState("");
  const [msg, setMsg] = useState("");

  const load = () => {
    setLoading(true);
    api.adminListDevices({ serial: serial || undefined, limit: 100 })
      .then((r) => setDevices(r.devices))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    load();
  }, []);

  const handleSeed = async () => {
    if (!seedSerial.trim()) return;
    try {
      await api.adminCreateDevice({ serial: seedSerial.trim().toUpperCase() });
      setMsg(`Device ${seedSerial} created`);
      setSeedSerial("");
      load();
    } catch (e) {
      setMsg(String(e));
    }
  };

  const handleToken = async () => {
    try {
      const res = await api.adminCreatePairingToken({
        serial: tokenSerial.trim() ? tokenSerial.trim().toUpperCase() : undefined,
      });
      setCreatedToken(res.token);
      setMsg(t("tokenCreated"));
    } catch (e) {
      setMsg(String(e));
    }
  };

  return (
    <div className="flex flex-col gap-6">
      <h1 className="text-xl font-semibold">{t("devices")}</h1>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Card className="flex flex-col gap-3">
          <h2 className="font-medium">{t("seedDevice")}</h2>
          <Input
            label={t("serial")}
            placeholder="SN-2026-000001"
            value={seedSerial}
            onChange={(e) => setSeedSerial(e.target.value)}
          />
          <Button onClick={handleSeed}>{tc("create")}</Button>
        </Card>
        <Card className="flex flex-col gap-3">
          <h2 className="font-medium">{t("createToken")}</h2>
          <Input
            label={t("serial")}
            placeholder="SN-2026-000001 (optional)"
            value={tokenSerial}
            onChange={(e) => setTokenSerial(e.target.value)}
          />
          <Button variant="secondary" onClick={handleToken}>{t("createToken")}</Button>
          {createdToken && (
            <p className="text-xs font-mono break-all bg-gray-100 p-2 rounded">{createdToken}</p>
          )}
        </Card>
      </div>

      {msg && <p className="text-sm text-green-700">{msg}</p>}

      <div className="flex gap-2">
        <Input
          placeholder={tc("search")}
          value={serial}
          onChange={(e) => setSerial(e.target.value)}
        />
        <Button onClick={load}>{tc("search")}</Button>
      </div>

      {loading ? (
        <Spinner className="h-8 w-8 mx-auto" />
      ) : (
        <Card padding={false}>
          <table className="w-full text-sm">
            <thead className="border-b bg-gray-50">
              <tr>
                <th className="text-start p-3">{t("serial")}</th>
                <th className="text-start p-3">Name</th>
                <th className="text-start p-3">Household</th>
                <th className="text-start p-3">State</th>
              </tr>
            </thead>
            <tbody>
              {devices.map((d) => (
                <tr key={d.id} className="border-b last:border-0">
                  <td className="p-3 font-mono">{d.serial}</td>
                  <td className="p-3">{d.name || "—"}</td>
                  <td className="p-3 text-xs">{d.household_id || "—"}</td>
                  <td className="p-3">
                    {d.state ? `${d.state.power} / ${d.state.connectivity}` : "—"}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </Card>
      )}
    </div>
  );
}
