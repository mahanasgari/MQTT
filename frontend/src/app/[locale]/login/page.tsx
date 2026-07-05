"use client";

import { Suspense, useState, useCallback, useEffect } from "react";
import { useSearchParams } from "next/navigation";
import { useAuth } from "@/lib/auth";
import { api, ApiError } from "@/lib/api";
import { isValidE164, formatPhoneError } from "@/lib/validation";
import { LanguageSwitcher } from "@/components/LanguageSwitcher";
import { useTranslations } from "next-intl";
import { useRouter } from "@/i18n/navigation";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { Card } from "@/components/ui/Card";
import { ErrorMessage } from "@/components/ui/ErrorMessage";

function LoginPageContent() {
  const t = useTranslations("login");
  const tc = useTranslations("common");
  const { login, isAuthenticated, isLoading } = useAuth();
  const router = useRouter();
  const searchParams = useSearchParams();
  const isDev = searchParams.has("dev");

  const [step, setStep] = useState<"phone" | "otp">("phone");
  const [phone, setPhone] = useState("");
  const [phoneError, setPhoneError] = useState("");
  const [otp, setOtp] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [expiresIn, setExpiresIn] = useState(0);
  const [retryAfter, setRetryAfter] = useState(0);
  const [countdown, setCountdown] = useState(0);
  const [devOtp, setDevOtp] = useState("");
  const [fetchingDevOtp, setFetchingDevOtp] = useState(false);

  const startCountdown = useCallback((seconds: number) => {
    setCountdown(seconds);
    const interval = setInterval(() => {
      setCountdown((prev) => {
        if (prev <= 1) {
          clearInterval(interval);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
  }, []);

  useEffect(() => {
    if (!isDev || step !== "otp" || !phone || devOtp) return;
    const trimmed = phone.trim();
    if (!isValidE164(trimmed)) return;
    setFetchingDevOtp(true);
    api
      .get<{ phone: string; code: string; expires_at: string }>(
        `/dev/otp/${encodeURIComponent(trimmed)}`,
        true,
      )
      .then((data) => {
        setDevOtp(data.code);
        setOtp(data.code);
      })
      .catch(() => {
        /* dev endpoint unavailable */
      })
      .finally(() => setFetchingDevOtp(false));
  }, [isDev, step, phone, devOtp]);

  if (isAuthenticated && !isLoading) {
    router.push("/dashboard");
    return null;
  }

  const handleSendOtp = async () => {
    const trimmed = phone.trim();
    if (!trimmed) {
      setError(t("errPhoneRequired"));
      return;
    }
    if (!isValidE164(trimmed)) {
      setError(t("errPhoneInvalid"));
      return;
    }
    setError("");
    setLoading(true);
    try {
      const res = await api.sendOtp({ phone: trimmed });
      setExpiresIn(res.expires_in_seconds);
      setRetryAfter(res.retry_after_seconds);
      startCountdown(res.retry_after_seconds);
      setStep("otp");
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("errSendOtp"));
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async () => {
    if (!otp.trim()) {
      setError(t("errOtpRequired"));
      return;
    }
    setError("");
    setLoading(true);
    try {
      const res = await api.verifyOtp({ phone: phone.trim(), code: otp.trim() });
      login(res.access_token, res.refresh_token, phone.trim());
      router.push("/dashboard");
    } catch (e) {
      setError(e instanceof ApiError ? e.detail : t("errInvalidCode"));
    } finally {
      setLoading(false);
    }
  };

  const validatePhone = (value: string) => {
    setPhone(value);
    const err = formatPhoneError(value);
    setPhoneError(err || "");
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
      <div className="absolute top-4 end-4">
        <LanguageSwitcher />
      </div>
      <Card className="w-full max-w-sm">
        <div className="text-center mb-6">
          <h1 className="text-xl font-semibold text-gray-900">{tc("appName")}</h1>
          <p className="text-sm text-gray-500 mt-1">
            {step === "phone" ? t("subtitlePhone") : t("subtitleOtp")}
          </p>
        </div>

        {error && (
          <div className="mb-4">
            <ErrorMessage message={error} />
          </div>
        )}

        {step === "phone" ? (
          <div className="flex flex-col gap-4">
            <Input
              label={t("phone")}
              type="tel"
              placeholder={t("phoneHint")}
              value={phone}
              error={phoneError}
              onChange={(e) => validatePhone(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && handleSendOtp()}
            />
            <Button
              onClick={handleSendOtp}
              loading={loading}
              disabled={!isValidE164(phone.trim())}
              className="w-full"
            >
              {t("sendOtp")}
            </Button>
          </div>
        ) : (
          <div className="flex flex-col gap-4">
            <p className="text-sm text-gray-500 text-center">
              {t("codeSentTo")} <span className="font-medium text-gray-900">{phone}</span>
            </p>

            {isDev && (
              <div className="rounded border border-yellow-300 bg-yellow-50 px-3 py-2 text-xs text-yellow-800">
                {fetchingDevOtp
                  ? t("devFetching")
                  : devOtp
                    ? t("devFilled", { code: devOtp })
                    : t("devUnavailable")}
              </div>
            )}

            <Input
              label={t("otp")}
              type="text"
              inputMode="numeric"
              placeholder="123456"
              maxLength={6}
              value={otp}
              onChange={(e) => setOtp(e.target.value.replace(/\D/g, ""))}
              onKeyDown={(e) => e.key === "Enter" && handleVerifyOtp()}
            />
            <Button onClick={handleVerifyOtp} loading={loading} className="w-full">
              {t("verify")}
            </Button>
            <div className="flex items-center justify-between text-sm">
              <button
                onClick={() => setStep("phone")}
                className="text-blue-600 hover:underline"
              >
                {t("changeNumber")}
              </button>
              {countdown > 0 ? (
                <span className="text-gray-400">{t("resendIn", { sec: countdown })}</span>
              ) : (
                <button
                  onClick={handleSendOtp}
                  className="text-blue-600 hover:underline"
                >
                  {t("resendCode")}
                </button>
              )}
            </div>
          </div>
        )}

        <p className="text-xs text-gray-400 text-center mt-6">{t("footer")}</p>

        {!isDev && step === "phone" && (
          <p className="text-xs text-gray-400 text-center mt-2">{t("devHint")}</p>
        )}
      </Card>
    </div>
  );
}

export default function LoginPage() {
  const tc = useTranslations("common");
  return (
    <Suspense fallback={
      <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
        <Card className="w-full max-w-sm">
          <div className="text-center mb-6">
            <h1 className="text-xl font-semibold text-gray-900">{tc("appName")}</h1>
            <p className="text-sm text-gray-500 mt-1">{tc("loading")}</p>
          </div>
        </Card>
      </div>
    }>
      <LoginPageContent />
    </Suspense>
  );
}
