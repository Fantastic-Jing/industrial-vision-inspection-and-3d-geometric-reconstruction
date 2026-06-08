%%  cv_lab3_stereo_measurements.m
%
%	Version: 	1.2
%	Author:		Stephan Neser
%	Date:		22.01.2020
%               24.01.2023 Changed to webcam interface (FF)
%
%   Code snippets for stereo measurements with ZEDm
%
%   needs:  ZedAcquire.m
%           ZedInit.m
%			CalibrationParameters for ZEDm in variable stereoParams（ZEDm 的双目标定参数）
%
%   Instructions:
%
%   This script consists of 6 sections:
%   
%   (1) Camera Init     
%
%   (2) Acquire an image pair
%   
%   (3)  Select points in I1 and display their epipolar lines in I2
% 
%   (4)  Rectify an image pair (given stereo calibration) and display an anaglyph   
%
%   (5)  Triangulate point pair, images must be undistorted 
%
%   (6)  Create and display disparity map   
%
%   (7)  Reconstruct scene into a point cloud and display it   
% 本脚本包含 7 个部分： 
% (1) 初始化相机 
% (2) 采集一对图像 
% (3) 在 I1 中选点并在 I2 中显示对应的极线 
% (4) 对图像进行立体校正并显示红青立体图 
% (5) 三角测量（图像必须去畸变）
% (6) 生成视差图 
% (7) 重建 3D 点云并显示 %
%
%
%%  (1)     Camera Init

% Init device (if not yet initialized)
vid = ZedInit();

%% (2) Acquire an image pair from ZEDm and show as an anaglyph
% 采集一对左右图像 I1（左）和 I2（右）
[I1, I2] = ZedAcquire(vid);
figure,
% 显示红青立体图（左图红色通道，右图青色通道）
imshowpair(I1,I2,'ColorChannels','red-cyan');
%% (3)  Select points in I1 and display their epipolar lines in I2
% 在 I1 中选择点，并在 I2 中显示对应的极线
close all;
imshow(I1);
% 用户在 I1 中点击点（双击结束）
[x1, y1] = getpts();

% 根据基础矩阵计算极线
epiLines = epipolarLine(stereoParams.FundamentalMatrix,[x1 y1]);
close all;

% 再次显示红青立体图
imshowpair(I1,I2,'ColorChannels','red-cyan');
hold on;

% 绘制用户选择的点
% Plot Points
plot(x1,y1,'ro','MarkerSize',15);

% 计算极线在图像边界的交点
% Plot Epipolar Lines
lineEndpoints = lineToBorderPoints(epiLines,size(I1))

% 绘制极线
line(lineEndpoints(:,[1,3])',lineEndpoints(:,[2,4])');

%% (4)  Rectify an image pair (given stereo calibration) and display an anaglyph
% 使用 stereoParams 对图像进行立体校正 
% OutputView = full 表示输出完整视野
[I1r, I2r] = rectifyStereoImages(I1,I2,stereoParams,'OutputView','full');  % Try: OutputView: valid, full 

% 显示校正后的红青立体图
figure,
imshowpair(I1r,I2r,'ColorChannels','red-cyan');

% 转为灰度图，用于视差计算
I1rg = rgb2gray(I1r);   % Grayscale version of I1r
I2rg = rgb2gray(I2r);   % Grayscale version of I2r


%% (5)  Triangulate point pair, images must be undistorted
% When the stereo rig is calibrated, we can use extract the 3D coordinates 
% of object points or for measurement purposes. This works for every image
% pair captured with the camera, we do not need to refer to one of the 
% calibration images!

% 三角测量：从左右图像中恢复 3D 点 
% 图像必须先去畸变

% For triangulation we need undistorted images

% 去畸变左右图像
I1u = undistortImage(I1,stereoParams.CameraParameters1);
I2u = undistortImage(I2,stereoParams.CameraParameters2);

% Select points in I1u, double click for the last point
close all;

% 在左图中选择点
imshow(I1u);
[x1, y1] = getpts();

% Now select the corresponding points in I2u
% 在右图中选择对应点
imshow(I2u);
[x2, y2] = getpts();

% Triangulate the point pairs. This is where the reconstuction happens
% The function returns the 3D points in array p3
% 三角测量，返回 3D 点坐标 p3（单位：毫米）
p3 = triangulate([x1 y1],[x2 y2],stereoParams)

% To measure the length of an object, we calculate the euclidian distance between the first two points
% 计算前两个点之间的欧氏距离（测量物体长度）
norm(p3(1,:)-p3(2,:))

%% 5b: Show epipolar line in undistorted images
% 在去畸变图像中显示极线（用于验证校正效果）
close all;
imshow(I1u);
[x1, y1] = getpts();
epiLines = epipolarLine(stereoParams.FundamentalMatrix,[x1 y1]);
close all;
imshowpair(I1u,I2u,'ColorChannels','red-cyan');
hold on;

% Plot Points
% 绘制点
plot(x1,y1,'ro','MarkerSize',15);
% Plot Epipolar Lines
% 绘制极线
lineEndpoints = lineToBorderPoints(epiLines,size(I1))
line(lineEndpoints(:,[1,3])',lineEndpoints(:,[2,4])');




%% (6)  Create and display disparity map
% 生成视差图（使用半全局匹配 SGM）
 

% Compute the disparity map through semi-global matching. 
% The matching is highly dependent on the structure of the scene and the matching parameters.
% Try to estimate the disparity range by examination of your rectified images (try display as red-cyan anaglyph)
% Try to vary the uniqueness parameter and examine its effects 

% disparityRange：视差范围（需根据场景调整） 
% uniquenessThreshold：唯一性约束（越大越严格）
disparityRange = [0 128];
uniquenessThreshold = 32;

% 计算视差图
disparityMap = disparitySGM(I1rg,I2rg,'DisparityRange',disparityRange,'UniquenessThreshold',uniquenessThreshold);

% Display the disparity map. Set the display range to the same value as the disparity range.

% 显示视差图
figure
imshow(disparityMap,disparityRange)
title('Disparity Map')
colormap jet
colorbar

%% (7)  Reconstruct scene into a point cloud and display it
% 使用视差图重建 3D 场景
% Project the image points into 3D
% reconstructScene 将视差图转换为 3D 点云（单位：毫米）
xyzPoints = reconstructScene(disparityMap,stereoParams);

% Copy the points to a point cloud object. 
% Division by 1000 transfers from mm to meter to make scales better
% readable
% 创建点云对象（除以 1000 转换为米）
pc = pointCloud(xyzPoints./1000,'Color',I1r);

% Create a streaming point cloud viewer
% 创建 3D 点云查看器
figure,
player3D = pcplayer([-3, 3], [-3, 3], [0, 8], 'VerticalAxis', 'y', ...
    'VerticalAxisDir', 'down');

% Visualize the point cloud
% 显示点云
view(player3D, pc);


