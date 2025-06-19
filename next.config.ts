import type { NextConfig } from "next";
import nextra from "nextra";

const nextConfig: NextConfig = {};

const withNextra = nextra({
  search: { codeblocks: false },
  defaultShowCopyCode: true,
});

export default withNextra(nextConfig);
