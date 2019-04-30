%% start up
close all;
clear all;
clc;
params.delsysFn   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/delsys_driving/Run_number_198_Plot_and_Store_Rep_2.8.csv.mat';
params.vidFn      = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/vids/MVI_0266.MP4';
params.rcsTdFn    = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/rcs_data/patient_comp/driving and randy app/Session1546902587066/DeviceNPC700395H/RawDataTD.mat';
params.rcsAccFn   = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/rcs_data/patient_comp/driving and randy app/Session1546902587066/DeviceNPC700395H/RawDataAccel.mat';
params.rcsEvntFn  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/rcs_data/patient_comp/driving and randy app/Session1546902587066/DeviceNPC700395H/EventLog.mat';
params.rcsDvcStFn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/rcs_data/patient_comp/driving and randy app/Session1546902587066/DeviceNPC700395H/DeviceSettings.mat';
params.drivingTm  = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/delsys_driving/driving_start_stop_times_off_stim.csv';
params.vidStart = 2.636; % this is without subtractions
params.delsysStart = seconds(76.811); % this is where first pressure pulse starts

params.framewidth = seconds(10); % in seconds
params.startFrame = params.delsysStart;
%% load delsys
load(params.delsysFn);

%% load RCS stuff
load(params.rcsTdFn);
rcsDat = outdatcomplete;
clear outdatcomplete;
load(params.rcsAccFn);
rcsDatAcc = outdatcomplete;
load(params.rcsEvntFn);
load(params.rcsDvcStFn);
hfig1 = figure;
% below should be commentd out on first run
correctNums = 1;
if correctNums
    params.delsys5Hz = seconds(58.9149);
    params.rcs5Hz    = rcsDat.derivedTimes(14752);
else
    params.delsys5Hz = seconds(0);
    params.rcs5Hz    = seconds(0);
end


