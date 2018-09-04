function dataraw = convertDelsysToMat(varargin)
if nargin==1
    [pn,fn,ext] = fileparts(varargin{1});
    dirout = pn; 
    fn = [fn ext];
else
    [fn,pn] = uigetfile('*.csv'); 
    dirout = pn; 
end
if exist(fullfile(dirout,[fn '.mat']),'file')
else
    fnmread = fullfile(dirout,fn);
    dataraw = readtable(fnmread);
    % chekc if data is larger than 2GB and needs to be saved using 7.3 flag
    varinfo = whos('dataraw');
    saveopt = '';
    if varinfo.bytes >= 2^31
        saveopt = '-v7.3';
    end
    save(fullfile(dirout,[fn '.mat']),'dataraw',saveopt);
end
fileout = fullfile(dirout,[fn '.mat']);
load(fileout,'dataraw'); 
end