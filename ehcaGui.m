% Copyright (C) 2011, 2012  Simon Schwab, schwab@puk.unibe.ch
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>

function varargout = ehcaGui(varargin)
% EHCAGUI MATLAB code for ehcaGui.fig
%      EHCAGUI, by itself, creates a new EHCAGUI or raises the existing
%      singleton*.
%
%      H = EHCAGUI returns the handle to a new EHCAGUI or the handle to
%      the existing singleton*.
%
%      EHCAGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EHCAGUI.M with the given input arguments.
%
%      EHCAGUI('Property','Value',...) creates a new EHCAGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ehcaGui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ehcaGui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ehcaGui

% Last Modified by GUIDE v2.5 22-May-2012 12:59:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ehcaGui_OpeningFcn, ...
                   'gui_OutputFcn',  @ehcaGui_OutputFcn, ...
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


% --- Executes just before ehcaGui is made visible.
function ehcaGui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ehcaGui (see VARARGIN)

% Choose default command line output for ehcaGui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ehcaGui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ehcaGui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in button_load.
function button_load_Callback(hObject, eventdata, handles)
% hObject    handle to button_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uigetfile('*.mat', 'Load segment file');
load(strcat(path, file));

global ehdata;
ehdata = ehcaDriver(segments);
set(handles.text_nr_trials, 'String', ehdata.get_nr_trials_str());
ehdata = ehdata.plot_segment(1);

% --- Executes on button press in button_back.
function button_back_Callback(hObject, eventdata, handles)
% hObject    handle to button_back (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ehdata;
ehdata = ehdata.plot_back();

% --- Executes on button press in button_next.
function button_next_Callback(hObject, eventdata, handles)
% hObject    handle to button_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ehdata;
ehdata = ehdata.plot_next();

% --- Executes on button press in botton_quit.
function botton_quit_Callback(hObject, eventdata, handles)
% hObject    handle to botton_quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('Have a nice day...\n\n');
close all;


% --- Executes on button press in button_parameter_detection.
function button_parameter_detection_Callback(hObject, eventdata, handles)
% hObject    handle to button_parameter_detection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ehdata;
ehdata = ehdata.get_param();

% --- Executes on button press in button_save.
function button_save_Callback(hObject, eventdata, handles)
% hObject    handle to button_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ehdata
segments = ehdata.segments;
param = ehdata.param;
[file, path]= uiputfile('*.mat','Save data as');
save(strcat(path, file), 'segments', 'param');
