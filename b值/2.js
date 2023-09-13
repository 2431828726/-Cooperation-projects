var dataInfo = [];
var dataInfoIndex = 1; // 序号从1开始

console.log(jsonData)
nextButton.addEventListener('click', function() {
    if (isFirstClick) {
        isFirstClick = false;
        nextButton.textContent = '下一个';
        currentDateTime = jsonData[0][0].split(' ')[0];  // 获取第一条数据的日期时间,年-月—日格式
        drawXYCurve();
    } else {
        if (currentDateTime > new Date(jsonData[jsonData.length - 1][0])) {
            alert('已达到数据末尾');
            return;
        }
        const currentDate = new Date(currentDateTime);
        currentDate.setDate(currentDate.getDate() + stepSize1); // 在当前日期上添加步长
        currentDateTime = currentDate.toISOString().split('T')[0]; // 转回年-月-日格式
        drawXYCurve();
    }
});
previousButton.addEventListener('click', function() {
    if (isFirstClick) {
        alert('已达到数据起始位置');
        return;
    } else {
        const currentDate = new Date(currentDateTime);
        currentDate.setDate(currentDate.getDate() - stepSize1); // 根据步长更新时间
        currentDateTime = currentDate.toISOString().split('T')[0]; // 转回年-月-日格式
        drawXYCurve();
    }
});

