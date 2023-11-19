<?php
// 设置数据库连接参数
$host = 'localhost';
$username = 'root1';
$password = '123456';
$dbname = 'user';

// 获取前端传递的经度和纬度参数
$latitude = $_GET['latitude'];
$longitude = $_GET['longitude'];

// 连接数据库
$conn = new mysqli($host, $username, $password, $dbname);
if ($conn->connect_error) {
  die("数据库连接失败: " . $conn->connect_error);
}

// 设置字符编码为UTF-8
$conn->set_charset("utf8");

// 构建查询语句，查询申报字段为当前位置的数据
$sql = "SELECT `当前位置` FROM 上报";
$result = $conn->query($sql);

// 将查询结果格式化为经纬度数据的数组
$data = [];
if ($result->num_rows > 0) {
  $index = 1;
  while ($row = $result->fetch_assoc()) {
    $location = $row['当前位置'];
    $coordinates = explode(',', $location);
    $longitude = floatval($coordinates[1]);
    $latitude = floatval($coordinates[0]);
    
    $point = [
      'name' => '申报人员' . $index,
      'value' => [$longitude, $latitude]
    ];
    $data[] = $point;
    $index++;
  }
}

// 返回经纬度数据的JSON格式
echo json_encode($data);

// 关闭数据库连接
$conn->close();
?>
