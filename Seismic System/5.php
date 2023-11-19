<?php

// 连接数据库
$host = 'localhost';
$username = 'root1'; // 替换为你的数据库用户名
$password = '123456'; // 替换为你的数据库密码
$dbname = 'user'; // 替换为你的数据库名称

$conn = new mysqli($host, $username, $password, $dbname);

// 检查数据库连接是否成功
if ($conn->connect_error) {
  die("数据库连接失败: " . $conn->connect_error);
}

// 构建日期范围
$endDate = date('Y-m-d'); // 当前日期
$startDate = date('Y-m-d', strtotime('-15 days', strtotime($endDate))); // 当前日期往前推15天

// 构建日期范围数组（从今天排到前面）
$dateRange = array();
$currentDate = $endDate;

while ($currentDate >= $startDate) {
  $dateRange[] = $currentDate;
  $currentDate = date('Y-m-d', strtotime('-1 day', strtotime($currentDate)));
}

// 查询数据库获取数据并按填报时间排序
$sql = "SELECT 性别, 填报时间 FROM 上报 WHERE 填报时间 BETWEEN '$startDate' AND '$endDate' ORDER BY 填报时间 ASC";
$result = $conn->query($sql);

$genderCount = array();

// 初始化性别计数器
foreach ($dateRange as $date) {
  $genderCount[$date] = array('男' => 0, '女' => 0);
}

// 遍历查询结果
if ($result->num_rows > 0) {
  while ($row = $result->fetch_assoc()) {
    $性别 = $row['性别'];
    $填报时间 = $row['填报时间'];

    if ($性别 === '男') {
      $genderCount[$填报时间]['男']++;
    } elseif ($性别 === '女') {
      $genderCount[$填报时间]['女']++;
    }
  }
}

// 构建返回数据
$data1 = array_reverse($dateRange); // 反转日期数组
$data2 = array();
$data3 = array();

foreach ($data1 as $date) {
  $data2[] = $genderCount[$date]['男'];
  $data3[] = $genderCount[$date]['女'];
}

// 返回数据给前端
$responseData = array(
  'data1' => $data1,
  'data2' => $data2,
  'data3' => $data3
);

// 输出JSON数据
header('Content-Type: application/json');
echo json_encode($responseData);

// 关闭数据库连接
$conn->close();
?>
