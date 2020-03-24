alldir = 'training_images';
subdir =  dir(alldir);
 
for i = 1 : length(subdir)
    if (isequal(subdir(i).name, '.') || ...
        isequal(subdir(i).name, '..' ) || ...
        ~subdir(i).isdir)   
        continue;
    end
     
    subdirpath = fullfile(alldir, subdir(i).name, 'img*');
    images = dir(subdirpath);   
     
    I1 = im2double(imread(fullfile(alldir, subdir(i).name, images(1).name)));
    I2 = im2double(imread(fullfile(alldir, subdir(i).name, images(2).name)));
    
%   ---------- Generate pos1 ----------
    I1_G = rgb2gray(I1);
    detector1 = detectHarrisFeatures(I1_G);
    pos1 = detector1.selectStrongest(25).Location;
%   ---------- Generate pos1 ----------

    find_matches(I1, pos1, I2);
    
end

% I1 = im2double(imread('training_images/bikes/img1.png'));
% I2 = im2double(imread('training_images/bikes/img2.png'));
%     
% I1_G = rgb2gray(I1);
% detector1 = detectHarrisFeatures(I1_G);
% pos1 = detector1.selectStrongest(25).Location;
%     
% find_matches(I1, pos1, I2);
