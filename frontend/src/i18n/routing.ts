import { defineRouting } from "next-intl/routing";

export const routing = defineRouting({
  locales: ["en", "fa"],
  defaultLocale: (process.env.NEXT_PUBLIC_DEFAULT_LOCALE as "en" | "fa") || "fa",
  localePrefix: "always",
});

export type Locale = (typeof routing.locales)[number];
