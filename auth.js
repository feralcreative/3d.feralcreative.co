// Google Authentication Handler
class GoogleAuth {
  constructor() {
    this.user = null;
    this.isInitialized = false;
    this.streamUrlSet = false;
  }

  // Initialize Google Sign-In
  async init() {
    return new Promise((resolve, reject) => {
      google.accounts.id.initialize({
        client_id: CONFIG.GOOGLE_CLIENT_ID,
        callback: (response) => this.handleCredentialResponse(response),
      });

      this.isInitialized = true;
      resolve();
    });
  }

  // Handle the credential response from Google
  handleCredentialResponse(response) {
    try {
      // Decode the JWT token to get user info
      const payload = this.parseJwt(response.credential);

      // Check if email is allowed
      if (!this.isEmailAllowed(payload.email)) {
        this.showError(`Access denied. Email ${payload.email} is not authorized.`);
        return;
      }

      // Store user info
      this.user = {
        email: payload.email,
        name: payload.name,
        picture: payload.picture,
        credential: response.credential,
      };

      // Store in localStorage for persistent login
      localStorage.setItem("user", JSON.stringify(this.user));

      // Log the login event
      if (window.activityLogger) {
        window.activityLogger.logLogin(this.user);
      }

      // Update UI
      this.onAuthStateChanged();
    } catch (error) {
      console.error("Authentication error:", error);
      this.showError("Authentication failed. Please try again.");
    }
  }

  // Check if email is allowed based on CONFIG
  isEmailAllowed(email) {
    // If no restrictions, allow all
    if (!CONFIG.ALLOWED_EMAILS || CONFIG.ALLOWED_EMAILS.length === 0) {
      return true;
    }

    // Check against allowed emails/domains
    return CONFIG.ALLOWED_EMAILS.some((allowed) => {
      if (allowed.startsWith("@")) {
        // Domain check
        return email.endsWith(allowed);
      } else {
        // Exact email check
        return email === allowed;
      }
    });
  }

  // Check if user has upload permissions
  canUpload(email) {
    // If no upload restrictions configured, deny by default for security
    if (!CONFIG.UPLOAD_ALLOWED_EMAILS || CONFIG.UPLOAD_ALLOWED_EMAILS.length === 0) {
      return false;
    }

    // Check against upload allowed emails/domains
    return CONFIG.UPLOAD_ALLOWED_EMAILS.some((allowed) => {
      if (allowed.startsWith("@")) {
        // Domain check
        return email.endsWith(allowed);
      } else {
        // Exact email check
        return email === allowed;
      }
    });
  }

  // Check if user has access to advanced features
  hasAdvancedFeatures(email) {
    // If no advanced features list configured, deny by default
    if (!CONFIG.ADVANCED_FEATURES || CONFIG.ADVANCED_FEATURES.length === 0) {
      return false;
    }

    // Check against advanced features allowed emails/domains
    return CONFIG.ADVANCED_FEATURES.some((allowed) => {
      if (allowed.startsWith("@")) {
        // Domain check
        return email.endsWith(allowed);
      } else {
        // Exact email check
        return email === allowed;
      }
    });
  }

  // Parse JWT token
  parseJwt(token) {
    const base64Url = token.split(".")[1];
    const base64 = base64Url.replace(/-/g, "+").replace(/_/g, "/");
    const jsonPayload = decodeURIComponent(
      atob(base64)
        .split("")
        .map((c) => {
          return "%" + ("00" + c.charCodeAt(0).toString(16)).slice(-2);
        })
        .join(""),
    );
    return JSON.parse(jsonPayload);
  }

  // Render the sign-in button
  renderSignInButton() {
    google.accounts.id.renderButton(document.getElementById("google-signin-button"), {
      theme: "filled_blue",
      size: "large",
      text: "signin_with",
      shape: "rectangular",
    });
  }

  // Check if user is already signed in (from localStorage)
  checkSession() {
    const storedUser = localStorage.getItem("user");
    if (storedUser) {
      this.user = JSON.parse(storedUser);

      // Log session restoration
      if (window.activityLogger) {
        window.activityLogger.logEvent("session_restored", {}, this.user);
      }

      this.onAuthStateChanged();
      return true;
    }
    return false;
  }

  // Sign out
  signOut() {
    // Log the logout event
    if (window.activityLogger && this.user) {
      window.activityLogger.logLogout(this.user);
    }

    this.user = null;
    localStorage.removeItem("user");
    google.accounts.id.disableAutoSelect();
    this.onAuthStateChanged();
  }

