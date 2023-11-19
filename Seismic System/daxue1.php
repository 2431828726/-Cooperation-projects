
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

// 获取请求参数
$minLatitude = floatval($_GET['minLatitude']);
$maxLatitude = floatval($_GET['maxLatitude']);
$minLongitude = floatval($_GET['minLongitude']);
$maxLongitude = floatval($_GET['maxLongitude']);

// 查询数据库获取矩形范围内的医院数据
$sql = "SELECT `名字`, `纬度`, `经度` FROM `大学` WHERE `纬度` BETWEEN $minLatitude AND $maxLatitude AND `经度` BETWEEN $minLongitude AND $maxLongitude";
$result = $conn->query($sql);

// 构建医院数据数组
$hospitals = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $hospitals[] = array(
            "name" => $row["名字"],
            "latitude" => $row["纬度"],
            "longitude" => $row["经度"]
        );
    }
}

// 返回医院数据
echo json_encode($hospitals);

// 关闭数据库连接
$conn->close();
?>