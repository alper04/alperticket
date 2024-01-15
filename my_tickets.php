

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



// Prepare the SQL statement
$stmt = $pdo->prepare("CALL GetUserTickets(:username)");

// Bind the parameters
$stmt->bindParam(':username', $username, PDO::PARAM_STR);

// Execute the statement
$stmt->execute();

// Fetch all the results
$tickets = $stmt->fetchAll(PDO::FETCH_ASSOC);


// Include the QR code library
require_once 'phpqrcode\qrlib.php';

// Directory to save QR codes
$qr_dir = 'qrcodes/';

// Loop through each ticket
foreach ($tickets as $ticket) {
    // Generate a QR code for the ticket_id and save it to a file
    $filename = $qr_dir . $ticket['ticket_id'] . '.png';
    QRcode::png($ticket['ticket_id'], $filename);
}

?>




<!DOCTYPE html>
<html>
<head>
    <title>My Tickets</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="parent-container">
        <div class="ticket_container">
            <?php foreach ($tickets as $ticket): ?>
                <div class="ticket">
                    <p class="ticket-city"><?php echo htmlspecialchars($ticket['city']); ?></p>
                    <p class="ticket-type"><?php echo htmlspecialchars($ticket['ticket_type']); ?></p>
                    <!-- Display the QR code -->
                    <img class="qr-code" src="<?php echo $qr_dir . $ticket['ticket_id'] . '.png'; ?>" alt="QR Code">
                    <p class="not-valid">Not yet valid</p>
                    <button class="validate-ticket">Validate Ticket</button>
                </div>
            <?php endforeach; ?>
        </div>
        <div class="button-container">
                <button class="my-tickets">My Tickets</button>
                <button class="buy-ticket">Buy Tickets</button>
        </div>
    </div>
</body>
</html>