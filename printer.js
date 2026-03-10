/**
 * FlashForge Printer Status Module
 * Communicates with FlashForge Adventurer 5M Pro via HTTP API
 */

class PrinterStatus {
  constructor(ip, serialNumber, checkCode) {
    this.ip = ip;
    this.serialNumber = serialNumber;
    this.checkCode = checkCode;

    // Determine if we're in production or development
    const isLocalhost = window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1";

    if (isLocalhost) {
      // Development: Use local proxy server to avoid CORS issues
      this.baseUrl = CONFIG.PRINTER_PROXY_URL.DEV;
      this.useProxy = false;
    } else {
      // Production: Use /api which is proxied by Nginx to printer-proxy-server.js on port 6199
      this.baseUrl = CONFIG.PRINTER_PROXY_URL.PROD;
      this.useProxy = false;
    }

    this.isConnected = false;
    this.printerInfo = null;
    this.machineInfo = null;
    this.jobInfo = null;
    this.lastValidJobInfo = null; // Cache for last valid print data
    this.updateInterval = null;
    this.onStatusUpdate = null;
    this.isUpdating = false; // Flag to prevent overlapping updates

    // State tracking for notifications
    this.previousState = null;
    this.previousProgress = 0;
    this.previousFileName = null;
    this.milestonesSent = new Set(); // Track which progress milestones we've sent

    // TEMPORARY: Initialize with test data to demonstrate caching feature
    this.lastValidJobInfo = {
      FileName: "no-model-loaded.3mf",
      Progress: 100,
      TimeRemaining: 0,
      PrintDuration: 7245, // 2 hours 45 seconds
      PrintLayer: 250,
      TargetPrintLayer: 250,
      EstimatedWeight: 13.5,
      FillAmount: 15,
    };
    console.log("[PRINTER] Initialized with test cache data:", this.lastValidJobInfo);
  }

  /**
   * Parse machine state from status string
   * Maps the raw status string to a human-readable machine state
   */
  parseMachineState(status) {
    if (!status) return "Unknown";

    const statusLower = status.toLowerCase();

    // Map status strings to machine states based on FlashForge API documentation
    if (statusLower.includes("ready") || statusLower.includes("idle")) {
      return "Ready";
    } else if (statusLower.includes("printing") || statusLower.includes("working")) {
      return "Printing";
    } else if (statusLower.includes("heating") || statusLower.includes("preheat")) {
      return "Heating";
    } else if (statusLower.includes("pausing")) {
      return "Pausing";
    } else if (statusLower.includes("paused")) {
      return "Paused";
    } else if (statusLower.includes("calibrat")) {
      return "Calibrating";
    } else if (statusLower.includes("cancel")) {
      return "Cancelled";
    } else if (statusLower.includes("complet") || statusLower.includes("finish")) {
      return "Completed";
    } else if (statusLower.includes("error")) {
      return "Error";
    } else if (statusLower.includes("busy")) {
      return "Busy";
    } else {
      return status; // Return original if no match
    }
  }

  /**
   * Initialize connection to printer
   */
  async initialize() {
    try {
      console.log("[PRINTER] Initializing connection...");
      console.log("[PRINTER] Base URL:", this.baseUrl);
      console.log("[PRINTER] Serial:", this.serialNumber);

      // Test connection by getting printer info
      const info = await this.getPrinterInfo();
      console.log("[PRINTER] Received info:", info);

      if (info) {
        this.isConnected = true;
        this.printerInfo = info;
        console.log("[PRINTER] Connected to printer. Info:", info);
        return true;
      }
      console.log("[PRINTER] No info received, connection failed");
      return false;
    } catch (error) {
      console.error("[PRINTER] Failed to connect to printer:", error);
      this.isConnected = false;
      return false;
    }
  }

  /**
   * Get printer information using /product endpoint
   */
  async getPrinterInfo() {
    try {
      const url = `${this.baseUrl}/product`;

      const body = {
        serialNumber: this.serialNumber,
        checkCode: this.checkCode,
      };

      console.log("[PRINTER] Fetching printer info from:", url);
      console.log("[PRINTER] Request body:", body);

      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
      });

      console.log("[PRINTER] Response status:", response.status);

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      console.log("[PRINTER] Raw response data:", data);

      // The API returns {code, message, product}, extract the product data
      const result = data.product || data;
      console.log("[PRINTER] Extracted product data:", result);

