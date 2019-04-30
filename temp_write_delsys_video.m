params.delsysFn = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/delsys_driving/Run_number_198_Plot_and_Store_Rep_2.8.csv.mat'; 
params.vidFn    = '/Users/roee/Starr_Lab_Folder/Data_Analysis/RCS_data/RCS01/v10-3-month/vids/MVI_0266.MP4'; 
%% set up figure 
hfig = figure; 
%% plot

load(params.delsysFn);

% set params 
params.framewidth = seconds(10); % in seconds 
params.vidFrame   = seconds(1/5); % number of seconds to advance for each video frame 
params.startFrame = seconds(60); 


hold on; 
y = dataraw.Pressure_TPMEMG10_trig;
secs = seconds((0:1:length(y )-1 )./dataraw.srates.trig); 
plot(secs',y,'LineWidth',2);
ylims = get(gca,'YLim'); 
hcur = plot(seconds([0 0]),ylims,...
    'LineWidth',2,...
    'Color',[0.7 0.7 0.7 0.5]); 

atEnd = 0; 
frmStart = seconds(0) + params.startFrame; 
frmEnd   = frmStart + params.framewidth; 
curPos   = (frmEnd - frmStart)/2 + params.startFrame; 

hax = gca; 
xlims = [frmStart frmEnd];
cnt = 1; 
%%
% set up video 
v = VideoWriter('Run_number_198_Plot_and_Store_Rep_2.mp4','MPEG-4'); 
v.Quality = 30; 
v.FrameRate = 5; 
open(v); 
while ~atEnd
    
    if xlims(2) > max(secs)
        atEnd = 0;
        break; 
    end
    set(hax,'XLim',xlims);
    set(hax,'YLim',ylims); 
    hcur.XData = [curPos curPos];
    curPos = curPos + params.vidFrame;
    xlims = xlims + params.vidFrame; 
    
    x = getframe(hfig); 
    writeVideo(v,x); 
    cnt = cnt + 1; 
end
close(v); 