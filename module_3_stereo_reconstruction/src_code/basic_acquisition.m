%%  cv_lab3_basic_acquisition.m
%
%	Version: 	1.1
%	Author:		Stephan Neser
%	Date:		22.01.2020
%               24.01.2023 Changed to webcam interface (FF)
%
%   needs:  ZedAcquire.m
%           ZedInit.m
%         

%clear all;close all;clc;

%% 	Basic Image Acquisition Cycle for ZEDm
%
% (1)	Initialization of the video stream. Call this only once per session.
% 		If you want to start the script as a whole and not in sections, then
% 		stop and clear vid at the end of your script.

vid = ZedInit();


%% (2)	Acquire an image pair and copy it to variables I1 and I2
close all;
[I1, I2] = ZedAcquire(vid);
imshowpair(I1,I2,'ColorChannels','red-cyan');

%% (3)	Clear vid
% 		Do this at the end of your script, to release camera for next start
clear vid

