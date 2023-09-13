nextButton.addEventListener('click', function() {
  if (isFirstClick) {
    isFirstClick = false;
    nextButton.textContent = '下一个';
    drawXYCurve();
  } else {
    if (currentIndex + windowSize >= jsonData.length) {
      alert('已达到数据末尾');
      return;
    }
   
    currentIndex += stepSize;
    drawXYCurve();
    console.log(currentIndex);
  }
});
previousButton.addEventListener('click', function() {
  if (isFirstClick) {
    alert('已达到数据起始位置');
    return;
  } else {
    currentIndex -= stepSize;
    drawXYCurve();

  }
});

console.log(jsonData)

var item6 = document.getElementById('item6');
var meanMagnitudeElement;
meanMagnitude = parseFloat(meanMagnitudeElement.innerText); // 使用容器中的均值
function drawXYCurve() {
  var startDate = new Date(jsonData[currentIndex][0]);
  var endDate = new Date(jsonData[currentIndex + windowSize - 1][0]);///--------------
  console.log('x值:', endDate);
  var xData = []; // x 值
  var yData = []; // ln(N)
  
  // 获取 x 值，并去重排序
  var xValues = jsonData
    .slice(currentIndex, currentIndex + windowSize)
    .map(function(item) {
      return parseFloat(item[3]);
    })
    .filter(function(value, index, self) {
      return self.indexOf(value) === index;
    })
    .sort(function(a, b) {
      return a - b;
    });
  var sumMagnitude = 0;
  var totalCount = 0;
  // 统计大于 x 值的个数 N，并计算 ln(N)
  for (var i = 0; i < xValues.length; i++) {
    var xValue = xValues[i];
    var count = 0;
    for (var j = currentIndex; j < currentIndex + windowSize; j++) {
      if (parseFloat(jsonData[j][3]) > xValue) {
        count++;
        sumMagnitude += parseFloat(jsonData[j][3]);
        totalCount++;
      }
    }
    var lnN = count === 0 ? 0 : Math.log(count);
    xData.push(xValue);
    yData.push(lnN);
    console.log(xData)
    console.log(yData);
  }
  var meanMagnitude = totalCount === 0 ? 0 : sumMagnitude / totalCount; // 计算均值
  var bValue = 0; // 默认b值为0
  // 判断最佳拟合直线是否是由两个数据点组成
  var isBestFitLineValid = xData.length >= 2 && yData.length >= 2;
//以三个离散点的外接圆半径的倒数作为中间点的曲率计算公式为k=4s/abc
function calculateCurvature(xData, yData, index) {
  var x = xData[index];
  var y = yData[index];
  var x1 = xData[index - 1];
  var y1 = yData[index - 1];
  var x2 = xData[index + 1];
  var y2 = yData[index + 1];
  // 计算三角形的三个边的长度
  var a = Math.sqrt((x - x1) ** 2 + (y - y1) ** 2);
  var b = Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2);
  var c = Math.sqrt((x - x2) ** 2 + (y - y2) ** 2);
  // 计算三角形的面积
  var s = 0.5 * Math.abs(x1*y+x*y2+x2*y1-y1*x-y*x2-y2*x1);
  // 计算曲率
  var curvature = 4 * s / (a * b * c);
  return curvature;
}
// 绘制曲线和直线
function drawCurveWithMaxCurvature(xData, yData, maxCurvatureIndex) {
  if (chart) {
    chart.destroy();
  }

  var ctx = document.getElementById("chartContainer").getContext("2d");

  // 创建散点图
  chart = new Chart(ctx, {
    type: "scatter",
    data: {
      datasets: [
        {
          label: "震级—频度分布",
          data: xData.map(function(x, index) {
            return {
              x: x,
              y: yData[index]
            };
          }),
          backgroundColor: "rgba(0, 0, 0, 0.5)",
          borderColor: "black",
          borderWidth: 0,
          pointRadius: 3,
        },
      ],
    },
    options: {
      responsive: true,
      scales: {
        x: {
          title: {
            display: true,
            text: "震级",
            ticks: {
              autoSkip: true,
              maxTicksLimit: 10,
            },
          },
        },
        y: {
          title: {
            display: true,
            text: "ln(N)",
          },
        },
      },
      plugins: {
        title: {
          display: true,
          text: "时间段：" + formatDate(startDate) + " - " + formatDate(endDate),
          padding: {
            top: 10,
            bottom: 30,
          },
        },
      },
    },
  });
// 绘制直线
var lineX1 = xData[maxCurvatureIndex - 1];
var lineY1 = yData[maxCurvatureIndex - 1];
var lineX2 = xData[maxCurvatureIndex + 1];
var lineY2 = yData[maxCurvatureIndex + 1];
var minX = Math.min(lineX1, lineX2);
var maxX = Math.max(lineX1, lineX2);
var minY = lineY1 + (lineY2 - lineY1) * (minX - lineX1) / (lineX2 - lineX1);
var maxY = lineY1 + (lineY2 - lineY1) * (maxX - lineX1) / (lineX2 - lineX1);
// 计算直线与 x 轴的交点坐标
var xIntercept = minX + (maxX - minX) * (0 - minY) / (maxY - minY);
// 计算直线与 y 轴的交点坐标
var yIntercept = minY + (maxY - minY) * (0 - minX) / (maxX - minX);
// 计算垂直线段的端点坐标
var verticalLineX = lineX1;
var upperVerticalLineY = lineY1 - 2; // 在 lineY1 的基础上减去 2 个单位
var lowerVerticalLineY = lineY1 + 2; // 在 lineY1 的基础上加上 2 个单位
// 绘制直线和垂直线段
chart.config.data.datasets.push(
  {
    label: "最大曲率直线",
    data: [{ x: xIntercept, y: 0 }, { x: 0, y: yIntercept }],
    type: "line",
    borderColor: "red",
    borderWidth: 2,
    fill: false,
  },
  {
    label: "Mc所在位置",
    data: [
      { x: verticalLineX, y: upperVerticalLineY },
      { x: verticalLineX, y: lowerVerticalLineY },
    ],
    type: "line",
    borderColor: "blue",
    borderWidth: 2,
    fill: false,
  }
);
chart.update();
}
// 创建用于存储时间和b值的数组
var index = item6.childElementCount + 1;
var time = formatDate(startDate);
var mcInputId = 'mcInput_' + currentIndex;
console.log("cuee:",currentIndex);
console.log(mcInputId)
var mcInput = '<input type="number" id="' + mcInputId + '" placeholder="输入Mc" />';
var bValueId = 'bValue_' + currentIndex;
var bValue = 0; // 默认b值为0，因为初始时还没有用户输入的Mc值
var text = '<div style="display: flex; align-items: center;">' +
  '<div style="flex: 1;">序号: ' + index + '</div>' +
  '<div style="flex: 1;">初始时间: ' + time + '</div>' +
  '<div style="flex: 1;">meanMagnitude: <span class="mean-magnitude">' + meanMagnitude.toFixed(2) + '</span></div>' +
  '<div style="flex: 1;">Mc: ' + mcInput + '</div>' +
  '<div style="flex: 1;">b: <span id="' + bValueId + '">' + bValue.toFixed(2) + '</span></div>' +
  '</div>';
