%%  ZedAcquire.m
%
%	Version: 	1.1
%	Author:		Stephan Neser
%	Date:		22.01.2020
%               24.01.2023 Changed to webcam interface (FF)
%
%% Acquire a stereo image pair from the ZEDm camera.
% The function gets the video object as an parameter an returns
% the two acquired images
%
function [I1,I2] = ZedAcquire(vid)
    I = snapshot(vid);
    w = size(I,2)/2;
    h = size(I,1);
    I1 = I(:,1:w,1:3);
    I2 = I(:,w+1:2*w,1:3);
end

