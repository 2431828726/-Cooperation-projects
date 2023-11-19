<?php
$host = 'localhost';
$username = 'root1';
$password = '123456';
$dbname = 'user';

// 创建数据库连接
$conn = new mysqli($host, $username, $password, $dbname);

if ($conn->connect_error) {
    die("数据库连接失败: " . $conn->connect_error);
}

// 查询上报表中的数据
$query = "SELECT `人员死亡`, `人员重伤`, `人员失踪` FROM 上报";
$result = $conn->query($query);

if ($result->num_rows > 0) {
    $response = array();

    while ($row = $result->fetch_assoc()) {
        $damagedHouses = calculateDamageValue($row['人员死亡']);
        $damagedSchools = calculateDamageValue($row['人员重伤']);
        $damagedHospitals = calculateDamageValue($row['人员失踪']);
    

        $response[] = array(
            '人员死亡' => $damagedHouses,
            '人员重伤' => $damagedSchools,
            '人员失踪' => $damagedHospitals,
            
        );
    }

    // 返回结果给JavaScript
    echo json_encode($response);
} else {
    // 如果没有数据，返回空数据给JavaScript
    echo json_encode(array());
}

$conn->close();

// 根据字段数据计算数值
function calculateDamageValue($value) {
    $value = trim($value);

    if ($value === '1-3') {
        return 2;
    } else if ($value === '4-9') {
        return 7;
    } else if ($value === '10以上') {
        return 10;
    } else {
        return 0;
    }
}
?>
