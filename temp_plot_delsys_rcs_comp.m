%% plot m1 power 
% filter beta and gamma 
figure; 
y = rcsDat.key3;
[b,a]        = butter(3,[14 20] / (srate/2),'bandpass'); % user 3rd order butter filter
y(191760:192359)  = mean(y); % get rid of the artifact              
y_filt       = filtfilt(b,a,y); %filter all 
[up, low] = envelope(y,120,'analytic'); % analytic rms 
y_mov_mean = movmean(up,[srate 0]);


secsPower = seconds( seconds ( rcsDat.derivedTimes - params.rcs5Hz) ); 


hplt = plot( secsPower,y_mov_mean); 
hplt.LineWidth = 3; 


%% plot
hfig = figure;
axcnt = 1; 
nrows = 4; 

% plot rcs acc 
searchStrings{1} = 'Samples'; 
hsub(axcnt) = subplot(nrows,1,axcnt); axcnt = axcnt + 1; 
secs = seconds( seconds ( rcsDatAcc.derivedTimes - params.rcs5Hz) ); 
st = rcsDatAcc; 
fldnms   = fieldnames(st);
searchSt = searchStrings{1};
idxuse = find(cellfun(@(x) any(strfind(x,searchSt)),fldnms)==1);
% plotting
hold on;
for i = 1:length(idxuse)
    xx = st.(fldnms{idxuse(i)});
    plot(secs',xx-mean(xx),'LineWidth',2);
    rmsUse(i,:) = (xx-mean(xx)).^2; 
end
yyaxis right;
hplt = plot( secsPower,y_filt); 
hplt.LineWidth = 3; 

% xM = movmean(rcsDatAcc.XSamples,[0 64]); 
% zM = movmean(rcsDatAcc.ZSamples,[0 64]); 
% deltas = xM-zM; 
% rmsMean = movmedian(sum(rmsUse,1),[0 250]);
% plot(secs',deltas,'LineWidth',3);
% title('rcs acc'); 

% set up stuff to plot
searchStrings{1} = 'DBS_5Hz_1_ACC';
searchStrings{2} = 'DBS_5Hz_1_Gyro';
searchStrings{3} = 'R_hand_2_Gyro';
ttls             = {'delsys acc dbs', 'delsys gyro dbs','delsys gyro r hand'};


% plot stuff
st = dataraw;
for s = 1 :length(searchStrings)
    fldnms   = fieldnames(st);
    searchSt = searchStrings{s}; 
    idxuse = find(cellfun(@(x) any(strfind(x,searchSt)),fldnms)==1);
    % plotting 
    hsub(axcnt) = subplot(nrows,1,axcnt); axcnt = axcnt + 1;
    hold on;
    for i = 1:length(idxuse)
        xx = st.(fldnms{idxuse(i)});
        secs = seconds((0:1:length(xx )-1 )./dataraw.srates.ACC)-params.delsys5Hz;
        plot(secs',xx-mean(xx),'LineWidth',2);
    end
    title(ttls{s});
end

% link axes
linkaxes(hsub,'x');