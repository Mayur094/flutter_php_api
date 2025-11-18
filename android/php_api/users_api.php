<?php

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if($_SERVER["REQUEST_METHOD"] === "OPTIONS") { exit; }

require "db.php";

//GET -> return all users
if($_SERVER["REQUEST_METHOD"] === "GET") {
    $stmt = $pdo -> query("SELECT * FROM users ORDER BY id DESC");
    $users = $stmt -> fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "status" => "success",
        "data" => $users
    ]);
     
    exit;
}

//POST -> insert user
if($_SERVER["REQUEST_METHOD"] === "POST"){
    $body = json_decode(file_get_contents("php://input"),true);

    $name = $body["name"] ?? "";
    $email = $body["email"] ?? "";

    if($name === "" || $email === ""){
        echo json_encode(["error" => "Name and Email are required"]);
        exit;
    }

    $stmt = $pdo -> prepare("INSERT INTO users (name, email) VALUES(?, ?)");
    $stmt -> execute([$name,$email]);

    echo json_encode([
        "status" => "success",
        "message" => "User saved",
        "data" => [
            "id" => $pdo -> lastInsertId(),
            "name" => $name,
            "email" => $email,
        ]
    ]);
    exit;
}

echo json_encode(["error" => "Method not allowed"]);

?>