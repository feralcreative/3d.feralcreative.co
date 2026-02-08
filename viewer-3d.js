/**
 * 3D Model Viewer Module
 * Handles displaying 3D models in a modal overlay using online-3d-viewer
 */

class ModelViewer {
  constructor() {
    this.isOpen = false;
    this.currentFileName = null;
    this.viewerInstance = null;
    this.modalElement = null;
    this.updateInterval = null;
    this.hashChangeHandler = null;

    // Set up hash change listener
    this.setupHashListener();

    // Check for model in URL hash on initialization
    this.checkHashOnLoad();
  }

  /**
   * Open modal and load 3D model
   * @param {string} fileName - Name of the model file to load
   * @param {boolean} updateHash - Whether to update the URL hash (default: true)
   */
  async openModal(fileName, updateHash = true) {
    if (!fileName || fileName === "--") {
      console.warn("[MODEL VIEWER] No valid filename provided");
      return;
    }

    this.currentFileName = fileName;
    this.isOpen = true;

    // Update URL hash if requested
    if (updateHash) {
      this.setHash(fileName);
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

    // Show modal
    this.modalElement.style.display = "flex";

    // Load the model
    await this.loadModel(fileName);
  }

  /**
   * Close modal and cleanup
   * @param {boolean} updateHash - Whether to clear the URL hash (default: true)
   */
  closeModal(updateHash = true) {
    if (!this.isOpen) return;

    this.isOpen = false;
    this.currentFileName = null;

    // Clear URL hash if requested
    if (updateHash) {
      this.clearHash();
    }

    // Hide modal
    if (this.modalElement) {
      this.modalElement.style.display = "none";
    }

    // Cleanup viewer instance
    if (this.viewerInstance) {
      this.viewerInstance = null;
    }

    // Clear viewer container
    const container = document.getElementById("model-viewer-container");
    if (container) {
      container.innerHTML = "";
    }

    // Hide error message
    const errorContainer = document.getElementById("model-viewer-error");
    if (errorContainer) {
      errorContainer.style.display = "none";
    }
  }

  /**
   * Load 3D model from file
   * @param {string} fileName - Name of the model file (will strip extension and use .stl)
   */
  async loadModel(fileName) {
    // Strip extension and replace with .stl
    // e.g., "model.3mf" -> "model.stl"
    const fileNameWithoutExt = fileName.replace(/\.[^.]+$/, "");
    const stlFileName = `${fileNameWithoutExt}.stl`;
    const modelPath = `/models/${stlFileName}`;

    console.log(`[MODEL VIEWER] Original filename: ${fileName}`);
    console.log(`[MODEL VIEWER] Looking for STL file: ${stlFileName}`);

    const container = document.getElementById("model-viewer-container");
    const errorContainer = document.getElementById("model-viewer-error");

    // Hide error message
    if (errorContainer) {
      errorContainer.style.display = "none";
    }

    try {
      // Check if file exists
      const response = await fetch(modelPath, { method: "HEAD" });
      if (!response.ok) {
        throw new Error(`Model file not found: ${stlFileName}`);
      }

      // Initialize viewer
      await this.initViewer(modelPath, container);
    } catch (error) {
      console.error("[MODEL VIEWER] Error loading model:", error);
      this.handleError(error.message);
    }
  }

  /**
   * Initialize the 3D viewer
   * @param {string} modelPath - Path to the model file
   * @param {HTMLElement} container - Container element for the viewer
   */
  async initViewer(modelPath, container) {
    try {
      // Import online-3d-viewer
      const OV = await import("online-3d-viewer");
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
            "images/envmaps/fishermans_bastion/posx.jpg",
            "images/envmaps/fishermans_bastion/negx.jpg",
            "images/envmaps/fishermans_bastion/posy.jpg",
            "images/envmaps/fishermans_bastion/negy.jpg",
            "images/envmaps/fishermans_bastion/posz.jpg",
            "images/envmaps/fishermans_bastion/negz.jpg",
          ],
          false,
        ),
        onModelLoaded: () => {
          this.onModelLoaded();
          // Note: Axes feature disabled - requires direct Three.js access
          // this.addColoredAxes();
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
   * Display error message
   * @param {string} message - Error message to display
   */
  handleError(message) {
    const errorContainer = document.getElementById("model-viewer-error");
    if (errorContainer) {
      errorContainer.textContent = message;
      errorContainer.style.display = "block";
    }
    console.error("[MODEL VIEWER]", message);
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
        <div class="model-viewer-body">
          <div id="model-viewer-container" class="model-viewer-container"></div>
          <div class="model-viewer-stats">
            <h4>Model Information</h4>
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
          </div>
        </div>
        <div id="model-viewer-error" class="model-viewer-error" style="display: none;"></div>
      </div>
    `;

    this.modalElement = modalContainer;

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
        link.download = `${this.currentFileName || "model"}_screenshot.png`;
        link.click();

        console.log("[MODEL VIEWER] Screenshot saved");
      }
    } catch (error) {
      console.error("[MODEL VIEWER] Error taking screenshot:", error);
    }
  }

  /**
   * Called when model is loaded - calculate and display model stats
   */
  onModelLoaded() {
    if (!this.viewerInstance || !this.OV) return;

    try {
      const model = this.viewerInstance.GetModel();
      if (!model) {
        console.warn("[MODEL VIEWER] No model available");
        return;
      }

      console.log("[MODEL VIEWER] Calculating model statistics...");

      // Get bounding box
      const boundingBox = this.OV.GetBoundingBox(model);
      const sizeX = (boundingBox.max.x - boundingBox.min.x).toFixed(2);
      const sizeY = (boundingBox.max.y - boundingBox.min.y).toFixed(2);
      const sizeZ = (boundingBox.max.z - boundingBox.min.z).toFixed(2);

      // Calculate volume and surface area
      const volume = this.OV.CalculateVolume(model);
      const surfaceArea = this.OV.CalculateSurfaceArea(model);

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
   * Set URL query parameter to model filename
   * @param {string} fileName - Model filename to set in URL
   */
  setHash(fileName) {
    if (!fileName) return;

    // Encode the filename to handle special characters
    const encodedFileName = encodeURIComponent(fileName);
    const url = new URL(window.location);
    url.searchParams.set("model", encodedFileName);

    // Use history.pushState to avoid page reload
    history.pushState(null, "", url);
    console.log(`[MODEL VIEWER] Set URL parameter: ?model=${encodedFileName}`);
  }

  /**
   * Clear URL query parameter
   */
  clearHash() {
    const url = new URL(window.location);
    if (url.searchParams.has("model")) {
      url.searchParams.delete("model");
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

  /**
   * Set up popstate listener for browser back/forward buttons
   */
  setupHashListener() {
    this.hashChangeHandler = () => {
      const fileName = this.getHashFileName();

      if (fileName && !this.isOpen) {
        // URL has model parameter and viewer is closed - open it
        console.log(`[MODEL VIEWER] URL change detected, opening model: ${fileName}`);
        this.openModal(fileName, false); // Don't update URL again
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
    if (fileName) {
      console.log(`[MODEL VIEWER] Model found in URL on load: ${fileName}`);
      // Wait a bit for the page to fully load before opening
      setTimeout(() => {
        this.openModal(fileName, false); // Don't update URL again
      }, 500);
    }
  }
}

// Make ModelViewer available globally
window.ModelViewer = ModelViewer;

// Initialize ModelViewer instance when DOM is ready
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", () => {
    window.modelViewer = new ModelViewer();
  });
} else {
  // DOM already loaded
  window.modelViewer = new ModelViewer();
}
