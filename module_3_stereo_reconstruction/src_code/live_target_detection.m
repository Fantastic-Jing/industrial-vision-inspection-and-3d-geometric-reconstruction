%%  cv_lab3_live_target_detection.m
%
%	Version: 	1.1
%	Author:		Stephan Neser
%	Date:		22.01.2020
%               24.01.2023 Changed to webcam interface (FF)
%
%   Demo for live target detection
%
%   needs:  ZedAcquire.m

%% (1)	Initialize Camera (only, if not yet initialized!)

vid = ZedInit();


%% (2)	Display 50 frames and try to detect the target
close all;
fig1=figure(1);
fig1.Name='acquired image';% 设置窗口名称为“acquired image”
[I1, I2] = ZedAcquire(vid);

% 循环显示 50 帧图像，并在每一帧中尝试检测棋盘格
for i = 1:50
    [I1, I2] = ZedAcquire(vid);
    % 在左图中检测棋盘格角点
    [imagePoints,boardSize] = detectCheckerboardPoints(I1);
    hImage = imshow(I1);
    hold on;
    % 如果检测到角点，则用红色星号标记
    if size(imagePoints,2) > 0
        plot(imagePoints(:,1),imagePoints(:,2),'r*','MarkerSize',10);
    end
    hold off;
    drawnow;
    
end

%%	(3)	Close camera (only if you want cleanup after session!)
clear vid
