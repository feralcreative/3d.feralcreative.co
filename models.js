import { modelPreviews } from "./model-previews.js";
import { ModelAdmin } from "./model-admin.js";

class ModelLibrary {
  constructor() {
    this.page = document.getElementById("models-page");
    this.search = document.getElementById("model-search");
    this.list = document.getElementById("models-list");
    this.status = document.getElementById("models-status");
    this.retry = document.getElementById("models-retry");
    this.models = [];
    this.notes = [];
    this.request = null;
    this.authenticated = false;

    document.title = "Models | Feral Creative";
    document.querySelector(".login-container h1").textContent = "Models";
    document.querySelector(".login-container p").textContent = "Sign in with your Google account to view the models.";
    this.search.addEventListener("input", () => this.render());
    this.retry.addEventListener("click", () => this.load());
  }

  setAuthenticated(authenticated) {
    this.authenticated = authenticated;
    this.page.style.display = authenticated ? "block" : "none";
    if (authenticated) {
      this.load();
    } else {
      this.request?.abort();
      this.models = [];
      this.list.replaceChildren();
    }
  }

  async load() {
    if (!this.authenticated) return;
    this.request?.abort();
    const request = new AbortController();
    this.request = request;
    this.models = [];
    this.notes = [];
    this.list.replaceChildren();
    this.search.disabled = true;
    this.retry.hidden = true;
    this.status.textContent = "Loading models…";

    const [catalogResult] = await Promise.allSettled([
      window.modelCatalog.load(true),
    ]);
    if (request.signal.aborted) return;

    if (catalogResult.status === "rejected") {
      this.status.textContent = "Could not load the model list. Check your connection and try again.";
      this.retry.hidden = false;
      return;
    }

    const catalog = catalogResult.status === "fulfilled" ? catalogResult.value : null;
    if (!catalog) this.notes.push("The model catalog could not be loaded.");

    this.models = (catalog?.models || []).filter((model) => !model.hidden && model.hasScad && model.id !== "no-model-loaded" && model.defaultViewId && model.views.some((view) => view.supported)).map((model) => ({
      model,
      search: [model.id, model.title, model.website.description, ...model.website.parts.map((part) => part.name), ...model.category, ...model.aliases, ...model.views.map((view) => view.file),
        ...model.downloads.map((download) => download.file)].join(" ").toLocaleLowerCase(),
    })).sort((a, b) => a.model.title.localeCompare(b.model.title, undefined, { numeric: true, sensitivity: "base" }));

    this.search.disabled = false;
    if (this.notes.length) this.retry.hidden = false;
    this.render();
  }

  render() {
    const query = this.search.value.trim().toLocaleLowerCase();
    const models = this.models.filter((entry) => entry.search.includes(query));

    this.list.replaceChildren(...models.map(({ model }) => this.modelRow(model)));
    modelPreviews.prune();
    this.list.hidden = !models.length;

    const total = this.models.length;
    const visible = models.length;
    let text;
    if (!total) {
      text = "No models are available yet.";
    } else if (!visible) {
      text = "No models match your search.";
    } else {
      text = query ? `${visible} of ${total} models` : `${total} models`;
    }
    this.status.textContent = [text, ...this.notes].join(" ");
  }

  modelRow(model) {
    const defaultView = model.views.find((view) => view.id === model.defaultViewId);
    const count = model.views.filter((view) => view.supported).length;
    return this.row(model.id, model.title, model.category.join(" / "), defaultView, model.website.description, count);
  }

  /**
   * @param {string} key - Value for the model query parameter
   * @param {string} title - Primary label
   * @param {string} meta - Secondary line, such as the category
   * @param {object} view - The main browser-viewable model
   */
  row(key, title, meta, view, description = "", count = 1) {
    const row = document.createElement("li");
    const link = document.createElement("a");
    const url = new URL(window.location);
    url.searchParams.set("model", key);
    url.searchParams.delete("view");
    link.href = url.pathname + url.search;
    link.className = "model-link model-card";
    link.appendChild(modelPreviews.create(view, title));

    const name = document.createElement("span");
    name.className = "model-card-content";
    const titleText = document.createElement("h2");
    titleText.className = "model-card-title";
    titleText.textContent = title;
    name.appendChild(titleText);
    if (meta) {
      const metaText = document.createElement("span");
      metaText.className = "model-meta";
      metaText.textContent = meta;
      name.appendChild(metaText);
    }
    if (description) {
      const copy = document.createElement("p");
      copy.className = "model-card-description";
      copy.textContent = description;
      name.appendChild(copy);
    }
    const details = document.createElement("span");
    details.className = "model-card-footer";
    details.textContent = `${count} ${count === 1 ? "view" : "views"}${Number.isFinite(view.bytes) ? ` · ${window.formatModelBytes(view.bytes)}` : ""}`;
    name.appendChild(details);
    link.appendChild(name);

    link.addEventListener("click", (event) => {
      if (event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
      event.preventDefault();
      if (this.authenticated) window.modelViewer.openModal(key);
    });
    row.appendChild(link);
    return row;
  }
}

if (/^\/models\/?$/.test(window.location.pathname)) {
  window.modelLibrary = new ModelLibrary();
  window.modelAdmin = new ModelAdmin(window.modelLibrary);
}
