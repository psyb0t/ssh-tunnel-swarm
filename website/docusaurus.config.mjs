const repository = "https://github.com/psyb0t/ssh-tunnel-swarm";
const baseUrl = "/ssh-tunnel-swarm/";
const docsPath = "../docs";

export default {
  title: "ssh-tunnel-swarm",
  tagline: "Many SSH tunnels from one rules file",
  url: "https://psyb0t.github.io",
  baseUrl,
  trailingSlash: true,
  future: { faster: { rspackBundler: true, swcJsLoader: true } },
  organizationName: "psyb0t",
  projectName: "ssh-tunnel-swarm",
  onBrokenLinks: "throw",
  onBrokenAnchors: "throw",
  markdown: { format: "detect", hooks: { onBrokenMarkdownLinks: "throw" } },
  scripts: [{ src: "https://psyb0t.github.io/analytics.js", async: true }],
  presets: [
    ["classic", {
      blog: false,
      sitemap: { ignorePatterns: [baseUrl + "search", baseUrl + "search/"] },
      theme: { customCss: "./src/css/theme.css" },
      docs: {
        path: docsPath,
        routeBasePath: "/",
        sidebarPath: "./sidebars.mjs",
        editUrl: ({ docPath }) => repository + "/edit/master/docs/" + docPath,
      },
    }],
  ],
  themes: [
    ["@easyops-cn/docusaurus-search-local", {
      docsDir: docsPath,
      docsRouteBasePath: "/",
      indexBlog: false,
      hashed: true,
    }],
  ],
  themeConfig: {
    navbar: {
      items: [
        { href: "https://psyb0t.github.io/projects/", label: "All projects", position: "left" },
        { href: repository + "/blob/master/CHANGELOG.md", label: "Changelog", position: "right" },
        { href: repository, label: "GitHub", position: "right" },
      ],
    },
    colorMode: { defaultMode: "dark" },
  },
};
