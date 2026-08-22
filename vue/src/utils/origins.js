const resolveOrigin = (envValue, fallback) => {
  if (envValue && envValue.trim().length) {
    return envValue.trim().replace(/\/+$/, "");
  }
  return fallback.replace(/\/+$/, "");
};

const marketingOrigin = resolveOrigin(
  import.meta.env.VITE_MARKETING_ORIGIN,
  import.meta.env.DEV ? "http://localhost:5173/marketing" : "/marketing"
);

const adminOrigin = resolveOrigin(
  import.meta.env.VITE_MARKETING_ADMIN_ORIGIN,
  import.meta.env.DEV ? "http://localhost:4001/marketing/admin" : "/marketing/admin"
);

const buildUrl = (origin, path = "/", ensureTrailingSlash = false) => {
  const base = origin.replace(/\/+$/, "");
  if (!path || path === "/") {
    return ensureTrailingSlash ? `${base}/` : base;
  }
  if (path.startsWith("?") || path.startsWith("#")) {
    return `${base}${path}`;
  }
  return `${base}/${path.replace(/^\/+/, "")}`;
};

export const marketingUrl = (path = "/") => buildUrl(marketingOrigin, path, true);
export const adminUrl = (path = "/") => buildUrl(adminOrigin, path);
