<?php

// 获取表单数据
$gender = $_POST['性别'];
$feeling = $_POST['感觉'];
$urgentItem = $_POST['急需物品'];
$deaths = $_POST['人员死亡'];
$severeInjuries = $_POST['人员重伤'];
$missingPeople = $_POST['人员失踪'];
$damagedHouses = $_POST['民房受损'];
$damagedSchools = $_POST['学校受损'];
$damagedHospitals = $_POST['医院受损'];
$otherBuildings = $_POST['其他建筑受损'];
$groundCondition = $_POST['地表情况'];
$otherDisasters = $_POST['其他灾害'];
$currentDatetime = $_POST['currentDatetime'];
$currentLocation = $_POST['currentLocation'];

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

// 构建插入数据的SQL语句
$sql = "INSERT INTO 上报 (性别, 感觉, 急需物品, 人员死亡, 人员重伤, 人员失踪, 民房受损, 学校受损, 医院受损, 其他建筑受损, 地表情况, 其他灾害, 填报时间, 当前位置)
        VALUES ('$gender', '$feeling', '$urgentItem', '$deaths', '$severeInjuries', '$missingPeople', '$damagedHouses', '$damagedSchools', '$damagedHospitals', '$otherBuildings', '$groundCondition', '$otherDisasters', '$currentDatetime', '$currentLocation')";

// 执行插入操作并检查是否成功
if ($conn->query($sql) === TRUE) {
    echo '<script>alert("数据已成功提交到数据库");</script>';
    echo '<script>window.location.href = "txt.html";</script>'; // 跳转到txt.html界面
} else {
    echo '<script>alert("提交数据到数据库时出错: ' . $conn->error . '");</script>';
}

// 关闭数据库连接
$conn->close();

?>
