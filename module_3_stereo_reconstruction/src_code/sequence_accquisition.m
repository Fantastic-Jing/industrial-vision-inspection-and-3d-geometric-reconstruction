%%  cv_lab3_sequence_acquisition.m
%
%	Version: 	1.1	
%	Author:		Stephan Neser
%	Date:		22.01.2020
%               24.01.2023 Changed to webcam interface (FF)
%
%   Sequence Acquisition for ZEDm
%   needs:  ZedAcquire.m
%           ZedInit.m
%
%   Use this script to acquire calibration sequences for ZEDm
%
%   Instructions:
%
%   This script consists of 4 sections:
%   
%   (1) Camera Init     
%   Inits the camera and creates the vid object needed for image
%   acquisition. Do not call this section, if the vid object already exists 
%   and the camera is already started!
%   
%   (2) Initialize Image Stack
%   Initializes the stack acquisition. It simply sets a base path and a
%   sequence number. Since the number is increased before writing the
%   images, the initial number mostly will be a zero, so the sequence will
%   start with image number 1. Please adjust the names and paths according
%   to your needs. The base path gives the directory where storage shall
%   happen. Leave this empty to work in your current working directory. The
%   routine will create two subdirs (Cam1 und Cam2) in this directory. This
%   is necessary, since Matlabs stereoCameraCalibrator wants the images         
%   in seperate directories. The base name gives the first part of the 
%   name. The default is "img". 
%   
%   (3) Acquire and check for checkerboard pattern
%   Acquires and image pair, checks for calibration patterns and displays
%   the images and the found pattern (if any).
%
%   (4) Add image to sequence
%   After a pair of images has acquired successfully, use this section to
%   store the image pair. The current image number is incremented 
%   automatically. After executing (1) and (2), use (3) and (4)
%   sequentially to acquire as much calibration images as needed.
%
%

%%  (1) Camera Init  (only, if not yet initialized!)
% 初始化 ZEDm 相机，返回视频对象 vid（如果已经初始化则不要重复执行）
vid = ZedInit();

%% (2)  Initialize image stack

% 当前图像编号初始化为 0（保存时会先 +1）
curImageNr = 0;
% 设置保存图像的主目录名称（可根据需要修改）
baseDir = 'test';
% 设置保存图像的基础文件名前缀
baseName = 'img';
% 在 baseDir 下创建 Cam01 和 Cam02 两个子目录，用于分别保存左右相机图像
mkdir(baseDir,'Cam01');
mkdir(baseDir,'Cam02');
% 构造左右相机图像的保存路径前缀（不含编号和扩展名）
basePath1 = baseDir+"/Cam01/"+baseName;
basePath2 = baseDir+"/Cam02/"+baseName;

%% (3) Acquire and check for checkerboard pattern

% 从 ZEDm 获取一对同步图像 I1（左）和 I2（右）
[I1, I2] = ZedAcquire(vid);

% 将左右图像以红青立体方式显示，便于快速检查
imshowpair(I1,I2,'ColorChannels','red-cyan');

% Detect checkerboard images on I0 and I1 and display them with detected
%  points on the targets
close all;

% Process I1
% -------- 处理左相机图像 I1 -------- 
% 在 I1 中检测棋盘格角点，返回角点坐标和棋盘格尺寸
[imgPts1,boardSize1] = detectCheckerboardPoints(I1);
% 显示左图
figure, 
imshow(I1);
hold on;
% 如果检测到角点，则用红色星号标记
if size(imgPts1,2) > 0
        plot(imgPts1(:,1),imgPts1(:,2),'r*','MarkerSize',10);
end
hold off;

% -------- 处理右相机图像 I2 -------- 
% 在 I2 中检测棋盘格角点
[imgPts2,boardSize1] = detectCheckerboardPoints(I2);
% 显示右图
figure,
imshow(I2);
hold on;
% 如果检测到角点，则用红色星号标记
if size(imgPts2,2) > 0
        plot(imgPts2(:,1),imgPts2(:,2),'r*','MarkerSize',10);
end
hold off;

%% (4)	Add current images to image stack

% 图像编号加 1（从 1 开始）
curImageNr = curImageNr+1;
% 构造左相机图像的完整文件名
name1 = sprintf('%s_Cam01_%i%s',basePath1,curImageNr,'.png');
% 构造右相机图像的完整文件名
name2 = sprintf('%s_Cam02_%i%s',basePath2,curImageNr,'.png');
% 保存左右图像到对应目录
imwrite(I1,name1);
imwrite(I2,name2);


%% Undistort this image

% 从 ZEDm 获取一对同步图像 I1（左）和 I2（右）
[measureSrc, tempImage] = ZedAcquire(vid);
figure,
imshow(measureSrc);
measure = undistortImage(measureSrc, cameraParams, 'OutputView', 'same');
figure,
imshow(measure);

%% extrinsic parameters 

squareSize = 12; % in millimeters
targetWorldPoints = generateCheckerboardPoints(boardSize, squareSize);
[targetImagePoints, boardSize] = detectCheckerboardPoints(measure);
[R, t] = extrinsics(targetImagePoints, targetWorldPoints, cameraParams);