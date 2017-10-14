%main.m
img=imread('..\data\butterfly.jpg');
img=double(img);%converting into double format
img=img/255;
img=rgb2gray(img);%converting the RGB colorspace into grayscale
% h,w - dimensions of image,
% n - number of levels in scale space
n=15; %max number of iteration
[h,w]=size(img);%stroing the dimension of the image
scale_space = zeros(h,w,n);
% [cim, r, c]=harris(img,1,1000,1,1);
sigma=2;%defining the initial scale value
h = waitbar(0,'Finding filter responses in 15 iterations');
k=2^(1/4);
for i=1:n
	if i>1
		sigma=sigma*k;
	end
	sigma;
	filter  = createFilter(sigma);
	scale_space(:,:,i)=imfilter(img, filter{1}).^2;%applying same filter 
	waitbar(i/n,h,sprintf('%d% / %d filters generated',i,n))%waitbar, random stuff
end
close(h);
cim=scale_space(:,:,1);
sze = 2*3+1;                   % Size of mask.
mx = ordfilt2(cim,sze^2,ones(sze)); % Grey-scale dilate.
size(mx)
cim = (cim==mx)&(cim>0.001);       % Find maxima.
[r,c] = find(cim);                  % Find row,col coords.
show_all_circles(img, c, r, 4*1)

imshow(mx);
