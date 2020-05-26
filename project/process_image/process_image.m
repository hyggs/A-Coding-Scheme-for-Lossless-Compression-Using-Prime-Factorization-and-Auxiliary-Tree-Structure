% *************************************************************
% author:   Gene Cheung                                      **
% date:     01/19/2019                                       **
% modified: 02/23/2020                                       **
% purpose:  process image block-by-block                     **
% *************************************************************

sigma = 0.1;                        % noise variance  (eecs6354)
bSize = 10;                         % block size

%imGr = imread('lena_bw.png'); 
%imGr = imread('peppers_bw.png'); 
imGr = imread('barbara_bw.png');       % grab ground truth image:  (eecs6354) 
                                    % baboon_bw.png, lena_bw.png,
                                    % peppers_bw.png, barbara.png

imGr = double(imGr)/255;            % work with normalized floating point numbers
[imHeight, imWidth] = size(imGr); 
bCol = floor(imWidth/bSize);        % num of blocks in columns and rows
bRow = floor(imHeight/bSize);
imGr = imGr(1:bRow*bSize,1:bCol*bSize);     % use only image that are integer multiples of blocks

figure;
imshow(imGr); 

imNoisy = imGr + sigma*randn(bRow*bSize, bCol*bSize); 
figure;                             % image with added Gaussian noise
imshow(imNoisy);

imNew = zeros(bRow*bSize, bCol*bSize);
% block-by-block processing ******
for Bi=1:bRow,
    for Bj=1:bCol,
     
        % 1. define block  
        bNoisy = imNoisy((Bi-1)*bSize+1:(Bi)*bSize, (Bj-1)*bSize+1:(Bj)*bSize);
        
        % 2. process defined block        
        [newB] = process_block(bNoisy);
        
        % 3. copy new block to new image
        imNew((Bi-1)*bSize+1:(Bi)*bSize, (Bj-1)*bSize+1:(Bj)*bSize) = newB;
        
    end
end

% compute MSE ******
imDiff = abs(imGr - imNoisy);
mse0 = sum(sum(imDiff)) / (bRow*bCol*bSize*bSize);
imDiff = abs(imGr - imNew);
mse1 = sum(sum(imDiff)) / (bRow*bCol*bSize*bSize);

% output image ******
figure;
imshow(imNew);