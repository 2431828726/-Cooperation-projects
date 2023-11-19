(function() {
  // 实例化对象
  var myChart = echarts.init(document.querySelector(".bar .chart"));
  // 指定配置和数据
  var option = {
    color: ["#2f89cf"],
    tooltip: {
      trigger: "axis",
      axisPointer: {
        // 坐标轴指示器，坐标轴触发有效
        type: "line" // 默认为直线，可选为：'line' | 'shadow'
      }
    },
    grid: {
      left: "0%",
      top: "10px",
      right: "0%",
      bottom: "4%",
      containLabel: true
    },
    xAxis: [
      {
        type: "category",
        data: [
          "Residential Building",
          "School",
          "Hospital",
          "Other "
        ],
        
        axisTick: {
          alignWithLabel: true
        },
        axisLabel: {
          textStyle: {
            color: "rgba(255,255,255,.6)",
            fontSize: "8"
          }
        },
        axisLine: {
          show: false
        }
      }
    ],
    yAxis: [
      {
        type: "value",
        axisLabel: {
          textStyle: {
            color: "rgba(255,255,255,.6)",
            fontSize: "12"
          }
        },
        axisLine: {
          lineStyle: {
            color: "rgba(255,255,255,.1)"
            // width: 1,
            // type: "solid"
          }
        },
        splitLine: {
          lineStyle: {
            color: "rgba(255,255,255,.1)"
          }
        }
      }
    ],
    series: [
      {
        name: "Number of Damages",
        type: "bar",
        barWidth: "35%",
        data: [],
        itemStyle: {
          barBorderRadius: 5
        }
      }
    ]
  };

  // 把配置给实例对象
  myChart.setOption(option);
  window.addEventListener("resize", function() {
    myChart.resize();
  });

  // 发起Ajax请求获取数据
  $.ajax({
    url: "1.php", // 修改为您的PHP文件路径
    type: "GET",
    dataType: "json",
    success: function(data) {
      // 将返回的数据相加并赋值给图表的数据项
      var totalData = data.map(function(item) {
        return Object.values(item).reduce(function(a, b) {
          return a + b;
        });
      });

      myChart.setOption({
        series: [
          {
            data: totalData
          }
        ]
      });
    },
    error: function(xhr, status, error) {
      console.log("Ajax请求失败：" + error);
    }
  });
})();


// --------------------------------------------------------折线图定制
(function() {
  // 基于准备好的dom，初始化echarts实例
  var myChart = echarts.init(document.querySelector(".line .chart"));

  // (1)准备数据
  var data = {
    year: [[]]
  };

  // 通过Ajax请求获取PHP返回的数据
  // 假设PHP文件名为data.php
  $.ajax({
    type: "GET",
    url: "4.php",
    dataType: "json",
    success: function(response) {
      // 获取PHP返回的数据
      var jsonData = response;

      // 将PHP返回的数据填充到对应的year数据中
      data.year[0] = [
        jsonData['其他灾害']['滑坡'],
        jsonData['其他灾害']['河堤塌陷'],
        jsonData['地表情况']['大裂缝'],
        jsonData['地表情况']['中裂缝'],
        jsonData['地表情况']['小裂缝'],
        jsonData['其他灾害']['无']
      ];

      // 重新设置echarts的数据
      myChart.setOption({
        series: [
          {
            data: data.year[0]
          }
        ]
      });
    },
    error: function(xhr, status, error) {
      console.log(error); // 输出错误信息
    }
  });

  // 2. 指定配置和数据
  var option = {
    color: ["#00f2f1"],
    tooltip: {
      // 通过坐标轴来触发
      trigger: "axis"
    },
    legend: {
      // 距离容器10%
      right: "6%",
      // 修饰图例文字的颜色
      textStyle: {
        color: "#4c9bfd"
      }
      // 如果series 里面设置了name，此时图例组件的data可以省略
      // data: ["邮件营销", "联盟广告"]
    },
    grid: {
      top: "17%",
      left: "3%",
      right: "4%",
      bottom: "3%",
      show: true,
      borderColor: "#012f4a",
      containLabel: true
    },

    xAxis: {
      type: "category",
      // boundaryGap: false, // 将此行注释掉或删除
      data: [
        "Landslide",
        "Riverbank Collapse",
        "Large Crack",
        "Medium Crack",
        "Small Crack",
        "None"
      ],
      
      // 去除刻度
      axisTick: {
        show: false
      },
      // 修饰刻度标签的颜色
      axisLabel: {
        color: "rgba(255,255,255,.7)",
        fontSize: 7 // 修改字体大小为12px
      },
      // 去除x坐标轴的颜色
      axisLine: {
        show: false
      }
    },
    yAxis: {
      type: "value",
      // 去除刻度
      axisTick: {
        show: false
      },
      // 修饰刻度标签的颜色
      axisLabel: {
        color: "rgba(255,255,255,.7)"
      },
      // 修改y轴分割线的颜色
      splitLine: {
        lineStyle: {
          color: "#012f4a"
        }
      }
    },
    series: [
      {
        name: "",
        type: "line",
        stack: "总量",
        // 是否让线条圆滑显示
        smooth: true,
        data: data.year[0]
      }
    ]
  };
  // 3. 把配置和数据给实例对象
  myChart.setOption(option);

  // 重新把配置好的新数据给实例对象
  myChart.setOption(option);

  window.addEventListener("resize", function() {
    myChart.resize();
  });
})();



