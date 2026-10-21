/**
 * 3D Model Viewer Module
 * Handles displaying 3D models in a modal overlay using online-3d-viewer
 */
import { normalizeProject, renderProjectContent } from "./project-content.js";
import { modelPreviews } from "./model-previews.js";

// Formats the site previews, with the up axis each online-3d-viewer importer
// assumes. The viewer rotates a Z-up import into its Y-up scene by itself.
// STEP, 3DM, and FCStd also have importers, but they fetch OCCT or rhino3dm from
// cdn.jsdelivr.net at runtime, so those views are listed as download-only.
const IMPORTER_UP = { stl: "Z", "3mf": "Z", glb: "Y", gltf: "Y", obj: "Y", ply: "Y", off: "Y" };
const UNIT_TO_MM = { mm: 1, m: 1000 };
const AVAILABILITY = new Set(["viewable", "no-mesh", "withheld"]);

function isBasename(name) {
  return typeof name === "string" && name !== "" && name !== "." && name !== ".." && !/[\/\\\0]/.test(name);
}

function fileStem(name) {
  return name.replace(/\.[^.]+$/, "");
}

function fileExtension(name) {
  const match = /\.([^.]+)$/.exec(name);
  return match ? match[1].toLowerCase() : "";
}

function formatBytes(bytes) {
  if (!Number.isFinite(bytes)) return "";
  return bytes < 1048576 ? `${Math.max(1, Math.round(bytes / 1024))} KB` : `${(bytes / 1048576).toFixed(1)} MB`;
}

function validBounds(bounds) {
  const triple = (value) => Array.isArray(value) && value.length === 3 && value.every(Number.isFinite);
  return bounds && triple(bounds.min) && triple(bounds.max) ? { min: bounds.min, max: bounds.max } : null;
}

function normalizeView(raw) {
  if (!raw || typeof raw.id !== "string" || !isBasename(raw.file)) return null;
  const format = (typeof raw.format === "string" ? raw.format : fileExtension(raw.file)).toLowerCase();
  if (!format) return null;
  // glTF is metres and Y-up by specification; every other format here is mm and Z-up from OpenSCAD.
  const gltf = format === "glb" || format === "gltf";
  const upAxis = typeof raw.up_axis === "string" ? raw.up_axis.toUpperCase() : "";
  return {
    id: raw.id,
    hidden: raw.hidden === true,
    label: typeof raw.label === "string" && raw.label ? raw.label : raw.id,
    file: raw.file,
    format,
    supported: format in IMPORTER_UP,
    bytes: Number.isFinite(raw.bytes) ? raw.bytes : null,
    sha256: typeof raw.sha256 === "string" ? raw.sha256 : "",
    units: raw.units in UNIT_TO_MM ? raw.units : gltf ? "m" : "mm",
    upAxis: upAxis === "Y" || upAxis === "Z" ? upAxis : gltf ? "Y" : "Z",
    sourceBoundsMm: validBounds(raw.source_bounds_mm),
    colourSource: typeof raw.colour_source === "string" ? raw.colour_source : "",
  };
}

function normalizeDownload(raw) {
  if (!raw || !isBasename(raw.file)) return null;
  return {
    export: typeof raw.export === "string" && raw.export ? raw.export : fileStem(raw.file),
    file: raw.file,
    format: (typeof raw.format === "string" ? raw.format : fileExtension(raw.file)).toLowerCase(),
    bytes: Number.isFinite(raw.bytes) ? raw.bytes : null,
    sha256: typeof raw.sha256 === "string" ? raw.sha256 : "",
  };
}

function normalizeModel(raw) {
  if (!raw || typeof raw.id !== "string" || !raw.id) return null;
  const strings = (value) => (Array.isArray(value) ? value.filter((item) => typeof item === "string" && item) : []);
  const excluded = new Set(strings(raw.excluded_files));
  const views = [];
  for (const view of (Array.isArray(raw.views) ? raw.views.filter(item => !excluded.has(item.file)) : []).map(normalizeView).filter(Boolean)) {
    // A view ID is the selector and URL key, so only the first of a repeated ID is reachable.
    if (views.some((item) => item.id === view.id)) {
      console.warn(`[MODEL CATALOG] ${raw.id}: duplicate view ID "${view.id}"; keeping the first`);
      continue;
    }
    views.push(view);
  }
  const downloads = (Array.isArray(raw.downloads) ? raw.downloads.filter(item => !excluded.has(item.file)) : []).map(normalizeDownload).filter(Boolean);
  let availability = AVAILABILITY.has(raw.availability) ? raw.availability : views.length ? "viewable" : "no-mesh";
  // A viewable entry whose views were all unusable has nothing to show.
  if (availability === "viewable" && !views.length) availability = "no-mesh";
  const shown = availability === "viewable" ? views : [];
  const previewable = shown.filter((view) => view.supported);
  const defaultView = previewable.find((view) => view.id === raw.default_view) || previewable[0] || null;
  return {
    id: raw.id,
    hidden: raw.hidden === true,
    title: typeof raw.title === "string" && raw.title ? raw.title : raw.id,
    category: strings(raw.category),
    hasScad: raw.has_scad === true,
    origin: typeof raw.origin === "string" ? raw.origin : "",
    status: typeof raw.status === "string" ? raw.status : "",
    availability,
    // Viewable in the catalog's sense, but every view is in a format the browser does not preview.
    downloadOnly: availability === "viewable" && !previewable.length,
    defaultViewId: defaultView ? defaultView.id : null,
    views: shown,
    downloads,
    aliases: strings(raw.aliases),
    website: normalizeProject(raw.website),
  };
}