var container = document.createElement('div');
container.innerHTML = text;
item6.appendChild(container);
// 获取更新后的均值元素
var mcInputEl = document.getElementById(mcInputId);
mcInputEl.addEventListener('change', function(event) {
  var index = item6.childElementCount + 1; // 更新索引值
  var time = formatDate(startDate); // 更新时间值
  var mcValue = parseFloat(event.target.value);
  var bValueElement = document.getElementById(bValueId);
  var bValue = calculateB(meanMagnitude, mcValue); // 计算得到的新的b值
  bValueElement.innerHTML = bValue.toFixed(2); // 更新b值显示
  // 将时间和b值添加到数组中
  dataArray[index-1] = { time: time, bValue: bValue };
  // 打印平均震级、mcValue、时间和b值
  console.log("平均震级:", meanMagnitude.toFixed(2));
  console.log("mcValue:", mcValue);
  console.log("时间:", time);
  console.log("b:", bValue);
  console.log("数组:", dataArray);
  drawNewCurve(dataArray);
});
function calculateB(meanMagnitude, mcValue) {
  var bValue = Math.log10(Math.E) / (meanMagnitude - mcValue);
  return bValue;
}
dataArray.push({ time: time, bValue: bValue });
var maxCurvature = 0;
var maxCurvatureIndex = 0;
for (var i = 1; i < xData.length - 1; i++) {
  var curvature = calculateCurvature(xData, yData, i);
  if (curvature > maxCurvature) {
    maxCurvature = curvature;
    maxCurvatureIndex = i;
  }
}
console.log('最大曲率:', maxCurvature);
console.log('最大曲率点索引:', maxCurvatureIndex);
drawCurveWithMaxCurvature(xData, yData, maxCurvatureIndex)
}


function drawNewCurve(dataArray) {
  // 创建一个用于存储 X 轴数据（时间）的数组
  var xLabels = dataArray.map(entry => entry.time);

  // 创建一个用于存储 Y 轴数据（bValue）的数组
  var yData = dataArray.map(entry => entry.bValue);

  // 如果已经存在图表实例，先销毁它
  if (newChart) {
    newChart.destroy();
  }

  // 获取 canvas 元素的上下文
  var ctx = document.getElementById("chartContainer2").getContext("2d");

  // 创建新的图表实例
  newChart = new Chart(ctx, {
    type: "line",
    data: {
      labels: xLabels,
      datasets: [
        {
          label: "B-Value",
          data: yData,
          borderColor: "blue",
          borderWidth: 2,
          fill: false
        }
      ]
    },
    options: {
      responsive: true,
      scales: {
        x: {
          title: {
            display: true,
            text: "时间"
          }
        },
        y: {
          title: {
            display: true,
            text: "bValue"
          }
        }
      },
      // 根据需要自定义其他图表选项
    }
  });

  // 其他绘制曲线的逻辑...
}


function formatDate(date) {
  var year = date.getFullYear();
  var month = date.getMonth() + 1;
  var day = date.getDate();
  return year + "-" + month + "-" + day;
}
// 调用函数绘制初始曲线
drawXYCurve();
var newChart = null; // 声明一个变量用于存储图表实例
if (newChart) {
  newChart.destroy(); // 销毁旧图表实例
}
newChart = new Chart(ctx, {
  // 创建新图表
});