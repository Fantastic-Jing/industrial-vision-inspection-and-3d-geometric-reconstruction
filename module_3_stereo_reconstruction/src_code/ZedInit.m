%%  ZedInit.m
%
%	Version: 	1.1	
%	Author:		Stephan Neser
%	Date:		22.01.2020
%               24.01.2023 Changed to webcam interface (FF)
%
%% Acquire a stereo image pair from the ZEDm camera.
%  The function gets the video object as an parameter an returns
%  the two acquired images
%
function vid = ZedInit()
% Connect to ZED-M camera
vid = webcam('ZED');
% Set video resolution
vid.Resolution = vid.AvailableResolutions{1};
% Get image size
%[height, width, channels] = size(snapshot(vid));
% Wait a second (or two) to allow camera to stabilize 
pause(1)