/**
 * Reads /models/catalog.json and resolves model IDs, published filenames, aliases,
 * and printer job names to catalog entries. Shared by the viewer and the library.
 */
class ModelCatalog {
  constructor() {
    this.request = null;
    this.reset();
  }

  reset() {
    this.available = false;
    this.generatedAt = null;
    this.settings = {};
    this.models = [];
    this.byId = new Map();
    this.byIdLower = new Map();
    this.byName = new Map();
    this.byStem = new Map();
  }

  /**
   * Resolves to this catalog. A missing or unreadable catalog resolves empty so
   * unmanaged STLs keep working; a network failure rejects.
   */
  load(force = false) {
    if (!this.request || force) {
      const request = fetch("/models/catalog.json", { cache: "no-store" })
        .then(async (response) => {
          if (response.status === 404) return null;
          if (!response.ok) throw new Error(`Model catalog unavailable (${response.status})`);
          // A server without a /models/ 404 answers a missing catalog with the HTML shell.
          const text = await response.text();
          try {
            return JSON.parse(text);
          } catch {
            console.warn("[MODEL CATALOG] /models/catalog.json is not JSON; treating the catalog as absent");
            return null;
          }
        })
        .then((data) => {
          this.index(data);
          return this;
        })
        .catch((error) => {
          if (this.request === request) this.request = null;
          throw error;
        });
      this.request = request;
    }
    return this.request;
  }

  index(data) {
    this.reset();
    if (!data) return;
    if (data.schema !== 1 || !Array.isArray(data.models)) {
      console.warn("[MODEL CATALOG] Unsupported catalog schema; ignoring it", data.schema);
      return;
    }
    this.available = true;
    this.settings = { amazon_affiliate_tag: typeof data.settings?.amazon_affiliate_tag === "string" ? data.settings.amazon_affiliate_tag : "" };
    this.generatedAt = typeof data.generated_at === "string" ? data.generated_at : null;
    for (const raw of data.models) {
      const model = normalizeModel(raw);
      if (!model || this.byId.has(model.id)) continue;
      this.models.push(model);
      this.byId.set(model.id, model);
      if (!this.byIdLower.has(model.id.toLowerCase())) this.byIdLower.set(model.id.toLowerCase(), model);
      const names = [...model.views.map((view) => view.file), ...model.downloads.map((download) => download.file), ...model.aliases];
      for (const name of names) {
        const key = name.toLowerCase();
        if (!this.byName.has(key)) this.byName.set(key, model);
        if (!this.byStem.has(fileStem(key))) this.byStem.set(fileStem(key), model);
      }
      for (const download of model.downloads) {
        const key = download.export.toLowerCase();
        if (!this.byStem.has(key)) this.byStem.set(key, model);
      }
    }
  }

  /**
   * @param {string} query - Model ID, published filename, alias, or printer job filename
   * @returns {object|null} Catalog model
   */
  resolve(query) {
    if (!this.available || typeof query !== "string" || !query) return null;
    const key = query.toLowerCase();
    const byId = this.byId.get(query) || this.byIdLower.get(key);
    if (byId) return byId;
    const byName = this.byName.get(key) || this.byStem.get(fileStem(key));
    if (byName) return byName;
    // A printer job named after the model ("<id>.3mf") only counts when there is something to show,
    // so a legacy STL of the same name still opens.
    const byJob = this.byIdLower.get(fileStem(key));
    return byJob && byJob.defaultViewId ? byJob : null;
  }

  /** True when a file in the models directory belongs to a catalog entry. */
  claims(fileName) {
    const key = fileName.toLowerCase();
    return this.byName.has(key) || this.byStem.has(fileStem(key));
  }
}

class ModelViewer {
  constructor() {
    this.isOpen = false;
    this.currentFileName = null;
    this.currentModel = null;
    this.currentView = null;
    this.viewerInstance = null;
    this.modalElement = null;
    this.updateInterval = null;
    this.hashChangeHandler = null;
    this.accessAllowed = false;
    this.loadVersion = 0;

    // Set up hash change listener
    this.setupHashListener();

  }

  setAccessAllowed(allowed) {
    this.accessAllowed = allowed;
    modelPreviews.setEnabled(allowed);
    if (!allowed) {
      this.closeModal(false);
      return;
    }
    this.checkHashOnLoad();
  }

