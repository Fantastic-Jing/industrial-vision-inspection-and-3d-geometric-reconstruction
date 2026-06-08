%% =======================
%  Coin Detection & Analysis with Type Classification
%  Experiment 2.2

clc;
clear;
close all;

%% Read an image and display it
I = im2gray(255 - imread('Reflect Light Coins.tif'));
% I = im2gray(255-imread('Transmit Light Coins.tif'));
figure(1)
imshow(I), title('Inverted Gray Image');

figure(2)
imhist(I), title('Inverted Gray Hist');
I2 = I;

%% close the coin
% I2 = imclose(I,strel('disk',6));
% figure(3)
% imshow(I2), title('After close');


%% Search the optimum threshold, assuming a bimodal histogram using Otsu's method
%  and binarize the image

% graythresh → MATLAB 内置函数，使用 Otsu 方法 自动计算阈值。
% 输出 level 是归一化的灰度值，范围在 0~1。
level = graythresh(I2);

% imbinarize → 根据给定阈值将灰度图像转为二值图像
bw = imbinarize(I2,level);

figure(4)
imshow(bw), title('Binarized Image');

%% Perform labeling in 8-connectivity and show number of objects

% bwconncomp → 查找二值图像中的连通区域（connected components）。
% 每个像素的 8 个邻居（上下左右及对角线）都算作连通
% 输出 cc 是一个object，包含：
% cc.PixelIdxList → 每个连通区域的像素索引列表
% cc.NumObjects → 连通区域的数量
% cc.ImageSize → 图像大小
cc = bwconncomp(bw, 8);

% 从 cc 结构体中读取 NumObjects
% 表示图像中 前景连通区域的总数
NumberOfObjects = cc.NumObjects;

%% Show all pixels of a specific object

% 选择第 2 个连通区域
n = 2; 

% 创建一个与bw大小相同的矩阵，所有元素为 false
area = false(size(bw)); % Create an matrix filled with false in the size of the image!      

% cc.PixelIdxList{n} → 第 n 个对象的所有像素索引
% 将这些像素在 area51 中置为 true
% 这样 area51 只保留第 n 个对象，其余像素为 false（背景）
area(cc.PixelIdxList{n}) = true;      % Replace the pixels of our object with true

figure(3), imshow(area), title('Area '+ string(n));         % and show it

%% Create a label image and display it

%每个连通区域会被分配一个 唯一整数标签（1,2,3,...）
labeled = labelmatrix(cc);

% label2rgb → 将标签矩阵转换为 彩色图像，便于可视化不同对象
% labeled → 标签矩阵
% @jet → 颜色映射方案（不同标签用 jet 色图显示）
% 'w' → 背景像素显示为白色
% 'shuffle' → 随机分配颜色给不同标签，避免相邻标签颜色重复
% 输出 RGB_label 是一个 RGB 彩色图像，每个对象用不同颜色显示
%whos labeled
RGB_label = label2rgb(labeled, @jet, 'w', 'shuffle');
figure(4), imshow(RGB_label), title('label image');

%% Perform feature extraction: find the smallest object and display it
% Refer to online help of regionprops for more features (there are many!)
% 说明：这一段代码用于 特征提取，找到图像中 面积最小的对象 并显示。
% regionprops 可以提取多种对象特征，如面积、周长、质心、边界框等。

%regionprops → 提取每个连通区域的属性
%'basic' → 提取基本属性：Area面积, Centroid质心, BoundingBox最小外接矩形 等
%输出 coinObjects 是一个结构体数组，每个元素对应一个对象
coinObjects = regionprops(cc, 'basic');       % feature extraction with basic features

% [coinObjects.Area] → 提取所有对象的 Area（像素数量）
% 生成一个行向量 areas，存储每个对象的面积
areas = [coinObjects.Area];                   % get the areas from the features

figure(5)
histogram(areas,6)
xlabel('Area Size')
ylabel('Number')
title('Areas Hist');

%% Plot centroids

% myObjects → 前面用 regionprops(cc,'basic') 得到的对象结构体数组
% myObjects.Centroid → 每个对象的质心坐标 (x, y)
% cat(1, ...) → 沿行方向合并所有质心，生成一个 N×2 矩阵
% 每行对应一个对象的质心
% 第一列：x 坐标
% 第二列：y 坐标
centroids = cat(1,coinObjects.Centroid);

figure(6), 
imshow(I);  % Display image
hold on;

% centroids(:,1) → 所有质心的 x 坐标
% centroids(:,2) → 所有质心的 y 坐标
% '+r' → 用红色加号标记
% 'MarkerSize',6 → 设置标记大小为 6
plot(centroids(:,1),centroids(:,2),'+r','MarkerSize',6);
title('Objects with Centroids');

%% Radius

% coinObjectsBoundingBox 返回 [x, y, width, height]，长度为 4。
% [coinObjects.BoundingBox] 会把所有硬币的 BoundingBox 拼成一个长向量，比如 4×N（N 为硬币数量）。
% reshape(..., 4, []) 把长向量重新排列为 4 行、若干列，列数自动计算。
% 每一列对应一个硬币的 [x; y; width; height]。

bboxes = reshape([coinObjects.BoundingBox], 4, [])';

% bboxes(:,3:4) 取每行的第 3 列和第 4 列，也就是 width 和 height。
radii_bbox = min(bboxes(:,3:4),[],2)/2;  % width/height 中取最小的一半

figure(7),

histogram(radii_bbox,6),
title('Radius Hist');
