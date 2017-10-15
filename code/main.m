%main.m
%CONVERT THIS INTO A INPUT FUNCTION WHICH TAKES N AND IMAGE
img=imread('..\data\butterfly.jpg');
img=rgb2gray(img);%converting the RGB colorspace into grayscale
img=double(img);%converting into double format
img=img/255;

% imshow(img);
% h,w - dimensions of image,
% n - number of levels in scale space
n=15; %max number of iteration
[h,w]=size(img);%stroing the dimension of the image
scale_space = zeros(h,w,n);
Scale_Space = zeros(h, w, n);
% [cim, r, c]=harris(img,1,1000,1,1);
Sigma=2;%defining the initial scale value
h = waitbar(0,'Finding filter responses in 15 iterations');
k=2^(0.35);
X=[];
Y=[];
R=[];
imshow(img); hold on;
threshold=0.02;
for i=1:n
	%if i>1
	sigma=Sigma*k^(i-1);
	%end
	sigma
	filter  = createFilter(sigma);
	scale_space(:,:,i)=imfilter(img, filter{1}).^2;%applying Laplacian filter and storing its squared values
	waitbar(i/n,h,sprintf('%d / %d filters generated',i,n))%waitbar, random stuff
	% cim=scale_space(:,:,i);
	% sze = 2*3+1; %mask of 7X7, based upon harris
	% radius=2^0.5*sigma;                   % radius of the circle, sigma=radius/1.414
	mx = ordfilt2(scale_space(:,:,i),9,ones(3,3)); % Grey-scale dilate.
	% % maxSpace(:,:,i) = max(maxSpace(:,:,max(i-1,1):min(i+1,n)),[],3);
	Scale_Space(:,:,i) = mx;
end

for i = 1:n
    Scale_Space(:,:,i) = max(Scale_Space(:,:,max(i-1,1):min(i+1,n)),[],3);
end
Scale_Space = Scale_Space .* (Scale_Space == scale_space);
for i=1:n
	[r,c] = find(Scale_Space(:,:,i)>=threshold);
	radius=2^0.5*Sigma*k^(i-1);% radius of the circle, sigma=radius/1.414
	s=size(r,2);
	Rad = repmat(radius, [s, 1]);
	size(Rad);
	% R=[R;Rad];
	if i==1
		[a,b]=custom_show_all_circles(img, c, r, Rad);
		X=a;
		Y=b;
		% i
		% size(a)
		% size(b)
	else
		[a,b]=custom_show_all_circles(img, c, r, Rad);
		% i
		% size(a)
		% size(b)
		X = [X; a];
		Y = [Y; b];
	end
	size(X)
	size(Y)
end
close(h);
line(X', Y', 'Color', 'r', 'LineWidth', 1.5);
% cim=scale_space(:,:,15);
% sze = 2*3+1; %mask of 7X7, based upon harris
% radius=2^0.5*22;                   % radius of the circle, sigma=radius/1.414
% mx = ordfilt2(cim,9,ones(3,3)); % Grey-scale dilate.
% size(mx);
% cim = (cim==mx)&(cim>0.02);     % Find maxima.
% [r,c] = find(cim);                  % Find row,col coords.
% show_all_circles(img, c, r, radius)
% pause
% imshow(cim);
