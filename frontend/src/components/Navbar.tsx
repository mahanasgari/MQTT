"use client";

import { useTranslations } from "next-intl";
import { Link, usePathname } from "@/i18n/navigation";
import { useState, useEffect } from "react";
import { useAuth } from "@/lib/auth";
import { api } from "@/lib/api";
import { HelpPanel } from "@/components/HelpPanel";
import { LanguageSwitcher } from "@/components/LanguageSwitcher";

const links = [
  { href: "/dashboard", key: "dashboard" as const },
  { href: "/devices", key: "devices" as const },
  { href: "/shares", key: "shares" as const },
];

export function Navbar() {
  const t = useTranslations("nav");
  const tc = useTranslations("common");
  const { user, logout } = useAuth();
  const pathname = usePathname();
  const [helpOpen, setHelpOpen] = useState(false);
  const [isAdmin, setIsAdmin] = useState(false);

  useEffect(() => {
    api.adminStats().then(() => setIsAdmin(true)).catch(() => setIsAdmin(false));
  }, [user]);

  return (
    <>
      <nav className="border-b bg-white sticky top-0 z-40">
        <div className="max-w-6xl mx-auto px-4 h-14 flex items-center justify-between">
          <div className="flex items-center gap-1">
            <Link
              href="/dashboard"
              className="font-semibold text-lg me-6 text-gray-900"
            >
              {tc("appName")}
            </Link>
            {links.map((l) => (
              <Link
                key={l.href}
                href={l.href}
                className={`px-3 py-1.5 rounded-md text-sm font-medium transition-colors ${
                  pathname.startsWith(l.href)
                    ? "bg-blue-50 text-blue-700"
                    : "text-gray-600 hover:text-gray-900 hover:bg-gray-50"
                }`}
              >
                {t(l.key)}
              </Link>
            ))}
            {isAdmin && (
              <Link
                href="/admin"
                className={`px-3 py-1.5 rounded-md text-sm font-medium transition-colors ${
                  pathname.startsWith("/admin")
                    ? "bg-purple-50 text-purple-700"
                    : "text-gray-600 hover:text-gray-900 hover:bg-gray-50"
                }`}
              >
                {tc("admin")}
              </Link>
            )}
          </div>
          <div className="flex items-center gap-3">
            <LanguageSwitcher />
            <button
              type="button"
              onClick={() => setHelpOpen(true)}
              className="text-sm text-gray-600 hover:text-gray-900"
            >
              {tc("help")}
            </button>
            <span className="text-sm text-gray-500">{user?.phone}</span>
            <button
              onClick={logout}
              className="text-sm text-red-600 hover:underline"
            >
              {tc("logout")}
            </button>
          </div>
        </div>
      </nav>
      <HelpPanel open={helpOpen} onClose={() => setHelpOpen(false)} />
    </>
  );
}
