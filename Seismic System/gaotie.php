<?php
// 获取 POST 请求的关键词
$keyword = $_POST['keyword'];

// 设置数据库连接参数
$host = 'localhost';
$username = 'root1';
$password = '123456';
$dbname = 'user';

// 建立数据库连接
$conn = new mysqli($host, $username, $password, $dbname);
if ($conn->connect_error) {
  die('数据库连接失败: ' . $conn->connect_error);
}

// 执行查询
$sql = "SELECT * FROM 高铁 WHERE 名字 LIKE '%$keyword%'";
$result = $conn->query($sql);

// 将查询结果转换为关联数组
$locations = array();
while ($row = $result->fetch_assoc()) {
  $name = $row['名字'];
  $latitude = $row['纬度'];
  $longitude = $row['经度'];
  $province = $row['省份'];

  $location = array(
    '名称' => $name,
    '纬度' => $latitude,
    '经度' => $longitude,
    '省份' => $province
  );

  array_push($locations, $location);
}

// 返回查询结果给前端
echo json_encode($locations);

// 关闭数据库连接
$conn->close();
?>
