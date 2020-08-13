function SimulateTargetTMS(xyzMNI2mm_vox)

addpath(genpath('/misc/jasper/alcauter/MATLABscripts'));

%%
% xyzMNI2mm_vox     vector with the MNI coordinates of the stimulation
% point in voxels (not mm)

% Sarael Alcauter, Feb 5, 2019 (based on SimulateSMAloc.m by S.A.)
% alcauter@inb.unam.mx

%% Set variables

% MNI path:
MNI='/usr/local/fsl/data/standard/MNI152_T1_2mm.nii.gz';
MNIbrain='/usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz';
% Threshold background/tissue:
binThr=0.15;

tst=load_nii(MNI);

%Reorient
T1_flip=flipdim(flipdim(permute(tst.img,[3 1 2]),1),2);
%Keep coronal slice
slice=mat2gray(squeeze(T1_flip(:,:,xyzMNI2mm_vox(2))));
% Binarize
BW=im2bw(slice,binThr);

% Find border
border=edge(BW,'log');

%% Define border
figure;imshowpair(slice,border);
uiwait(msgbox({'Select the head contour'}));
[x,y] = ginput(1);

% Get clusters
cc=bwconncomp(border);
in=sub2ind(size(border),round(y(1)),round(x(1))); % Inion in index format
% Keep the cluster with the Nasion
i=1;
f=0;
while f==0
    f=sum(ismember(cc.PixelIdxList{i},in));
    i=i+1;
end
borderPixelIDs=cc.PixelIdxList{i-1};
borderH=border*0;
borderH(borderPixelIDs)=1;

%% Get the distance map from stimulation point to brain border

% BW image of the stim point
slice_stim=slice*0;
slice_stim(abs(xyzMNI2mm_vox(3)-90),xyzMNI2mm_vox(1))=1;
% Distance map
Dmap=bwdist(slice_stim);
% Find the point on the border closest to stim point
[minDistance,Stim]=min(Dmap(borderPixelIDs));

%% Stimulation points and normal to the head

% Get subindices
%[yVx,xVx]=ind2sub(size(D),Vx);
[yStim,xStim]=ind2sub(size(Dmap),borderPixelIDs(Stim));
% Draw Landmarks
r=0; % Radius in Pixels
Lm=slice*0;

    % Tangent and Normal

    Nbp=10; % Number of points before and after Stim point to model de surface

    %Fit polinomial to the surface from Vertex to endP
    [rowPs,colPs]=ind2sub(size(slice),borderPixelIDs(Stim-Nbp:Stim+Nbp)); % Subindices
    Pol=polyfit(colPs,rowPs,2); % Fit 
    Pder=polyder(Pol);          % Derivate
    M=-1/polyval(Pder,xStim);   % Define the slope of the Normal

    % Evaluate the normal
    for i=1:length(colPs)
        Lm(round(M*(colPs(i)-xStim)+yStim),colPs(i))=1;
    end
    
Lm(yStim-r:yStim+r,xStim-r:xStim+r)=2; % Stimulation point (closest point on head border)  

% Brain border
tst=load_nii(MNIbrain);

%Reorient
T1_flip=flipdim(flipdim(permute(tst.img,[3 1 2]),1),2);
%Keep coronal slice
slice=mat2gray(squeeze(T1_flip(:,:,xyzMNI2mm_vox(2))));
% Binarize
BW=im2bw(slice,binThr);

% Find border (brain
cc=bwconncomp(edge(BW,'log'));
for i=1:cc.NumObjects
    ccsize(i)=length(cc.PixelIdxList{i});
end
[~,iM]=max(ccsize); % Keep the largest cluster
borderB=slice*0;
borderB(cc.PixelIdxList{iM})=1;
Dmap=bwdist(borderB); % Distance map for the normal

% Find the closest point between brain border and normal (not always
% intersect because of discretization)
ixLm=find(Lm>0);
[imValue,im]=min(Dmap(ixLm));
imValue    % print the value of the minimum

Lm(ixLm(im))=5;  % set this point in the Landmarks matrix
Lm=Lm+borderH;  % include head border in the figure

%% Final Figure

figure;
imshowpair(slice,Lm);hold on;
plot(colPs,polyval(Pol,colPs));hold on;  % Polinomial of the head surface
plot(colPs,M*(colPs-xStim)+yStim);hold on;  % Tangent to the head surface
plot(colPs,(-1/M)*(colPs-xStim)+yStim);      % Normal to the head surface

[yP,xP]=ind2sub(size(slice),ixLm(im));   % print the coordinates


[xP xyzMNI2mm_vox(2) 90-yP]





