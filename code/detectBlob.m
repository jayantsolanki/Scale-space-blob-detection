%detectBlob1.m
function detectBlob1(img, Sigma, n, threshold, color, mode, time)
%% img: image on top of which you want to display the circles, just pass the rgb image after reading it using imread
%% sigma: starting value of the sigma
%% n: size of the scale-sapce 
%% threshold: for adjusting the number of the circles, typically between 0.005 to 0.001, check the method there, varies for squared response
%% for squared response and absoulte values of imfilter 
%% color: parameter specifying the color of the circles
%% mode: parameter specifying type of preprocessing required, 1 for image resizing, 0 for scale changing, default 1
%% time:optional, for calculating time for execution, default set to 0 for no time measurement

	% img=imread('..\data\butterfly.jpg');
	if nargin < 7
	    time=0;
	end
	if nargin < 6
	    mode=1;
	end
	% h,w - dimensions of image
	[h,w,ch]=size(img);%storing the dimensions of the image
	if ch==3
		img=rgb2gray(img);%converting the RGB colorspace into grayscale
	end
	img=double(img);%converting into double format
	img=img/255;
	% img=im2double(img);

	% imshow(img);
	scale_space = zeros(h,w,n);%for storing the original filter response
	Scale_Space = zeros(h,w,n);% for storing the preprocessed filter responses after ordfilt2
	Sscale_Sspace = zeros(h,w,n); %for storing the preprocessed filter responses after non-maximum suppression
	h = waitbar(0,sprintf('Finding filter responses in %d iterations',n));
	k=2^(0.35);%value of the scaling factor
	X=[]; %for storing X coordinates of the pixels after non maximum suppression
	Y=[]; %for storing Y coordinates of the pixels after non maximum suppression
	% threshold=0.07;
	if time==1
		tic
	end
	if mode==0
		for i=1:n
			sigma=Sigma*k^(i-1);
			filter  = createFilter(sigma);
			% scale_space(:,:,i)=imfilter(img, filter{1},'same', 'replicate').^2;%applying Laplacian filter and storing its squared values
			scale_space(:,:,i)=abs(imfilter(img, filter{1}, 'same', 'replicate'));%absolute value
			waitbar(i/n,h,sprintf('%d / %d filters generated',i,n))%waitbar, random stuff
			mx = ordfilt2(scale_space(:,:,i),49,ones(7,7)); % Grey-scale dilate., taking 9 for alloting max in neighbourhood
			if time==0
				imagesc(mx); 
				colorbar;
				title(sprintf('Showing the filter response for iteration %d, sigma = %0.3f',i, sigma));
				truesize;
			end
			% pause
			Scale_Space(:,:,i) = mx;
		end
	else
		for i=1:n
			% sigma=Sigma*k^(i-1);
			filter  = createFilter(Sigma);
			IMG = imresize(img, 1/k^(i-1), 'cubic');
			temp = imfilter(IMG, filter{1},'same', 'replicate').^2;%applying Laplacian filter and storing its squared values
			% temp = abs(imfilter(IMG, filter{1}, 'same', 'replicate'));%absolute value
			waitbar(i/n,h,sprintf('%d / %d filters generated',i,n))%waitbar, random stuff
			% scale_space(:,:,i) = imresize(temp, [h, w], 'bicubic');
			scale_space(:,:,i) = imresize(temp, size(img), 'cubic'); % lanczos3, lanczos2, cubic similar to bicubic, resizing back to original config
			mx = ordfilt2(scale_space(:,:,i),49,ones(7,7)); % Grey-scale dilate., taking 9 for alloting max in neighbourhood
			if time==0
				imagesc(mx); 
				colorbar;
				title(sprintf('Showing the filter response for iteration %d, sigma = %0.3f',i, Sigma));
				truesize;
			end
			% pause
			Scale_Space(:,:,i) = mx;
		end
	end
	% waitbar(h,sprintf('Done! Now showing the circles.'));
	close(h);
	%now looking for maximum response of a pixel at a particular sigma, for each three consecutive scales, but not following the 26 pixels comparision
	% [qw,er]=max(Scale_Space(:,:,:),[],3);
	%this one is more optimised function
	% for i = 1:n
	% 	if i==1
	% 		Scale_Space(:,:,i) = max(Scale_Space(:,:,1:i+1),[],3);
	% 	elseif i==n
	% 		Scale_Space(:,:,i) = max(Scale_Space(:,:,i-1:i),[],3);
	% 	else
	% 		Scale_Space(:,:,i) = max(Scale_Space(:,:,i-1:i+1),[],3);
	% 	end
	% 	% Scale_Space(x,y,i)=g(x,y,er(x,y));
	% end
	% Sscale_Sspace=Scale_Space;
	%this one is crude but easier to understand
	[h,w]=size(img);
	for i=1:h
		for j=1:w
			[l,p]=max(Scale_Space(i,j,:),[],3);% for particular pixel position i and j, find the max pixel value and the scale number it is present
			Sscale_Sspace(i,j,p)=l;
		end
	end
	Sscale_Sspace = Sscale_Sspace .* (Sscale_Sspace == scale_space);%preserving the detected pixels and setting the other pixels to zero
	for i=1:n
		[r,c] = find(Sscale_Sspace(:,:,i)>=threshold);%return only those pixels position which are greater than or equal to the threshold
		radius=2^0.5*Sigma*k^(i-1);% radius of the circle, sigma=radius/1.414
		if i==1
			[a,b]=custom_show_all_circles(c, r, radius);
			X=a;
			Y=b;
		else
			[a,b]=custom_show_all_circles(c, r, radius);
			X = [X; a];%appending up all the circles coordinates detected for each scale size
			Y = [Y; b];
		end
		% size(X);
		% size(Y);
		if(size(Y,1)>5000)%breakpoint if program go haywire
			disp('To many cicles, exiting now')
			return
		end
	end
	if time==1
		toc
	end
	imshow(img); 
	truesize;
	% hold on;
	line(X', Y', 'Color', color, 'LineWidth', 1.5);
	title(sprintf('%d blobs, at threshold %0.3f for intial sigma %0.1f and scale-space size %d',size(X,1), threshold, Sigma, n));
	fprintf('%d Blobs printed\n', size(X,1));
end