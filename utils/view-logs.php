<?php
/**
 * Activity Log Viewer
 * 
 * View and analyze user activity logs.
 * Deploy this to your Synology NAS at: /web/3d.feralcreative.co/api/view-logs.php
 * 
 * Access via: https://3d.feralcreative.co/api/view-logs.php
 */

// Configuration
define('LOG_DIR', '/volume1/web/3d.feralcreative.co/logs');

// Simple authentication (change this password!)
define('ADMIN_PASSWORD', 'your_secure_password_here');

// Check authentication
session_start();
if (!isset($_SESSION['authenticated'])) {
    if (isset($_POST['password']) && $_POST['password'] === ADMIN_PASSWORD) {
        $_SESSION['authenticated'] = true;
    } else {
        showLoginForm();
        exit;
    }
}

// Handle logout
if (isset($_GET['logout'])) {
    session_destroy();
    header('Location: view-logs.php');
    exit;
}

// Get action
$action = $_GET['action'] ?? 'list';

switch ($action) {
    case 'list':
        showLogList();
        break;
    case 'view':
        viewLog($_GET['file'] ?? '');
        break;
    case 'stats':
        showStats($_GET['file'] ?? '');
        break;
    case 'download':
        downloadLog($_GET['file'] ?? '');
        break;
    default:
        showLogList();
}

