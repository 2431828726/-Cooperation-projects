<?php
// 设置数据库连接参数
$host = 'localhost';
$username = 'root1';
$password = '123456';
$dbname = 'user';

// 创建数据库连接
$conn = new mysqli($host, $username, $password, $dbname);
if ($conn->connect_error) {
    die("数据库连接失败: " . $conn->connect_error);
}

// 获取POST请求中的关键词信息
$keyword = $_POST['keyword'];

// 构建SQL查询语句
$sql = "SELECT * FROM 机构 WHERE 名字 LIKE '%$keyword%'";

// 执行查询
$result = $conn->query($sql);

// 将查询结果转换为JSON格式并返回给前端
$data = array();
if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        $name = $row['名字'];
        $latitude = $row['纬度'];
        $longitude = $row['经度'];

        // 检查经度和纬度的值是否有效
        if ($latitude !== null && $longitude !== null) {
            $location = array(
                '名称' => $name,
                '纬度' => $latitude,
                '经度' => $longitude
            );

            $data[] = $location;
        }
    }
}

echo json_encode($data);

// 关闭数据库连接
$conn->close();
?>