  /**
   * Open modal and load 3D model
   * @param {string} fileName - Model ID, published filename, alias, or printer job filename
   * @param {boolean} updateHash - Whether to update the URL hash (default: true)
   * @param {string|null} viewId - Catalog view to show instead of the model's default
   */
  async openModal(fileName, updateHash = true, viewId = null) {
    if (!this.accessAllowed) return;
    if (!fileName || fileName === "--") {
      console.warn("[MODEL VIEWER] No valid filename provided");
      return;
    }

    this.currentFileName = fileName;
    this.currentModel = null;
    this.currentView = null;
    this.isOpen = true;
    modelPreviews.setModalOpen(true);
    this.returnFocus = document.activeElement;
    const loadVersion = ++this.loadVersion;
    this.destroyViewer();

    // Update URL hash if requested
    if (updateHash) {
      this.setHash(fileName, viewId);
    }

    // Create modal if it doesn't exist
    if (!this.modalElement) {
      this.createModal();
    }

    // Update modal header with filename
    const header = this.modalElement.querySelector(".model-viewer-header h3");
    if (header) {
      header.textContent = fileName;
    }
    this.renderOptions(null);
    this.renderProject(null);
    this.hideMessage();
    const container = document.getElementById("model-viewer-container");
    if (container) container.innerHTML = "";

    // Show modal
    this.modalElement.style.display = "flex";
    this.modalElement.querySelector(".model-viewer-close").focus();
    this.clearStats();

    let model = null;
    try {
      model = (await window.modelCatalog.load()).resolve(fileName);
    } catch (error) {
      // Without the catalog, a published STL of the same name can still be shown.
      console.warn("[MODEL VIEWER] Catalog unavailable; trying the file directly:", error.message);
    }
    if (loadVersion !== this.loadVersion || !this.isOpen) return;

    if (!model) {
      await this.loadModel(fileName, loadVersion);
      return;
    }

    this.currentModel = model;
    if (header) header.textContent = model.title;
    const view = model.views.find((item) => item.id === viewId && item.supported) || model.views.find((item) => item.id === model.defaultViewId);
    this.renderOptions(model);
    this.renderProject(model);
    if (!view) {
      this.showMessage(this.unavailableMessage(model), "notice");
      return;
    }
    await this.showView(view, loadVersion);
  }

  unavailableMessage(model) {
    if (model.availability === "withheld") return "This model is not published.";
    if (model.downloadOnly) {
      const formats = [...new Set(model.views.map((view) => view.format.toUpperCase()))].join(", ");
      return `${formats} files can't be previewed in the browser. Use the download menu above.`;
    }
    return "No 3D view is available for this model.";
  }

  /**
   * Switch the open catalog model to another view
   * @param {string} viewId - Catalog view ID
   * @param {boolean} updateHash - Whether to record the view in the URL
   */
  async selectView(viewId, updateHash = true) {
    const view = this.currentModel?.views.find((item) => item.id === viewId);
    if (!view || !view.supported || view === this.currentView) return;
    const loadVersion = ++this.loadVersion;
    this.destroyViewer();
    if (updateHash) this.setHash(this.currentFileName, view.id === this.currentModel.defaultViewId ? null : view.id);
    this.hideMessage();
    this.clearStats();
    await this.showView(view, loadVersion);
  }

  async showView(view, loadVersion) {
    this.currentView = view;
    this.modalElement.querySelectorAll(".model-view-btn").forEach((button) => {
      button.setAttribute("aria-pressed", String(button.dataset.view === view.id));
    });
    const select = this.modalElement.querySelector(".model-view-select select");
    if (select) select.value = view.id;
    const version = view.sha256 ? `?v=${encodeURIComponent(view.sha256.slice(0, 12))}` : "";
    const modelPath = `/models/${encodeURIComponent(view.file)}${version}`;
    const container = document.getElementById("model-viewer-container");
    try {
      const response = await fetch(modelPath, { method: "HEAD" });
      if (loadVersion !== this.loadVersion || !this.isOpen) return;
      if (!response.ok) throw new Error(`Model file not found: ${view.file}`);
      await this.initViewer(modelPath, container, loadVersion, view);
    } catch (error) {
      if (loadVersion !== this.loadVersion || !this.isOpen) return;
      console.error("[MODEL VIEWER] Error loading view:", error);
      this.handleError(error.message);
    }
  }

  /**
   * Close modal and cleanup
   * @param {boolean} updateHash - Whether to clear the URL hash (default: true)
   */
  closeModal(updateHash = true) {
    if (!this.isOpen) return;

    this.isOpen = false;
    modelPreviews.setModalOpen(false);
    this.currentFileName = null;
    this.currentModel = null;
    this.currentView = null;
    ++this.loadVersion;

    // Clear URL hash if requested
    if (updateHash) {
      this.clearHash();
    }

    // Hide modal
    if (this.modalElement) {
      this.modalElement.style.display = "none";
    }

    // Cleanup viewer instance
    this.destroyViewer();
    this.returnFocus?.focus();

    // Clear viewer container
    const container = document.getElementById("model-viewer-container");
    if (container) {
      container.innerHTML = "";
    }

    this.hideMessage();
  }

