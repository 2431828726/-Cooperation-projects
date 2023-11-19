<?php
$host = 'localhost';
$username = 'root1';
$password = '123456';
$dbname = 'user';

// 创建数据库连接
$conn = new mysqli($host, $username, $password, $dbname);
if ($conn->connect_error) {
    die("连接失败：" . $conn->connect_error);
}

// 从名为上报的表中获取急需物品字段的数据
$query = "SELECT `急需物品` FROM 上报";
$result = $conn->query($query);

if ($result->num_rows > 0) {
    $data = array(); // 存储获取到的数据
    while ($row = $result->fetch_assoc()) {
        $data[] = $row['急需物品'];
    }
    
    // 将数据转换为 JSON 格式并输出给前端
    echo json_encode($data);
} else {
    echo "没有找到急需物品的数据";
}

// 关闭数据库连接
$conn->close();
?>
