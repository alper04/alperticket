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

// Check if form has been submitted
if (!empty($_POST)) {
    $city = $_POST['city'];
    $ticket_type = $_POST['ticket_type'];

    $stmt = $pdo->prepare("SELECT ticketType_id, price FROM ticket_types WHERE city = :city AND ticket_type = :ticket_type");
    $stmt->execute(['city' => $city, 'ticket_type' => $ticket_type]);
    $result = $stmt->fetch(PDO::FETCH_ASSOC);

    // Store ticketType_id in session
    $_SESSION['ticketType_id'] = $result['ticketType_id'];

    echo json_encode($result);
}

?>