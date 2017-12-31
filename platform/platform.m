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
	general_model;
elseif Cfg.Scenario==1
	sim_fixbeamforming;
elseif Cfg.Scenario==2
	sim_frost_BF;
elseif Cfg.Scenario==3
	sim_GJBF_NLMS;
elseif Cfg.Scenario==4
	sim_test_script;
else
	display('not supported yet');
end


