% *************************************************************
% author:   Gene Cheung                                      **
% date:     01/19/2019                                       **
% modified: 02/23/2020                                       **
% purpose:  denoise block by spectral filtering              **
% *************************************************************

function [newB] = process_block(inputB)

%% 1. define DCT (type II) basis functions *********
[bSize, bSize2] = size(inputB);         
epsilon = 0.0001;

nr = 0:(bSize-1);                       % define orthonomal basis  (eecs6354)
nc = 0:(bSize-1);
dcts = ones(1,bSize) * sqrt(2/bSize);   % normalization factors for DCT-II
dcts(1) = sqrt(1/bSize);
for i=1:bSize,
    for j=1:bSize2,
        % use convention of row-by-row
        temp = cos(pi/bSize*(nr+1/2)*(i-1))' * cos(pi/bSize*(nc+1/2)*(j-1));
        temp = temp * dcts(i) * dcts(j);
        ind = (i-1)*bSize + j;
        for k=1:bSize,
            Phi(ind,(k-1)*bSize+1:(k)*bSize) = temp(k,:);
        end
    end
end
PhiT = Phi';


%% 2. process block in vectorized form *********
% 2.1 vectorize and transform inputB ********
for i=1:bSize,
    vecB((i-1)*bSize+1:(i)*bSize) = inputB(i,:);
end

% 2.2 design linear operator for vecB ********
Lambda = ones(bSize*bSize,1);
bw = 3;                             % Assumed signal BW  (eecs6354)
for i=1:bSize,
    for j=1:bSize,
        if i > bw || j > bw,        % Design spectral filter  (eecs6354)
            Lambda((i-1)*bSize+j) = 0;  % example filter 1 ******
            %Lambda((i-1)*bSize+j) = (bSize-i)/bSize * (bSize-j)/bSize;  % example filter 2 ******
        end
    end
end
Lambda = diag(Lambda);
A = PhiT*Lambda*Phi;

% 2.3 apply operator on vecB ********
y = A*vecB';


%% 3. output solution in block form *********
for i=1:bSize,
    newB(i,:) = y((i-1)*bSize+1:(i)*bSize);
end
