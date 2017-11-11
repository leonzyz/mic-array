%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% platform: microphone array simulation platform

%   Author: leonzyz
%   Date: 2017/10/21 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('../source','../cfg','../platform','./src','../out');
clear all;close all;
global Cfg;
Cfg.Outdir='../out';
readcfg;
gen_const;
if Cfg.Scenario==0
	test_subfunction;
	display('test')
elseif Cfg.Scenario==1
	sim_fixbeamforming;
else
	display('not supported yet');
end


