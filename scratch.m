%% indev settings
indev.Fs = [];
% set this to wherever the circuits are stored
indev.Circuit_Path = 'C:\TytoLogy\Toolbox\TDTToolbox\Circuits\RZ5';
% for recording from 16 Channels
indev.Circuit_Name = 'RZ5_1ChannelAcquire_zBus';
% Dnum = device number - this is for RZ5
indev.Dnum=1;
indev.C = [];
indev.status = 0;

%% outdev settings
outdev.Fs = [];
% set this to wherever the circuits are stored
outdev.Circuit_Path = 'C:\TytoLogy\Toolbox\TDTToolbox\Circuits\RZ6\';
outdev.Circuit_Name = 'RZ6_SpeakerOutput_zBus';
% Dnum = device number - this is for RX6, device 1
outdev.Dnum=1;
outdev.C = [];
outdev.status = 0;

%% other settings
interface = 'GB';
device_num = 1;

%% Initialize zBus control
disp('...starting zBUS...')
tmpdev = zBUSinit('GB');
zBUS.C = tmpdev.C;
zBUS.handle = tmpdev.handle;
zBUS.status = tmpdev.status;

%% initialize RZ5
%{
% create invisible figure for control
indev.handle = figure;
set(indev.handle, 'Visible', 'off');
% Create ActiveX control object
indev.C = actxcontrol('RPco.x',[5 5 26 26], indev.handle);
% Clears all the Buffers and circuits on that RP2
indev.C.ClearCOF;
% connects RP2 via USB or Xbus given the proper device number
% invoke(indev.C,'ConnectRX5', interface, device_num);
indev.C.ConnectRZ5(interface, device_num);
% Since the device is not started, set status to 0
indev.status = 0;
% Loads circuits
indev.status = RPload(indev);
% Starts Circuits
inStatus = RPrun(indev);
% get sample freq
indev.Fs = RPsamplefreq(indev);
% get the tags and values for the circuits
tmptags = RPtagnames(indev);
indev.TagName = tmptags;
%}
disp('...starting Medusa attached to RZ5...')
tmpdev = RZ5init('GB');
indev.C = tmpdev.C;
indev.handle = tmpdev.handle;
indev.status = tmpdev.status;

%% initialize RZ6
disp('...starting RZ6 for lautspracher output...')
tmpdev = RZ6init('GB', outdev.Dnum);
outdev.C = tmpdev.C;
outdev.handle = tmpdev.handle;
outdev.status = tmpdev.status;

%% Loads circuits
indev.status = RPload(indev);
outdev.status = RPload(outdev);

%% Starts Circuits
inStatus = RPrun(indev);
outStatus = RPrun(outdev);

%% Get circuit information
% get the input and output sampling rates
outdev.Fs = RPsamplefreq(outdev);
indev.Fs = RPsamplefreq(indev);
% get the tags and values for the circuits
tmptags = RPtagnames(outdev);
outdev.TagName = tmptags;				
tmptags = RPtagnames(indev);
indev.TagName = tmptags;

%% clean up
disp('...closing indev')
indev.status = RPclose(indev);
disp('...closing outdev');
outdev.status = RPclose(outdev);
disp('...closing zBUS')
zBUS.status = zBUSclose(zBUS);