  // Update UI based on auth state
  onAuthStateChanged() {
    const loginScreen = document.getElementById("login-screen");
    const streamContainer = document.getElementById("stream-container");
    const hamburgerMenu = document.getElementById("hamburger-menu");
    const userEmail = document.getElementById("user-email");
    const streamImage = document.getElementById("stream-image");
    const uploadBtn = document.getElementById("upload-btn");
    const prepFilamentBtn = document.getElementById("prep-filament-btn");

    if (this.user) {
      // User is signed in
      loginScreen.style.display = "none";
      streamContainer.style.display = "flex";
      hamburgerMenu.style.display = "block";
      userEmail.textContent = this.user.email;

      // Show/hide upload button based on permissions
      if (uploadBtn) {
        if (this.canUpload(this.user.email)) {
          uploadBtn.style.display = "flex";
        } else {
          uploadBtn.style.display = "none";
        }
      }

      // Show/hide filament change prep button based on advanced features access
      if (prepFilamentBtn) {
        if (this.hasAdvancedFeatures(this.user.email)) {
          prepFilamentBtn.style.display = "flex";
        } else {
          prepFilamentBtn.style.display = "none";
        }
      }

      // Set the appropriate stream URL based on environment (only once)
      if (!this.streamUrlSet) {
        const isLocalhost = window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1";
        const streamUrl = isLocalhost ? CONFIG.STREAM_URL.DEV : CONFIG.STREAM_URL.PROD;

        // Set up error handler to show offline image
        streamImage.onerror = function () {
          this.src = "/images/offline.jpg";
          this.onerror = null; // Prevent infinite loop
        };

        streamImage.src = streamUrl;
        this.streamUrlSet = true;

        // Initialize printer status monitoring
        this.initPrinterStatus();
      }
    } else {
      // User is signed out
      loginScreen.style.display = "flex";
      streamContainer.style.display = "none";
      hamburgerMenu.style.display = "none";
      streamImage.src = ""; // Clear the stream URL
      this.streamUrlSet = false;

      // Stop printer status monitoring
      if (window.printerStatus) {
        window.printerStatus.stopUpdates();
      }
    }
  }

  // Initialize printer status monitoring
  initPrinterStatus() {
    // Check if printer configuration is set
    if (!CONFIG.PRINTER || !CONFIG.PRINTER.IP || CONFIG.PRINTER.IP === "192.168.1.XXX") {
      console.warn("Printer configuration not set. Please update config.js with your printer details.");
      this.updatePrinterUI({
        isConnected: false,
        error: "Printer not configured",
      });
      return;
    }

    // Initialize static project information from config
    this.initProjectInfo();

    // Initialize notification service
    if (CONFIG.SLACK && CONFIG.SLACK.WEBHOOK_URL) {
      window.notificationService = new NotificationService(CONFIG.SLACK.WEBHOOK_URL, CONFIG.SLACK);
      console.log("[NOTIFICATIONS] Slack notifications enabled");
    } else {
      console.warn("[NOTIFICATIONS] Slack webhook not configured");
    }

    // Create printer status instance
    window.printerStatus = new PrinterStatus(CONFIG.PRINTER.IP, CONFIG.PRINTER.SERIAL, CONFIG.PRINTER.CHECK_CODE);

    // Initialize connection
    window.printerStatus.initialize().then((connected) => {
      if (connected) {
        console.log("Printer connected successfully");
        // Start automatic updates
        window.printerStatus.startUpdates(CONFIG.PRINTER.UPDATE_INTERVAL, (status) => {
          this.updatePrinterUI(status);
        });
      } else {
        console.error("Failed to connect to printer");
        this.updatePrinterUI({
          isConnected: false,
          error: "Offline",
        });
      }
    });
  }

  // Initialize project information from config
  initProjectInfo() {
    // No longer needed - project info is now shown via the job filename
    // which is updated dynamically in updatePrinterUI
  }

