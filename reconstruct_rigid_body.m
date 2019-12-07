function markerArray = reconstruct_rigid_body(markerArray)
% this function reconstructs rigid body markers based on the rigid body
% assumption. markerArray=[n_markers x n_samples x n_dimension].
% n_markers>=4. 

[n_marker,n_sample,n_dim]=size(markerArray);

%% get reconstruction matrices (v_coords) from good frames
% first we create a coordinate system for each frame 
% select marker with least amount of nans as base:
n_nan=sum(isnan(markerArray(:,:,1)),2); % nr of nan per marker
[~,order]=sort(n_nan); % from low to high nr of nan's

base=markerArray(order(1:n_dim),:,:); % markers used for initial reconstruction
good_samples=find(~isnan(sum(base(:,:,1)))); % samples with at least 3 good markers

% preallocate memory:
V_array=nan(length(good_samples),n_dim,n_dim);
v_coord_array=nan(n_marker-n_dim,n_sample,n_dim);
% construct weights used for later reconstruction:
for i_sample=good_samples
    % construct reference frame (currently assuming 3 dims ...):
    origin=squeeze(base(1,i_sample,:)); % origin of axis system
    v1=squeeze(base(2,i_sample,:))-origin; % first independent vector
    v2=squeeze(base(3,i_sample,:))-origin; % second independent vector
    v3=cross(v1,v2); % third independent vector
    V=[v1 v2 v3]; % change of coordinates vector
    V_array(i_sample,:,:)=V;
   for j_marker=1:n_marker-n_dim
       target_vec=squeeze(markerArray(order(j_marker+n_dim),i_sample,:));
       if isnan(target_vec(1))
           continue % we will not get reconstruction parameters here
       else
           target_vec=target_vec-origin; % transport to origin 
           v_coord=V\target_vec; % coords of target vec expressed in v coordinate system
           % now store v_coords for later:
           v_coord_array(j_marker,i_sample,:)=v_coord;
       end
       
   end
end
%keyboard
%% now reconstruct all nan markers based on the mean v_coords:
mean_v_coords=squeeze(nanmean(v_coord_array(:,:,:),2))'; % mean of the v_coordinate vectors
bad_samples=find(isnan(sum(markerArray(:,:,1)))); % all samples that contain some nan value in a marker
bad_samples=intersect(bad_samples,good_samples); % samples that contain some nan value AND for which we have a reconstruction
for i_sample=bad_samples
    % construct reference frame (currently assuming 3 dims ...):
    origin=squeeze(base(1,i_sample,:)); % origin of axis system
    V=squeeze(V_array(i_sample,:,:)); % orthonormal rotation matrix
    for j_marker=1:n_marker-n_dim
        if isnan(markerArray(order(j_marker+n_dim),i_sample,1)) % only reconstruct if bad
            markerArray(order(j_marker+n_dim),i_sample,:)=origin+V*mean_v_coords(:,j_marker);       
        end
    end
end
%keyboard