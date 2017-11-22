addpath('../source','../cfg','../platform','../platform/src','../out');
clear all;close all;
global Cfg;
Cfg.DebugEn=1;
Cfg.DebugMask=bin2dec('1000000');
Cfg.CCAF_K=20;
Cfg.SimMicNum=4;
[upb,lowb]=gen_ccaf_mask(20);
