"use client";

import { useAuth } from "@/lib/auth";
import { useRouter, Link } from "@/i18n/navigation";
import { useEffect, useState } from "react";
import { useTranslations } from "next-intl";
import { api, ApiError } from "@/lib/api";
import { Spinner } from "@/components/ui/Spinner";
import { LanguageSwitcher } from "@/components/LanguageSwitcher";

export default function AdminLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const { isAuthenticated, isLoading } = useAuth();
  const router = useRouter();
  const t = useTranslations("admin");
  const tc = useTranslations("common");
  const [allowed, setAllowed] = useState<boolean | null>(null);

  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      router.push("/login");
      return;
    }
    if (isAuthenticated) {
      api.adminStats()
        .then(() => setAllowed(true))
        .catch((e) => {
          if (e instanceof ApiError && e.status === 403) {
            setAllowed(false);
            router.push("/dashboard");
          } else {
            setAllowed(false);
          }
        });
    }
  }, [isAuthenticated, isLoading, router]);

  if (isLoading || allowed === null) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <Spinner className="h-8 w-8" />
      </div>
    );
  }

  if (!allowed) return null;

  const nav = [
    { href: "/admin", label: t("stats") },
    { href: "/admin/users", label: t("users") },
    { href: "/admin/devices", label: t("devices") },
    { href: "/admin/households", label: t("households") },
    { href: "/admin/events", label: t("events") },
  ];

  return (
    <div className="min-h-screen flex flex-col bg-gray-50">
      <header className="border-b bg-white">
        <div className="max-w-6xl mx-auto px-4 h-14 flex items-center justify-between">
          <div className="flex items-center gap-4">
            <span className="font-semibold text-purple-800">{t("title")}</span>
            <nav className="flex gap-1">
              {nav.map((item) => (
                <Link
                  key={item.href}
                  href={item.href}
                  className="px-2 py-1 text-sm text-gray-600 hover:text-purple-700 rounded"
                >
                  {item.label}
                </Link>
              ))}
            </nav>
          </div>
          <div className="flex items-center gap-3">
            <LanguageSwitcher />
            <Link href="/dashboard" className="text-sm text-blue-600 hover:underline">
              {t("backToApp")}
            </Link>
          </div>
        </div>
      </header>
      <main className="flex-1 max-w-6xl w-full mx-auto px-4 py-6">{children}</main>
    </div>
  );
}
