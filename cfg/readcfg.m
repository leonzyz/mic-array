%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% readcfg: Read configuretion patarmeter for platform
%   Example:
%   Cfg.XXX=Value;	%Comment

%   Author: leonzyz
%   Date: 2017/10/21 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global Cfg;
Cfg.Scenario=0;	%0=test_subfunction,1=fixbeamforming
Cfg.Fs=16e3;	%processing sample rate
Cfg.ChanFs=64e3;	%modeling sample rate
Cfg.ChanType=0;	%0=single impulse channel;1=
Cfg.MicNum=4;	%microphone number
Cfg.MicDist=4.1e-2;	%microphone distance
Cfg.SNR=10;	%SNR of single microphone
Cfg.SIR=10;	%SIR of single microphone
Cfg.SourceType=0;	%0=single tone,1=voice
Cfg.SourceFreq=1e3;	%only for SourceType=0
Cfg.SourceLen=1e3;	%only for SourceType=0
Cfg.SourceFilename="source/test.adc";	%only for SourceType=1
%Cfg.SourceFs=16e3;	%voice source file sample rate
Cfg.SourcePos=[1,90];	%voice source distance and direction
Cfg.NoiseTpye=0;	%Interference typ,0=awgn,1=noise source
Cfg.NoiseFilename="source/noise.wav";	%only for SourceType=1
%Cfg.NoiseFs=16e3;	%only for SourceType=1
Cfg.InfType=0;	%0=single tone,1=awgn,2=voice source
Cfg.InfNum=0;	%number of interference
Cfg.InfFreq=1.5e3;	%only for InfType=0
Cfg.InfBW=8e3;	%only for InfType=1
%Cfg.InfFs=16e3;	%only for InfType=2
Cfg.InfFilename="source/wav";	%only for InfType=2
Cfg.InfPos=[1,45];	%voice source distance and direction