var item6 = document.getElementById('item6');
var meanMagnitudeElement;
meanMagnitude = parseFloat(meanMagnitudeElement.innerText); // 使用容器中的均值
function drawXYCurve() {
    var startDate = currentDateTime;
    var endDate = new Date(currentDateTime);

    endDate.setDate(endDate.getDate() + windowSize1);

    var endDateString = endDate.toISOString().split('T')[0];
    var xData = [];
    var yData = [];

    var currentDateString = currentDateTime;

    var xValues = jsonData
        .filter(function (item) {
            var itemDate = item[0].split(' ')[0];
            return itemDate >= currentDateString && itemDate <= endDateString;
        })
        .map(function (item) {
            return parseFloat(item[3]);
        })
        .sort(function (a, b) {
            return a - b;
        });

    var sumMagnitude = 0;
    var totalCount = 0;

    xValues.sort(function (a, b) {
        return a - b;
    });

    var addedXValues = {};

    for (var i = 0; i < xValues.length; i++) {
        var xValue = xValues[i];

        var count = 0;

        for (var j = 0; j < xValues.length; j++) {
            if (xValues[j] >= xValue) {
                count++;
            }
        }

        var lnN = count === 0 ? 0 : Math.log(count);

        totalCount++;
        sumMagnitude += xValue;

        if (!addedXValues[xValue]) {
            xData.push(xValue);
            yData.push(lnN);
            addedXValues[xValue] = true;
        }
    }
    console.log(totalCount)
    console.log(sumMagnitude)
    // 获取已有的图表实例
    var myChart = Chart.getChart('chartContainer');

    // 如果之前不存在图表，就创建一个新的
    if (!myChart) {
        var ctx = document.getElementById('chartContainer').getContext('2d');
        myChart = new Chart(ctx, {
            type: 'scatter',
            data: {
                datasets: [{
                    label: '震级—频度分布',
                    data: [],
                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                    borderColor: 'rgba(75, 192, 192, 1)',
                    borderWidth: 1
                }]
            },
            options: {
                scales: {
                    x: {
                        type: 'linear',
                        position: 'bottom',
                        title: {
                            display: true,
                            text: '震级'
                        }
                    },
                    y: {
                        type: 'linear',
                        position: 'left',
                        title: {
                            display: true,
                            text: 'ln(N)'
                        }
                    }
                },
                plugins: {
                    title: {
                        display: true,
                        text: "时间段：" + currentDateString + " - " + endDateString,
                        padding: {
                            top: 10,
                            bottom: 30,
                        },
                    },
                },
            },
        });
    }

    // 更新标题
    myChart.options.plugins.title.text = "时间段：" + currentDateString + " - " + endDateString;

    // 更新散点图数据
    myChart.data.datasets[0].data = xData.map(function (_, i) {
        return { x: xData[i], y: yData[i] };
    });
    function calculateCurvature(xData, yData, index) {
        var x = xData[index];
        var y = yData[index];
        var x1 = xData[index - 1];
        var y1 = yData[index - 1];
        var x2 = xData[index + 1];
        var y2 = yData[index + 1];
        var a = Math.sqrt((x - x1) ** 2 + (y - y1) ** 2);
        var b = Math.sqrt((x2 - x1) ** 2 + (y2 - y1) ** 2);
        var c = Math.sqrt((x - x2) ** 2 + (y - y2) ** 2);
        var s = 0.5 * Math.abs(x1 * y + x * y2 + x2 * y1 - y1 * x - y * x2 - y2 * x1);
        var curvature = 4 * s / (a * b * c);
        return curvature;
    }
    
    // 找到最大曲率点的索引
    var maxCurvature = -Infinity;
    var maxCurvatureIndex = -1;

    for (var i = 1; i < xData.length - 1; i++) {
        var curvature = calculateCurvature(xData, yData, i);
        if (curvature > maxCurvature) {
            maxCurvature = curvature;
            maxCurvatureIndex = i;
        }
    }
    // 获取最大曲率对应的点坐标
    var maxCurvatureX = xData[maxCurvatureIndex];
    var maxCurvatureY = yData[maxCurvatureIndex];
console.log(maxCurvatureX )

// 先移除之前的垂直线和直线
myChart.config.data.datasets = myChart.config.data.datasets.filter(dataset => dataset.label !== '最大曲率点所在位置' && dataset.label !== '最大曲率点对应的切线');

// 计算垂直线段的端点坐标
var verticalLineX = xData[maxCurvatureIndex];
var upperVerticalLineY = Math.min(...yData);
var lowerVerticalLineY = Math.max(...yData);

// 绘制垂直线段
myChart.config.data.datasets.push({
  type: 'line',
  data: [
    { x: verticalLineX, y: upperVerticalLineY },
    { x: verticalLineX, y: lowerVerticalLineY }
  ],
  fill: false,
  borderColor: 'blue',
  borderWidth: 2,
  label: '最大曲率点所在位置'
});

// 计算直线的斜率和截距
var lineX1 = xData[maxCurvatureIndex - 1];
var lineY1 = yData[maxCurvatureIndex - 1];
var lineX2 = xData[maxCurvatureIndex + 1];
var lineY2 = yData[maxCurvatureIndex + 1];

var slope = (lineY2 - lineY1) / (lineX2 - lineX1);
var intercept = lineY1 - slope * lineX1;

// 计算直线与 x 轴的交点坐标
var xIntercept = -intercept / slope;

// 计算直线与 y 轴的交点坐标
var yIntercept = intercept;

// 绘制直线
myChart.config.data.datasets.push({
  type: 'line',
  data: [
    { x: xIntercept, y: 0 },
    { x: 0, y: yIntercept }
  ],
  fill: false,
  borderColor: 'red',
  borderWidth: 2,
  label: '最大曲率点对应的切线'
});
    // 更新图表
    myChart.update();
    var item6 = document.getElementById('item6');
var dataInfoIndex = 1; // 初始化 dataInfoIndex
var maxCurvatureX = xData[maxCurvatureIndex]; // 初始化 maxCurvatureX

// 添加修正值变量
var correctionMcValue = 0;
// 初始化初始的 bvalue
var bvalue = calculateBValue(maxCurvatureX);
// 创建输入框和按钮
var inputMc = document.createElement('input');
inputMc.type = 'number';
inputMc.placeholder = '输入修正Mc';
var buttonUpdate = document.createElement('button');
buttonUpdate.textContent = '输入修正Mc';
// 添加输入框和按钮到 item6 容器
item6.appendChild(inputMc);
item6.appendChild(buttonUpdate);
// 创建并更新 dataInfo 对象
var dataInfo = {
    index: dataInfoIndex,
    date: currentDateString,
    maxCurvatureX: maxCurvatureX,
    bvalue: bvalue
};

// 获取已有的图表实例，保证容器和容器2之间不冲突
var myChart2 = Chart.getChart('chartContainer2');

// 如果之前不存在图表，就创建一个新的
if (myChart2) {
    myChart2.destroy();
}

// 更新显示的函数
function updateDisplay() {
    // 计算修正后的 maxCurvatureX 和 bvalue
    var correctedMaxCurvatureX = maxCurvatureX + correctionMcValue;
    var correctedBValue = calculateBValue(correctedMaxCurvatureX);

    var item6Content = ` 时间点: ${dataInfo.date} 初始Mc: ${dataInfo.maxCurvatureX.toFixed(2)} 初始bvalue: ${dataInfo.bvalue} `;

    // 如果有修正值，添加修正后的值
    if (correctionMcValue !== 0) {
        item6Content += `修正后Mc: ${correctedMaxCurvatureX.toFixed(2)} 修正后bvalue: ${correctedBValue}`;
    }

    var item6Element = document.createElement('div');
    item6Element.classList.add('data-item');
    item6Element.textContent = item6Content;
    item6.appendChild(item6Element);

    // 在 JavaScript 中设置样式
    item6Element.style.marginBottom = '6px';
    item6Element.style.fontSize = '6px';

    // 将数据添加到数组中
    dataArray.push({
        date: dataInfo.date,
        bvalue: (correctionMcValue !== 0) ? correctedBValue : dataInfo.bvalue
    });

    // 更新 dataInfoIndex
    dataInfoIndex++;
}
updateDisplay(); // 初始状态直接调用一次
// 监听按钮点击事件
buttonUpdate.addEventListener('click', function () {
    var correctionMc = parseFloat(inputMc.value);
    if (!isNaN(correctionMc)) {
        correctionMcValue = correctionMc; // 存储修正值
        updateDisplay(); // 更新显示
    } else {
        alert('请输入有效的数值来修正 Mc。');
    }
});
function calculateBValue(maxCurvatureX) {
    return (Math.log(Math.E) / ((sumMagnitude / totalCount) - maxCurvatureX)).toFixed(2);
}
function updateItem6() {
    // 计算修正后的 maxCurvatureX 和 bvalue
    var correctedMaxCurvatureX = maxCurvatureX + correctionMcValue;
    var correctedBValue = calculateBValue(correctedMaxCurvatureX);

    var item6Content = ` 时间点: ${dataInfo.date} 初始Mc: ${dataInfo.maxCurvatureX.toFixed(2)} 初始bvalue: ${dataInfo.bvalue} 修正后Mc: ${correctedMaxCurvatureX.toFixed(2)} 修正后bvalue: ${correctedBValue} `;

    var item6Element = document.createElement('div');
    item6Element.classList.add('data-item');
    item6Element.textContent = item6Content;
    item6.appendChild(item6Element);
    // 在 JavaScript 中设置样式
    item6Element.style.marginBottom = '6px';
    item6Element.style.fontSize = '6px';
    // 更新 dataInfoIndex
    dataInfoIndex++;
}
console.log(dataArray)
var newDataArray = [];
// 遍历dataArray数组
for (var i = 0; i < dataArray.length; i++) {
    var currentData = dataArray[i];
    var isDuplicate = false;

    // 检查是否存在相同时间的数据
    for (var j = 0; j < newDataArray.length; j++) {
        if (currentData.date === newDataArray[j].date) {
            isDuplicate = true;
            newDataArray[j] = currentData; // 替换掉旧数据
            break;
        }
    }
    // 如果不存在相同时间的数据，将当前数据添加到新数组中
    if (!isDuplicate) {
        newDataArray.push(currentData);
    }
}
var ctx = null; 
var myChart = null;
function initializeChart() {
    ctx = document.getElementById("chartContainer2").getContext("2d");

    // 从 newDataArray 中获取数据
    var years = newDataArray.map(function(data) {
        return data.date;
    });

    var dataValues = newDataArray.map(function(data) {
        return data.bvalue;
    });

    if (myChart) {
        myChart.destroy();
    }

    myChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: years,
            datasets: [{
                label: 'b值随时间变化情况',
                data: dataValues,
                fill: false,
                borderColor: 'rgb(75, 192, 192)',
                tension: 0.1
            }]
        },
        options: {
            scales: {
                x: {
                    type: 'category',
                    title: {
                        display: true,
                        text: '时间'
                    }
                },
                y: {
                    title: {
                        display: true,
                        text: 'b值'
                    }
                }
            }
        }
    });
}

// 调用 initializeChart 函数来初始化图表
initializeChart();

console.log(newDataArray)

}




