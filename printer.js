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
      this.baseUrl = `http://localhost:3001`;
      this.useProxy = false;
    } else {
      // Production: Use separate subdomain for printer API
      // Synology reverse proxy forwards 3dprinter.feralcreative.co to localhost:6199
      this.baseUrl = `https://3dprinter.feralcreative.co`;
      this.useProxy = false;
    }

    this.isConnected = false;
    this.printerInfo = null;
    this.machineInfo = null;
    this.jobInfo = null;
    this.updateInterval = null;
    this.onStatusUpdate = null;
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
        NozzleTemp: detail.rightTemp || detail.leftTemp || 0,
        BedTemp: detail.platTemp || 0,
        MaterialType: detail.rightFilamentType || detail.leftFilamentType || "--",
        MaterialColor: "--", // API doesn't provide color
      };

      console.log("[PRINTER] Mapped machine info:", this.machineInfo);

      // Store job info separately for getAllStatus()
      // estimatedTime is already the remaining time, not total time
      this.jobInfo = {
        FileName: detail.printFileName || "--",
        Progress: detail.printProgress ? Math.round(detail.printProgress * 100) : 0,
        TimeRemaining: detail.estimatedTime ? Math.round(detail.estimatedTime) : 0,
      };

      console.log("[PRINTER] Job info:", this.jobInfo);

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
    const [printerInfo, machineInfo] = await Promise.all([this.getPrinterInfo(), this.getMachineInfo()]);

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
    const status = await this.getAllStatus();
    if (this.onStatusUpdate) {
      this.onStatusUpdate(status);
    }
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
