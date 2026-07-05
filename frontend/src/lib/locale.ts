/** Resolve locale prefix for client-side redirects (auth, API 401). */
export function getLocalePrefix(): "en" | "fa" {
  if (typeof window === "undefined") return "fa";
  const match = window.location.pathname.match(/^\/(en|fa)(\/|$)/);
  if (match) return match[1] as "en" | "fa";
  const stored = localStorage.getItem("locale");
  if (stored === "en" || stored === "fa") return stored;
  return "fa";
}

export function localizedLoginPath(): string {
  return `/${getLocalePrefix()}/login`;
}