      return result;
    } catch (error) {
      console.error("[PRINTER] Error fetching printer info:", error);
      return null;
    }
  }

  /**
   * Get machine status (temperatures, positions, etc.) using /detail endpoint
   */
  async getMachineInfo() {
    try {
      const url = `${this.baseUrl}/detail`;

      const body = {
        serialNumber: this.serialNumber,
        checkCode: this.checkCode,
      };

      console.log("[PRINTER] Fetching machine info from:", url);
      console.log("[PRINTER] Request body:", body);

      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(body),
      });

      console.log("[PRINTER] Response status:", response.status);

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      console.log("[PRINTER] Raw machine info response:", data);

      // The API returns {code, message, product}, extract the product data
      const detail = data.product || data.detail || data;
      console.log("[PRINTER] Extracted detail data:", detail);

      // Map the actual API response to expected format
      this.machineInfo = {
        Status: detail.status || "unknown",
        MachineState: this.parseMachineState(detail.status),
        NozzleTemp: detail.rightTemp || detail.leftTemp || 0,
        NozzleTargetTemp: detail.rightTargetTemp || detail.leftTargetTemp || 0,
        BedTemp: detail.platTemp || 0,
        BedTargetTemp: detail.platTargetTemp || 0,
        MaterialType: detail.rightFilamentType || detail.leftFilamentType || "--",
        MaterialColor: "--", // API doesn't provide color
        NozzleModel: detail.nozzleModel || "--",
        NozzleStyle: detail.nozzleStyle !== undefined ? detail.nozzleStyle : "--",
        DoorStatus: detail.doorStatus || "--",
        LightStatus: detail.lightStatus || "--",
        CurrentPrintSpeed: detail.currentPrintSpeed || 0,
        CumulativePrintTime: detail.cumulativePrintTime || 0,
      };

      console.log("[PRINTER] Mapped machine info:", this.machineInfo);

      // Store job info separately for getAllStatus()
      // estimatedTime is already the remaining time, not total time
      this.jobInfo = {
        FileName: detail.printFileName || "--",
        Progress: detail.printProgress ? Math.round(detail.printProgress * 100) : 0,
        TimeRemaining: detail.estimatedTime ? Math.round(detail.estimatedTime) : 0,
        PrintDuration: detail.printDuration ? Math.round(detail.printDuration) : 0,
        PrintLayer: detail.printLayer || 0,
        TargetPrintLayer: detail.targetPrintLayer || 0,
        EstimatedWeight: detail.estimatedRightWeight || 0,
        FillAmount: detail.fillAmount || 0,
      };

      console.log("[PRINTER] Job info:", this.jobInfo);

      // Cache valid job data for display when printer goes idle
      // Only cache if we have a valid filename and some progress
      if (this.jobInfo.FileName && this.jobInfo.FileName !== "--") {
        // Check if this is a new print (different filename)
        const isNewPrint = !this.lastValidJobInfo || this.lastValidJobInfo.FileName !== this.jobInfo.FileName;

        if (isNewPrint) {
          console.log("[PRINTER] New print detected:", this.jobInfo.FileName);
        }

        // Always update cache with current job data when we have a valid filename
        this.lastValidJobInfo = { ...this.jobInfo };
        console.log("[PRINTER] Cached job info:", this.lastValidJobInfo);
      }

      return this.machineInfo;
    } catch (error) {
      console.error("[PRINTER] Error fetching machine info:", error);
      return null;
    }
  }

  /**
   * Get current job information
   */
  async getJobInfo() {
    try {
      const url = this.useProxy ? `${this.baseUrl}?endpoint=job` : `${this.baseUrl}/job`;

      const response = await fetch(url, {
        method: "GET",
        headers: this.useProxy
          ? {}
          : {
              SN: this.serialNumber,
              CHKCODE: this.checkCode,
            },
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      this.jobInfo = data;
      return data;
    } catch (error) {
      console.error("Error fetching job info:", error);
      return null;
    }
  }

  /**
   * Get all status information
   */
  async getAllStatus() {
    console.log("[PRINTER] Getting all status...");

    // Make requests sequentially instead of parallel to avoid overwhelming the printer
    // FlashForge printers in LAN-only mode can be flaky with simultaneous requests
    const printerInfo = await this.getPrinterInfo();

    // Small delay between requests to give printer time to process
    await new Promise((resolve) => setTimeout(resolve, 100));

    const machineInfo = await this.getMachineInfo();

    console.log("[PRINTER] All status - printerInfo:", printerInfo);
    console.log("[PRINTER] All status - machineInfo:", machineInfo);
    console.log("[PRINTER] All status - jobInfo:", this.jobInfo);

    // Use jobInfo from getMachineInfo() since /detail endpoint has all the data
    // The /job endpoint returns empty for this printer model
    const result = {
      printer: printerInfo,
      machine: machineInfo,
      job: this.jobInfo || null,
      isConnected: this.isConnected,
      timestamp: new Date().toISOString(),
    };

    console.log("[PRINTER] Returning status:", result);
    return result;
  }

  /**
   * Start automatic status updates
   */
  startUpdates(interval = 5000, callback) {
    this.onStatusUpdate = callback;

    // Initial update
    this.updateStatus();

    // Set up interval
    this.updateInterval = setInterval(() => {
      this.updateStatus();
    }, interval);
  }

  /**
   * Update status and call callback
   */
  async updateStatus() {
    // Skip if already updating to prevent overlapping requests
    if (this.isUpdating) {
      console.log("[PRINTER] Skipping update - previous update still in progress");
      return;
    }

    this.isUpdating = true;
    try {
      const status = await this.getAllStatus();

      // Detect state changes for notifications
      this.detectStateChanges(status);

      if (this.onStatusUpdate) {
        this.onStatusUpdate(status);
      }
    } catch (error) {
      console.error("[PRINTER] Error during update:", error);
    } finally {
      this.isUpdating = false;
    }
  }

  /**
   * Detect state changes and trigger notifications
   */
  detectStateChanges(status) {
    if (!status || !status.machine || !status.job) {
      return;
    }

    // Use MachineState (parsed, title case) instead of Status (raw, lowercase)
    const currentState = status.machine.MachineState;
    const currentProgress = status.job.Progress || 0;
    const currentFileName = status.job.FileName;

    console.log(`[PRINTER] detectStateChanges - State: ${currentState}, Progress: ${currentProgress}%`);

    // Check if this is a new print (different file)
    if (currentFileName && currentFileName !== "--" && currentFileName !== this.previousFileName) {
      console.log("[PRINTER] New print detected:", currentFileName);
      this.previousFileName = currentFileName;
      this.milestonesSent.clear(); // Reset milestones for new print
    }

    // Detect state transitions
    if (this.previousState !== currentState) {
      console.log(`[PRINTER] State changed: ${this.previousState} → ${currentState}`);

      // Print started (idle/ready → printing)
      if (
        currentState === "Printing" &&
        (this.previousState === "Ready" || this.previousState === "Idle" || this.previousState === null)
      ) {
        this.onPrintStarted(status);
      }

      // Print completed (printing → ready/idle with 100% progress)
      if (
        (currentState === "Ready" || currentState === "Idle") &&
        this.previousState === "Printing" &&
        this.previousProgress >= 99
      ) {
        this.onPrintCompleted(status);
      }

      // Print paused
      if (currentState === "Paused" && this.previousState === "Printing") {
        this.onPrintPaused(status);
      }

      // Print failed/cancelled (printing → ready/idle with low progress)
      if (
        (currentState === "Ready" || currentState === "Idle") &&
        this.previousState === "Printing" &&
        this.previousProgress < 99 &&
        this.previousProgress > 0
      ) {
        this.onPrintFailed(status);
      }

      this.previousState = currentState;
    }

    // Check for progress milestones (50% only)
    if (currentState === "Printing" && currentProgress > 0) {
      console.log(`[PRINTER] Checking milestones - Current: ${currentProgress}%, Previous: ${this.previousProgress}%`);
      const milestones = [50];
      for (const milestone of milestones) {
        if (currentProgress >= milestone && this.previousProgress < milestone) {
          if (!this.milestonesSent.has(milestone)) {
            console.log(`[PRINTER] 🎯 Milestone reached: ${milestone}%`);
            this.onProgressMilestone(status, milestone);
            this.milestonesSent.add(milestone);
          } else {
            console.log(`[PRINTER] Milestone ${milestone}% already sent`);
          }
        }
      }
    }

    this.previousProgress = currentProgress;
  }

  /**
   * Event handlers for state changes (to be overridden or used with callbacks)
   * NOTE: Notifications are now handled server-side by printer-proxy-server.js
   * Client-side notifications are disabled to prevent duplicates
   */
  onPrintStarted(status) {
    console.log("[PRINTER] Print started:", status.job.FileName);
    // Notifications handled server-side - client-side disabled to prevent duplicates
    // if (window.notificationService) {
    //   window.notificationService.notifyPrintStarted(status);
    // }
  }

  onPrintCompleted(status) {
    console.log("[PRINTER] Print completed:", status.job.FileName);
    // Notifications handled server-side - client-side disabled to prevent duplicates
    // if (window.notificationService) {
    //   window.notificationService.notifyPrintCompleted(status);
    // }
  }

  onProgressMilestone(status, milestone) {
    console.log(`[PRINTER] Progress milestone: ${milestone}%`);
    // Notifications handled server-side - client-side disabled to prevent duplicates
    // if (window.notificationService) {
    //   window.notificationService.notifyProgress(status, milestone);
    // }
  }

  onPrintPaused(status) {
    console.log("[PRINTER] Print paused");
    // Notifications handled server-side - client-side disabled to prevent duplicates
    // if (window.notificationService) {
    //   window.notificationService.notifyPrintPaused(status);
    // }
  }

  onPrintFailed(status) {
    console.log("[PRINTER] Print failed/cancelled");
    // Notifications handled server-side - client-side disabled to prevent duplicates
    // if (window.notificationService) {
    //   window.notificationService.notifyPrintFailed(status);
    // }
  }

  /**
   * Stop automatic updates
   */
  stopUpdates() {
    if (this.updateInterval) {
      clearInterval(this.updateInterval);
      this.updateInterval = null;
    }
  }
}
