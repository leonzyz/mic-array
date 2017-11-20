%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% readcfg: Read configuretion patarmeter for platform
%   Example:
%   Cfg.XXX=Value;	%Comment

%   Author: leonzyz
%   Date: 2017/10/21 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global Cfg;
Cfg.Scenario=0;	%0=general model,1=fixbeamforming,2=frost beamforming,3=GJBF
Cfg.BeamformingMode=2;	%beamforming mode in general model,0=fixbeamforming,1=frost beamforming,2=GJBF,3=CCAF+NCAF
Cfg.BFSimMode=2;	%0=debug,1=power sweep, fix steer angle, try different source angle,2=interference sweep, fix steer angle and source angle, try different interference angle
Cfg.GenieEn=1;	%Genie info enable
Cfg.DebugEn=1;	%0=disable,1=enable
Cfg.DebugMask=bin2dec('000000');	%bit0=channel mapping out, bit1=fbf in,bit2=beampattern steer out,bit3=snr debug,bit4=frost/GJBF/CCAF ABM BF debug 
Cfg.FixEn=0;	%
Cfg.AdcFs=16e3;	%processing sample rate
Cfg.ChanFs=64e3;	%modeling sample rate
Cfg.ChanMode=0;	%0=simple delay mode,1=reveberant room
Cfg.MicNum=4;	%microphone number
%Cfg.MicNum=3;	%microphone number
%Cfg.MicDist=0.8e-2;	%microphone distance
Cfg.MicDist=4.1e-2;	%microphone distance
%Cfg.MicDist=1.1e-2;	%microphone distance
Cfg.MicArrayType=0;	%0=ULA,1=RLA,etc
Cfg.SNR=40;	%SNR of single microphone
Cfg.SIR=0;	%SIR of single microphone
%Cfg.TargetSigPow=0.1;	%
Cfg.SourceType=2;	%0=single tone,1=voice,2=bandpass gaussian signal
Cfg.SourceFreq=600;	%only for SourceType=0
Cfg.SourceVadMaskEn=1;	%only for Source Typt 0/2
Cfg.SourceVadMaskPeriod=0.5;	%VAD Mask period
Cfg.SourceVadMaskLen=0.3;	%VAD Mask length of "1"
Cfg.SourceDuration=2;	%in unit of second,only for SourceType=0 & 2
Cfg.SourceBW=[300,3700];	%bandpass gaussian signal start/end freq
Cfg.SourcePower=0.1;	%only for SourceType 0 & 2
Cfg.SourceFilename='../source/wav/arctic_a0114-sin.wav';	%only for SourceType=1
%Cfg.SourceFs=16e3;	%voice source file sample rate,if the source file contain Fs, it will be overwrote
Cfg.SourcePos=[40,90];	%voice source distance and direction
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
Cfg.InfPos=[10,120];	%voice source distance and direction
Cfg.GccEn=0;	%0=GCC disble, 1=GCC enable
Cfg.GccNotchEn=0;	%
Cfg.FBFSteerMode=1;	%0=delay sum,1=filter sum(sinc function)
Cfg.FBFSteerAngle=90;
Cfg.FBFfiltLen=11;	%for FBF mode=1
Cfg.FBFMode=0;	%0=1/N sum,1=cheby approx
Cfg.CCAF_u=0.05;	%adaptive beam forming training speed of CCAF
Cfg.ANC_u=0.05;	%adaptive beam forming training speed of ANC
Cfg.ANC_AdaptionU=1;	%ANC u factor adaption enable,0=fix ANC u,1=adaptive u
Cfg.BlockMatrixType=0;	%BM type for GJBF, 0=[1,-1,0..] cyclic vector, 1=partial hadamar matrix
Cfg.ANC_W_NormEn=1;	%ANC normalization enable
Cfg.ANC_W_NormTH=10;	%ANC normalization Threshold
Cfg.AncVadMaskEn=1;	%0=ANC training all the time, 1=ANC traininig only when VAD=0