//------------------------------------------------------------

(function() {
  // 基于准备好的dom，初始化echarts实例
  var myChart = echarts.init(document.querySelector(".bar1 .chart"));

  var titlename = ["Fatalities", "Severe Injuries", "Missing Persons"];

  var myColor = ["#1089E7", "#F57474", "#56D0E3"];

  $.ajax({
    url: "2.php", // 修改为您的PHP文件路径
    type: "GET",
    dataType: "json",
    success: function(jsonData) {
      var data = [];

      // 提取数据
      for (var i = 0; i < jsonData.length; i++) {
        var item = jsonData[i];
        var sum = item["人员死亡"] + item["人员重伤"] + item["人员失踪"];
        data.push(sum);
      }

      var option = {
        //图标位置
        grid: {
          top: "10%",
          left: "22%",
          bottom: "10%"
        },
        xAxis: {
          show: false
        },
        yAxis: [
          {
            show: true,
            data: titlename,
            inverse: true,
            axisLine: {
              show: false
            },
            splitLine: {
              show: false
            },
            axisTick: {
              show: false
            },
            axisLabel: {
              color: "#fff",
              rich: {
                lg: {
                  backgroundColor: "#339911",
                  color: "#fff",
                  borderRadius: 15,
                  align: "center",
                  width: 25,
                  height: 15
                }
              }
            }
          }
        ],
        series: [
          {
            name: "number",
            type: "bar",
            data: data,
            barCategoryGap: 50,
            barWidth: 15,
            itemStyle: {
              normal: {
                barBorderRadius: 20,
                color: function(params) {
                  var num = titlename.length;
                  return myColor[params.dataIndex % num];
                }
              }
            },
            label: {
              normal: {
                show: true,
                position: "inside",
                formatter: "{c} number"
              }
            }
          }
        ]
      };

      // 使用刚指定的配置项和数据显示图表
      myChart.setOption(option);
    },
    error: function(xhr, status, error) {
      console.log("请求数据失败");
    }
  });
})();