  destroyViewer() {
    if (this.viewerInstance) {
      this.viewerInstance.Destroy();
      this.viewerInstance = null;
    }
  }

  /**
   * Load a model that is not in the catalog: a top-level STL of the same name
   * @param {string} fileName - Name of the model file (will strip extension and use .stl)
   */
  async loadModel(fileName, loadVersion = this.loadVersion) {
    // Strip extension and replace with .stl
    // e.g., "model.3mf" -> "model.stl"
    const fileNameWithoutExt = fileName.replace(/\.[^.]+$/, "");
    const stlFileName = /\.stl$/i.test(fileName) ? fileName : `${fileNameWithoutExt}.stl`;
    let modelPath = `/models/${encodeURIComponent(stlFileName)}`;

    console.log(`[MODEL VIEWER] Original filename: ${fileName}`);
    console.log(`[MODEL VIEWER] Looking for STL file: ${stlFileName}`);

    const container = document.getElementById("model-viewer-container");
    this.hideMessage();

    try {
      // Check if file exists
      let response = await fetch(modelPath, { method: "HEAD" });
      if (loadVersion !== this.loadVersion || !this.isOpen) return;
      // Older share links encoded the query value twice. Prefer the literal
      // filename, then try one decoded value only when that file is missing.
      if (response.status === 404 && /%[0-9a-f]{2}/i.test(stlFileName)) {
        let legacyName;
        try { legacyName = decodeURIComponent(stlFileName); } catch {}
        if (legacyName && !/[\/\\]/.test(legacyName)) {
          modelPath = `/models/${encodeURIComponent(legacyName)}`;
          response = await fetch(modelPath, { method: "HEAD" });
          if (loadVersion !== this.loadVersion || !this.isOpen) return;
        }
      }
      if (!response.ok) {
        throw new Error(`Model file not found: ${stlFileName}`);
      }

      // Initialize viewer; unmanaged STLs are OpenSCAD/SketchUp millimetres, Z up.
      await this.initViewer(modelPath, container, loadVersion, { format: "stl", units: "mm", upAxis: "Z", sourceBoundsMm: null });
    } catch (error) {
      if (loadVersion !== this.loadVersion || !this.isOpen) return;
      console.error("[MODEL VIEWER] Error loading model:", error);
      this.handleError(error.message);
    }
  }

  /**
   * Initialize the 3D viewer
   * @param {string} modelPath - Path to the model file
   * @param {HTMLElement} container - Container element for the viewer
   * @param {object} view - Format, units, up axis, and source bounds of the file
   */
  async initViewer(modelPath, container, loadVersion, view) {
    try {
      // Import online-3d-viewer
      const OV = await import("online-3d-viewer");
      if (loadVersion !== this.loadVersion || !this.isOpen) return;
      this.OV = OV; // Store OV for later use

      // Clear container
      container.innerHTML = "";

      // Initialize viewer with settings and store instance
      this.viewerInstance = new OV.EmbeddedViewer(container, {
        backgroundColor: new OV.RGBAColor(0, 0, 0, 255), // Black background
        defaultColor: new OV.RGBColor(200, 200, 200), // Light gray default color
        edgeSettings: new OV.EdgeSettings(false, new OV.RGBColor(0, 0, 0), 1), // No edges
        environmentSettings: new OV.EnvironmentSettings(
          [
            "/images/envmaps/fishermans_bastion/posx.jpg",
            "/images/envmaps/fishermans_bastion/negx.jpg",
            "/images/envmaps/fishermans_bastion/posy.jpg",
            "/images/envmaps/fishermans_bastion/negy.jpg",
            "/images/envmaps/fishermans_bastion/posz.jpg",
            "/images/envmaps/fishermans_bastion/negz.jpg",
          ],
          false,
        ),
        onModelLoaded: () => {
          if (loadVersion !== this.loadVersion || !this.isOpen) return;
          this.applyUpAxis(view);
          this.onModelLoaded(view);
          // Note: Axes feature disabled - requires direct Three.js access
          // this.addColoredAxes();
        },
        onModelLoadFailed: () => {
          if (loadVersion !== this.loadVersion || !this.isOpen) return;
          this.handleError("Could not load this model. Check your connection and try opening it again.");
        },
      });

      // Load the model
      await this.viewerInstance.LoadModelFromUrlList([modelPath]);

      console.log("[MODEL VIEWER] Viewer initialized successfully");
    } catch (error) {
      console.error("[MODEL VIEWER] Error initializing viewer:", error);
      throw error;
    }
  }

