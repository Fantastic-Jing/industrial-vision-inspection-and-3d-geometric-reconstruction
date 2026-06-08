%% CV EIT Lab2 support script Harris-Corner-Detector and Hough-Transform
%
%   Stephan Neser 2019, FF 2024
%
%   Script for Hough transform and Harris corner detector
%
%   This script is organized in sections. Each section performs a well
%   defined task.
%   You can start a section by placing the cursor inside the section and
%   press Ctrl+Enter on Windows, Cmd+Enter on OSX
% 
%   To start your experiments load an image with the first section
%   
%   To experiment with the Harris corner detector, use the second section.
%   Please feel free to look up the other options of the corner detector in
%   the online help or to experiment with the other feature detectors of
%   the Computer Vision Systems Toolbox
%
%   To experiment with the Hough-Transform (HT) execute the Hough-Section first.
%   It will carry out all computations for the Hough-Transform.
%   The following sections depend on this and plot different results of the
%   HT. Please feel free to experiment with different parameter settings.


clear all;
close all;
%% Read image, convert to greyscale and rotate by angle gamma
%  Modify the path to load other images and experiment with them!
I = imread('pattern.tif');
%Convert image to graylevel, but only if it is a color image
if size(I,3) == 3 
    Ib = rgb2gray(I);
else 
    Ib = I;
end
%% Harris corner detector
% With this section you can apply the Harris corner detector to Ib
% and show its results

% detectHarrisFeatures(Ib)
% 对灰度图 Ib 运行 Harris 角点检测算法。
% MinQuality=0.15 表示丢掉最弱的 85% 角点，只保留质量 ≥ 15% 的点。
% 使用 9×9 的窗口来计算 Harris 响应。这个窗口越大，越能平滑噪声，但定位会变得更粗。
points = detectHarrisFeatures(Ib,'MinQuality', 0.15, 'FilterSize', 9);
% 输出 points 是一个 cornerPoints 对象，里面包含：
% 每个角点的位置 (x,y)
% 强度（metric）
% 比例、方向等额外信息

% Harris 会找到很多点，这里选出 最显著的 128 个角点
strongest = selectStrongest(points,128);  % Use this, if needed, to sort out weakt points
imshow(I);
title('Harris corner detector')
hold on;
plot(strongest);
plot(strongest.Location(:,1), strongest.Location(:,2), ...
    'ro', 'MarkerSize', 10, 'LineWidth', 2);



%% Hough-Transformation
% in this section we perform the hough transform
% always execute this section before attempting any plots in the 
% following sections!

% Parameter block
% Adjust this according to your needs

% nPeaks = 10, 只从 Hough 累加平面中取 10 个最强的“线的证据”。
% 
% fillGap = 10, 一条线如果中间断了 ≤10 像素，MATLAB 会自动“补齐”。
% 
% minLength = 1 ,提取的线段至少要有 1 像素长。（实际中设成 30 或更大，以避免虚假检测。）
% 
% threshold = 0.2
% 峰值阈值（相对最大峰）。小于 20% 的投票峰不算是真线。

nPeaks = 23;        % How many of the strongest peaks shall we extract?
fillGap = 500;        % Lentgh of gaps in pixels that will be filled during line extraction
minLength = 500;      % Minimum length a line must have to be extracted
threshold = 0.5;     % Minimum peak height relative to maximum peak to be accepted as a peak

% This are all functions needed for the hough transform
edgeImage     = edge(Ib,'sobel');          % Create edge image

% 图像中的每个边缘像素 (x, y) → 在 (θ, ρ) 上画一条正弦曲线。
% ρ = x cosθ + y sinθ

% 许多点位于同一条线 → 它们的曲线交于同一点 (θ₀, ρ₀)。交点的投票次数成为 Hough 累加器 H 中的一个峰。
% H：累加器矩阵
% θ = theta：扫描的角度数组
% ρ = rho：扫描的距离数组
[H,theta,rho] = hough(edgeImage);          % Perform Hough transform

% 峰就是直线的参数 (θ, ρ)。
% 返回 nPeaks 个最大投票点, 必须大于 threshold * max(H(:))
peaks         = houghpeaks(H,nPeaks,...    % extract the strongest peaks
                          'Threshold',threshold);

