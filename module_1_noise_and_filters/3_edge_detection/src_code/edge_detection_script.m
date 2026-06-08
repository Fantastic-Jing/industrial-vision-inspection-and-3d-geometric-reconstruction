%% 1.5 Edge Filters - MATLAB

clc; clear; close all;

% 1读取 Lenna 图像
I = imread('Lena.tif');
if size(I,3) == 3
    I_gray = rgb2gray(I); % 转为灰度
else
    I_gray = I;
end
I_gray = double(I_gray); % 转 double 便于滤波

% 定义 Sobel 和 Prewitt 核
sobel_x = [-1 0 1; -2 0 2; -1 0 1];
sobel_y = sobel_x';

prewitt_x = [-1 0 1; -1 0 1; -1 0 1];
prewitt_y = prewitt_x';

laplace = [0 -1 0; -1 4 -1; 0 -1 0]; % 常用 Laplacian 核

% 应用卷积滤波
I_sobelX = imfilter(I_gray, sobel_x, 'replicate');
I_sobelY = imfilter(I_gray, sobel_y, 'replicate');
I_prewittX = imfilter(I_gray, prewitt_x, 'replicate');
I_prewittY = imfilter(I_gray, prewitt_y, 'replicate');
I_laplace = imfilter(I_gray, laplace, 'replicate');
BW_sobel = edge(I_gray, 'sobel'); 
BW_prewitt = edge(I_gray, 'prewitt');

figure; imshow(uint8(I_gray)); title('Original Gray');
saveas(gcf, 'Original_Gray.jpg');

figure; imshow(uint8(I_sobelX)); title('Sobel X');
saveas(gcf, 'Sobel_X.jpg');

figure; imshow(uint8(I_sobelY)); title('Sobel Y');
saveas(gcf, 'Sobel_Y.jpg');

figure; imshow(uint8(I_prewittX)); title('Prewitt X');
saveas(gcf, 'Prewitt_X.jpg');

figure; imshow(uint8(I_prewittY)); title('Prewitt Y');
saveas(gcf, 'Prewitt_Y.jpg');

figure; imshow(uint8(I_laplace + 128)); title('Laplace (shifted)');
saveas(gcf, 'Laplace_shifted.jpg');

figure; imshow(BW_sobel); title('edge() Sobel');
saveas(gcf, 'edge_Sobel.jpg');

figure; imshow(BW_prewitt); title('edge() Prewitt');
saveas(gcf, 'edge_Prewitt.jpg');


