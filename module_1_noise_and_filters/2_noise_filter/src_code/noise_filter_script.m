%% Task d) Noise estimation and binomial filtering

% Open fig format file
fig1 = open('1-4-a.fig');
fig2 = open('1-4-b.fig');

% Read image from fig
h1 = findobj(fig1,'Type','image');  
h2 = findobj(fig2,'Type','image');

% get pixels data
I1 = double(get(h1,'CData'));
I2 = double(get(h2,'CData'));

% Caculate noise 
NoiseImage = I1 - I2;

% Transfer as linear array
NoiseArray = NoiseImage(:);

% Calculate diviation of NoiseArray 
n_original = std(NoiseArray);

%   num2str(n_original)：把数值 n_original 转成字符串，才能和文字一起显示。
%   'Original noise amplitude: '：文字说明
%   disp(...)：显示输出
disp(['Original noise amplitude: ', num2str(n_original)]);

%  binomial filters 
B3 = [1 2 1; 2 4 2; 1 2 1]/16;
B5 = [1 4 6 4 1; 4 16 24 16 4; 6 24 36 24 6; 4 16 24 16 4; 1 4 6 4 1]/256;
B7 = [1 6 15 20 15 6 1;
      6 36 90 120 90 36 6;
      15 90 225 300 225 90 15;
      20 120 300 400 300 120 20;
      15 90 225 300 225 90 15;
      6 36 90 120 90 36 6;
      1 6 15 20 15 6 1]/4096;

%   卷积到图像边缘时
%   'replicate' 用边缘像素扩展（最常用）
%   'symmetric' 镜像补边
%   'circular' 像拼乐高一样循环
%   'same' 输出尺寸不变（默认），否则 'full' 会变大

% 对两张图像分别进行滤波
I1_f3 = imfilter(I1, B3, 'replicate');
I1_f5 = imfilter(I1, B5, 'replicate');
I1_f7 = imfilter(I1, B7, 'replicate');
I1_md = medfilt2(I1, [3 3]);


I2_f3 = imfilter(I2, B3, 'replicate');
I2_f5 = imfilter(I2, B5, 'replicate');
I2_f7 = imfilter(I2, B7, 'replicate');
I2_md = medfilt2(I2, [3 3]);

% 滤波后计算噪声
Noise_f3 = I1_f3 - I2_f3;
Noise_f5 = I1_f5 - I2_f5;
Noise_f7 = I1_f7 - I2_f7;
Noise_md = I1_md - I2_md;

n_f3 = std(Noise_f3(:));
n_f5 = std(Noise_f5(:));
n_f7 = std(Noise_f7(:));
n_md = std2(Noise_md); % std2() => std(matrix(:))

disp(['Noise after 3x3 binomial filter: ', num2str(n_f3)]);
disp(['Noise after 5x5 binomial filter: ', num2str(n_f5)]);
disp(['Noise after 7x7 binomial filter: ', num2str(n_f7)]);
disp(['Noise after 3x3 median filter: ', num2str(n_md)]);

% 显示原图和滤波结果
figure;
subplot(2,5,1); imshow(I1,[]); title('Original I1');
xlim([300 400]);   % 只显示 x 在 1~2
ylim([300 400]);   % 只显示 y 在 0~1
subplot(2,5,2); imshow(I1_f3,[]); title('I1 binomial 3x3');
xlim([300 400]);   % 只显示 x 在 1~2
ylim([300 400]);   % 只显示 y 在 0~1
subplot(2,5,3); imshow(I1_f5,[]); title('I1 binomial 5x5');
xlim([300 400]);   % 只显示 x 在 1~2
ylim([300 400]);   % 只显示 y 在 0~1
subplot(2,5,4); imshow(I1_f7,[]); title('I1 binomial 7x7');
xlim([300 400]);   % 只显示 x 在 1~2
ylim([300 400]);   % 只显示 y 在 0~1
subplot(2,5,5); imshow(I2_md,[]); title('I1 median 3x3');
xlim([300 400]);   % 只显示 x 在 1~2
ylim([300 400]);   % 只显示 y 在 0~1

subplot(2,5,6); imshow(I2,[]); title('Original I2');
subplot(2,5,7); imshow(I2_f3,[]); title('I2 binomial 3x3');
subplot(2,5,8); imshow(I2_f5,[]); title('I2 binomial 5x5');
subplot(2,5,9); imshow(I2_f7,[]); title('I2 binomial 7x7');
subplot(2,5,10); imshow(I2_md,[]); title('I2 median 3x3');

%{
figure
subplot(1,2,1); imshow(I1,[]); title('Original I1');
subplot(1,2,2); imshow(I2,[]); title('Original I2');

figure
subplot(1,2,1);  imshow(I1_f3,[]); title('I1 3x3');
subplot(1,2,2);  imshow(I2_f3,[]); title('I2 3x3');

figure
subplot(1,2,1);  imshow(I1_f5,[]); title('I1 5x5');
subplot(1,2,2);  imshow(I1_f5,[]); title('I2 5x5');

figure
subplot(1,2,1);  imshow(I1_f7,[]); title('I1 7x7');
subplot(1,2,2);  imshow(I1_f7,[]); title('I2 7x7');

%}

% 可选：绘制噪声直方图
figure;
subplot(2,3,1); histogram(NoiseArray,50); title('Original Noise');
subplot(2,3,2); histogram(Noise_f3(:),50); title('3x3 binomial Filtered Noise');
subplot(2,3,4); histogram(Noise_f5(:),50); title('5x5 binomial Filtered Noise');
subplot(2,3,5); histogram(Noise_f7(:),50); title('7x7 binomial Filtered Noise');
subplot(2,3,3); histogram(Noise_md(:),50); title('3x3 median Filtered Noise');

