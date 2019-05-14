function dataraw = convertDelsysToMat(varargin)
%% convert delsys .csv files to a matlab table 
% input: delsys .csv file (exported from Delsys file export utility) 
% output: raw data in structure format (headings saved) 

% usage: 
% convertDelsysToMat(fn); 
fprintf('Note that you need to use the Delsys File Conversion Utility for this tool\n');
fprintf('Very important that you include headers as this is used to determin number of points output in each channel\n');

if nargin>=1
    [pn,fn,ext] = fileparts(varargin{1});
    dirout = pn; 
    fn = [fn ext];
else
    [fn,pn] = uigetfile('*.csv'); 
    dirout = pn; 
end

filename = fn; 
if exist(fullfile(dirout,[filename '.mat']),'file')
    load(fullfile(dirout,[filename '.mat']),'dataraw');
else
    fnmread = fullfile(dirout,filename);
    ds = datastore(fnmread);
    ds.MissingValue = 0; 
    % only read actual data, not time doman data 
    idxinclude = ~cellfun(@(x) any(regexpi(x,'x_s_')), ds.VariableNames); % exclude time array 
    vnmsRead = ds.VariableNames(idxinclude); 
    ds.SelectedVariableNames = vnmsRead;
    % get number of points for each channel by using text scan 
    fid = fopen(fnmread,'r');
    numLines = ds.NumHeaderLines;
    your_text = cell(numLines,1);
    for ii = 1:numLines
        your_text(ii) = {fgetl(fid)};
    end 
    fclose(fid);
    numberPoints = cell2mat(...
        cellfun(@(x) str2double(x),...
        regexp(your_text, '(?<=Number of points: )[0-9]+', 'match'),'UniformOutput',false));
    % read the whole file into table format (might not work if you don't
    % have enough RAM on your compuer 
    
    % read all raw data 
    start = tic; 
    dat = readall(ds); 
    fprintf('read all data in %f seconds\n',toc(start)); 
    
    % save all data as structure,only include number of points recorded 
    dataraw = struct();
    for v = 1:length(vnmsRead)
        if isempty(strfind(vnmsRead{v},'IM'))
            suffix = '_trig';
        else
            suffix = '';
        end
        dataraw.([vnmsRead{v} suffix])= dat.(vnmsRead{v})(1:numberPoints(v));
    end
    dataraw.srates.EMG     = 15/0.0135;
    dataraw.srates.ACC     = 2/0.0135;
    dataraw.srates.Gyro    = 2/0.0135;
    dataraw.srates.Mag     = 1/0.0135;
    dataraw.srates.trig    = 26/0.0135;

    % check if data is larger than 2GB and needs to be saved using 7.3 flag
    varinfo = whos('dataraw');
    saveopt = '';
    if varinfo.bytes >= 2^31
        saveopt = '-v7.3';
    end
    save(fullfile(dirout,[filename '.mat']),'dataraw',saveopt);
end

end