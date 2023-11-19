// 1. 实例化对象
var myChart = echarts.init(document.querySelector(".map .chart"));

// 2. 指定配置和数据
var option = {
  tooltip: {
    trigger: "item",
    formatter: "{b}"
  },
  geo: {
    map: "china",
    roam: true,
    label: {
      show: true,
      color: "#000",
      fontSize: 6,
      emphasis: {
        show: true
      }
    },
    itemStyle: {
      normal: {
        areaColor: "#3388ff",
        borderColor: "#404a59",
        borderWidth: 2
      },
      emphasis: {
        areaColor: "#FF0000"
      }
    }
  },
  series: [
    {
      type: "effectScatter",
      coordinateSystem: "geo",
      data: [], // 此处为占位符，需要从服务器获取数据并填充
      symbolSize: 10,
      label: {
        show: true,
        formatter: "{b}",
        position: "right",
        color: "#000",
        fontSize: 8
      },
      itemStyle: {
        color: "#FF0000"
      },
      emphasis: {
        focus: 'self',
        label: {
          show: true,
          formatter: function(params) {
            var point = params.data;
            return point.name + "\n经度：" + point.value[0] + "\n纬度：" + point.value[1];
          },
          position: "top",
          color: "#000",
          fontSize: 10,
          backgroundColor: "#fff",
          padding: [5, 10],
          borderColor: "#ccc",
          borderWidth: 1,
          textStyle: {
            color: "#000"
          }
        }
      }
    }
  ]
};

var data1; // 存储地图1.php的数据
var data2; // 存储地图2.php的数据

// 3. 发送AJAX请求获取地图1.php的数据
var xhr1 = new XMLHttpRequest();
xhr1.open("GET", "map1.php", true);
xhr1.onreadystatechange = function () {
  if (xhr1.readyState === 4 && xhr1.status === 200) {
    data1 = JSON.parse(xhr1.responseText);

    console.log(data1);

    // 绘制图表
    drawChart();
  }
};
xhr1.send();

// 4. 发送AJAX请求获取地图2.php的数据
var xhr2 = new XMLHttpRequest();
xhr2.open("GET", "map2.php", true);
xhr2.onreadystatechange = function () {
  if (xhr2.readyState === 4 && xhr2.status === 200) {
    data2 = JSON.parse(xhr2.responseText);

    console.log(data2);

    // 绘制图表
    drawChart();
  }
};
xhr2.send();

// 绘制图表的函数
function drawChart() {
  if (data1 && data2) {
    // 修改散点图的颜色为黄色
    option.series[0].itemStyle.color = "#FF0000";

    // 添加第二个系列数据
    option.series.push({
      type: "effectScatter",
      coordinateSystem: "geo",
      data: data2,
      symbolSize: 10,
      label: {
        show: true,
        formatter: "{b}",
        position: "right",
        color: "#000",
        fontSize: 8
      },
      itemStyle: {
        color: "#FFFF00"
      },
      emphasis: {
        focus: 'self',
        label: {
          show: true,
          formatter: function(params) {
            var point = params.data;
            return point.name + "\n经度：" + point.value[0] + "\n纬度：" + point.value[1];
          },
          position: "top",
          color: "#000",
          fontSize: 10,
          backgroundColor: "#fff",
          padding: [5, 10],
          borderColor: "#ccc",
          borderWidth: 1,
          textStyle: {
            color: "#000"
          }
        }
      }
    });

    // 将地图1.php的数据填充到第一个系列数据中
    option.series[0].data = data1;

    // 使用刚指定的配置和数据显示图表
    myChart.setOption(option);
  }
}