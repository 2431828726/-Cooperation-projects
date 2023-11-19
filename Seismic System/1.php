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
$query = "SELECT `民房受损`, `学校受损`, `医院受损`, `其他建筑受损` FROM 上报";
$result = $conn->query($query);

if ($result->num_rows > 0) {
    $response = array();

    while ($row = $result->fetch_assoc()) {
        $damagedHouses = calculateDamageValue($row['民房受损']);
        $damagedSchools = calculateDamageValue($row['学校受损']);
        $damagedHospitals = calculateDamageValue($row['医院受损']);
        $damagedOthers = calculateDamageValue($row['其他建筑受损']);

        $response[] = array(
            '民房受损' => $damagedHouses,
            '学校受损' => $damagedSchools,
            '医院受损' => $damagedHospitals,
            '其他建筑受损' => $damagedOthers
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
