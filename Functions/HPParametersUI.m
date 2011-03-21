function varargout = HPParametersUI(varargin)
% HPPARAMETERSUI M-file for HPParametersUI.fig
%      HPPARAMETERSUI, by itself, creates a new HPPARAMETERSUI or raises the existing
%      singleton*.
%
%      H = HPPARAMETERSUI returns the handle to a new HPPARAMETERSUI or the handle to
%      the existing singleton*.
%
%      HPPARAMETERSUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HPPARAMETERSUI.M with the given input arguments.
%
%      HPPARAMETERSUI('Property','Value',...) creates a new HPPARAMETERSUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HPParametersUI_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HPParametersUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HPParametersUI

% Last Modified by GUIDE v2.5 10-Mar-2009 18:28:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HPParametersUI_OpeningFcn, ...
                   'gui_OutputFcn',  @HPParametersUI_OutputFcn, ...
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


% --- Executes just before HPParametersUI is made visible.
function HPParametersUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HPParametersUI (see VARARGIN)

% Choose default command line output for HPParametersUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes HPParametersUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HPParametersUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function StimDurationCtrl_Callback(hObject, eventdata, handles)
% hObject    handle to StimDurationCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StimDurationCtrl as text
%        str2double(get(hObject,'String')) returns contents of StimDurationCtrl as a double


% --- Executes during object creation, after setting all properties.
function StimDurationCtrl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StimDurationCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StimDelayCtrl_Callback(hObject, eventdata, handles)
% hObject    handle to StimDelayCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StimDelayCtrl as text
%        str2double(get(hObject,'String')) returns contents of StimDelayCtrl as a double


% --- Executes during object creation, after setting all properties.
function StimDelayCtrl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StimDelayCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RampCtrl_Callback(hObject, eventdata, handles)
% hObject    handle to RampCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RampCtrl as text
%        str2double(get(hObject,'String')) returns contents of RampCtrl as a double


% --- Executes during object creation, after setting all properties.
function RampCtrl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RampCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StimIntervalCtrl_Callback(hObject, eventdata, handles)
% hObject    handle to StimIntervalCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of StimIntervalCtrl as text
%        str2double(get(hObject,'String')) returns contents of StimIntervalCtrl as a double


% --- Executes during object creation, after setting all properties.
function StimIntervalCtrl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StimIntervalCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in HPEnableCtrl.
function HPEnableCtrl_Callback(hObject, eventdata, handles)
% hObject    handle to HPEnableCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of HPEnableCtrl



function HPFreqCtrl_Callback(hObject, eventdata, handles)
% hObject    handle to HPFreqCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HPFreqCtrl as text
%        str2double(get(hObject,'String')) returns contents of HPFreqCtrl as a double


% --- Executes during object creation, after setting all properties.
function HPFreqCtrl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HPFreqCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LPEnableCtrl.
function LPEnableCtrl_Callback(hObject, eventdata, handles)
% hObject    handle to LPEnableCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of LPEnableCtrl



function LPFreqCtrl_Callback(hObject, eventdata, handles)
% hObject    handle to LPFreqCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of LPFreqCtrl as text
%        str2double(get(hObject,'String')) returns contents of LPFreqCtrl as a double


% --- Executes during object creation, after setting all properties.
function LPFreqCtrl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to LPFreqCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AcqDurationCtrl_Callback(hObject, eventdata, handles)
% hObject    handle to AcqDurationCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of AcqDurationCtrl as text
%        str2double(get(hObject,'String')) returns contents of AcqDurationCtrl as a double


% --- Executes during object creation, after setting all properties.
function AcqDurationCtrl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AcqDurationCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HeadstageGainCTRL_Callback(hObject, eventdata, handles)
% hObject    handle to HeadstageGainCTRL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HeadstageGainCTRL as text
%        str2double(get(hObject,'String')) returns contents of HeadstageGainCTRL as a double


% --- Executes during object creation, after setting all properties.
function HeadstageGainCTRL_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HeadstageGainCTRL (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MonitorGainCtrl_Callback(hObject, eventdata, handles)
% hObject    handle to MonitorGainCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MonitorGainCtrl as text
%        str2double(get(hObject,'String')) returns contents of MonitorGainCtrl as a double


% --- Executes during object creation, after setting all properties.
function MonitorGainCtrl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MonitorGainCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function DecimationFactorCtrl_Callback(hObject, eventdata, handles)
% hObject    handle to DecimationFactorCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DecimationFactorCtrl as text
%        str2double(get(hObject,'String')) returns contents of DecimationFactorCtrl as a double


% --- Executes during object creation, after setting all properties.
function DecimationFactorCtrl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DecimationFactorCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MonitorChannelCtrl.
function MonitorChannelCtrl_Callback(hObject, eventdata, handles)
% hObject    handle to MonitorChannelCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns MonitorChannelCtrl contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MonitorChannelCtrl


% --- Executes during object creation, after setting all properties.
function MonitorChannelCtrl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MonitorChannelCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TTLPulseDurCtrl_Callback(hObject, eventdata, handles)
% hObject    handle to TTLPulseDurCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TTLPulseDurCtrl as text
%        str2double(get(hObject,'String')) returns contents of TTLPulseDurCtrl as a double


% --- Executes during object creation, after setting all properties.
function TTLPulseDurCtrl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TTLPulseDurCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function HeadstageGainCtrl_Callback(hObject, eventdata, handles)
% hObject    handle to HeadstageGainCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HeadstageGainCtrl as text
%        str2double(get(hObject,'String')) returns contents of HeadstageGainCtrl as a double


% --- Executes during object creation, after setting all properties.
function HeadstageGainCtrl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HeadstageGainCtrl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