  /**
   * The viewer already turns each import upright from its importer's assumed up
   * axis (STL and 3MF Z, glTF and OBJ Y). Only a declared Z-up file read by a
   * Y-up importer needs the camera turned as well.
   * @param {object} view - Format and declared up axis of the loaded file
   */
  applyUpAxis(view) {
    const importerUp = IMPORTER_UP[view.format];
    if (!importerUp || importerUp === view.upAxis || !this.viewerInstance || !this.OV) return;
    if (view.upAxis !== "Z") {
      console.warn(`[MODEL VIEWER] ${view.format.toUpperCase()} declared ${view.upAxis}-up; the importer assumes ${importerUp}-up`);
      return;
    }
    const viewer = this.viewerInstance.GetViewer();
    viewer.SetUpVector(this.OV.Direction.Z, false);
    viewer.FitSphereToWindow(viewer.GetBoundingSphere(() => true), false);
  }

  /**
   * Display error message
   * @param {string} message - Error message to display
   */
  handleError(message) {
    this.showMessage(message, "error");
    console.error("[MODEL VIEWER]", message);
  }

  /**
   * @param {string} message - Text to show over the viewer
   * @param {"error"|"notice"} kind - An error is red; a notice is neutral
   */
  showMessage(message, kind) {
    const errorContainer = document.getElementById("model-viewer-error");
    if (errorContainer) {
      errorContainer.textContent = message;
      errorContainer.classList.toggle("is-notice", kind === "notice");
      errorContainer.style.display = "block";
    }
  }

  hideMessage() {
    const errorContainer = document.getElementById("model-viewer-error");
    if (errorContainer) {
      errorContainer.style.display = "none";
    }
  }

  clearStats() {
    this.modalElement.querySelectorAll(".stat-value").forEach((value) => { value.textContent = "--"; });
  }

  /**
   * Show a catalog model's views and downloads, or hide the bar
   * @param {object|null} model - Catalog model
   */
  renderOptions(model) {
    const options = this.modalElement.querySelector(".model-viewer-options");
    const views = this.modalElement.querySelector(".model-viewer-views");
    const downloads = options.querySelector(".model-viewer-downloads");
    views.replaceChildren();
    downloads.replaceChildren();

    if (model) {
      for (const view of model.views.filter((item) => item.supported)) {
        const button = document.createElement("button");
        button.type = "button";
        button.className = "model-view-btn";
        button.dataset.view = view.id;
        button.appendChild(modelPreviews.create(view, view.label, true));
        const label = document.createElement("span");
        label.className = "model-view-label";
        label.textContent = view.label;
        button.appendChild(label);
        button.setAttribute("aria-pressed", "false");
        button.addEventListener("click", () => this.selectView(view.id));
        views.appendChild(button);
      }
    }

    if (model && model.downloads.length) {
      const menu = document.createElement("details");
      menu.className = "model-downloads-menu";
      const summary = document.createElement("summary");
      summary.textContent = model.downloads.length === 1 ? "Download" : `Downloads (${model.downloads.length})`;
      const list = document.createElement("ul");
      for (const download of model.downloads) {
        const item = document.createElement("li");
        const link = document.createElement("a");
        link.className = "model-download-link";
        link.href = `/models/${encodeURIComponent(download.file)}`;
        link.download = download.file;
        const size = formatBytes(download.bytes);
        link.textContent = `${download.export} · ${download.format.toUpperCase()}${size ? ` · ${size}` : ""}`;
        item.appendChild(link);
        list.appendChild(item);
      }
      menu.append(summary, list);
      // A model with nothing to preview leads with its files.
      menu.open = !model.defaultViewId;
      downloads.appendChild(menu);
    }

    views.hidden = !views.childElementCount;
    downloads.hidden = !downloads.childElementCount;
    options.hidden = downloads.hidden;
    modelPreviews.prune();
  }

  renderProject(model) {
    const details = this.modalElement.querySelector(".model-project-details");
    renderProjectContent(details, model, window.modelCatalog.settings);
    this.modalElement.querySelector(".model-viewer-body").classList.toggle("has-project", !details.hidden);
  }

