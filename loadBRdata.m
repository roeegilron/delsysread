function datout  = loadBRdata(ipadir)
addpath(genpath(fullfile(pwd,'toolboxes','xml2struct')));
addpath(genpath(fullfile(pwd,'toolboxes','json')))
ff = findFilesBVQX(ipadir,'BRRAW_*.mat');
if ~isempty(ff)
    load(ff{1});
    datout = brraw;
    skipthis = 1;
else
    skipthis = 0;
end
if ~skipthis
    [pn,fn] = fileparts(ipadir);
%     s = cellfun(@(x) str2num(x), regexp(fn,'[0-9]+','match'));
%     filesfound = findFilesBVQX(ipadir,'*.txt');
%     [pn,fn,ext] = fileparts(filesfound{1});
    cnt = 1;
    if any(strfind(fn,'raw')) % if its a raw file, get xml data from non raw xml
        xmlfnm = [fn(1:end-4) '.xml'];
    else
        xmlfnm = [fn '.xml'];
    end
    xmlstruc = xml2struct(fullfile(pn,xmlfnm));
    if isfield(xmlstruc,'RecordingItem')
        xmlstrucparsed = parseXMLstruc(xmlstruc);
    else
        xmlstrucparsed = parseXMLstruc2(xmlstruc);
    end
    xmldata = xmlstrucparsed.RecordingItem;
    data = importdata(fullfile(pn,[fn ext])); % import the actual data
    idx = strfind(fn,'_');
    datvec = datevec(fn(idx(1)+1:idx(1)+19),'yyyy_mm_dd_HH_MM_SS');
    dateuse = datetime(datvec);
    datout(cnt).fn = fn;
    datout(cnt).fntime = dateuse;
    datout(cnt).algoconfig = xmlstrucparsed.RecordingItem.AlgorithmConfig;
    datout(cnt).detection = xmlstrucparsed.RecordingItem.AlgorithmConfig.Coefficients; 
    datout(cnt).duration  = xmlstrucparsed.RecordingItem.RecordingDuration;
    datout(cnt).tdsr        = str2num(xmlstrucparsed.RecordingItem.SenseChannelConfig.TDSampleRate(1:3));
    datout(cnt).pdsr        = str2num(xmlstrucparsed.RecordingItem.SenseChannelConfig.PowSampleRate(1:3));
    for i = 1:4
        chanmeta = xmlstrucparsed.RecordingItem.SenseChannelConfig.(['Channel' num2str(i)]);
        datout(cnt).(['chan' num2str(i)]) = data(:,i); 
        datout(cnt).(['chan' num2str(i) 'type']) = chanmeta.ChannelType; 
        
        datout(cnt).(['chan' num2str(i) 'CtrFreq']) = chanmeta.CtrFreq; 
        datout(cnt).(['chan' num2str(i) 'PowGain']) = chanmeta.PowGain;
        datout(cnt).(['chan' num2str(i) 'TDGain']) = chanmeta.TDGain;
        datout(cnt).(['chan' num2str(i) 'BW']) = chanmeta.BW;
        datout(cnt).(['chan' num2str(i) 'elecs']) = sprintf('-%s+%s',chanmeta.MinusInput,chanmeta.PlusInput); 
    end
    datout(cnt).chan5 = data(:,5); 
    datout(cnt).chan6 = data(:,6); 
    
    brraw = datout; 
    save(fullfile(pn,['BRRAW_' fn '.mat']),'brraw');
end
end