%% specify a uniform noise:
astim.type			=	'noise_uniform';
astim.channel		=	1;
astim.duration		=	100;
astim.delay			=	50;
astim.ramptime		=	5;
astim.ramptype		=	'sin2';
astim.db				=	50;
astim.fmin			=	1000;
astim.fmax			=	10000;

%% specify a tone:
bstim.type			=	'tone';
bstim.channel		=	1;
bstim.duration		=	50;
bstim.delay			=	0;
bstim.ramptime		=	1;
bstim.ramptype		=	'linear';
bstim.db				=	40;
bstim.freq			=	440;
bstim.phase			=	0;

%% specify a wav file:
cstim.type			=	'wav';
cstim.channel		=	2;
cstim.duration		=	0;
cstim.delay			=	100;
cstim.ramptime		=	5;
cstim.ramptype		=	'linear';
cstim.db				=	60;
cstim.filename		=	'c:\home\users\potato\wavstims\braaap.wav';


%% Store these stimulus specifications in a cell array called StimList
StimList{1} = astim;
StimList{2} = bstim;
StimList{3} = cstim;

%% then save the StimList in a .mat file.
% windows
% save('c:\home\users\potato\stimlists\mystims.mat', 'StimList', '-MAT')
%  mac
save('./mystims.mat', 'StimList', '-MAT')

%% The individual stimulus paramater fields would then be accessed as:
StimList{2}.type
	
% or 
StimList{1}.fmin
