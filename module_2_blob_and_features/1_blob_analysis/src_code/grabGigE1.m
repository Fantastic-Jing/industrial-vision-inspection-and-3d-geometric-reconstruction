% A short program to acquire an image from a camera with GigE-interface
vid = videoinput('gige', 1, 'Mono8');   % connect to the camera
src = getselectedsource(vid);

% apeture = 4
src.ExposureTimeAbs = 10000;    % set exposure time in µs
src.GainFactor = 1;             % set gain factor (1..10)

preview(vid);                   % show live image
pause;                          % wait until key pressed


pic = getsnapshot(vid);         % acquire an image

closepreview(vid);

%%
pic = snapshot2;

fig1=figure(1);
fig1.Name='acquired image';
imshow(pic);                     % display acquired image
imwrite(pic, 'straight line.tif');  % save image

% fig2=figure(2);
% fig2.Name='Histogram of aquired image';
% imhist(pic)

delete(vid);                    % set camera free


