function c3dout = loadc3d (c3dFileName)

fileName = which(c3dFileName);


itf = actxserver('C3DServer.C3D');  % makes "itf" a COM object for the "c3dserver" package
openc3d(itf, 0, fileName);    % applies the correct open options to the file you choose

try
    analogs = getanalogchannels(itf);
    c3dout.analogs = analogs;
catch e
end

% frames = nframes(itf);  % calculates and displays the number of video frames
frameRateIndex = itf.GetParameterIndex('POINT','RATE'); %% get Index for the Frame Rate
MocapframeRate = double(itf.GetParameterValue(frameRateIndex, 0));  % get value of the Frame Rate

allMocapMarkers = get3dtargets(itf);
closec3d(itf);

% this just puts all markerData in a single array [nMarker x nSample x 3]
fieldNames=fields(allMocapMarkers);
% preallocate array:
nr_mocap_samples=length(allMocapMarkers.(fieldNames{1}));
nr_mocap_markers=length(fieldNames)-1; % -1 because one field is 'units'
c3d_markerArray=nan(nr_mocap_markers,nr_mocap_samples,3);
for iField=1:length(fieldNames)
    fieldName=char(fieldNames{iField});
    if contains(fieldName,'M') % this is a marker
        mNr=str2double(fieldName(end-1:end))+1;
        c3d_markerArray(mNr,:,:)=allMocapMarkers.(fieldNames{iField});
    end
end
c3dout.markerArray=c3d_markerArray;