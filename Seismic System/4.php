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
$sql = "SELECT 地表情况, 其他灾害 FROM 上报";
$result = $conn->query($sql);

$data = array();

if ($result->num_rows > 0) {
  // 统计地表情况和其他灾害类型的重复个数
  $countMap = array(
    '地表情况' => array(),
    '其他灾害' => array()
  );

  while ($row = $result->fetch_assoc()) {
    $地表情况 = $row['地表情况'];
    $其他灾害 = $row['其他灾害'];

    // 统计地表情况类型的重复个数
    if (isset($countMap['地表情况'][$地表情况])) {
      $countMap['地表情况'][$地表情况]++;
    } else {
      $countMap['地表情况'][$地表情况] = 1;
    }

    // 统计其他灾害类型的重复个数
    if (isset($countMap['其他灾害'][$其他灾害])) {
      $countMap['其他灾害'][$其他灾害]++;
    } else {
      $countMap['其他灾害'][$其他灾害] = 1;
    }
  }

  // 构建结果数组
  $resultData = array(
    '地表情况' => $countMap['地表情况'],
    '其他灾害' => $countMap['其他灾害']
  );

  // 将结果转换为JSON格式
  $jsonData = json_encode($resultData);

  // 输出JSON数据
  header('Content-Type: application/json');
  echo $jsonData;
} else {
  // 没有查询到数据
  echo "没有数据";
}

// 关闭数据库连接
$conn->close();
?>
