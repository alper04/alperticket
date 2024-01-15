<?php
include 'db.php';
$pdo = getDb();
$ticketID = $_POST['ticketID'];

$stmt = $pdo->prepare("CALL ValidateTicket(:ticketID)");
$stmt->bindParam(':ticketID', $ticketID, PDO::PARAM_STR);
$stmt->execute();

$stmt2 = $pdo->prepare("SELECT expiry_date FROM tickets WHERE ticket_id = :ticketID");
$stmt2->bindParam(':ticketID', $ticketID, PDO::PARAM_STR);
$stmt2->execute();
$expiryDate = $stmt2->fetch(PDO::FETCH_ASSOC);

$date = new DateTime($expiryDate['expiry_date']);
$formattedDate = $date->format('d-m-Y H:i:s');

echo json_encode(['success' => true, 'expiry_date' => $formattedDate]);
?>