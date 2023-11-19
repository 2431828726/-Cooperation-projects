<?php
// 设置数据库连接参数
$host = 'localhost';
$username = 'root1';
$password = '123456';
$dbname = 'user';

// 获取经纬度参数
$latitude = $_POST['latitude'];
$longitude = $_POST['longitude'];

// 创建数据库连接
$conn = new mysqli($host, $username, $password, $dbname);

// 检查连接是否成功
if ($conn->connect_error) {
    die("数据库连接失败: " . $conn->connect_error);
}

// 构建插入经纬度的SQL语句

$sql = "INSERT INTO 申报1 (经度, 纬度) VALUES ('$latitude', '$$longitude')";
// 执行SQL语句
if ($conn->query($sql) === TRUE) {
    echo "经纬度已写入数据库";
} else {
    echo "写入数据库时出现错误: " . $conn->error;
}

// 关闭数据库连接
$conn->close();
?>