  // Update printer status UI
  updatePrinterUI(status) {
    // Update printer name
    const printerName = document.getElementById("printer-name");
    if (status.printer && status.printer.Name) {
      printerName.textContent = status.printer.Name;
    }

    // Update printer state badge
    const printerState = document.getElementById("printer-state");
    if (!status.isConnected) {
      printerState.textContent = status.error || "Offline";
      printerState.className = "status-badge error";
      return;
    }

    // Use the parsed MachineState from printer.js
    if (status.machine && status.machine.MachineState) {
      const state = status.machine.MachineState;
      printerState.textContent = state;
      printerState.className = `status-badge ${state.toLowerCase()}`;
    } else if (status.machine && status.machine.Status) {
      // Fallback to raw status if MachineState is not available
      printerState.textContent = status.machine.Status;
      printerState.className = "status-badge unknown";
    }

    // Update temperatures with targets and heating indicators
    if (status.machine) {
      const tempNozzle = document.getElementById("temp-nozzle");
      const tempBed = document.getElementById("temp-bed");
      const TEMP_THRESHOLD = 5; // degrees C - consider "at temp" when within this range

      if (status.machine.NozzleTemp !== undefined) {
        const current = Math.round(status.machine.NozzleTemp);
        const target = status.machine.NozzleTargetTemp ? Math.round(status.machine.NozzleTargetTemp) : null;

        if (target && target > 0) {
          const isHeating = current < target - TEMP_THRESHOLD;
          const atTemp = Math.abs(current - target) <= TEMP_THRESHOLD;
          const heatingIcon = isHeating ? '<span class="heating-icon">🔥</span>' : "";
          const tempClass = atTemp ? "temp-at-target" : isHeating ? "temp-heating" : "";

          tempNozzle.innerHTML = `${heatingIcon}<span class="temp-current ${tempClass}">${current}°C</span> <span class="temp-separator">/</span> <span class="temp-target">${target}°C</span>`;
        } else {
          tempNozzle.textContent = `${current}°C`;
        }
      }

      if (status.machine.BedTemp !== undefined) {
        const current = Math.round(status.machine.BedTemp);
        const target = status.machine.BedTargetTemp ? Math.round(status.machine.BedTargetTemp) : null;

        if (target && target > 0) {
          const isHeating = current < target - TEMP_THRESHOLD;
          const atTemp = Math.abs(current - target) <= TEMP_THRESHOLD;
          const heatingIcon = isHeating ? '<span class="heating-icon">🔥</span>' : "";
          const tempClass = atTemp ? "temp-at-target" : isHeating ? "temp-heating" : "";

          tempBed.innerHTML = `${heatingIcon}<span class="temp-current ${tempClass}">${current}°C</span> <span class="temp-separator">/</span> <span class="temp-target">${target}°C</span>`;
        } else {
          tempBed.textContent = `${current}°C`;
        }
      }
    }

    // Determine if printer is idle and we should use cached data
    const printerIsIdle =
      status.machine &&
      (status.machine.Status.toLowerCase().includes("ready") || status.machine.Status.toLowerCase().includes("idle"));
    const currentJobEmpty = !status.job || !status.job.FileName || status.job.FileName === "--";

    console.log("[UI] Cache check - printerIsIdle:", printerIsIdle, "currentJobEmpty:", currentJobEmpty);
    console.log("[UI] status.machine:", status.machine);
    console.log("[UI] status.job:", status.job);
    console.log("[UI] window.printerStatus.lastValidJobInfo:", window.printerStatus?.lastValidJobInfo);

    // Use cached data if printer is idle and current job is empty
    let displayJob = status.job;
    if (printerIsIdle && currentJobEmpty && window.printerStatus && window.printerStatus.lastValidJobInfo) {
      console.log("[UI] ✅ Printer idle, using cached job data:", window.printerStatus.lastValidJobInfo);
      displayJob = window.printerStatus.lastValidJobInfo;
    } else {
      console.log("[UI] ❌ Not using cache - conditions not met");
    }

    // Update job information
    if (status.job) {
      const jobFile = document.getElementById("job-file");
      const jobProgress = document.getElementById("job-progress");
      const jobTime = document.getElementById("job-time");
      const jobDuration = document.getElementById("job-duration");
      const jobLayer = document.getElementById("job-layer");

      if (displayJob.FileName && displayJob.FileName !== "--") {
        // Create "View Model" button with 3D rotation icon
        jobFile.innerHTML = `<button class="view-model-btn" data-filename="${displayJob.FileName}">
          View <span class="material-icons">3d_rotation</span> Model
        </button>`;

        // Add click event listener to the button
        const button = jobFile.querySelector(".view-model-btn");
        if (button) {
          button.addEventListener("click", (e) => {
            e.preventDefault();
            const fileName = e.currentTarget.getAttribute("data-filename");
            if (window.modelViewer) {
              window.modelViewer.openModal(fileName);
            }
          });
        }
      } else {
        jobFile.textContent = "--";
      }

      if (displayJob.Progress !== undefined) {
        jobProgress.textContent = `${Math.round(displayJob.Progress)}%`;
      }
      if (displayJob.TimeRemaining !== undefined) {
        jobTime.textContent = this.formatTime(displayJob.TimeRemaining);
      }
      if (displayJob.PrintDuration !== undefined) {
        jobDuration.textContent = this.formatTime(displayJob.PrintDuration);
      }
      if (displayJob.PrintLayer !== undefined && displayJob.TargetPrintLayer !== undefined) {
        if (displayJob.TargetPrintLayer > 0) {
          jobLayer.textContent = `${displayJob.PrintLayer} / ${displayJob.TargetPrintLayer}`;
        } else {
          jobLayer.textContent = "--";
        }
      }
    }

    // Update material information
    if (status.machine || status.job) {
      const materialType = document.getElementById("material-type");
      const materialColor = document.getElementById("material-color");
      const materialWeight = document.getElementById("material-weight");
      const materialInfill = document.getElementById("material-infill");

      if (status.machine && status.machine.MaterialType) {
        materialType.textContent = status.machine.MaterialType;
      }

      // Use filament color from config if available, otherwise use API value
      if (materialColor) {
        if (CONFIG.PRINTER.FILAMENT && CONFIG.PRINTER.FILAMENT.COLOR) {
          materialColor.textContent = CONFIG.PRINTER.FILAMENT.COLOR;
        } else if (status.machine && status.machine.MaterialColor) {
          materialColor.textContent = status.machine.MaterialColor;
        }
      }

      // Update material weight and infill - use displayJob if available
      const jobDataForMaterial = displayJob || status.job;
      if (jobDataForMaterial) {
        if (jobDataForMaterial.EstimatedWeight !== undefined && jobDataForMaterial.EstimatedWeight > 0) {
          materialWeight.textContent = `${jobDataForMaterial.EstimatedWeight.toFixed(1)}g`;
        } else {
          materialWeight.textContent = "--";
        }

        if (jobDataForMaterial.FillAmount !== undefined && jobDataForMaterial.FillAmount > 0) {
          materialInfill.textContent = `${jobDataForMaterial.FillAmount}%`;
        } else {
          materialInfill.textContent = "--";
        }
      }
    }

    // Update printer info
    if (status.machine) {
      const nozzleModel = document.getElementById("nozzle-model");
      const printSpeed = document.getElementById("print-speed");
      const doorStatus = document.getElementById("door-status");
      const lightStatus = document.getElementById("light-status");

      if (status.machine.NozzleModel) {
        nozzleModel.textContent = status.machine.NozzleModel;
      }

      if (status.machine.CurrentPrintSpeed !== undefined && status.machine.CurrentPrintSpeed > 0) {
        printSpeed.textContent = `${status.machine.CurrentPrintSpeed} mm/s`;
      } else {
        printSpeed.textContent = "--";
      }

      if (status.machine.DoorStatus) {
        doorStatus.textContent = status.machine.DoorStatus === "open" ? "Open" : "Closed";
      }

      if (status.machine.LightStatus) {
        lightStatus.textContent = status.machine.LightStatus === "open" ? "On" : "Off";
      }

      // Update cumulative statistics (if element exists)
      const cumulativeTime = document.getElementById("cumulative-time");
      if (cumulativeTime) {
        if (status.machine.CumulativePrintTime !== undefined && status.machine.CumulativePrintTime > 0) {
          cumulativeTime.textContent = `${status.machine.CumulativePrintTime}h`;
        } else {
          cumulativeTime.textContent = "--";
        }
      }
    }
  }

  // Format time in seconds to human-readable format
  formatTime(seconds) {
    if (!seconds || seconds < 0) return "--";

    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);

    if (hours > 0) {
      return `${hours}h ${minutes}m`;
    } else {
      return `${minutes}m`;
    }
  }

  // Show error message
  showError(message) {
    const errorDiv = document.getElementById("error-message");
    errorDiv.textContent = message;
    errorDiv.style.display = "block";
    setTimeout(() => {
      errorDiv.style.display = "none";
    }, 5000);
  }
}

// Initialize auth when page loads
let auth;
window.addEventListener("load", async () => {
  auth = new GoogleAuth();

  // Check if in dev mode (only works on localhost)
  const isLocalhost = window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1";
  if (CONFIG.DEV_MODE && isLocalhost) {
    // Bypass authentication in dev mode
    auth.user = {
      email: "dev@localhost",
      name: "Developer",
      picture: null,
      credential: null,
    };
    auth.onAuthStateChanged();
    return;
  }

  // Check if already signed in
  if (!auth.checkSession()) {
    // Wait for Google API to load, then initialize
    await auth.init();
    auth.renderSignInButton();
  }
});
