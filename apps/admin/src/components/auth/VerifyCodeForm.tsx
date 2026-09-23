"use client";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import Cookies from "js-cookie";

import axios from "axios";
import axiosSecure from "@/components/hook/axiosSecure";

export default function VerifyCodeForm() {
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [code, setCode] = useState(["", "", "", "", "", ""]);
  const [error, setError] = useState("");

  const handleChange = (index: number, value: string) => {
    const char = value.slice(-1);
    const newCode = [...code];
    newCode[index] = char;
    setCode(newCode);

    if (char && index < 5) {
      const nextInput = document.getElementById(`code-${index + 1}`);
      nextInput?.focus();
    }
  };

  const handleKeyDown = (index: number, e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === "Backspace") {
      if (!code[index] && index > 0) {
        const newCode = [...code];
        newCode[index - 1] = "";
        setCode(newCode);
        const prevInput = document.getElementById(`code-${index - 1}`);
        prevInput?.focus();
      }
    } else if (e.key === "ArrowLeft" && index > 0) {
      e.preventDefault();
      document.getElementById(`code-${index - 1}`)?.focus();
    } else if (e.key === "ArrowRight" && index < 5) {
      e.preventDefault();
      document.getElementById(`code-${index + 1}`)?.focus();
    }
  };

  const handlePaste = (e: React.ClipboardEvent<HTMLInputElement>) => {
    e.preventDefault();
    const pastedData = e.clipboardData.getData("text").trim();
    const cleanData = pastedData.replace(/[^a-zA-Z0-9]/g, "").slice(0, 6);
    if (!cleanData) return;

    const newCode = [...code];
    for (let i = 0; i < 6; i++) {
      newCode[i] = cleanData[i] || "";
    }
    setCode(newCode);

    const focusIndex = Math.min(cleanData.length, 5);
    const targetInput = document.getElementById(`code-${focusIndex}`);
    targetInput?.focus();
  };

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError("");

    const otp = code.join("");
    const email = localStorage.getItem("reset_email");

    if (!email) {
      setError("Session expired. Please try resetting password again.");
      setLoading(false);
      return;
    }

    if (otp.length < 6) {
      setError("Please enter the complete 6-digit verification code.");
      setLoading(false);
      return;
    }

    const numericCode = Number(otp);
    if (isNaN(numericCode)) {
      setError("Please enter a valid numeric code.");
      setLoading(false);
      return;
    }

    try {
      const response = await axiosSecure.post("/auth/verify-email", {
        email,
        oneTimeCode: numericCode,
      });

      if (response.data?.success || response.status === 200) {
        localStorage.setItem("reset_otp", otp);

        // Store reset token if returned in response
        const responseData = response.data;
        const token =
          responseData?.token ||
          responseData?.data?.token ||
          responseData?.accessToken ||
          responseData?.data?.accessToken;

        if (token && typeof token === "string") {
          Cookies.set("token", token, { expires: 1 });
          localStorage.setItem("reset_token", token);
        }

        router.push("/new-password");
      } else {
        setError("Invalid verification code.");
      }
    } catch (err: unknown) {
      let msg = "Verification failed.";
      if (axios.isAxiosError(err) && err.response?.data?.message) {
        msg = err.response.data.message;
      } else if (err instanceof Error) {
        msg = err.message;
      }
      setError(msg);
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="w-full">
      <div className="text-center mb-10">
        <h1 className="text-3xl font-bold mb-2 text-white">Verify Reset Password</h1>
        <p className="text-white/50">
          Enter the 6-digit code sent to your email to reset your password.
        </p>
      </div>

      <form onSubmit={onSubmit} className="space-y-8">
        <div className="grid grid-cols-6 gap-2 sm:gap-3 justify-center">
          {code.map((digit, index) => (
            <input
              key={index}
              id={`code-${index}`}
              type="text"
              inputMode="numeric"
              autoComplete="one-time-code"
              maxLength={1}
              value={digit}
              onChange={(e) => handleChange(index, e.target.value)}
              onKeyDown={(e) => handleKeyDown(index, e)}
              onPaste={handlePaste}
              className="w-full h-14 sm:h-16 bg-[#111827] border border-white/10 rounded-xl text-center text-xl sm:text-2xl font-bold text-white focus:border-blue-500 focus:ring-1 focus:ring-blue-500 outline-none transition-all"
            />
          ))}
        </div>

        {error && <div className="text-red-500 text-sm mt-2">{error}</div>}

        <Button
          type="submit"
          variant="premium"
          className="w-full h-12 text-base"
          disabled={loading}
        >
          {loading ? "Verifying..." : "Verify Code"}
        </Button>
      </form>
    </div>
  );
}

