/**
 * User Activity Logger
 * Logs authentication events, session data, and user activity
 */

class ActivityLogger {
  constructor() {
    this.sessionId = this.generateSessionId();
    this.sessionStartTime = null;
    this.lastActivityTime = null;
    this.activityLog = [];
    this.heartbeatInterval = null;
    this.logEndpoint = null;

    // Determine log endpoint based on environment
    const isLocalhost = window.location.hostname === "localhost" || window.location.hostname === "127.0.0.1";
    if (!isLocalhost) {
      this.logEndpoint = `${window.location.origin}/api/log.php`;
    }
  }

  // Generate unique session ID
  generateSessionId() {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }

  // Get browser and device information
  getBrowserInfo() {
    const ua = navigator.userAgent;
    let browserName = "Unknown";
    let browserVersion = "Unknown";
    let osName = "Unknown";

    // Detect browser
    if (ua.indexOf("Firefox") > -1) {
      browserName = "Firefox";
      browserVersion = ua.match(/Firefox\/([0-9.]+)/)?.[1] || "Unknown";
    } else if (ua.indexOf("Chrome") > -1 && ua.indexOf("Edg") === -1) {
      browserName = "Chrome";
      browserVersion = ua.match(/Chrome\/([0-9.]+)/)?.[1] || "Unknown";
    } else if (ua.indexOf("Safari") > -1 && ua.indexOf("Chrome") === -1) {
      browserName = "Safari";
      browserVersion = ua.match(/Version\/([0-9.]+)/)?.[1] || "Unknown";
    } else if (ua.indexOf("Edg") > -1) {
      browserName = "Edge";
      browserVersion = ua.match(/Edg\/([0-9.]+)/)?.[1] || "Unknown";
    }

    // Detect OS
    if (ua.indexOf("Win") > -1) osName = "Windows";
    else if (ua.indexOf("Mac") > -1) osName = "macOS";
    else if (ua.indexOf("Linux") > -1) osName = "Linux";
    else if (ua.indexOf("Android") > -1) osName = "Android";
    else if (ua.indexOf("iOS") > -1 || ua.indexOf("iPhone") > -1 || ua.indexOf("iPad") > -1) osName = "iOS";

    return {
      browser: browserName,
      browserVersion: browserVersion,
      os: osName,
      userAgent: ua,
      language: navigator.language,
      screenResolution: `${window.screen.width}x${window.screen.height}`,
      viewportSize: `${window.innerWidth}x${window.innerHeight}`,
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
      platform: navigator.platform,
    };
  }

  // Log user login
  async logLogin(user) {
    this.sessionStartTime = new Date();
    this.lastActivityTime = new Date();

    const browserInfo = this.getBrowserInfo();

    const loginData = {
      event: "login",
      sessionId: this.sessionId,
      timestamp: this.sessionStartTime.toISOString(),
      user: {
        email: user.email,
        name: user.name,
      },
      browser: browserInfo,
      referrer: document.referrer || "direct",
      url: window.location.href,
    };

    this.activityLog.push(loginData);
    await this.sendLog(loginData);

    // Start heartbeat to track session duration
    this.startHeartbeat();

    console.log("📊 Login logged:", loginData);
  }

  // Log user logout
  async logLogout(user) {
    const logoutTime = new Date();
    const sessionDuration = this.sessionStartTime ? (logoutTime - this.sessionStartTime) / 1000 : 0;

    const logoutData = {
      event: "logout",
      sessionId: this.sessionId,
      timestamp: logoutTime.toISOString(),
      user: {
        email: user?.email || "unknown",
        name: user?.name || "unknown",
      },
      sessionDuration: Math.round(sessionDuration),
      sessionDurationFormatted: this.formatDuration(sessionDuration),
    };

    this.activityLog.push(logoutData);
    await this.sendLog(logoutData);

    this.stopHeartbeat();

    console.log("📊 Logout logged:", logoutData);
  }

