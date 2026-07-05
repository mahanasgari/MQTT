const E164_REGEX = /^\+[1-9]\d{6,14}$/;

export function isValidE164(phone: string): boolean {
  return E164_REGEX.test(phone.trim());
}

export function formatPhoneError(phone: string): string | null {
  const trimmed = phone.trim();
  if (!trimmed) return "Phone number is required";
  if (!isValidE164(trimmed)) return "Must be in E.164 format (e.g. +8613800138000)";
  return null;
}