% plot delsys
hsub(1) = subplot(2,1,1);
y = dataraw.DBS_5Hz_1_EMG1_IM_;
secs = seconds((0:1:length(y )-1 )./dataraw.srates.EMG)-params.delsys5Hz;
plot(secs',y,'LineWidth',2);
title('delsys');
% plot rcs
hsub(2) = subplot(2,1,2);
y = rcsDat.key0;
secs = rcsDat.derivedTimes-params.rcs5Hz;
plot(secs,y,'LineWidth',2);
title('rcs');
linkaxes(hsub,'x');

%% load event times
rcsStartStopTimes = readtable(params.drivingTm); % these are times after 5Hz was subtracted

%% plot spectral chunks of data
% chanls rec from
params.time_before = seconds(10);
params.time_after  = seconds(10);

prfig.plotwidth           = 10;
prfig.plotheight          = 18; 
prfig.figdir              = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/figures';
prfig.figtype             = '-djpeg';
prfig.closeafterprint     = 1; 
prfig.resolution          = 300; 

searchStrings{1} = 'DBS_5Hz_1_ACC';
searchStrings{2} = 'R_hand_2_Gyro';
ttls             = {'delsys acc dbs','delsys gyro r hand'};


% get delsys data
st = dataraw;
for s = 1 :length(searchStrings)
    fldnms   = fieldnames(st);
    searchSt = searchStrings{s};
    idxuse = find(cellfun(@(x) any(strfind(x,searchSt)),fldnms)==1);
    % get data
    for i = 1:length(idxuse)
        tmp = st.(fldnms{idxuse(i)});
        xx(s,i,:) = tmp - mean(tmp);
        secsDelsys(s,i,:) = seconds((0:1:length(xx )-1 )./dataraw.srates.ACC)-params.delsys5Hz;
    end
end

for c = 1:4
    fnmuse = sprintf('key%d',c-1);
    ttluse = sprintf('stopping %s',outRec.tdData(c).chanFullStr);
    prfig.figname = sprintf('starting_high_gamma60-200%d',c);
    
    y = rcsDat.(fnmuse);
    y = y -mean(y);
    % get spectrla data
    srate = unique(rcsDat.samplerate);
    [s,f,t,p] = spectrogram(y,srate,ceil(0.875*srate),1:200,srate,'yaxis','psd');
    % zp = zscore(p);
    % pscaled = abs(p)./abs(repmat(mean(p,2),1,size(p,2)));
    % pcolor(t, f,zscore(p))
    deltaSubtract = abs(rcsDat.derivedTimes(1) - params.rcs5Hz);
    secs = seconds(t)-deltaSubtract;
    % plot delsys data
    
    

    % plot
    
    hfig = figure;
    
    nrows = size(rcsStartStopTimes,1);
    pavg = [];
    for s = 1:size(rcsStartStopTimes,1)
        % plot rc+s data
        hsub(s) = subplot(nrows,1,s);
        hold on;
        stop_time = seconds(rcsStartStopTimes.rcs_acc_stop(s));
        idxUse = secs > (stop_time - params.time_before) & secs < (stop_time + params.time_after);
        % save datsa for averaging - since it is spectral data, compute
        % points 
        interPointDur = mean(diff(secs));
        datPoints = ceil(params.time_before/interPointDur); 
        [~, indexPoint] = min(abs(secs-stop_time));
        res.(fnmuse)(:,:,s) = 10*log10(p(:,indexPoint - datPoints : indexPoint + datPoints )); 

        % plot 
        surf(secs(idxUse), f, 10*log10(p(:,idxUse)), 'EdgeColor', 'none');
        ylims = get(hsub(s),'YLim');
        plot([stop_time stop_time],ylims,'LineWidth',2,'Color',[0.2 0.2 0.2 0.5]);
        view(0, 90)
        axis tight
        shading interp
        % plot delsys data overlayd
        yyaxis right
        secsDel = squeeze(secsDelsys(2,1,:)) ; % 5 hz acc
        idxUse = secsDel > (stop_time - params.time_before) & secsDel < (stop_time + params.time_after);
        plot(secsDel(idxUse),squeeze(xx(1,:, idxUse)) ,'LineWidth',2,'Color',[0.2 0.2 0.2 0.15]);
    end
    suptitle(ttluse);
    % save figure
%     plot_hfig(hfig,prfig); 
end

%% plot averages 
prfig.figname = sprintf('starting_high_gamme_avg60-200_test');
prfig.plotwidth           = 15;
prfig.plotheight          = 15; 
badTrials                 = 10; 
hfig = figure;
for c = 1:4
    fnmuse = sprintf('key%d',c-1);
    subplot(2,2,c); 
    hold on; 
    ttluse = sprintf('stopping avg %s',outRec.tdData(c).chanFullStr);
    idxkeep = setxor(1:size(res.(fnmuse),3),badTrials); % keep everythign but bad trials 
    pToAvg = res.(fnmuse)(:,:,idxkeep);
    pavg = mean(pToAvg,3);
    pavgRescale = rescale(pavg,0,1); 
    % z score the results and subtract mean 
    idxmiddle = ceil(size(pavg,2)/2);
    idxmiddle = ceil(idxmiddle/2); 
    meanVec   = mean(pavgRescale(:,1:idxmiddle),2);
    divVec    = repmat(meanVec,1,size(pavg,2));
    zscoreMat = pavgRescale./divVec;
    % XX 
    idxLine = ceil(size(pavg,2)/2);
    secsUse = (1:size(pavg,2)) .* interPointDur;
    secsUse = secsUse - secsUse(idxLine); 
    surf( secsUse, f, pavgRescale, 'EdgeColor', 'none');
%     surf(1:size(pavg,2), f, zscoreMat, 'EdgeColor', 'none');
    view(0, 90)
    % XX 
    ylims = get(gca,'YLim');
    
    zmax = max(pavgRescale(:));
    plot3(seconds([0 0]),ylims,[zmax zmax],'LineWidth',5,'Color',[0.2 0.2 0.2 0.5]);
    title(ttluse); 
    axis tight
    shading interp
    ylim(gca,[0 100]); 
    
end
% plot_hfig(hfig,prfig);
figdir = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/figures';
fnmuse = fullfile(figdir,'stopping data driving'); 
 savefig(fnmuse); 



