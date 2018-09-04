function fileout = convertDelsysToMat(varargin)
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
    save(fullfile(dirout,[fn '.mat']),'dataraw');
end
fileout = fullfile(dirout,[fn '.mat']);
end