  /**
   * Create modal HTML structure
   */
  createModal() {
    // Get or create modal container
    let modalContainer = document.getElementById("model-viewer-modal");
    if (!modalContainer) {
      modalContainer = document.createElement("div");
      modalContainer.id = "model-viewer-modal";
      modalContainer.className = "model-viewer-modal";
      document.body.appendChild(modalContainer);
    }

    // Create modal content
    modalContainer.innerHTML = `
      <div class="model-viewer-content">
        <div class="model-viewer-header">
          <h3>3D Model</h3>
          <div class="model-viewer-toolbar">
            <button class="toolbar-btn" id="btn-fit-view" title="Fit to View">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M8 3H5a2 2 0 0 0-2 2v3m18 0V5a2 2 0 0 0-2-2h-3m0 18h3a2 2 0 0 0 2-2v-3M3 16v3a2 2 0 0 0 2 2h3"/>
              </svg>
            </button>
            <button class="toolbar-btn" id="btn-screenshot" title="Take Screenshot">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
                <circle cx="12" cy="13" r="4"/>
              </svg>
            </button>
          </div>
          <button class="model-viewer-close" aria-label="Close viewer">
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="18" y1="6" x2="6" y2="18"></line>
              <line x1="6" y1="6" x2="18" y2="18"></line>
            </svg>
          </button>
        </div>
        <div class="model-viewer-options" hidden>
          <div class="model-viewer-downloads" hidden></div>
        </div>
        <div class="model-viewer-body">
          <div class="model-viewer-stage">
          <div id="model-viewer-container" class="model-viewer-container"></div>
          <div class="model-viewer-views" role="group" aria-label="Project views and parts" hidden></div>
          <details class="model-viewer-stats">
            <summary>Model information</summary>
            <div class="stats-grid">
              <div class="stat-item">
                <span class="stat-label">Dimensions:</span>
                <span id="stat-dimensions" class="stat-value">--</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">Volume:</span>
                <span id="stat-volume" class="stat-value">--</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">Surface Area:</span>
                <span id="stat-surface-area" class="stat-value">--</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">Triangles:</span>
                <span id="stat-triangles" class="stat-value">--</span>
              </div>
              <div class="stat-item">
                <span class="stat-label">Vertices:</span>
                <span id="stat-vertices" class="stat-value">--</span>
              </div>
            </div>
          </details>
          <div id="model-viewer-error" class="model-viewer-error" style="display: none;"></div>
          </div>
          <aside class="model-project-details" aria-label="Project details" hidden></aside>
        </div>
      </div>
    `;

    this.modalElement = modalContainer;
    modalContainer.setAttribute("role", "dialog");
    modalContainer.setAttribute("aria-modal", "true");
    modalContainer.setAttribute("aria-label", "3D model viewer");

    // Set up event listeners
    this.setupEventListeners();
  }

  /**
   * Set up modal event listeners
   */
  setupEventListeners() {
    if (!this.modalElement) return;

    // Close button
    const closeButton = this.modalElement.querySelector(".model-viewer-close");
    if (closeButton) {
      closeButton.addEventListener("click", (e) => {
        e.stopPropagation(); // Prevent click from bubbling to document
        this.closeModal();
      });
    }

    // Toolbar buttons
    const fitViewBtn = this.modalElement.querySelector("#btn-fit-view");
    if (fitViewBtn) {
      fitViewBtn.addEventListener("click", () => this.fitToView());
    }

    const screenshotBtn = this.modalElement.querySelector("#btn-screenshot");
    if (screenshotBtn) {
      screenshotBtn.addEventListener("click", () => this.takeScreenshot());
    }

    // ESC key
    const escHandler = (e) => {
      if (e.key === "Tab" && this.isOpen) {
        // View buttons and download links come and go with the model; trap only what is shown.
        const focusable = [...this.modalElement.querySelectorAll("button:not(:disabled), a[href], select, summary")].filter((element) => element.offsetParent !== null);
        const first = focusable[0];
        const last = focusable[focusable.length - 1];
        if (e.shiftKey && document.activeElement === first) {
          e.preventDefault();
          last.focus();
        } else if (!e.shiftKey && document.activeElement === last) {
          e.preventDefault();
          first.focus();
        }
      }
      if (e.key === "Escape" && this.isOpen) {
        e.stopPropagation(); // Prevent event from bubbling
        e.preventDefault(); // Prevent default ESC behavior
        this.closeModal();
      }
    };
    document.addEventListener("keydown", escHandler);

    // Backdrop click (click outside modal content)
    this.modalElement.addEventListener("click", (e) => {
      if (e.target === this.modalElement) {
        e.stopPropagation(); // Prevent click from bubbling to document
        this.closeModal();
      }
    });

    // Prevent clicks on modal content from bubbling to backdrop
    const modalContent = this.modalElement.querySelector(".model-viewer-content");
    if (modalContent) {
      modalContent.addEventListener("click", (e) => {
        e.stopPropagation(); // Prevent clicks inside modal from reaching backdrop handler
      });
    }
  }

  /**
   * Fit model to view
   */
  fitToView() {
    if (!this.viewerInstance || !this.OV) {
      console.warn("[MODEL VIEWER] No viewer instance available");
      return;
    }

    try {
      const model = this.viewerInstance.GetModel();
      if (!model) {
        console.warn("[MODEL VIEWER] No model available");
        return;
      }

      // Calculate bounding sphere from bounding box
      const boundingBox = this.OV.GetBoundingBox(model);

      // Calculate center point as Coord3D
      const centerX = (boundingBox.min.x + boundingBox.max.x) / 2;
      const centerY = (boundingBox.min.y + boundingBox.max.y) / 2;
      const centerZ = (boundingBox.min.z + boundingBox.max.z) / 2;
      const center = new this.OV.Coord3D(centerX, centerY, centerZ);

      // Calculate radius (half the diagonal of the bounding box)
      const dx = boundingBox.max.x - boundingBox.min.x;
      const dy = boundingBox.max.y - boundingBox.min.y;
      const dz = boundingBox.max.z - boundingBox.min.z;
      const radius = Math.sqrt(dx * dx + dy * dy + dz * dz) / 2;

      const viewer = this.viewerInstance.GetViewer();
      if (viewer && typeof viewer.FitSphereToWindow === "function") {
        // FitSphereToWindow expects a bounding sphere object with center and radius properties
        const boundingSphere = {
          center: center,
          radius: radius,
        };
        viewer.FitSphereToWindow(boundingSphere, true); // true for animation
        console.log("[MODEL VIEWER] Fit to view");
      } else {
        console.warn("[MODEL VIEWER] FitSphereToWindow method not available");
      }
    } catch (error) {
      console.error("[MODEL VIEWER] Error fitting to view:", error);
    }
  }

