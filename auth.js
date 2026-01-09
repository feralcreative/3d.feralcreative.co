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

      // Store in session
      sessionStorage.setItem("user", JSON.stringify(this.user));

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
        .join("")
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

  // Check if user is already signed in (from session)
  checkSession() {
    const storedUser = sessionStorage.getItem("user");
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
    sessionStorage.removeItem("user");
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

    if (this.user) {
      // User is signed in
      loginScreen.style.display = "none";
      streamContainer.style.display = "flex";
      hamburgerMenu.style.display = "block";
      userEmail.textContent = this.user.email;

      // Set the appropriate stream URL based on environment (only once)
      if (!this.streamUrlSet) {
        const isLocalhost = window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1";
        const streamUrl = isLocalhost ? CONFIG.STREAM_URL.DEV : CONFIG.STREAM_URL.PROD;

        // Set up error handler to show offline image
        streamImage.onerror = function () {
          this.src = "./images/offline.jpg";
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
          error: "Connection failed",
        });
      }
    });
  }

  // Initialize project information from config
  initProjectInfo() {
    const projectLink = document.getElementById("project-link");
    if (CONFIG.PRINTER.CURRENT_PROJECT && CONFIG.PRINTER.CURRENT_PROJECT.NAME) {
      projectLink.textContent = CONFIG.PRINTER.CURRENT_PROJECT.NAME;
      projectLink.href = CONFIG.PRINTER.CURRENT_PROJECT.URL || "#";
    }
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

    // Determine printer state from machine info
    if (status.machine && status.machine.Status) {
      const machineStatus = status.machine.Status;
      if (machineStatus.includes("PRINTING") || machineStatus.includes("WORKING")) {
        printerState.textContent = "Printing";
        printerState.className = "status-badge printing";
      } else if (machineStatus.includes("READY") || machineStatus.includes("IDLE")) {
        printerState.textContent = "Ready";
        printerState.className = "status-badge idle";
      } else {
        printerState.textContent = machineStatus;
        printerState.className = "status-badge";
      }
    }

    // Update temperatures
    if (status.machine) {
      const tempNozzle = document.getElementById("temp-nozzle");
      const tempBed = document.getElementById("temp-bed");

      if (status.machine.NozzleTemp !== undefined) {
        tempNozzle.textContent = `${Math.round(status.machine.NozzleTemp)}°C`;
      }
      if (status.machine.BedTemp !== undefined) {
        tempBed.textContent = `${Math.round(status.machine.BedTemp)}°C`;
      }
    }

    // Update job information
    if (status.job) {
      const jobFile = document.getElementById("job-file");
      const jobProgress = document.getElementById("job-progress");
      const jobTime = document.getElementById("job-time");

      if (status.job.FileName) {
        jobFile.textContent = status.job.FileName;
      }
      if (status.job.Progress !== undefined) {
        jobProgress.textContent = `${Math.round(status.job.Progress)}%`;
      }
      if (status.job.TimeRemaining !== undefined) {
        jobTime.textContent = this.formatTime(status.job.TimeRemaining);
      }
    }

    // Update material information
    if (status.machine) {
      const materialType = document.getElementById("material-type");
      const materialColor = document.getElementById("material-color");

      if (status.machine.MaterialType) {
        materialType.textContent = status.machine.MaterialType;
      }

      // Use filament color from config if available, otherwise use API value
      if (CONFIG.PRINTER.FILAMENT && CONFIG.PRINTER.FILAMENT.COLOR) {
        materialColor.textContent = CONFIG.PRINTER.FILAMENT.COLOR;
      } else if (status.machine.MaterialColor) {
        materialColor.textContent = status.machine.MaterialColor;
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
