import nextra from "nextra";

const withNextra = nextra({
  search: false,
});

export default withNextra({
  eslint: {
    // Warning: This allows production builds to successfully complete even if
    // your project has ESLint errors.
    ignoreDuringBuilds: true,
  },
});