// 折线图 优秀作品
(function() {
  // 基于准备好的dom，初始化echarts实例
  var myChart = echarts.init(document.querySelector(".line1 .chart"));

  option = {
    tooltip: {
      trigger: "axis",
      axisPointer: {
        lineStyle: {
          color: "#dddc6b"
        }
      }
    },
    legend: {
      top: "0%",
      textStyle: {
        color: "rgba(255,255,255,.5)",
        fontSize: "12"
      }
    },
    grid: {
      left: "10",
      top: "30",
      right: "10",
      bottom: "10",
      containLabel: true
    },

    xAxis: [
      {
        type: "category",
        boundaryGap: false,
        axisLabel: {
          textStyle: {
            color: "rgba(255,255,255,.6)",
            fontSize: 12
          }
        },
        axisLine: {
          lineStyle: {
            color: "rgba(255,255,255,.2)"
          }
        },
        data: []
      },
      {
        axisPointer: { show: false },
        axisLine: { show: false },
        position: "bottom",
        offset: 20
      }
    ],

    yAxis: [
      {
        type: "value",
        axisTick: { show: false },
        axisLine: {
          lineStyle: {
            color: "rgba(255,255,255,.1)"
          }
        },
        axisLabel: {
          textStyle: {
            color: "rgba(255,255,255,.6)",
            fontSize: 12
          }
        },
        splitLine: {
          lineStyle: {
            color: "rgba(255,255,255,.1)"
          }
        }
      }
    ],
    series: [
      {
        name: "Male",
        type: "line",
        smooth: true,
        symbol: "circle",
        symbolSize: 5,
        showSymbol: false,
        lineStyle: {
          normal: {
            color: "#0184d5",
            width: 2
          }
        },
        areaStyle: {
          normal: {
            color: new echarts.graphic.LinearGradient(
              0,
              0,
              0,
              1,
              [
                {
                  offset: 0,
                  color: "rgba(1, 132, 213, 0.4)"
                },
                {
                  offset: 0.8,
                  color: "rgba(1, 132, 213, 0.1)"
                }
              ],
              false
            ),
            shadowColor: "rgba(0, 0, 0, 0.1)"
          }
        },
        itemStyle: {
          normal: {
            color: "#0184d5",
            borderColor: "rgba(221, 220, 107, .1)",
            borderWidth: 12
          }
        },
        data: []
      },
      {
        name: "Female",
        type: "line",
        smooth: true,
        symbol: "circle",
        symbolSize: 5,
        showSymbol: false,
        lineStyle: {
          normal: {
            color: "#00d887",
            width: 2
          }
        },
        areaStyle: {
          normal: {
            color: new echarts.graphic.LinearGradient(
              0,
              0,
              0,
              1,
              [
                {
                  offset: 0,
                  color: "rgba(0, 216, 135, 0.4)"
                },
                {
                  offset: 0.8,
                  color: "rgba(0, 216, 135, 0.1)"
                }
              ],
              false
            ),
            shadowColor: "rgba(0, 0, 0, 0.1)"
          }
        },
        itemStyle: {
          normal: {
            color: "#00d887",
            borderColor: "rgba(221, 220, 107, .1)",
            borderWidth: 12
          }
        },
        data: []
      }
    ]
  };

  // 使用刚指定的配置项和数据显示图表。
  myChart.setOption(option);

  // 发送请求获取数据
  fetch('5.php')
    .then(response => response.json())
    .then(data => {
      myChart.setOption({
        xAxis: [
          {
            data: data.data1
          },
          {
            data: data.data1
          }
        ],
        series: [
          {
            name: 'Male',
            data: data.data2
          },
          {
            name: 'Female',
            data: data.data3
          }
        ]
      });
    });

  window.addEventListener("resize", function() {
    myChart.resize();
  });
})();



// 点位分布统计模块
(function() {
  // 1. 实例化对象
  var myChart = echarts.init(document.querySelector(".pie1 .chart"));

  // 2. 指定配置项和数据
  var option = {
    legend: {
      top: "90%",
      itemWidth: 10,
      itemHeight: 10,
      textStyle: {
        color: "rgba(255,255,255,.5)",
        fontSize: "12"
      }
    },
    tooltip: {
      trigger: "item",
      formatter: "{a} <br/>{b} : {c} ({d}%)"
    },
    // 注意颜色写的位置
    color: [
      "#006cff",
      "#60cda0",
      "#ed8884",
      "#ff9f7f",
      "#0096ff",
      "#9fe6b8",
      "#32c5e9"
    ],
    series: [
      {
        name: "Percentage of Urgently Needed Items",
        type: "pie",
        // 如果radius是百分比则必须加引号
        radius: ["10%", "70%"],
        center: ["50%", "42%"],
        roseType: "radius",
        data: [], // 数据将会在后续更新
        // 修饰饼形图文字相关的样式 label对象
        label: {
          fontSize: 10
        },
        // 修饰引导线样式
        labelLine: {
          // 连接到图形的线长度
          length: 10,
          // 连接到文字的线长度
          length2: 10
        }
      }
    ]
  };

  // 3. 配置项和数据给我们的实例化对象
  myChart.setOption(option);

  // 4. 当我们浏览器缩放的时候，图表也等比例缩放
  window.addEventListener("resize", function() {
    // 让我们的图表调用 resize 这个方法
    myChart.resize();
  });

  // 通过PHP获取数据库提供的数据
  fetch("3.php")
    .then(function(response) {
      return response.json();
    })
    .then(function(data) {
      var newData = [];
      var categories = ["Medicine", "Food", "Water", "Clothing", "Tent", "Rescue Equipment", "All"];


      categories.forEach(function(category) {
        var count = 0;
        data.forEach(function(item) {
          if (item === category) {
            count++;
          }
        });
        newData.push({ value: count, name: category });
      });

      // 更新数据
      option.series[0].data = newData;
      myChart.setOption(option);
    })
    .catch(function(error) {
      console.log("Error: " + error);
    });
})();



