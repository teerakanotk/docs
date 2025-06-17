import nextra from "nextra";

const withNextra = nextra({
  search: { codeblocks: false },
  defaultShowCopyCode: true,
});

const nextConfig = {};

export default withNextra(nextConfig);