  /**
   * Take screenshot of current view
   */
  takeScreenshot() {
    if (!this.viewerInstance) {
      console.warn("[MODEL VIEWER] No viewer instance available");
      return;
    }

    try {
      const viewer = this.viewerInstance.GetViewer();
      if (viewer && viewer.GetImageAsDataUrl) {
        const dataUrl = viewer.GetImageAsDataUrl(1920, 1080, false);

        // Create download link
        const link = document.createElement("a");
        link.href = dataUrl;
        const name = this.currentModel
          ? `${this.currentModel.id}${this.currentView ? `-${this.currentView.id}` : ""}`
          : this.currentFileName || "model";
        link.download = `${name}_screenshot.png`;
        link.click();

        console.log("[MODEL VIEWER] Screenshot saved");
      }
    } catch (error) {
      console.error("[MODEL VIEWER] Error taking screenshot:", error);
    }
  }

  /**
   * Called when model is loaded - calculate and display model stats
   * @param {object} view - Units, up axis, and source bounds of the loaded file
   */
  onModelLoaded(view) {
    if (!this.viewerInstance || !this.OV) return;

    try {
      const model = this.viewerInstance.GetModel();
      if (!model) {
        console.warn("[MODEL VIEWER] No model available");
        return;
      }

      console.log("[MODEL VIEWER] Calculating model statistics...");

      // Dimensions in the source's own X × Y × Z millimetres. The generator's
      // bounds are authoritative; otherwise convert the file's units and, for a
      // Y-up file, read its Z extent as the source's Y.
      const scale = UNIT_TO_MM[view.units] || 1;
      let size;
      if (view.sourceBoundsMm) {
        size = [0, 1, 2].map((axis) => view.sourceBoundsMm.max[axis] - view.sourceBoundsMm.min[axis]);
      } else {
        const boundingBox = this.OV.GetBoundingBox(model);
        const extent = ["x", "y", "z"].map((axis) => (boundingBox.max[axis] - boundingBox.min[axis]) * scale);
        size = view.upAxis === "Y" ? [extent[0], extent[2], extent[1]] : extent;
      }
      const [sizeX, sizeY, sizeZ] = size.map((value) => value.toFixed(2));

      // Calculate volume and surface area in mm³ and mm²
      const volume = this.OV.CalculateVolume(model) * scale ** 3;
      const surfaceArea = this.OV.CalculateSurfaceArea(model) * scale ** 2;

      // Count triangles and vertices
      let triangleCount = 0;
      let vertexCount = 0;

      model.EnumerateMeshes((mesh) => {
        triangleCount += mesh.TriangleCount();
        vertexCount += mesh.VertexCount();
      });

      // Update UI
      document.getElementById("stat-dimensions").textContent = `${sizeX} × ${sizeY} × ${sizeZ} mm`;
      document.getElementById("stat-volume").textContent = `${volume.toFixed(2)} mm³`;
      document.getElementById("stat-surface-area").textContent = `${surfaceArea.toFixed(2)} mm²`;
      document.getElementById("stat-triangles").textContent = triangleCount.toLocaleString();
      document.getElementById("stat-vertices").textContent = vertexCount.toLocaleString();

      console.log("[MODEL VIEWER] Model statistics calculated successfully");
    } catch (error) {
      console.error("[MODEL VIEWER] Error calculating model statistics:", error);
    }
  }