  // Log page activity (heartbeat)
  async logActivity(user) {
    this.lastActivityTime = new Date();
    const sessionDuration = this.sessionStartTime ? (this.lastActivityTime - this.sessionStartTime) / 1000 : 0;

    const activityData = {
      event: "heartbeat",
      sessionId: this.sessionId,
      timestamp: this.lastActivityTime.toISOString(),
      user: {
        email: user?.email || "unknown",
      },
      sessionDuration: Math.round(sessionDuration),
      url: window.location.href,
      pageVisible: !document.hidden,
    };

    this.activityLog.push(activityData);
    await this.sendLog(activityData);
  }

  // Log custom event
  async logEvent(eventName, eventData = {}, user = null) {
    const eventLog = {
      event: eventName,
      sessionId: this.sessionId,
      timestamp: new Date().toISOString(),
      user: user
        ? {
            email: user.email,
            name: user.name,
          }
        : null,
      data: eventData,
    };

    this.activityLog.push(eventLog);
    await this.sendLog(eventLog);

    console.log(`📊 Event logged: ${eventName}`, eventLog);
  }

  // Start heartbeat to track active session
  startHeartbeat() {
    // Send heartbeat every 60 seconds
    this.heartbeatInterval = setInterval(() => {
      if (window.auth && window.auth.user) {
        this.logActivity(window.auth.user);
      }
    }, 60000); // 60 seconds

    // Log when page becomes visible/hidden
    document.addEventListener("visibilitychange", () => {
      if (window.auth && window.auth.user) {
        this.logEvent(document.hidden ? "page_hidden" : "page_visible", {}, window.auth.user);
      }
    });

    // Log when user leaves page
    window.addEventListener("beforeunload", () => {
      if (window.auth && window.auth.user) {
        // Use sendBeacon for reliable logging on page unload
        const logoutData = {
          event: "page_unload",
          sessionId: this.sessionId,
          timestamp: new Date().toISOString(),
          user: {
            email: window.auth.user.email,
          },
          sessionDuration: Math.round((new Date() - this.sessionStartTime) / 1000),
        };
        this.sendLogBeacon(logoutData);
      }
    });
  }

  // Stop heartbeat
  stopHeartbeat() {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval);
      this.heartbeatInterval = null;
    }
  }

  // Format duration in human-readable format
  formatDuration(seconds) {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = Math.floor(seconds % 60);

    const parts = [];
    if (hours > 0) parts.push(`${hours}h`);
    if (minutes > 0) parts.push(`${minutes}m`);
    if (secs > 0 || parts.length === 0) parts.push(`${secs}s`);

    return parts.join(" ");
  }

  // Send log to server
  async sendLog(logData) {
    // In development (localhost), just log to console
    if (!this.logEndpoint) {
      console.log("📊 [DEV] Log:", logData);
      return;
    }

    try {
      await fetch(this.logEndpoint, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(logData),
      });
    } catch (error) {
      console.error("Failed to send log:", error);
    }
  }

  // Send log using sendBeacon (for page unload)
  sendLogBeacon(logData) {
    if (!this.logEndpoint) {
      console.log("📊 [DEV] Beacon Log:", logData);
      return;
    }

    const blob = new Blob([JSON.stringify(logData)], { type: "application/json" });
    navigator.sendBeacon(this.logEndpoint, blob);
  }

  // Get all logs for current session
  getSessionLogs() {
    return this.activityLog;
  }

  // Export logs as JSON
  exportLogs() {
    const dataStr = JSON.stringify(this.activityLog, null, 2);
    const dataBlob = new Blob([dataStr], { type: "application/json" });
    const url = URL.createObjectURL(dataBlob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `activity-log-${this.sessionId}.json`;
    link.click();
    URL.revokeObjectURL(url);
  }
}

// Create global logger instance
window.activityLogger = new ActivityLogger();