function showLoginForm() {
    ?>
    <!DOCTYPE html>
    <html>
    <head>
        <title>Activity Logs - Login</title>
        <style>
            body { font-family: Arial, sans-serif; background: #f5f5f5; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
            .login-box { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
            input[type="password"] { padding: 0.5rem; width: 200px; margin: 0.5rem 0; }
            button { padding: 0.5rem 1rem; background: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; }
            button:hover { background: #0056b3; }
        </style>
    </head>
    <body>
        <div class="login-box">
            <h2>Activity Logs</h2>
            <form method="POST">
                <input type="password" name="password" placeholder="Password" required>
                <button type="submit">Login</button>
            </form>
        </div>
    </body>
    </html>
    <?php
}

function showLogList() {
    $files = glob(LOG_DIR . '/activity-*.jsonl');
    rsort($files); // Most recent first
    
    ?>
    <!DOCTYPE html>
    <html>
    <head>
        <title>Activity Logs</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 2rem; background: #f5f5f5; }
            .container { max-width: 1200px; margin: 0 auto; background: white; padding: 2rem; border-radius: 8px; }
            h1 { color: #333; }
            table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
            th, td { padding: 0.75rem; text-align: left; border-bottom: 1px solid #ddd; }
            th { background: #f8f9fa; font-weight: 600; }
            a { color: #007bff; text-decoration: none; margin-right: 1rem; }
            a:hover { text-decoration: underline; }
            .logout { float: right; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Activity Logs <a href="?logout=1" class="logout">Logout</a></h1>
            <table>
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>File Size</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($files as $file): 
                        $filename = basename($file);
                        $size = filesize($file);
                        $sizeFormatted = formatBytes($size);
                        $date = str_replace(['activity-', '.jsonl'], '', $filename);
                    ?>
                    <tr>
                        <td><?= htmlspecialchars($date) ?></td>
                        <td><?= $sizeFormatted ?></td>
                        <td>
                            <a href="?action=view&file=<?= urlencode($filename) ?>">View</a>
                            <a href="?action=stats&file=<?= urlencode($filename) ?>">Stats</a>
                            <a href="?action=download&file=<?= urlencode($filename) ?>">Download</a>
                        </td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </body>
    </html>
    <?php
}

function viewLog($filename) {
    $filepath = LOG_DIR . '/' . basename($filename);
    if (!file_exists($filepath)) {
        echo "Log file not found.";
        return;
    }

    $lines = file($filepath, FILE_IGNORE_NEW_LINES);
    $logs = array_map('json_decode', $lines);

    ?>
    <!DOCTYPE html>
    <html>
    <head>
        <title>View Log - <?= htmlspecialchars($filename) ?></title>
        <style>
            body { font-family: Arial, sans-serif; margin: 2rem; background: #f5f5f5; }
            .container { max-width: 1400px; margin: 0 auto; background: white; padding: 2rem; border-radius: 8px; }
            .log-entry { background: #f8f9fa; padding: 1rem; margin: 0.5rem 0; border-radius: 4px; border-left: 4px solid #007bff; }
            .log-entry.login { border-left-color: #28a745; }
            .log-entry.logout { border-left-color: #dc3545; }
            .log-entry.heartbeat { border-left-color: #6c757d; }
            .event-type { font-weight: 600; color: #007bff; }
            .timestamp { color: #6c757d; font-size: 0.9em; }
            .user-info { color: #495057; }
            pre { background: #fff; padding: 0.5rem; border-radius: 4px; overflow-x: auto; }
            a { color: #007bff; text-decoration: none; }
            a:hover { text-decoration: underline; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Log: <?= htmlspecialchars($filename) ?></h1>
            <p><a href="?action=list">← Back to list</a></p>
            <p>Total entries: <?= count($logs) ?></p>

            <?php foreach (array_reverse($logs) as $log): ?>
                <div class="log-entry <?= $log->event ?? '' ?>">
                    <div class="event-type"><?= strtoupper($log->event ?? 'UNKNOWN') ?></div>
                    <div class="timestamp"><?= $log->timestamp ?? 'N/A' ?></div>
                    <?php if (isset($log->user)): ?>
                        <div class="user-info">User: <?= htmlspecialchars($log->user->email ?? 'unknown') ?> (<?= htmlspecialchars($log->user->name ?? 'N/A') ?>)</div>
                    <?php endif; ?>
                    <?php if (isset($log->sessionDuration)): ?>
                        <div>Session Duration: <?= $log->sessionDurationFormatted ?? $log->sessionDuration . 's' ?></div>
                    <?php endif; ?>
                    <?php if (isset($log->server->ip)): ?>
                        <div>IP: <?= htmlspecialchars($log->server->ip) ?></div>
                    <?php endif; ?>
                    <details>
                        <summary>Full Data</summary>
                        <pre><?= json_encode($log, JSON_PRETTY_PRINT) ?></pre>
                    </details>
                </div>
            <?php endforeach; ?>
        </div>
    </body>
    </html>
    <?php
}

function showStats($filename) {
    $filepath = LOG_DIR . '/' . basename($filename);
    if (!file_exists($filepath)) {
        echo "Log file not found.";
        return;
    }

    $lines = file($filepath, FILE_IGNORE_NEW_LINES);
    $logs = array_map('json_decode', $lines);

    // Calculate statistics
    $stats = [
        'total_events' => count($logs),
        'unique_users' => [],
        'events_by_type' => [],
        'total_session_time' => 0,
        'sessions' => [],
    ];

    foreach ($logs as $log) {
        // Count events by type
        $event = $log->event ?? 'unknown';
        $stats['events_by_type'][$event] = ($stats['events_by_type'][$event] ?? 0) + 1;

        // Track unique users
        if (isset($log->user->email)) {
            $stats['unique_users'][$log->user->email] = true;
        }

        // Track sessions
        if (isset($log->sessionId)) {
            if (!isset($stats['sessions'][$log->sessionId])) {
                $stats['sessions'][$log->sessionId] = [
                    'user' => $log->user->email ?? 'unknown',
                    'start' => $log->timestamp ?? null,
                    'events' => 0,
                    'duration' => 0,
                ];
            }
            $stats['sessions'][$log->sessionId]['events']++;
            if (isset($log->sessionDuration)) {
                $stats['sessions'][$log->sessionId]['duration'] = max(
                    $stats['sessions'][$log->sessionId]['duration'],
                    $log->sessionDuration
                );
            }
        }
    }

    $stats['unique_users'] = count($stats['unique_users']);

    ?>
    <!DOCTYPE html>
    <html>
    <head>
        <title>Stats - <?= htmlspecialchars($filename) ?></title>
        <style>
            body { font-family: Arial, sans-serif; margin: 2rem; background: #f5f5f5; }
            .container { max-width: 1200px; margin: 0 auto; background: white; padding: 2rem; border-radius: 8px; }
            .stat-box { background: #f8f9fa; padding: 1rem; margin: 0.5rem 0; border-radius: 4px; }
            .stat-label { font-weight: 600; color: #495057; }
            .stat-value { font-size: 1.5em; color: #007bff; }
            table { width: 100%; border-collapse: collapse; margin-top: 1rem; }
            th, td { padding: 0.75rem; text-align: left; border-bottom: 1px solid #ddd; }
            th { background: #f8f9fa; font-weight: 600; }
            a { color: #007bff; text-decoration: none; }
            a:hover { text-decoration: underline; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Statistics: <?= htmlspecialchars($filename) ?></h1>
            <p><a href="?action=list">← Back to list</a></p>

            <div class="stat-box">
                <div class="stat-label">Total Events</div>
                <div class="stat-value"><?= $stats['total_events'] ?></div>
            </div>

            <div class="stat-box">
                <div class="stat-label">Unique Users</div>
                <div class="stat-value"><?= $stats['unique_users'] ?></div>
            </div>
            <h2>Events by Type</h2>
            <table>
                <thead>
                    <tr>
                        <th>Event Type</th>
                        <th>Count</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($stats['events_by_type'] as $type => $count): ?>
                    <tr>
                        <td><?= htmlspecialchars($type) ?></td>
                        <td><?= $count ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>

            <h2>Sessions</h2>
            <table>
                <thead>
                    <tr>
                        <th>User</th>
                        <th>Start Time</th>
                        <th>Duration</th>
                        <th>Events</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($stats['sessions'] as $sessionId => $session): ?>
                    <tr>
                        <td><?= htmlspecialchars($session['user']) ?></td>
                        <td><?= htmlspecialchars($session['start'] ?? 'N/A') ?></td>
                        <td><?= formatDuration($session['duration']) ?></td>
                        <td><?= $session['events'] ?></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </body>
    </html>
    <?php
}

function downloadLog($filename) {
    $filepath = LOG_DIR . '/' . basename($filename);
    if (!file_exists($filepath)) {
        echo "Log file not found.";
        return;
    }

    header('Content-Type: application/json');
    header('Content-Disposition: attachment; filename="' . $filename . '"');
    readfile($filepath);
}

function formatBytes($bytes) {
    $units = ['B', 'KB', 'MB', 'GB'];
    $i = 0;
    while ($bytes >= 1024 && $i < count($units) - 1) {
        $bytes /= 1024;
        $i++;
    }
    return round($bytes, 2) . ' ' . $units[$i];
}

function formatDuration($seconds) {
    $hours = floor($seconds / 3600);
    $minutes = floor(($seconds % 3600) / 60);
    $secs = floor($seconds % 60);

    $parts = [];
    if ($hours > 0) $parts[] = "{$hours}h";
    if ($minutes > 0) $parts[] = "{$minutes}m";
    if ($secs > 0 || empty($parts)) $parts[] = "{$secs}s";

    return implode(' ', $parts);
}
