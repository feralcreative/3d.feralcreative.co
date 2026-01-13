<?php
/**
 * Activity Logger API
 * 
 * Receives and stores user activity logs from the web application.
 * Logs are stored in JSON format with one file per day.
 * 
 * Deploy this to your Synology NAS at: /web/3d.feralcreative.co/api/log.php
 */

// Enable CORS for your domain
header('Access-Control-Allow-Origin: https://3d.feralcreative.co');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit;
}

// Configuration
// Use /app/logs in Docker container, fallback to NAS path if not in container
define('LOG_DIR', file_exists('/app/logs') ? '/app/logs' : '/volume1/web/3d.feralcreative.co/logs');
define('MAX_LOG_SIZE', 10 * 1024 * 1024); // 10MB per file

// Ensure log directory exists
if (!file_exists(LOG_DIR)) {
    mkdir(LOG_DIR, 0755, true);
}

// Get request body
$rawInput = file_get_contents('php://input');
$logData = json_decode($rawInput, true);

if (!$logData) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid JSON']);
    exit;
}

// Add server-side metadata
$logData['server'] = [
    'timestamp' => date('c'),
    'ip' => $_SERVER['REMOTE_ADDR'] ?? 'unknown',
    'userAgent' => $_SERVER['HTTP_USER_AGENT'] ?? 'unknown',
    'referer' => $_SERVER['HTTP_REFERER'] ?? 'none',
    'requestMethod' => $_SERVER['REQUEST_METHOD'],
];

// Determine log file name (one file per day)
$date = date('Y-m-d');
$logFile = LOG_DIR . "/activity-{$date}.jsonl";

// Append log entry (JSON Lines format - one JSON object per line)
$logEntry = json_encode($logData) . "\n";

// Check if file is getting too large
if (file_exists($logFile) && filesize($logFile) > MAX_LOG_SIZE) {
    // Rotate log file
    $rotatedFile = LOG_DIR . "/activity-{$date}-" . time() . ".jsonl";
    rename($logFile, $rotatedFile);
}

// Write log entry
if (file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX) === false) {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to write log']);
    exit;
}

// Return success
http_response_code(200);
echo json_encode([
    'success' => true,
    'timestamp' => date('c'),
    'event' => $logData['event'] ?? 'unknown',
]);
