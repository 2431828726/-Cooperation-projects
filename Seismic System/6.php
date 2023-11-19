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

// 查询数据库获取数据
$sql = "SELECT 当前位置, 急需物品, 填报时间 FROM 上报";
$result = $conn->query($sql);

$data = array();
$counter = 1;

// 遍历查询结果
if ($result->num_rows > 0) {
  while ($row = $result->fetch_assoc()) {
    $row['序号'] = 'Reporter' . $counter;
    $data[] = $row;
    $counter++;
  }
}

// 返回数据给前端
$responseData = array(
  'data' => $data
);

// 输出JSON数据
header('Content-Type: application/json');
echo json_encode($responseData);

// 关闭数据库连接
$conn->close();
?>
