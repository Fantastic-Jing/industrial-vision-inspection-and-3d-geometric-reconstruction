% A short program to acquire images from a camera with GigE-interface
% with noise calculation
clc
close all

vid = videoinput('gige', 1, 'Mono8');   % connect to the camera
src = getselectedsource(vid);

src.ExposureTimeAbs = 20000;    % set exposure time in µs
src.GainFactor = 1;             % set gain factor (1..10)

%preview(vid);                   % show live image
%pause;                          % wait until key pressed

pica = getsnapshot(vid);        % acquire an image 1
avgIntensity = mean(pica,'all');

%closepreview(vid);

fig1=figure(1);
fig1.Name='acquired image 1';
imshow(pica);                   % display acquired image 1

% grab another image and show the difference
picb = getsnapshot(vid);        % acquire another image 2


diffpic=int16(pica)-int16(picb); % calculate pixel-wise difference (signed)


fig2=figure(2);
fig2.Name='difference of two images (signed image in pseudocolors)';
imagesc(diffpic), colorbar;     % display the difference with scaled colors

fig3=figure(3);
fig3.Name='difference histogram';
imhist(int8(diffpic))

avgNoise=std2(diffpic)          % calculate the standard deviation of the image -> noise


delete(vid);                    % set camera free