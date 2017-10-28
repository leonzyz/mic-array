%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% readcfg: Read configuretion patarmeter for platform
%   Example:
%   Cfg.XXX=Value;	%Comment

%   Author: leonzyz
%   Date: 2017/10/21 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global Cfg;
Cfg.Scenario=0;	%0=test_subfunction,1=fixbeamforming
Cfg.DebugEn=1;	%0=disable,1=enable
Cfg.FixEn=0;	%
Cfg.AdcFs=16e3;	%processing sample rate
Cfg.ChanFs=64e3;	%modeling sample rate
Cfg.ChanType=0;	%0=single impulse channel;1=
Cfg.MicNum=4;	%microphone number
Cfg.MicDist=4.1e-2;	%microphone distance
Cfg.SNR=10;	%SNR of single microphone
Cfg.SIR=10;	%SIR of single microphone
%Cfg.TargetSigPow=0.1;	%
Cfg.SourceType=1;	%0=single tone,1=voice
Cfg.SourceFreq=500;	%only for SourceType=0
Cfg.SourceDuration=4;	%second,only for SourceType=0
Cfg.SourceFilename='../source/wav/arctic_a0114-sin.wav';	%only for SourceType=1
%Cfg.SourceFs=16e3;	%voice source file sample rate,if the source file contain Fs, it will be overwrote
Cfg.SourcePos=[1,90];	%voice source distance and direction
Cfg.NoiseType=0;	%Interference typ,0=awgn,1=noise source
%Cfg.NoiseBW=8e3;	%only for NoiseType=0
Cfg.NoiseFilename='source/noise.wav';	%only for SourceType=1
%Cfg.NoiseFs=16e3;	%if the source file contain Fs, it will be overwrote
Cfg.InfType=1;	%0=single tone,1=lowpass awgn,2=voice source
Cfg.InfNum=0;	%number of interference
Cfg.InfFreq=1e3;	%only for InfType=0
Cfg.InfBW=4e3;	%only for InfType=1
%Cfg.InfFs=16e3;	%if the source file contain Fs, it will be overwrote
Cfg.InfFilename='source/wav/arctic_a0118-sin.wav';	%only for InfType=2
Cfg.InfPos=[1,45];	%voice source distance and direction
