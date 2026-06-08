clear all;
close all;

%% Read image, convert to greyscale and rotate by angle gamma
%  Modify the path to load other images and experiment with them!
I = imread('square.tif');
% I = imread('StraightLine_45d.jpg');
%Convert image to graylevel, but only if it is a color image
if size(I,3) == 3 
    Ib = rgb2gray(I);
else 
    Ib = I;
end

 % gamma = 30;
 % Rotate angle gamma
 % Ib = imrotate(Ib,gamma);

%% Harris corner detector
% 对灰度图 Ib 运行 Harris 角点检测算法。
points = detectHarrisFeatures(Ib,'MinQuality', 0.15, 'FilterSize', 9);
% 输出 points 是一个 cornerPoints 对象

% Harris 会找到很多点，这里选出 最显著的 2 个角点
strongest = selectStrongest(points,120);  % Use this, if needed, to sort out weakt points
imshow(I);
hold on;
plot(strongest);

%% pre process
% 开运算 → 去掉局部亮点噪声（结构噪声）
Ib = imopen(Ib,strel('diamond',3));

% 高斯滤波 → 去掉纹理、高频噪声（像素级噪声）
Ib = imfilter(Ib,fspecial('gaussian',[10 10],2),'replicate');

%% Hough-Transformation
nPeaks = 4;        % How many of the strongest peaks shall we extract?
fillGap = 30;        % Lentgh of gaps in pixels that will be filled during line extraction
minLength = 200;      % Minimum length a line must have to be extracted
threshold = 0.2;     % Minimum peak height relative to maximum peak to be accepted as a peak

% Create edge image
edgeImage     = edge(Ib,'sobel');

% Perform Hough transform
[H,theta,rho] = hough(edgeImage);          

% 返回 nPeaks 个最大投票点
peaks         = houghpeaks(H,nPeaks,...    % extract the strongest peaks
                          'Threshold',threshold);

% 根据每个峰值给出的 (θ, ρ)，在 edgeImage 上找哪些像素属于这条直线
% 分析像素连接性，把它们组合成一个或多个线段
lines         = houghlines(edgeImage,... % find line segments on the found lines
                           theta,...
                           rho,...
                           peaks,...
                           'FillGap',fillGap,...
                           'MinLength',minLength);
% 输出一个结构体数组 lines
% Plot original image and edge image
figure, 
imshowpair(Ib, edgeImage,'montage');

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
