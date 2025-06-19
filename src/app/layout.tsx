import type { Metadata } from "next";
import "./globals.css";
import { Analytics } from "@vercel/analytics/next";

import { Footer, Layout, Navbar } from "nextra-theme-docs";
import { Head } from "nextra/components";
import { getPageMap } from "nextra/page-map";

export const metadata: Metadata = {
  title: {
    default: "CTS Document",
    template: "%s - CTS Document",
  },
};

const navbar = (
  <Navbar
    logo={<p>CTS Document</p>}
    projectLink={"https://github.com/teerakanotk/docs"}
  />
);
const footer = <Footer>© {new Date().getFullYear()} CTS Document</Footer>;

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" dir="ltr" suppressHydrationWarning>
      <Head />
      <body>
        <Layout
          navbar={navbar}
          pageMap={await getPageMap()}
          docsRepositoryBase="https://github.com/teerakanotk/docs/tree/main"
          footer={footer}
          search={false}
          sidebar={{ autoCollapse: true, toggleButton: false }}
        >
          {children}
        </Layout>
        <Analytics />
      </body>
    </html>
  );
}