% 根据每个峰值给出的 (θ, ρ)，在 edgeImage 上找哪些像素属于这条直线
% 分析像素连接性，把它们组合成一个或多个线段
% 它输出一个结构体数组 lines，每条线段有：
% point1（起点坐标）
% point2（终点坐标）
% theta
% rho
lines         = houghlines(edgeImage,... % find line segments on the found lines
                           theta,...
                           rho,...
                           peaks,...
                           'FillGap',fillGap,...
                           'MinLength',minLength);


%% Plot original image and edge image
figure, 
imshowpair(Ib, edgeImage,'montage');
title('Hough-Transformation');
%% Plot Hough-Buffer with strongest peaks
figure,

% 显示 Hough 累加器矩阵
imshow(imadjust(H/max(max(H))),'XData',theta,'YData',rho,'InitialMagnification','fit');
title('Hough Buffer');
xlabel('\theta'), ylabel('\rho');
axis on, axis normal, hold on;
hold on
% 标记 Hough 峰值
plot(theta(peaks(:,2)),rho(peaks(:,1)),'s','color','red');

%% Show hough buffer in 3D
figure, mesh(H);
title('Hough Buffer 3D Plot');
xlabel('\theta'), ylabel('\rho');

%% Plot detected line segments
figure, imshow(Ib), hold on
max_len = 0;
for k = 1:length(lines)
   % Extract start and end point of line seqment k

   % lines → 前面 houghlines 得到的结构体数组
   % lines(k).point1 → 第 k 条线的起点 [x1, y1]
   % lines(k).point2 → 第 k 条线的终点 [x2, y2]
   % xy → 2×2 矩阵，第一行为起点，第二行为终点
   xy = [lines(k).point1; lines(k).point2];
    
   % Plot it
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

   % Plot beginnings and ends of lines
   plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
   plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

end

%% ==== Method to get chessboard corners WITHOUT houghlines ====
% Using intersection of two lines defined by Hough peaks
% This method computes a chessboard corner by intersecting two lines
% obtained from the strongest Hough peaks. 
% Instead of relying on houghlines(), we directly use the analytical
% line equations from the Hough transform.

% use the first two dominant Hough peaks
peak1 = 1;
peak2 = 2;

% Extract (rho, theta) values from the Hough accumulator
% peaks stores indices into H, where:
%   peaks(k,1) → row index in rho (distance)
%   peaks(k,2) → column index in theta (angle)
rho1 = rho(peaks(peak1,1));
theta1 = deg2rad(theta(peaks(peak1,2)));

rho2 = rho(peaks(peak2,1));
theta2 = deg2rad(theta(peaks(peak2,2)));

% Convert each Hough line from polar form
%       rho = x*cos(theta) + y*sin(theta)
% to the linear form:
%       a*x + b*y = rho
% where a = cos(theta) and b = sin(theta)
a1 = cos(theta1); 
b1 = sin(theta1);

a2 = cos(theta2);
b2 = sin(theta2);

% Form the linear for the intersection:
% 
%   [a1  b1] [x] = [rho1]
%   [a2  b2] [y]   [rho2]
%
% Solving this 2×2 system yields the (x, y) coordinate where the
% two Hough lines intersect — which corresponds to one chessboard corner.
A = [a1 b1;
     a2 b2];
B = [rho1; rho2];

% Solve the matrix using left division (A \ B)
corner_xy = A \ B;

% Display the result
figure; 
imshow(Ib); 
title('Corner from Hough Peak Intersection');
hold on;

plot(corner_xy(1), corner_xy(2), '+', 'Color', 'g', 'MarkerSize', 6, 'LineWidth', 1);
plot(corner_xy(1), corner_xy(2), 'ro', ...
     'MarkerSize', 10, 'LineWidth', 2);


%% assess the precision of the Harris-Corner 

hough_corner_x = corner_xy(1);
hough_corner_y = corner_xy(2);

select_corner = 115;
harris_corner_x = strongest.Location(select_corner,1);
harris_corner_y = strongest.Location(select_corner,2);

distances = sqrt((harris_corner_x-hough_corner_x).^2 + (harris_corner_y-hough_corner_y).^2);
distances;

figure; 
imshow(Ib); 
title('Corner from Hough and Harris');
hold on;
plot(hough_corner_x, hough_corner_y, '+', 'Color', 'g', 'MarkerSize', 6, 'LineWidth', 1);
plot(harris_corner_x, harris_corner_y, '+', 'Color', 'r', 'MarkerSize', 6, 'LineWidth', 1);

