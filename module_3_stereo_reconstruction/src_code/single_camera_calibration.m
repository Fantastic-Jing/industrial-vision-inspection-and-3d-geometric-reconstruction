%%  cv_lab3_single_camera_calibration.m
%
%	Version: 	1.1	
%	Author:		Stephan Neser
%	Date:		22.01.2020
%               24.01.2023 Changed to webcam interface (FF)
%
% 	Code Snippets for Single Camera Calibration Measurements
%
%	needs: ZedAcquire.m
%		   Calibration parameters in variable cameraParameters	
%			
%   This script consists of 4 sections:
%   
%   (1) Camera Init  (just for convenience)
%
%   (2) Acquire an image and extract calibration target (just for convenience)
%   
%   (3) Undistort an image
% 
%   (4) Measure metric dimensions with a calibrated camera
%

%clear all;close all;clc;
%% (1)	Init Camera (if not yet started)

vid = ZedInit();


%% (2)	Acquire an image and extract the calibration target

[I1, I2] = ZedAcquire(vid);

close all;
% I1
[imgPts1,boardSize1] = detectCheckerboardPoints(I1);
[imgPts2,boardSize2] = detectCheckerboardPoints(I2);
figure,
imshowpair(I1,I2,'Montage');
hold on;
% Markers 1
if size(imgPts1,2) > 0
        plot(imgPts1(:,1),imgPts1(:,2),'ro','MarkerSize',5);
end

% Markers 2
if size(imgPts2,2) > 0
        plot(imgPts2(:,1)+size(I1,2),imgPts2(:,2),'go','MarkerSize',5);
end

%% (3)	Undistort image
% This assumes that Cam1 has been calibrated and the camera parameters are 
% stored in cameraParams!
[I1, I2] = ZedAcquire(vid);
I1d = undistortImage(I1,cameraParams);S
imshowpair(I1,I1d,'montage');

%% (4)	Measure metric dimensions with the calibrated camera
% This assumes that Cam1 has been calibrated and the camera parameters are 
% stored in cameraParams!
%
% Please note, that the points to be measured must be located in the plane defined
% by the calibration target for valid results!

% Acquire image, undistort and display it
% The image should have a calibration target in it. This calibration target
% defines the target plane in which our measurement will occur.
[I1, I2] = ZedAcquire(vid);
[I1d, newOrigin] = undistortImage(I1,cameraParams,'OutputView','same');
figure()
imshow(I1d);

% Now mark two points on the target with the mouse (first with a single left click, second with a double click).
% Select two points on the boarder of the checkerboard. Since those are no
% part of the estimation of the extrinsic parameters, we have an
% independent measurement.
[x, y] = getpts();
imagePoints = [x y]';

% Detect the checkerboard.
[targetImagePoints, boardSize] = detectCheckerboardPoints(I1d);

% Calculate world points for this board
squareSize = 12;  % in mm, for boards used in lab
targetWorldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Adjust the imagePoints so that they are expressed in the coordinate system
% used in the original image, before it was undistorted.  This adjustment
% makes it compatible with the cameraParameters object computed for the original image.
imagePointsOld = imagePoints;
%imagePoints = imagePoints + newOrigin; % adds newOrigin to every row of imagePoints
% Compute rotation and translation of the camera.
[R, t] = extrinsics(targetImagePoints, targetWorldPoints, cameraParams);

% Transfer the image points to world points
% We get only Xw and Yw, since our measurment plane equals Zw=0!
worldPoints = pointsToWorld(cameraParams, R, t, [x y])
distance = norm(worldPoints(1,:)-worldPoints(2,:))

