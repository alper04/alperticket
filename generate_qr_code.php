<?php
require_once 'phpqrcode/qrlib.php';

$qr_dir = 'qrcodes/';
$ticket_id = $_POST['ticket_id'];

// Generate a QR code for the ticket_id and save it to a file
$filename = $qr_dir . $ticket_id . '.png';
QRcode::png($ticket_id, $filename);

echo $filename;
?>