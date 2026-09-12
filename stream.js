/**
 * MJPEG stream client.
 *
 * Chrome and Safari will not render a multipart/x-mixed-replace response in an
 * <img> when it arrives over HTTP/2, and every path to this page negotiates
 * HTTP/2 -- Cloudflare in front of the site, and the Synology reverse proxy in
 * front of Surveillance Station. Reading the multipart stream with fetch() and
 * decoding the parts here sidesteps that entirely: the <img> only ever sees an
 * ordinary JPEG blob.
 *
 * The stream is fetched from our own proxy (see /stream in
 * printer-proxy-server.js) so that the Surveillance Station StmKey stays on the
 * server instead of shipping to every visitor in config.js.
 */

const RECONNECT_BASE_MS = 1000;
const RECONNECT_MAX_MS = 15000;
const ATTEMPTS_BEFORE_OFFLINE = 3;
const OFFLINE_IMAGE = "/images/offline.jpg";

// A frame that has not advanced in this long means the connection is up but the
// camera has stopped sending. Used by the periodic health check in auth.js.
const STALL_TIMEOUT_MS = 15000;

// If no boundary turns up within this much data the response is not the stream
// we expect, so drop the buffer rather than growing it without limit.
const MAX_BUFFER_BYTES = 8 * 1024 * 1024;

const encoder = new TextEncoder();
const decoder = new TextDecoder();
const HEADER_END = encoder.encode("\r\n\r\n");

function concat(a, b) {
  const merged = new Uint8Array(a.length + b.length);
  merged.set(a, 0);
  merged.set(b, a.length);
  return merged;
}

function indexOf(haystack, needle, from) {
  outer: for (let i = from; i <= haystack.length - needle.length; i++) {
    for (let j = 0; j < needle.length; j++) {
      if (haystack[i + j] !== needle[j]) continue outer;
    }
    return i;
  }
  return -1;
}

function parseBoundary(contentType) {
  const match = /boundary=("?)([^";,]+)\1/i.exec(contentType || "");
  return match ? match[2].trim() : null;
}

function parseContentLength(headerBlock) {
  const match = /content-length:\s*(\d+)/i.exec(headerBlock);
  return match ? Number(match[1]) : 0;
}

class MjpegStream {
  constructor(imageElement, url) {
    this.image = imageElement;
    this.url = url;
    this.controller = null;
    this.objectUrl = null;
    this.reconnectTimer = null;
    this.running = false;
    this.attempts = 0;
    this.lastFrameAt = 0;
  }

  start() {
    if (this.running) return;
    this.running = true;
    this.attempts = 0;

    // Very old browsers get the previous behaviour: point the <img> straight at
    // the stream and hope the platform renders it.
    if (!window.fetch || !window.ReadableStream || !window.AbortController) {
      console.warn("[STREAM] Streaming fetch unavailable, falling back to <img> source");
      this.image.src = this.url;
      return;
    }

    this.connect();
  }

  stop() {
    this.running = false;
    clearTimeout(this.reconnectTimer);
    this.reconnectTimer = null;

    if (this.controller) {
      this.controller.abort();
      this.controller = null;
    }

    if (this.objectUrl) {
      URL.revokeObjectURL(this.objectUrl);
      this.objectUrl = null;
    }

    this.image.src = "";
    this.lastFrameAt = 0;
  }

  restart() {
    const wasRunning = this.running;
    this.stop();
    if (wasRunning) this.start();
  }

  // True when the connection is open but frames have stopped arriving.
  isStalled() {
    return this.running && this.lastFrameAt > 0 && Date.now() - this.lastFrameAt > STALL_TIMEOUT_MS;
  }

  async connect() {
    this.controller = new AbortController();

    try {
      const response = await fetch(this.url, {
        signal: this.controller.signal,
        cache: "no-store",
      });

      if (!response.ok) throw new Error(`stream responded ${response.status}`);
      if (!response.body) throw new Error("stream returned no body");

      const boundary = parseBoundary(response.headers.get("content-type"));
      if (!boundary) throw new Error("stream is missing a multipart boundary");

      this.attempts = 0;
      this.lastFrameAt = Date.now();
      console.log("[STREAM] Connected");

      await this.readFrames(response.body.getReader(), boundary);
      throw new Error("stream closed by server");
    } catch (error) {
      // stop() aborts the fetch on purpose; that is not a failure to report.
      if (!this.running) return;
      console.warn(`[STREAM] ${error.message}`);
      this.scheduleReconnect();
    }
  }

  async readFrames(reader, boundary) {
    const delimiter = encoder.encode(`--${boundary}`);
    let buffer = new Uint8Array(0);

    for (;;) {
      const { done, value } = await reader.read();
      if (done) return;

      buffer = concat(buffer, value);

      for (;;) {
        const start = indexOf(buffer, delimiter, 0);
        if (start === -1) break;

        const headerEnd = indexOf(buffer, HEADER_END, start);
        if (headerEnd === -1) break;

        const headers = decoder.decode(buffer.subarray(start, headerEnd));
        const bodyStart = headerEnd + HEADER_END.length;
        const declaredLength = parseContentLength(headers);

        let bodyEnd;
        if (declaredLength > 0) {
          bodyEnd = bodyStart + declaredLength;
          if (buffer.length < bodyEnd) break; // rest of the frame is still in flight
        } else {
          // No Content-Length, so the frame runs up to the next boundary.
          const next = indexOf(buffer, delimiter, bodyStart);
          if (next === -1) break;
          bodyEnd = next;
        }

        this.showFrame(buffer.slice(bodyStart, bodyEnd));
        buffer = buffer.slice(bodyEnd);
      }

      if (buffer.length > MAX_BUFFER_BYTES) {
        console.warn("[STREAM] Discarding oversized buffer with no frame boundary");
        buffer = new Uint8Array(0);
      }
    }
  }

  showFrame(bytes) {
    const next = URL.createObjectURL(new Blob([bytes], { type: "image/jpeg" }));
    const previous = this.objectUrl;

    this.image.src = next;
    this.objectUrl = next;
    this.lastFrameAt = Date.now();

    if (previous) URL.revokeObjectURL(previous);
  }

  scheduleReconnect() {
    this.attempts += 1;

    if (this.attempts === ATTEMPTS_BEFORE_OFFLINE) {
      this.image.src = OFFLINE_IMAGE;
    }

    const delay = Math.min(RECONNECT_BASE_MS * 2 ** (this.attempts - 1), RECONNECT_MAX_MS);
    console.log(`[STREAM] Reconnecting in ${delay}ms (attempt ${this.attempts})`);

    clearTimeout(this.reconnectTimer);
    this.reconnectTimer = setTimeout(() => {
      if (this.running) this.connect();
    }, delay);
  }
}

window.MjpegStream = MjpegStream;
