<?php
// 获取 POST 参数
$north = $_POST['north'];
$east = $_POST['east'];
$south = $_POST['south'];
$west = $_POST['west'];

// 连接数据库

// 设置数据库连接参数
$host = 'localhost';
$username = "root1";
$password = "123456";
$dbname = "user";


$conn = new mysqli($host, $username, $password, $dbname);

// 查询数据库获取地震数据
$sql = "SELECT latitude, longitude, time, depth,location, magnitude FROM earthquake WHERE latitude BETWEEN $south AND $north AND longitude BETWEEN $west AND $east";
$result = $conn->query($sql);

// 将查询结果转换为 JSON 格式返回给前端
$data = array();
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}
echo json_encode($data);

// 关闭数据库连接
$conn->close();
?>
