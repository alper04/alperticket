<?php
include 'db.php';
$pdo = getDb();
$ticketID = $_POST['ticketID'];

$stmt = $pdo->prepare("SELECT valid_date, expiry_date FROM tickets WHERE ticket_id = :ticketID");
$stmt->bindParam(':ticketID', $ticketID, PDO::PARAM_STR);
$stmt->execute();
$ticket = $stmt->fetch(PDO::FETCH_ASSOC);

if ($ticket['valid_date'] === null && $ticket['expiry_date'] === null) {
    echo json_encode(['status' => 'not_valid']);
} elseif ($ticket['valid_date'] !== null && $ticket['expiry_date'] !== null) {
    $expiryDate = new DateTime($ticket['expiry_date']);
    $formattedExpiryDate = $expiryDate->format('d-m-Y H:i:s');
    echo json_encode(['status' => 'valid', 'expiry_date' => $formattedExpiryDate]);
} elseif ($ticket['valid_date'] === null) {
    echo json_encode(['status' => 'expired']);
}
?>