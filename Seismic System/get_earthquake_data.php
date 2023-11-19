<?php
 // 配置数据库连接信息
 $servername = "localhost";
 $username = "root1";
 $password = "123456";
 $dbname = "user";

 // 建立数据库连接
 $conn = mysqli_connect($servername, $username, $password, $dbname);
 if (!$conn) {
   die("Connection failed: " . mysqli_connect_error());
 }
 
 // 获取搜索条件
 $minLng = $_POST['minLng'];
 $maxLng = $_POST['maxLng'];
 $minLat = $_POST['minLat'];
 $maxLat = $_POST['maxLat'];
 $depth = $_POST['depth'];
 $magnitude = $_POST['magnitude'];
 $location = $_POST['location'];
 // 进行必要的数据处理
 if ($minLng == '') $minLng = -180;
 if ($maxLng == '') $maxLng = 180;
 if ($minLat == '') $minLat = -90;
 if ($maxLat == '') $maxLat = 90;
 if ($depth == '') $depth = 10000;
 if ($magnitude == '') $magnitude = 0;

 // 执行SQL查询
 $sql = "SELECT longitude, latitude, depth, location,magnitude ,location FROM earthquake WHERE " .
        "longitude >= $minLng AND longitude <= $maxLng AND " .
        "latitude >= $minLat AND latitude <= $maxLat AND " .
        "depth <= $depth AND magnitude >= $magnitude" 
       
        ;
 $result = mysqli_query($conn, $sql);
 


 
 // 构造GeoJSON格式数据
 $features = array();
 while ($row = mysqli_fetch_assoc($result)) {
   $properties = array(
     'longitude' => $row['longitude'],
     'latitude' => $row['latitude'],
     'depth' => $row['depth'],
     'magnitude' => $row['magnitude'],
     'location' => $row['location'] // 将数据表中的 location 字段加入到 GeoJSON 的 properties 中
   );
   $geometry = array(
     'type' => 'Point',
     'coordinates' => array(floatval($row['longitude']), floatval($row['latitude']))
   );
   $feature = array(
     'type' => 'Feature',
     'geometry' => $geometry,
     'properties' => $properties
   );
   array_push($features, $feature);
 }
 
 // 输出GeoJSON格式数据
 header('Content-type: application/json');
 echo json_encode(array(
   'type' => 'FeatureCollection',
   'features' => $features
 ));
 
 // 关闭数据库连接
 mysqli_close($conn);

 
 

 
 

 
 
?>