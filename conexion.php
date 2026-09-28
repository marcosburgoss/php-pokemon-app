<?php
    $dbHost = getenv('DB_HOST') ?: '127.0.0.1';
    $dbPort = (int) (getenv('DB_PORT') ?: 3306);
    $dbUser = getenv('DB_USER') ?: 'root';
    $dbPassword = getenv('DB_PASSWORD') ?: '9512';
    $dbName = getenv('DB_NAME') ?: 'pokemonPlus';

    $conexion = mysqli_connect($dbHost, $dbUser, $dbPassword, $dbName, $dbPort)
        or die("Error en la conexion con la BD");
?>