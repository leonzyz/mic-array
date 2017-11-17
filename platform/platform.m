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
elseif Cfg.Scenario==1
	sim_fixbeamforming;
elseif Cfg.Scenario==2
	sim_frost_BF;
else
	display('not supported yet');
end


