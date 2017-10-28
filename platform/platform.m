%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% platform: microphone array simulation platform

%   Author: leonzyz
%   Date: 2017/10/21 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('../source','../cfg','../platform','./src');
clear all;close all;
global Cfg;
readcfg;
if Cfg.Scenario==0
	test_subfunction;
elseif Cfg.Scenario==1
	sim_fixbeamforming;
else
	display('not supported yet');
end


