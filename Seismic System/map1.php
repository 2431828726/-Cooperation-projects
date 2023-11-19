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
    die("连接失败: " . $conn->connect_error);
}

// 查询数据库数据
$sql = "SELECT 经度, 纬度 FROM 申报1";
$result = $conn->query($sql);

// 构建数据数组
$data = array();
if ($result->num_rows > 0) {
    $index = 1;
    while ($row = $result->fetch_assoc()) {
        $longitude = floatval($row["经度"]); // 转换为数值类型
        $latitude = floatval($row["纬度"]); // 转换为数值类型

        $data[] = array(
            'name' => '紧急求救人员' . $index,
            'value' => array($longitude, $latitude)
        );
        $index++;
    }
}

// 关闭数据库连接
$conn->close();

// 返回JSON格式的数据
header('Content-Type: application/json');
echo json_encode($data);
?>
