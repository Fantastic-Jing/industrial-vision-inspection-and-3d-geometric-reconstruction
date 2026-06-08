%% Acquire an image from a camera with GigE-interface and calculate average intensity
%imaqreset;
close all;

vid = videoinput('gige', 1, 'Mono8');   % connect to the camera
src = getselectedsource(vid);

src.ExposureTimeAbs = 10000;    % set exposure time in µs
src.GainFactor = 1;             % set gain factor (1..10)

preview(vid);                   % show live image
pause;                          % wait until key pressed

pic = getsnapshot(vid);         % acquire an image

closepreview(vid);

fig1=figure(1);
fig1.Name='acquired image';
%imshow(pic);                     % display acquired image
averageGW=mean(pic, 'all')       % calculate mean intensity
%imwrite(pic, 'picture01.tif');  % save image

%% 1.4 Noise measurements ..
% b) relative noise level n(t)/B(t) over t
tic
numpics=10; % number of pictures to acquire
t0=5000;    % exposure time for average intensity 30
t1=35000;   % exposure time for average intensity 220
dt=(t1-t0)/(numpics-1);

x=zeros(numpics,1);         % Create an array for the exposure times ..
average=zeros(numpics,1);   % .. average intensity ..
noise=zeros(numpics,1);     % .. and the noise of each picture.
fig2=figure(2);
fig2.Name='increase exposure time';
for i=1:numpics

    x(i)=t0+(i-1)*dt;
    src.ExposureTimeAbs=x(i);
    %dumppic = getsnapshot(vid);         % grab 1st image
    %dumppic = getsnapshot(vid);         % grab 1st image
    %pause(0.2);
 
    pic = getsnapshot(vid);             % grab 1st image
    imshow(pic);
    average(i)=mean(pic, 'all');        % calculate mean intensity
    pic2 = getsnapshot(vid);            % grab 2nd image
    pic2 = double(pic2) - double(pic);  % calculate difference 
    noise(i)=std(double(reshape(pic2,[],1))); % calculate noise

end

figure(3); plot(average);
figure(4); plot(noise);
fig5=figure(5);
fig5.Name='n-t relative noise level with increased exposure time';
plot(x, noise./average), xlabel('exposure time in µs');
toc 

%% c) relative noise level over gain

numpics=10;     % number of pictures to acquire (maximum 10!)
tm=t1/220*128;  % Calculate exposure time for gray value 128

fig6=figure(6);
fig6.Name='increase gain';
src.ExposureTimeAbs=t1/(numpics+1); 
for i=1:numpics
    src.ExposureTimeAbs=tm/i;       % calculate and set exposure time
    src.GainFactor = i;             % set gain factor (1..10)
    x(i)=i;
    pic = getsnapshot(vid);         % grab 1st image
    imshow(pic);
    average(i)=mean(pic, 'all');    % calculate mean intensity
    pic2 = getsnapshot(vid);        % grab 2nd image
    pic2 = double(pic2) - double(pic);          % calculate difference 
    noise(i)=std(double(reshape(pic2,[],1)));   % calculate noise
end

fig7=figure(7);
fig7.Name='relative noise level with increased gain and reduced exposure time';
plot(x, noise./average), xlabel('gain factor');

%%
delete(vid);                    % set camera free