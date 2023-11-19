(function() {
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
        show: true, // 显示省份名称
        color: "#000", // 文字颜色
        fontSize: 6, // 文字大小
        emphasis: {
          show: true // 高亮样式
        }
      },
      itemStyle: {
        normal: {
          areaColor: "#3388ff", // 修改为蓝色
          borderColor: "#404a59",
          borderWidth: 2
        },
        emphasis: {
          areaColor: "#FF0000"
        }
      }
    },

  };

  // 3. 设置点击事件处理程序
  myChart.on("click", function(params) {
    if (params.seriesType === "scatter") {
      alert("当前城市：" + params.data.name);
      // 在这里可以进行自定义操作，如显示更详细的信息等
    }
  });

  // 4. 使用刚指定的配置和数据显示图表。
  myChart.setOption(option);
})();
