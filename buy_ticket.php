<?php

// Start the session
session_start();

// Check if the user is logged in
if (!isset($_SESSION['loggedin']) || $_SESSION['loggedin'] !== true) {
    // If not, redirect them to the login page
    header("Location: index.php");
    exit();
}

// Include db.php
include 'db.php';
// Get the PDO object
$pdo = getDb();
// get username from session
$username = $_SESSION['username'];

// Get user_id from users table
$stmt = $pdo->prepare("SELECT user_id FROM users WHERE username = :username");
$stmt->execute(['username' => $username]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

// Check if form has been submitted
if (!empty($_POST)) {
  // Get ticketType_id from session
  $ticketType_id = $_SESSION['ticketType_id'];

  // Call BuyTicket procedure
  $stmt = $pdo->prepare("CALL BuyTicket(:ticketType_id, :user_id)");
  $stmt->execute(['ticketType_id' => $ticketType_id, 'user_id' => $user['user_id']]);
}

?>