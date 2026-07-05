"use client";

import { useEffect, useState } from "react";
import { Link } from "@/i18n/navigation";
import { useTranslations } from "next-intl";

interface HelpPanelProps {
  open: boolean;
  onClose: () => void;
}

const SECTION_KEYS = ["login", "household", "addDevice", "control", "share"] as const;

export function HelpPanel({ open, onClose }: HelpPanelProps) {
  const t = useTranslations("help");
  const tc = useTranslations("common");
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    if (open) {
      setVisible(true);
      document.body.style.overflow = "hidden";
    } else {
      document.body.style.overflow = "";
      const timer = setTimeout(() => setVisible(false), 200);
      return () => clearTimeout(timer);
    }
    return () => {
      document.body.style.overflow = "";
    };
  }, [open]);

  if (!open && !visible) return null;

  return (
    <div className="fixed inset-0 z-50 flex justify-end">
      <button
        type="button"
        aria-label={t("closeAria")}
        className={`absolute inset-0 bg-black/30 transition-opacity ${
          open ? "opacity-100" : "opacity-0"
        }`}
        onClick={onClose}
      />
      <aside
        className={`relative w-full max-w-md bg-white shadow-xl h-full overflow-y-auto transition-transform ${
          open ? "translate-x-0" : "translate-x-full"
        }`}
      >
        <div className="sticky top-0 bg-white border-b px-5 py-4 flex items-center justify-between">
          <h2 className="text-lg font-semibold text-gray-900">{t("title")}</h2>
          <button
            type="button"
            onClick={onClose}
            className="text-gray-500 hover:text-gray-800 text-sm"
          >
            {tc("close")}
          </button>
        </div>
        <div className="px-5 py-4 flex flex-col gap-4">
          {SECTION_KEYS.map((key) => (
            <div key={key}>
              <h3 className="text-sm font-semibold text-gray-800">
                {t(`sections.${key}.title`)}
              </h3>
              <p className="text-sm text-gray-600 mt-1">
                {t(`sections.${key}.body`)}
              </p>
            </div>
          ))}
          <div className="pt-2 border-t">
            <Link
              href="/guide"
              onClick={onClose}
              className="text-sm font-medium text-blue-600 hover:underline"
            >
              {t("fullGuide")}
            </Link>
          </div>
        </div>
      </aside>
    </div>
  );
}
