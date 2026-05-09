import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "نِصاب — مقارنة هوامش الربح البنكية",
  description: "منصة سعودية لمقارنة هوامش الربح عبر 11 بنك سعودي بدقة 95% عبر Grok",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ar" dir="rtl">
      <body>{children}</body>
    </html>
  );
}
