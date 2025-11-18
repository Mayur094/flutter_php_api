<?php

$host = "127.0.0.1";
$port = 3380;
$db = "flutter_api";
$user = "root";
$pass = "";

try{
    $pdo = new PDO(
        "mysql:host=$host;port=$port;dbname=$db;charset=utf8mb4",
        $user,
        $pass,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
} catch (Execption $e){
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Database connection failed",
        "error" => $e -> getMessage()
    ]);
    exit;
}

?>