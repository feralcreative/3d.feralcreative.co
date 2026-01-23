/**
 * Slack Notification Service
 * Sends formatted notifications to Slack for printer status changes
 */

class NotificationService {
  constructor(webhookUrl, config) {
    this.webhookUrl = webhookUrl;
    this.config = config || {};
    this.enabled = config.ENABLED !== false;
    this.lastNotificationTime = {};
    this.notificationCooldown = 60000; // 1 minute cooldown between duplicate notifications
  }

  /**
   * Check if notifications are enabled globally and for specific event type
   */
  isEnabled(eventType) {
    if (!this.enabled || !this.webhookUrl) {
      return false;
    }
    if (this.config.NOTIFICATIONS && eventType) {
      return this.config.NOTIFICATIONS[eventType] !== false;
    }
    return true;
  }

  /**
   * Check if we should send notification (cooldown check)
   */
  shouldNotify(eventKey) {
    const now = Date.now();
    const lastTime = this.lastNotificationTime[eventKey] || 0;
    return now - lastTime > this.notificationCooldown;
  }

  /**
   * Mark notification as sent
   */
  markNotified(eventKey) {
    this.lastNotificationTime[eventKey] = Date.now();
  }

  /**
   * Send notification to Slack via proxy server
   * This avoids CORS issues by routing through the backend
   */
  async send(message) {
    if (!this.webhookUrl) {
      console.warn("[NOTIFICATIONS] No webhook URL configured");
      return false;
    }

    try {
      // Determine proxy URL based on environment
      const proxyUrl = window.location.hostname === "localhost" ? "http://localhost:3001/notify" : "/api/notify";

      const response = await fetch(proxyUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          webhookUrl: this.webhookUrl,
          message: message,
        }),
      });

      if (!response.ok) {
        throw new Error(`Proxy error: ${response.status}`);
      }

      console.log("[NOTIFICATIONS] Sent:", message.text || message.blocks?.[0]?.text?.text);
      return true;
    } catch (error) {
      console.error("[NOTIFICATIONS] Failed to send:", error);
      return false;
    }
  }

  /**
   * Format temperature display
   */
  formatTemp(current, target) {
    if (target && target > 0) {
      return `${current}°C → ${target}°C`;
    }
    return `${current}°C`;
  }

  /**
   * Format time duration (seconds to human readable)
   */
  formatDuration(seconds) {
    if (!seconds || seconds <= 0) return "0m";
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    if (hours > 0) {
      return `${hours}h ${minutes}m`;
    }
    return `${minutes}m`;
  }

  /**
   * Notify: Print Started
   */
  async notifyPrintStarted(status) {
    if (!this.isEnabled("PRINT_STARTED")) return;

    const eventKey = `print_started_${status.job.FileName}`;
    if (!this.shouldNotify(eventKey)) return;

    const message = {
      text: "🟢 Print Started",
      blocks: [
        {
          type: "header",
          text: {
            type: "plain_text",
            text: "🟢 Print Started",
            emoji: true,
          },
        },
        {
          type: "section",
          fields: [
            {
              type: "mrkdwn",
              text: `*File:*\n${status.job.FileName}`,
            },
            {
              type: "mrkdwn",
              text: `*Material:*\n${status.machine.MaterialType}`,
            },
            {
              type: "mrkdwn",
              text: `*Nozzle:*\n${this.formatTemp(status.machine.NozzleTemp, status.machine.NozzleTargetTemp)}`,
            },
            {
              type: "mrkdwn",
              text: `*Bed:*\n${this.formatTemp(status.machine.BedTemp, status.machine.BedTargetTemp)}`,
            },
          ],
        },
        {
          type: "context",
          elements: [
            {
              type: "mrkdwn",
              text: `Started at ${new Date().toLocaleTimeString()}`,
            },
          ],
        },
      ],
    };

    const sent = await this.send(message);
    if (sent) this.markNotified(eventKey);
  }

  /**
   * Notify: Print Completed
   */
  async notifyPrintCompleted(status) {
    if (!this.isEnabled("PRINT_COMPLETED")) return;

    const eventKey = `print_completed_${status.job.FileName}`;
    if (!this.shouldNotify(eventKey)) return;

    const message = {
      text: "✅ Print Completed",
      blocks: [
        {
          type: "header",
          text: {
            type: "plain_text",
            text: "✅ Print Completed!",
            emoji: true,
          },
        },
        {
          type: "section",
          fields: [
            {
              type: "mrkdwn",
              text: `*File:*\n${status.job.FileName}`,
            },
            {
              type: "mrkdwn",
              text: `*Duration:*\n${this.formatDuration(status.job.PrintDuration)}`,
            },
            {
              type: "mrkdwn",
              text: `*Layers:*\n${status.job.PrintLayer} / ${status.job.TargetPrintLayer}`,
            },
            {
              type: "mrkdwn",
              text: `*Weight:*\n${status.job.EstimatedWeight}g`,
            },
          ],
        },
        {
          type: "context",
          elements: [
            {
              type: "mrkdwn",
              text: `Completed at ${new Date().toLocaleTimeString()}`,
            },
          ],
        },
      ],
    };

    const sent = await this.send(message);
    if (sent) this.markNotified(eventKey);
  }

  /**
   * Notify: Progress Milestone
   */
  async notifyProgress(status, milestone) {
    if (!this.isEnabled("PROGRESS_MILESTONES")) return;

    const eventKey = `progress_${milestone}_${status.job.FileName}`;
    if (!this.shouldNotify(eventKey)) return;

    const message = {
      text: `📊 Print ${milestone}% Complete`,
      blocks: [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: `*${status.job.FileName}* is *${milestone}%* complete\n⏱️ ${this.formatDuration(status.job.TimeRemaining)} remaining`,
          },
        },
      ],
    };

    const sent = await this.send(message);
    if (sent) this.markNotified(eventKey);
  }

  /**
   * Notify: Print Paused
   */
  async notifyPrintPaused(status) {
    if (!this.isEnabled("PRINT_PAUSED")) return;

    const message = {
      text: "⏸️ Print Paused",
      blocks: [
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: `⏸️ *Print Paused*\n${status.job.FileName} at ${status.job.Progress}%`,
          },
        },
      ],
    };

    await this.send(message);
  }

  /**
   * Notify: Print Failed/Cancelled
   */
  async notifyPrintFailed(status) {
    if (!this.isEnabled("PRINT_FAILED")) return;

    const message = {
      text: "❌ Print Failed",
      blocks: [
        {
          type: "header",
          text: {
            type: "plain_text",
            text: "❌ Print Failed",
            emoji: true,
          },
        },
        {
          type: "section",
          fields: [
            {
              type: "mrkdwn",
              text: `*File:*\n${status.job.FileName}`,
            },
            {
              type: "mrkdwn",
              text: `*Progress:*\n${status.job.Progress}%`,
            },
          ],
        },
      ],
    };

    await this.send(message);
  }
}
