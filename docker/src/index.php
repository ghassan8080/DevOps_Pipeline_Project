<?php
$servername = "mysql";
$username = "root";
$password = "rootpassword";
$dbname = "appdb";

try {
    $pdo = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "<h1>تم الاتصال بقاعدة البيانات بنجاح!</h1>";
    echo "<p>الوقت الحالي: " . date('Y-m-d H:i:s') . "</p>";

    // Create a test table
    $pdo->exec("CREATE TABLE IF NOT EXISTS test_table (
        id INT AUTO_INCREMENT PRIMARY KEY,
        message VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )");

    // Insert test data
    $pdo->exec("INSERT IGNORE INTO test_table (id, message) VALUES (1, 'مرحباً من PHP!')");

    // Retrieve data
    $stmt = $pdo->query("SELECT * FROM test_table");
    echo "<h2>البيانات من قاعدة البيانات:</h2>";
    while ($row = $stmt->fetch()) {
        echo "<p>ID: " . $row['id'] . " - الرسالة: " . $row['message'] . " - التاريخ: " . $row['created_at'] . "</p>";
    }
} catch(PDOException $e) {
    echo "<h1>خطأ في الاتصال: " . $e->getMessage() . "</h1>";
}
?>
