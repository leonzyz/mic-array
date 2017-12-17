addpath('../source','../cfg','../platform','../platform/src','../out');
clear all;close all;
global Cfg;

%{
%}
Cfg.DebugEn=1;
Cfg.DebugMask=bin2dec('1000000');
Cfg.CCAF_K=20;
Cfg.SimMicNum=3;
Cfg.MicNum=3;
Cfg.MicRowNum=2;
Cfg.SimMicRowNum=2;
%Cfg.CCAF_MaskFileDir='../source/RA_CCAF_MaskFile_3Mic_Dist1_32K';
Cfg.CCAF_MaskFileDir='../source/RA_CCAF_MaskFile_3Mic_Dist1_32K_Comp20_new';
%[upb,lowb]=gen_ccaf_mask(10);
[upb,lowb]=gen_ccaf_mask_RA(10);


%{
Cfg.DebugEn=1;
Cfg.DebugMask=bin2dec('1000000');
Cfg.CCAF_K=20;
Cfg.SimMicNum=4;
Cfg.MicNum=4;
Cfg.MicRowNum=1;
Cfg.SimMicRowNum=1;
Cfg.CCAF_MaskFileDir='../source/CCAF_MaskFile_4Mic_Dist4';
[upb,lowb]=gen_ccaf_mask(20);
%}