  /**
   * Add colored coordinate axes (SketchUp style: Red=X, Green=Y, Blue=Z)
   * Note: This feature requires access to the internal Three.js scene
   */
  addColoredAxes() {
    if (!this.viewerInstance || !this.OV) return;

    try {
      // Get the model to calculate appropriate axis size
      const model = this.viewerInstance.GetModel();
      if (!model) {
        console.warn("[MODEL VIEWER] Could not get model for axes");
        return;
      }

      const boundingBox = this.OV.GetBoundingBox(model);
      const sizeX = boundingBox.max.x - boundingBox.min.x;
      const sizeY = boundingBox.max.y - boundingBox.min.y;
      const sizeZ = boundingBox.max.z - boundingBox.min.z;
      const maxSize = Math.max(sizeX, sizeY, sizeZ);
      const axisLength = maxSize * 0.5; // 50% of model size

      // Create axis lines as OV meshes
      const createAxisMesh = (color, endPoint, name) => {
        const mesh = new this.OV.Mesh();
        mesh.SetName(name);

        // Add vertices
        const v1 = mesh.AddVertex(new this.OV.Coord3D(0, 0, 0));
        const v2 = mesh.AddVertex(endPoint);

        // Add line
        mesh.AddLine(v1, v2);

        // Create material
        const material = new this.OV.PhongMaterial();
        material.color = color;
        const materialIndex = model.AddMaterial(material);
        mesh.SetMaterial(materialIndex);

        return mesh;
      };

      // Create axes with SketchUp colors
      const xAxis = createAxisMesh(new this.OV.RGBColor(255, 0, 0), new this.OV.Coord3D(axisLength, 0, 0), "X-Axis");
      const yAxis = createAxisMesh(new this.OV.RGBColor(0, 255, 0), new this.OV.Coord3D(0, axisLength, 0), "Y-Axis");
      const zAxis = createAxisMesh(new this.OV.RGBColor(0, 0, 255), new this.OV.Coord3D(0, 0, axisLength), "Z-Axis");

      // Add axes to model
      model.AddMesh(xAxis);
      model.AddMesh(yAxis);
      model.AddMesh(zAxis);

      // Force viewer to update
      const viewer = this.viewerInstance.GetViewer();
      if (viewer && typeof viewer.Render === "function") {
        viewer.Render();
      }

      console.log("[MODEL VIEWER] Added colored coordinate axes");
    } catch (error) {
      console.error("[MODEL VIEWER] Error adding axes:", error);
    }
  }

  /**
   * Set URL query parameters to the model and, when not the default, its view
   * @param {string} fileName - Model ID or filename to set in URL
   * @param {string|null} viewId - Catalog view ID, or null for the default view
   */
  setHash(fileName, viewId = null) {
    if (!fileName) return;

    const url = new URL(window.location);
    url.searchParams.set("model", fileName);
    if (viewId) {
      url.searchParams.set("view", viewId);
    } else {
      url.searchParams.delete("view");
    }

    // Use history.pushState to avoid page reload
    if (url.href !== window.location.href) history.pushState(null, "", url);
  }

  /**
   * Clear URL query parameter
   */
  clearHash() {
    const url = new URL(window.location);
    if (url.searchParams.has("model") || url.searchParams.has("view")) {
      url.searchParams.delete("model");
      url.searchParams.delete("view");
      // Use history.replaceState to avoid adding to browser history
      history.replaceState(null, "", url);
      console.log("[MODEL VIEWER] Cleared URL parameter");
    }
  }

  /**
   * Get model filename from URL query parameter
   * @returns {string|null} - Model filename or null if not found
   */
  getHashFileName() {
    const url = new URL(window.location);
    const fileName = url.searchParams.get("model");

    if (fileName) {
      console.log(`[MODEL VIEWER] Found model in URL: ${fileName}`);
      return fileName;
    }

    return null;
  }

  /** @returns {string|null} Catalog view ID from the URL */
  getHashView() {
    return new URL(window.location).searchParams.get("view");
  }

  /**
   * Set up popstate listener for browser back/forward buttons
   */
  setupHashListener() {
    this.hashChangeHandler = () => {
      const fileName = this.getHashFileName();
      const viewId = this.getHashView();

      if (this.accessAllowed && fileName && (!this.isOpen || this.currentFileName !== fileName)) {
        // URL has model parameter and viewer is closed - open it
        console.log(`[MODEL VIEWER] URL change detected, opening model: ${fileName}`);
        this.openModal(fileName, false, viewId); // Don't update URL again
      } else if (this.accessAllowed && fileName && this.currentModel) {
        // Same model, different view
        this.selectView(viewId || this.currentModel.defaultViewId, false);
      } else if (!fileName && this.isOpen) {
        // URL parameter cleared and viewer is open - close it
        console.log("[MODEL VIEWER] URL parameter cleared, closing viewer");
        this.closeModal(false); // Don't clear URL again
      }
    };

    window.addEventListener("popstate", this.hashChangeHandler);
  }

  /**
   * Check for model in URL query parameter on page load
   */
  checkHashOnLoad() {
    const fileName = this.getHashFileName();
    if (this.accessAllowed && fileName && (!this.isOpen || this.currentFileName !== fileName)) {
      console.log(`[MODEL VIEWER] Model found in URL on load: ${fileName}`);
      this.openModal(fileName, false, this.getHashView());
    }
  }
}

// Make ModelViewer and the shared catalog available globally
window.ModelViewer = ModelViewer;
window.ModelCatalog = ModelCatalog;
window.modelCatalog = new ModelCatalog();
window.formatModelBytes = formatBytes;

// Initialize ModelViewer instance when DOM is ready
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", () => {
    window.modelViewer = new ModelViewer();
  });
} else {
  // DOM already loaded
  window.modelViewer = new ModelViewer();
}
