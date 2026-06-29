<?php

$botToken = '8689764472:AAFB9u56aOGNnc9B5iIKghg9w7oIQ968vP8';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

function tg_request($url, $isPost = false) {
    $headers = [];
    foreach (getallheaders() as $k => $v) {
        // 不转发 host 头
        if (strtolower($k) !== 'host') {
            $headers[] = "$k: $v";
        }
    }

    $opts = [
        'http' => [
            'method'          => $isPost ? 'POST' : 'GET',
            'header'          => implode("\r\n", $headers),
            'content'         => $isPost ? file_get_contents('php://input') : null,
            'ignore_errors'   => true,
        ],
        'ssl' => [
            'verify_peer'      => false,
            'verify_peer_name' => false,
        ],
    ];
    $ctx = stream_context_create($opts);
    return file_get_contents($url, false, $ctx);
}

// ?c=true → 获取文件名
if (isset($_GET['c']) && $_GET['c'] === 'true') {
    $fileId = $_GET['file_id'] ?? '';
    if ($fileId === '') {
        http_response_code(400);
        echo 'missing file_id';
        exit;
    }

    $resp = tg_request("https://api.telegram.org/bot{$botToken}/getFile?file_id=" . urlencode($fileId), false);
    $data = json_decode($resp, true);
    if (!($data['ok'] ?? false)) {
        http_response_code(502);
        echo 'getFile failed';
        exit;
    }

    header('Content-Type: text/plain; charset=utf-8');
    echo basename($data['result']['file_path']);
    exit;
}

// 正常代理转发
$method = $_GET['action'] ?? 'sendDocument';
$target = "https://api.telegram.org/bot{$botToken}/" . $method;

$isPost = in_array($_SERVER['REQUEST_METHOD'], ['POST', 'PUT', 'PATCH']);
$response = tg_request($target, $isPost);

// 取状态码
$statusLine = $http_response_header[0] ?? '';
preg_match('#HTTP/\d\.\d (\d+)#', $statusLine, $m);
http_response_code((int)($m[1] ?? 200));

// sendDocument → 自动返回文件名
if ($method === 'sendDocument') {
    $json = json_decode($response, true);
    $fileId = $json['result']['document']['file_id'] ?? '';
    if ($fileId !== '') {
        $fileResp = tg_request("https://api.telegram.org/bot{$botToken}/getFile?file_id=" . urlencode($fileId), false);
        $fileData = json_decode($fileResp, true);
        if (($fileData['ok'] ?? false) && isset($fileData['result']['file_path'])) {
            header('Content-Type: text/plain; charset=utf-8');
            echo basename($fileData['result']['file_path']);
            exit;
        }
    }
}

// 原样返回 Telegram 响应
foreach ($http_response_header as $h) {
    if (stripos($h, 'Content-Type:') === 0) {
        header($h);
    }
}
echo $response;
