<?php
    // Start the session
    session_start();

    // Include db.php
    include 'db.php';

    $loginFailed = false;

    // Get the PDO object
    $pdo = getDb();

    // Check if form is submitted
    if ($_SERVER["REQUEST_METHOD"] == "POST") {
        $username = $_POST['username'];
        $password = $_POST['password'];

        // Call the LoginUser function
        $stmt = $pdo->prepare("SELECT LoginUser(?, ?) AS user_exists");
        $stmt->execute([$username, $password]);
        $result = $stmt->fetch();

        // If user exists, redirect to my_tickets.html
        if ($result['user_exists']) {
            // Set a session variable
            $_SESSION['loggedin'] = true;
            $_SESSION['username'] = $username;

            header("Location: my_tickets.php");
            exit();
        } else {
            $loginFailed = true;
        }
    }
?>

<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" type="text/css" href="styles.css">
</head>
<body>
    <div class="login-container">
        <form action="index.php" method="post">
            <input type="text" name="username" placeholder="Username" required>
            <input type="password" name="password" placeholder="Password" required>
            <input type="submit" value="Login">
            <?php if ($loginFailed): ?>
                <p class="login-failed">Login failed. Please try again.</p>
            <?php endif; ?>
        </form>
    </div>
</body>
</html>