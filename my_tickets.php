

<?php



// Start the session
session_start();

// Check if the user is logged in
if (!isset($_SESSION['loggedin']) || $_SESSION['loggedin'] !== true) {
    // If not, redirect them to the login page
    header("Location: index.php");
    exit();
}

-include 'db.php';
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


-require_once 'phpqrcode\qrlib.php';

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
                    <p class="not-valid ticket-status">Not yet valid</p>
                    <p id="countdown-<?php echo $ticket['ticket_id']; ?>"></p>
                    <button class="validate-ticket" data-ticket-id="<?php echo $ticket['ticket_id']; ?>">Validate Ticket</button>
                </div>
            <?php endforeach; ?>
        </div>
        <div class="button-container">
                <button class="my-tickets">My Tickets</button>
                <button class="buy-ticket">Buy Tickets</button>
        </div>
    </div>
   

    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script>
$(document).ready(function() {

    $('.validate-ticket').each(function() {
    var ticketID = $(this).data('ticket-id');
    var ticketStatus = $(this).siblings('.ticket-status');
    var button = $(this); // Store a reference to the button
    $.post('get_ticket_status.php', { ticketID: ticketID }, function(response) {
        if (response.status === 'valid') {
            // Use the stored reference to the button
            button.prop('disabled', true);
            button.css('background-color', 'gray');
            startCountdown(response.expiry_date, ticketID, ticketStatus);
        } else if (response.status === 'expired') {
            ticketStatus.text('Ticket expired');
        } else if (response.status === 'not_valid'){
            ticketStatus.text('Not Yet Valid');
        }
    }, 'json');
});

$('.validate-ticket').click(function() {
    var ticketID = $(this).data('ticket-id');
    var ticketStatus = $(this).siblings('.ticket-status');
    var button = $(this); // Store a reference to the button
    $.post('validate_ticket.php', { ticketID: ticketID }, function(response) {
        if (response.success) {
            startCountdown(response.expiry_date, ticketID, ticketStatus);
        }
    }, 'json');
    
    // Use the stored reference to the button
    button.prop('disabled', true);
    button.css('background-color', 'gray');
});
    
});


function startCountdown(resp, ticketID, ticketStatus) {
    // Update the ticket status in the UI
    ticketStatus.text('Valid');
    ticketStatus.css('background-color', 'green');
    // Start the countdown timer
    var expiryDateParts = resp.split(/[- :]/);
                // Ensure the year is four digits
                var year = expiryDateParts[2].length === 2 ? '20' + expiryDateParts[2] : expiryDateParts[2];
                var month = expiryDateParts[1] - 1; // adjust month part to be in the range 0-11
                var day = expiryDateParts[0];
                var expiryDate = new Date(Date.UTC(year, month, day, expiryDateParts[3], expiryDateParts[4], expiryDateParts[5]));
                 // Log the expiry_date received from the server
                console.log("expiry_date from server: ", resp);

                // Get the time difference between UTC and the local timezone in milliseconds
                var timezoneOffset = expiryDate.getTimezoneOffset() * 60 * 1000;

                // Add the timezone offset to the expiry date
                expiryDate = new Date(expiryDate.getTime() + timezoneOffset);

                // Log the expiryDate after parsing and adjusting for timezone
                console.log("expiryDate after parsing and adjusting for timezone: ", expiryDate);

                var countdown = setInterval(function() {
                    var now = new Date().getTime();
                    var distance = expiryDate - now;

                    // Log the distance calculated in the countdown function
                    console.log("distance: ", distance);

                    var days = Math.floor(distance / (1000 * 60 * 60 * 24));
                    var hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                    var minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                    var seconds = Math.floor((distance % (1000 * 60)) / 1000);

                    document.getElementById("countdown-" + ticketID).innerHTML = days + "d " + hours + "h "
                    + minutes + "m " + seconds + "s ";

                    if (distance < 0) {
                        clearInterval(countdown);
                        document.getElementById("countdown-" + ticketID).innerHTML = "";
                        ticketStatus.text('EXPIRED');
                        ticketStatus.css('background-color', 'brown');
                    }
                }, 1000);


            }


    document.querySelector('.my-tickets').addEventListener('click', function() {
        window.location.href = 'my_tickets.php';
    });

    document.querySelector('.buy-ticket').addEventListener('click', function() {
        window.location.href = 'buy_tickets.php';
    });


</script>


</body>
</html>