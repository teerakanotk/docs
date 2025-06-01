import type { MetaRecord } from "nextra";

const PROXMOX: MetaRecord = {
  index: {
    title: "Installation",
  },
  repository: {
    title: "Repository",
  },
};

const TECHNITIUM: MetaRecord = {
  index: {
    title: "Installation",
  },
  dns: {
    title: "DNS",
  },
};

const NPM: MetaRecord = {
  index: {
    title: "Nginx Proxy Manager",
  },
};

export default {
  proxmox: { items: PROXMOX },
  technitium: { items: TECHNITIUM },
  // npm: { items: NPM },
};
