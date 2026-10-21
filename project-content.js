// Project copy stays plain text. Authored links are validated before reaching the DOM.
export function safeProjectUrl(value) {
  try {
    const url = new URL(value);
    return url.protocol === "https:" && !url.username && !url.password ? url : null;
  } catch {
    return null;
  }
}

export function normalizeProject(raw = {}) {
  const text = (value) => typeof value === "string" ? value : "";
  const items = (value) => Array.isArray(value) ? value.filter((item) => item && typeof item === "object") : [];
  return {
    description: text(raw?.description),
    instructions: items(raw?.instructions).map((item) => ({ title: text(item.title), text: text(item.text) })).filter((item) => item.text),
    parts: items(raw?.parts).map((item) => ({
      name: text(item.name), quantity: text(item.quantity), specification: text(item.specification),
      url: safeProjectUrl(item.url)?.href || "",
    })).filter((item) => item.name),
    links: items(raw?.links).map((item) => ({ label: text(item.label), url: safeProjectUrl(item.url)?.href || "" })).filter((item) => item.label && item.url),
  };
}

export function productLink(value, tag = "") {
  const url = safeProjectUrl(value);
  if (!url) return null;
  const amazon = url.hostname === "amazon.com" || url.hostname.endsWith(".amazon.com");
  if (amazon && /^[a-zA-Z0-9-]+$/.test(tag)) url.searchParams.set("tag", tag);
  return { href: url.href, affiliate: amazon && Boolean(url.searchParams.get("tag")), amazon };
}

function element(tag, text, className) {
  const node = document.createElement(tag);
  if (text) node.textContent = text;
  if (className) node.className = className;
  return node;
}

export function renderProjectContent(container, model, settings = {}) {
  container.replaceChildren();
  const project = model?.website;
  if (!project) { container.hidden = true; return; }
  const section = (title) => {
    const node = element("section");
    node.appendChild(element("h4", title));
    container.appendChild(node);
    return node;
  };
  if (project.description) section("About this project").appendChild(element("p", project.description));
  if (project.instructions.length) {
    const instructions = section("Printing & assembly");
    for (const instruction of project.instructions) {
      if (instruction.title) instructions.appendChild(element("h5", instruction.title));
      instructions.appendChild(element("p", instruction.text));
    }
  }
  let hasAffiliate = false;
  if (project.parts.length) {
    const parts = section("Parts & supplies");
    const list = element("ul", "", "project-parts");
    for (const part of project.parts) {
      const item = element("li");
      item.appendChild(element("strong", `${part.quantity ? `${part.quantity} × ` : ""}${part.name}`));
      if (part.specification) item.appendChild(element("p", part.specification));
      const product = productLink(part.url, settings.amazon_affiliate_tag);
      if (product) {
        const link = element("a", product.amazon ? "View on Amazon ↗" : "View product ↗");
        link.href = product.href;
        link.target = "_blank";
        link.rel = product.affiliate ? "sponsored noopener noreferrer" : "noopener noreferrer";
        item.appendChild(link);
        hasAffiliate ||= product.affiliate;
      }
      list.appendChild(item);
    }
    parts.appendChild(list);
    if (hasAffiliate) parts.appendChild(element("p", "As an Amazon Associate I earn from qualifying purchases.", "affiliate-disclosure"));
  }
  if (project.links.length) {
    const links = section("Project links");
    for (const item of project.links) {
      const link = element("a", `${item.label} ↗`, "project-source-link");
      link.href = item.url;
      link.target = "_blank";
      link.rel = "noopener noreferrer";
      links.appendChild(link);
    }
  }
  container.hidden = !container.childElementCount;
}
