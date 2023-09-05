clear all;
clc;
clear all;


%--------1
A=readmatrix("E:\研究生阶段文件\1.txt");
%测量值
x11=A(:,1);
y11=A(:,2);
y12=y11/10;
 %预测值   
xA1=A(:,1);
yA1=A(:,3);
yA2=yA1/10;
%E
figure (1);
hold on;
plot(x11,y12,'o','MarkerEdgeColor','b','MarkerSize',2);hold on;

xlabel('E','FontSize',15, 'FontWeight', 'Bold');
%N
figure (2);
x11=A(:,1);
plot(x11,y12,'o','MarkerEdgeColor','b','MarkerSize',2);hold on;

xlabel('N','FontSize',15, 'FontWeight', 'Bold');
%H
figure (3);
x11=A(:,1);
y11=A(:,10);
y12=y11/10;  
xA1=A(:,1);
yA1=A(:,11);
yA2=yA1/10;
hold on;
plot(x11,y12,'o','MarkerEdgeColor','b','MarkerSize',2);hold on;

xlabel('H','FontSize',15, 'FontWeight', 'Bold');