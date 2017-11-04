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
Cfg.DebugMask=bin2dec('1000');	%bit 0=mapping geometry channel debug
Cfg.FixEn=0;	%
Cfg.AdcFs=16e3;	%processing sample rate
Cfg.ChanFs=64e3;	%modeling sample rate
Cfg.ChanType=0;	%0=single impulse channel;1=
Cfg.MicNum=4;	%microphone number
Cfg.MicDist=4.1e-2;	%microphone distance
Cfg.MicArrayType=0;	%0=ULA,1=RLA,etc
Cfg.SNR=30;	%SNR of single microphone
Cfg.SIR=30;	%SIR of single microphone
%Cfg.TargetSigPow=0.1;	%
Cfg.SourceType=0;	%0=single tone,1=voice
Cfg.SourceFreq=3000;	%only for SourceType=0
Cfg.SourceDuration=4;	%second,only for SourceType=0
Cfg.SourceFilename='../source/wav/arctic_a0114-sin.wav';	%only for SourceType=1
%Cfg.SourceFs=16e3;	%voice source file sample rate,if the source file contain Fs, it will be overwrote
Cfg.SourcePos=[1,135];	%voice source distance and direction
Cfg.NoiseType=0;	%Interference typ,0=awgn,1=noise source
%Cfg.NoiseBW=8e3;	%only for NoiseType=0
Cfg.NoiseFilename='source/noise.wav';	%only for SourceType=1
%Cfg.NoiseFs=16e3;	%if the source file contain Fs, it will be overwrote
Cfg.InfType=0;	%0=single tone,1=lowpass awgn,2=voice source
Cfg.InfNum=0;	%number of interference
Cfg.InfFreq=1.3e3;	%only for InfType=0
Cfg.InfBW=2e3;	%only for InfType=1
%Cfg.InfFs=16e3;	%if the source file contain Fs, it will be overwrote
Cfg.InfFilename='source/wav/arctic_a0118-sin.wav';	%only for InfType=2
Cfg.InfPos=[1,45];	%voice source distance and direction
Cfg.ChanMode=0;	%0=simple delay mode,1=reveberant room
Cfg.GccEn=0;	%0=GCC disble, 1=GCC enable
Cfg.FBFSteerMode=1;	%0=delay sum,1=filter sum(sinc function)
Cfg.FBFSteerAngle=80;
Cfg.FBFfiltLen=15;	%for FBF mode=1
Cfg.FBFMode=0;	%0=1/N sum,1=cheby approx
