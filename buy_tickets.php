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


?>



<!DOCTYPE html>
<html>
<head>
    <title>Buy Tickets</title>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="parent-container">
        <div class="buy_container">
            <div class="buy_content">
                <select id="city" onchange="showticket_type()">
                    <option value="">Select city</option>
                    <option value="Pécs">Pécs</option>
                    <option value="Budapest">Budapest</option>
                </select>
                <select id="ticket_type" style="display: none;" onchange="showPurchaseButton()">
                    <option value="">Select ticket type</option>
                    <option value="Single-Ticket">Single-Ticket</option>
                    <option value="Student-Ticket">Student-Ticket</option>
                </select>
                <p id="price"></p>
                <button id="purchaseButton" style="display: none;">Purchase Ticket</button>
            </div>
        </div>  
        <div class="button-container">
            <button class="my-tickets">My Tickets</button>
            <button class="buy-ticket">Buy Tickets</button>
        </div>
    </div>

    <script>

    document.getElementById('ticket_type').addEventListener('change', function() {
        var city = document.getElementById('city').value;
        var ticket_type = this.value;

        var xhr = new XMLHttpRequest();
        xhr.open('POST', 'get_ticket_info.php', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onload = function() {
            if (this.status == 200) {
                var result = JSON.parse(this.responseText);
                document.getElementById('price').innerText = result.price + ' HUF';
            }
        };
        xhr.send('city=' + city + '&ticket_type=' + ticket_type);
    });
    
    function showticket_type() {
        var city = document.getElementById("city").value;
        if (city != "") {
            document.getElementById("ticket_type").style.display = "block";
        } else {
            document.getElementById("ticket_type").style.display = "none";
            document.getElementById("purchaseButton").style.display = "none";
        }
    }

    function showPurchaseButton() {
        var ticket_type = document.getElementById("ticket_type").value;
        if (ticket_type != "") {
            document.getElementById("purchaseButton").style.display = "block";
        } else {
            document.getElementById("purchaseButton").style.display = "none";
        }
    }

    document.querySelector('.my-tickets').addEventListener('click', function() {
    window.location.href = 'my_tickets.php';
    });

    document.querySelector('.buy-ticket').addEventListener('click', function() {
        window.location.href = 'buy_tickets.php';
    });

    document.getElementById('purchaseButton').addEventListener('click', function() {
    var city = document.getElementById('city').value;
    var ticket_type = document.getElementById('ticket_type').value;

    var xhr = new XMLHttpRequest();
    xhr.open('POST', 'buy_ticket.php', true);
    xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
    xhr.onload = function() {
        if (this.status == 200) {
            alert('Ticket purchased successfully');
        }
    };
    xhr.send('city=' + city + '&ticket_type=' + ticket_type);
    });

    </script>

</body>
</html>