clear all
close all
clc

% sort out pathing etc
tmp=mfilename('fullpath');
tmp=tmp(1:length(tmp)-length(mfilename)); % full path of current file location
dataDir=[tmp,'..\data\pilot01'];
addpath(genpath(dataDir))
cd(tmp) % move to 'matlab' directory

d=dir(dataDir);

%% treadmill coordinate system:
% +X to right
% +Y forward
% +Z up

for iFile=3
    fname=d(iFile).name; %what the hell is this
    if ~contains(fname,'c3d')
        continue
    end
    c3dout = loadc3d (fname);
    markerArray=c3dout.markerArray/1000; % [m] raw markerpositions 
    
    n_nan=sum(isnan(markerArray(:,:,1)),2); % nr of nan per marker
    markerArray(n_nan==length(markerArray),:,:)=[]; % cut out bad markers
    [n_marker,n_sample,n_dim]=size(markerArray);
    % body markers:
    hand=markerArray(7:9,:,:);
    %% reconstruct frame markers
    % first we construct the coordinate markers:
    frameMarkers=markerArray(1:6,:,:);
    frameMarkers_reconstructed=reconstruct_rigid_body(frameMarkers); 
    
    % frame markers:
    LB=squeeze(frameMarkers_reconstructed(3,:,:)); % left back
    RB=squeeze(frameMarkers_reconstructed(2,:,:)); % right back
    LF=squeeze(frameMarkers_reconstructed(5,:,:)); % left forward
    RF=squeeze(frameMarkers_reconstructed(6,:,:)); % right forward
    home=squeeze(frameMarkers_reconstructed(1,:,:)); % home base
    target=squeeze(frameMarkers_reconstructed(4,:,:)); % target
  
    figure
    for i=1:10:n_sample
            % all markers:
            plot3(frameMarkers_reconstructed(:,i,1),frameMarkers_reconstructed(:,i,2),frameMarkers_reconstructed(:,i,3),'ko'); hold on
            plot3(frameMarkers(:,i,1),frameMarkers(:,i,2),frameMarkers(:,i,3),'ro'); 
            xlabel ('x lab')
            ylabel ('y lab')
            zlabel ('z lab')
            axis equal
            drawnow
    end
  
    
    %% change of coordinates for hand and target markers:
    originArray=nan(n_dim,n_sample);
    for i=1:n_sample
        origin=home(i,:)'; % origin
        originArray(:,i)=origin;
        v1=RB(i,:)'-LB(i,:)'; % first independent vector
        v2=LF(i,:)'-LB(i,:)'; % second independent vector
        v2=v2-(v2'*v1)/(v1'*v1)*v1; % orthogonalize (Gramm-Schmidt)
        v1=v1/sqrt(v1'*v1); % normalize
        v2=v2/sqrt(v2'*v2);
        v3=cross(v1,v2); % third orthonormal vector
        R=[v1 v2 v3]; % orthonormal rotation matrix
        
        target_local(1:3,i)=R'*(target(i,:)'-origin);
        for j=1:3
            hand_local(j,i,1:3)=R'*(squeeze(hand(j,i,:))-origin);
        end
    end
    
    %% visualize     
    figure
    for i=1:10:n_sample
            % all markers:
            plot3(hand_local(3,i,1),hand_local(3,i,2),hand_local(3,i,3),'ko'); hold on
            %plot3(home_local(1,i),home_local(2,i),home_local(3,i),'bo'); hold on 
            plot3(target_local(1,i),target_local(2,i),target_local(3,i),'ro'); hold on 
            xlabel('x local')
            ylabel('y local')
            zlabel('z local')
            axis equal
            drawnow
    end
    %% fictional forces
    [B,A]=butter(4,20/(2*480));
    for iDim=1:3
    originArray(iDim,:)=filtfilt(B,A,originArray(iDim,:));
    end
    v_origin=diff1d(originArray,480);
    a_origin=diff1d(v_origin,480);
    
end
