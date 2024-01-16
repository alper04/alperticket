<?php

if (basename(__FILE__) == basename($_SERVER['PHP_SELF'])) {
    // The file is not included or required, so stop the script
    die('Access denied kys xD');
}

function getDb() {
    $host = 'localhost';
    $db   = 'alperjegy';
    $user = 'test';
    $pass = 'test';
    $charset = 'utf8mb4';

    $dsn = "mysql:host=$host;dbname=$db;charset=$charset";
    $opt = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ];
    return new PDO($dsn, $user, $pass, $opt);
}

?>