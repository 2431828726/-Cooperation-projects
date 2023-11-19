<?php
// 设置数据库连接参数
$host = 'localhost';
$username = 'root1';
$password = '123456';
$dbname = 'user';

// 创建数据库连接
$conn = new mysqli($host, $username, $password, $dbname);

// 检查连接是否成功
if ($conn->connect_error) {
    die('数据库连接失败: ' . $conn->connect_error);
}

// 查询文物表的数据
$sql = 'SELECT 经度, 纬度, 名字, `add` FROM 文物';
$result = $conn->query($sql);

// 将查询结果转换为 JSON 格式
$data = [];
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }
}

// 返回 JSON 数据
header('Content-Type: application/json');
echo json_encode($data);

// 关闭数据库连接
$conn->close();
?>
