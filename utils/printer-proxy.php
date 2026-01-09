<?php
/**
 * FlashForge Printer API Proxy
 * 
 * This script proxies requests from the web app to the local printer,
 * solving CORS and network isolation issues.
 * 
 * Deploy this to your Synology NAS at: /web/3d.feralcreative.co/api/printer.php
 */

// Enable CORS for your domain
$allowedOrigins = ['https://3d.feralcreative.co', 'http://localhost:5501', 'http://localhost:3000'];
$origin = $_SERVER['HTTP_ORIGIN'] ?? '';
if (in_array($origin, $allowedOrigins)) {
    header("Access-Control-Allow-Origin: $origin");
}
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, SN, CHKCODE');
header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Printer configuration
define('PRINTER_IP', '192.168.1.55');
define('PRINTER_SERIAL', 'SNMOME9201982');
define('PRINTER_CHECK_CODE', '7a385286');

// Get the endpoint from query parameter or POST body
$endpoint = $_GET['endpoint'] ?? null;
$postData = json_decode(file_get_contents('php://input'), true);
if (!$endpoint && isset($postData['endpoint'])) {
    $endpoint = $postData['endpoint'];
}
if (!$endpoint) {
    $endpoint = 'product';
}

// Validate endpoint
$allowedEndpoints = ['product', 'detail', 'job'];
if (!in_array($endpoint, $allowedEndpoints)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid endpoint']);
    exit;
}

// Build printer URL - FlashForge uses port 8898
$printerUrl = "http://" . PRINTER_IP . ":8898/" . $endpoint;

// Initialize cURL
$ch = curl_init($printerUrl);

// Prepare request body for POST endpoints
$requestBody = null;
if (in_array($endpoint, ['product', 'detail'])) {
    $requestBody = json_encode([
        'serialNumber' => PRINTER_SERIAL,
        'checkCode' => PRINTER_CHECK_CODE,
    ]);
}

// Set cURL options
$curlOptions = [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_TIMEOUT => 10,
];

// Add POST data if needed
if ($requestBody) {
    $curlOptions[CURLOPT_POST] = true;
    $curlOptions[CURLOPT_POSTFIELDS] = $requestBody;
    $curlOptions[CURLOPT_HTTPHEADER] = [
        'Content-Type: application/json',
    ];
} else {
    // For GET requests (job endpoint)
    $curlOptions[CURLOPT_HTTPHEADER] = [
        'SN: ' . PRINTER_SERIAL,
        'CHKCODE: ' . PRINTER_CHECK_CODE,
    ];
}

curl_setopt_array($ch, $curlOptions);

// Execute request
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);

curl_close($ch);

// Handle errors
if ($error) {
    http_response_code(500);
    echo json_encode([
        'error' => 'Failed to connect to printer',
        'details' => $error
    ]);
    exit;
}

// Return response
http_response_code($httpCode);
echo $response;
