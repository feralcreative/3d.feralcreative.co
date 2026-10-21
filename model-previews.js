// One offscreen renderer supplies visible cards and part thumbnails. The page
// never creates a WebGL context per card or downloads the whole catalog at once.
const MAX_AUTOMATIC_BYTES = 25 * 1024 * 1024;
const ENVIRONMENT = ["posx", "negx", "posy", "negy", "posz", "negz"].map((face) => `/images/envmaps/fishermans_bastion/${face}.jpg`);

class ModelPreviews {
  constructor() {
    this.queue = [];
    this.pending = new Set();
    this.memory = new Map();
    this.busy = false;
    this.modalOpen = false;
    this.enabled = false;
    this.sessionVersion = Date.now();
    this.observer = new IntersectionObserver((entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue;
        this.observer.unobserve(entry.target);
        this.pending.delete(entry.target);
        this.queue.push(entry.target.previewJob);
      }
      this.drain();
    }, { rootMargin: "120px" });
  }

  create(view, label, priority = false) {
    const slot = document.createElement("span");
    slot.className = "model-preview";
    slot.dataset.state = "waiting";
    const image = document.createElement("img");
    image.alt = "";
    image.width = 480;
    image.height = 320;
    const caption = document.createElement("span");
    caption.className = "model-preview-caption";
    caption.textContent = "Loading preview…";
    slot.append(image, caption);
    slot.setAttribute("role", "img");
    slot.setAttribute("aria-label", `${label} preview`);
    const key = `${view.file}:${view.sha256 || this.sessionVersion}:${view.upAxis || "Z"}:v1`;
    slot.previewJob = { slot, image, caption, view, key, priority };
    this.observer.observe(slot);
    this.pending.add(slot);
    return slot;
  }

  prune() {
    for (const slot of this.pending) {
      if (slot.isConnected) continue;
      this.observer.unobserve(slot);
      this.pending.delete(slot);
    }
    this.queue = this.queue.filter((job) => job.slot.isConnected);
  }

  setModalOpen(open) {
    this.modalOpen = open;
    this.drain();
  }

  setEnabled(enabled) {
    this.enabled = enabled;
    if (!enabled) {
      this.queue = [];
      this.observer.disconnect();
      this.pending.clear();
      this.abort?.();
    } else this.drain();
  }

  async cache() {
    if (!this.cacheRequest) this.cacheRequest = globalThis.caches?.open("feral-model-previews-v1").catch(() => null);
    return this.cacheRequest;
  }

  async drain() {
    if (this.busy || !this.enabled) return;
    this.queue = this.queue.filter((job) => job.slot.isConnected);
    const index = this.queue.findIndex((job) => !this.modalOpen || job.priority);
    if (index < 0) return;
    const job = this.queue.splice(index, 1)[0];
    this.busy = true;
    const { slot, image, caption, view, key } = job;
    try {
      const cache = await this.cache();
      const cacheKey = new URL(`/_model-preview/${encodeURIComponent(key)}`, window.location.origin).href;
      let data = this.memory.get(key);
      if (!data && cache) {
        try { data = await cache.match(cacheKey).then((response) => response?.text()); } catch {}
      }
      if (!data && view.bytes > MAX_AUTOMATIC_BYTES) {
        slot.dataset.state = "large";
        caption.textContent = "Open for 3D preview";
        return;
      }
      if (!data) {
        data = await this.render(view);
        this.memory.set(key, data);
        if (this.memory.size > 150) this.memory.delete(this.memory.keys().next().value);
        // Cache failures (private browsing or quota) must not hide a good preview.
        if (cache) {
          cache.put(cacheKey, new Response(data)).then(async () => {
            const keys = await cache.keys();
            if (keys.length > 400) await cache.delete(keys[0]);
          }).catch(() => {});
        }
      }
      if (!slot.isConnected || !data?.startsWith("data:image/png")) return;
      image.src = data;
      slot.dataset.state = "ready";
      caption.textContent = "";
    } catch {
      slot.dataset.state = "error";
      caption.textContent = "Preview unavailable";
    } finally {
      this.busy = false;
      this.drain();
    }
  }

  async render(view) {
    const OV = await import("online-3d-viewer");
    if (!this.enabled) throw new Error("Preview cancelled");
    if (!this.host) {
      this.host = document.createElement("div");
      this.host.className = "model-preview-renderer";
      this.host.setAttribute("aria-hidden", "true");
      document.body.appendChild(this.host);
    }
    return new Promise((resolve, reject) => {
      const timeout = setTimeout(() => fail(new Error("Preview timed out")), 25000);
      let settled = false;
      const fail = (error) => {
        if (settled) return;
        settled = true;
        clearTimeout(timeout);
        this.renderer?.Destroy();
        this.renderer = null;
        this.host.replaceChildren();
        reject(error);
      };
      this.abort = () => fail(new Error("Preview cancelled"));
      this.onLoaded = () => {
        requestAnimationFrame(() => {
          if (settled) return;
          try {
            const viewer = this.renderer.GetViewer();
            const importerYUp = ["glb", "gltf", "obj", "ply", "off"].includes(view.format);
            viewer.SetUpVector(importerYUp && view.upAxis === "Z" ? OV.Direction.Z : OV.Direction.Y, false);
            viewer.FitSphereToWindow(viewer.GetBoundingSphere(() => true), false);
            const data = viewer.GetImageAsDataUrl(480, 320, false);
            settled = true;
            clearTimeout(timeout);
            resolve(data);
          } catch (error) { fail(error); }
        });
      };
      this.onFailed = () => fail(new Error("Preview failed"));
      try {
        if (!this.renderer) {
          const renderer = new OV.EmbeddedViewer(this.host, {
            backgroundColor: new OV.RGBAColor(22, 22, 26, 255),
            defaultColor: new OV.RGBColor(200, 200, 200),
            environmentSettings: new OV.EnvironmentSettings(ENVIRONMENT, false),
            onModelLoaded: () => { if (this.renderer === renderer) this.onLoaded(); },
            onModelLoadFailed: () => { if (this.renderer === renderer) this.onFailed(); },
          });
          this.renderer = renderer;
        }
        this.renderer.LoadModelFromUrlList([`/models/${encodeURIComponent(view.file)}`]);
      } catch (error) { fail(error); }
    });
  }
}

export const modelPreviews = new ModelPreviews();
