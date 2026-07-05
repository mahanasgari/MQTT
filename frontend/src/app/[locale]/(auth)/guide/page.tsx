"use client";

import { Link } from "@/i18n/navigation";
import { useTranslations } from "next-intl";
import { Card } from "@/components/ui/Card";
import { Button } from "@/components/ui/Button";

const SECTION_IDS = [
  "login",
  "household",
  "addDevice",
  "control",
  "share",
  "troubleshoot",
] as const;

export default function GuidePage() {
  const t = useTranslations("guide");

  return (
    <div className="max-w-2xl mx-auto flex flex-col gap-6">
      <div>
        <Link href="/dashboard" className="text-sm text-blue-600 hover:underline">
          {t("backDashboard")}
        </Link>
        <h1 className="text-xl font-semibold text-gray-900 mt-2">{t("title")}</h1>
        <p className="text-sm text-gray-500 mt-1">{t("subtitle")}</p>
      </div>

      <div className="flex gap-2">
        <Link href="/devices/add">
          <Button size="sm">{t("addDevice")}</Button>
        </Link>
        <Link href="/shares">
          <Button variant="secondary" size="sm">{t("manageShares")}</Button>
        </Link>
      </div>

      <div className="flex flex-col gap-4">
        {SECTION_IDS.map((id) => {
          const steps = t.raw(`sections.${id}.steps`) as string[];
          return (
            <div key={id} id={id}>
              <Card>
                <h2 className="text-base font-semibold text-gray-900">
                  {t(`sections.${id}.title`)}
                </h2>
                <ol className="mt-3 list-decimal list-inside flex flex-col gap-2">
                  {steps.map((step) => (
                    <li key={step} className="text-sm text-gray-600 leading-relaxed">
                      {step}
                    </li>
                  ))}
                </ol>
              </Card>
            </div>
          );
        })}
      </div>
    </div>
  );
}
