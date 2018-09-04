function varargout = delsysViewApp(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @delsysViewApp_OpeningFcn, ...
    'gui_OutputFcn',  @delsysViewApp_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before delsysViewApp is made visible.
function delsysViewApp_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
set(gcf,'toolbar','figure');

% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = delsysViewApp_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


% --- Executes on selection change in hChannels.
function hChannels_Callback(hObject, eventdata, handles)
updatePlot(hObject, eventdata)


% --- Executes during object creation, after setting all properties.
function hChannels_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in hComp.
function hComp_Callback(hObject, eventdata, handles)
updatePlot(hObject, eventdata)


% --- Executes during object creation, after setting all properties.
function hComp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hLoadData.
function hLoadData_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
fileout = convertDelsysToMat();
handles.rawdata = fileout;
populateControls(handles)

function populateControls(handles)
varnames  = handles.rawdata.Properties.VariableNames';
% populate variable names
sensors = {'EMG',...
    'ACCX','ACCY','ACCZ',...
    'GyroX','GyroY','GyroZ'...
    'MagX','MagY','MagZ'};
handles.varnames = varnames;
handles.hComp.String = sensors;
handles.hComp.Max  = length(sensors);
handles.hComp.Min  = 1;
handles.hComp.Value = 1;
% populate channel names
idxuse = cellfun(@(x) any(strfind(x,'EMG')),varnames);
sensnamesraw = varnames(idxuse);
for i = 1:length(sensnamesraw)
    idcut = strfind(sensnamesraw{i},'EMG');
    sensenames{i,1} = sensnamesraw{i}(1:idcut-2);
end
handles.hChannels.String = sensenames;
handles.hChannels.Max  = length(sensenames);
handles.hChChannelsomp.Min  = 1;
handles.hChannels.Value = 1;
guidata(gcf,handles);

function updatePlot(hObject,eventdata)
handles = guidata(gcf);
varnames = handles.varnames;
% get selected channel strings
channames = handles.hChannels.String;
chanuse = channames( handles.hChannels.Value );
% get selected comp strings
compnames = handles.hComp.String;
compuse = compnames( handles.hComp.Value );

% comp num of suplots
if isfield(handles,'hsubs')
    if isgraphics(handles.hsubs)
        delete(handles.hsubs);
    end
end
hsubs = [];
hplts = [];
handles.hsubs = [];
handles.hplts = [];
hparent = handles.hPlotAx;
% compute the number of plots

[numplots, plotnumMatrix, titlesUse] = genPlotNums(chanuse,compuse);
for c = 1:size(chanuse,1)
    for p = 1:size(compuse,1)
        % get data
        chan = chanuse{c};
        comp = compuse{p};
        regexpstr = sprintf('%s_%s',chan,comp);
        idxuse = cellfun(@(x) any(strfind(x,regexpstr)),varnames);
        if sum(idxuse)==0
            break;
        end
        yfnm = varnames{idxuse};
        xfnm = varnames{find(idxuse==1)-1};
        yvals = handles.rawdata.(yfnm);
        xvals = seconds(handles.rawdata.(xfnm));
        % plot
        hsubs(plotnumMatrix(c,p)) = subplot(numplots,1,plotnumMatrix(c,p),'Parent',hparent);
        hold on;
        
        % get rid of last bit (NaNs 
        idxuse = ~isnan(xvals); 
        idxdur = find(idxuse==1); 
        % dc offset
        yvals = yvals(idxuse) - mean(yvals(idxuse),1);
        hplts(c,p) = plot(xvals(idxdur),yvals);
        % title 
        title(titlesUse{c,p}); 
    end
end
handles.hsubs = hsubs;
handles.hplts = hsubs;
if ~isempty(hsubs)
    linkaxes(hsubs,'x');
end
guidata(gcf,handles);
x=2;

function [numplots, plotnumMatrix,titlesUse] = genPlotNums(chanuse,compuse)
for p = 1:length(compuse)
    comp1{p,1} = compuse{p,1}(1:end-1);
end
cnt = 1; 
for p = 1:size(comp1,1)
    if p == 1
        comp1{p,2} = cnt; 
    else
        if strcmp(comp1(p),comp1(p-1))
            comp1{p,2} = cnt; 
        else
            cnt = cnt +1; 
            comp1{p,2} = cnt; 
        end
    end
end

fprintf('\n\n');
fprintf('==================\n');
fprintf('start plot:\n');
fprintf('==================\n');
basecnt = 0; 
for c = 1:size(chanuse,1)
    for p = 1:size(compuse,1)
        plotnumMatrix(c,p) = comp1{p,2}+basecnt;
        chan = chanuse{c};
        comp = compuse{p};
        ttlraw = sprintf('%s %s',chan, comp1{p,1});
        titlesUse{c,p} = strrep(ttlraw,'_',' ');
        fprintf('%s \t %s \t plot num = %d\n',chan,comp,plotnumMatrix(c,p))
    end
    basecnt = plotnumMatrix(c,p);
end
fprintf('==================\n');
fprintf('end plot:\n');
fprintf('==================\n');
numplots = max(plotnumMatrix(:));



function hMin_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
if isfield(handles,'hsubs')
    if ~isempty(handles.hsubs)
        xlims = get(handles.hsubs(1),'XLim');
        maxval = seconds(str2num(handles.hMin.String));
        xlims(1,1) = maxval;
        set(handles.hsubs,'XLim',xlims);
    end
end
guidata(gcf,handles);
% hObject    handle to hMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hMin as text
%        str2double(get(hObject,'String')) returns contents of hMin as a double


% --- Executes during object creation, after setting all properties.
function hMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function hMax_Callback(hObject, eventdata, handles)
handles = guidata(gcf);
if isfield(handles,'hsubs')
    if ~isempty(handles.hsubs)
        xlims = get(handles.hsubs(1),'XLim');
        maxval = seconds(str2num(handles.hMax.String));
        xlims(1,2) = maxval;
        set(handles.hsubs,'XLim',xlims);
    end
end
guidata(gcf,handles);

% hObject    handle to hMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hMax as text
%        str2double(get(hObject,'String')) returns contents of hMax as a double


% --- Executes during object creation, after setting all properties.
function hMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
