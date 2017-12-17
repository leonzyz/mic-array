%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% readcfg: Read configuretion patarmeter for platform
%   Example:
%   Cfg.XXX=Value;	%Comment

%   Author: leonzyz
%   Date: 2017/10/21 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global Cfg;
Cfg.Scenario=0;	%0=general model,1=fixbeamforming,2=frost beamforming,3=GJBF
Cfg.BeamformingMode=5;	%beamforming mode in general model,0=fixbeamforming,1=frost beamforming,2=GJBF,3=CCAF+NCAF,4=rectanguler array CCAF+NCAF, 5=rectanguler array CCAF+NCAF 2X1D, 
Cfg.BFSimMode=2;	%0=debug,1=power sweep, fix steer angle, try different source angle,2=interference sweep, fix steer angle and source angle, try different interference angle,3=get CCAF mask
Cfg.BFSimPhaseStep=10;
Cfg.GenieEn=0;	%Genie info enable
Cfg.DebugEn=0;	%0=disable,1=enable
Cfg.DebugMask=bin2dec('0000000');	%bit0=channel mapping out, bit1=fbf in,bit2=beampattern steer out,bit3=source gen,bit4=frost/GJBF/CCAF ABM BF debug,bit 5=SNR debug,bit 6=CCAF Mask debug
Cfg.FixEn=0;	%
Cfg.AdcFs=32e3;	%processing sample rate
Cfg.ChanFs=64e3;	%modeling sample rate
Cfg.ChanMode=0;	%0=simple delay mode,1=reveberant room
Cfg.MicRowNum=2	% Mic array row number, the first row is at Y postion=0,
Cfg.MicNum=3;	%microphone number
%Cfg.MicNum=3;	%microphone number
Cfg.MicDist=1.0e-2;	%microphone distance
%Cfg.MicDist=4.1e-2;	%microphone distance
Cfg.MicRowDist=18e-2;	%mic array distance of each row
%Cfg.MicDist=1.1e-2;	%microphone distance
Cfg.MicArrayType=0;	%0=ULA,1=RLA,etc
Cfg.SNR=40;	%SNR of single microphone
Cfg.SIR=0;	%SIR of single microphone
%Cfg.TargetSigPow=0.1;	%
Cfg.SourceType=2;	%0=single tone,1=voice,2=bandpass gaussian signal
Cfg.SourceFreq=100;	%only for SourceType=0
Cfg.SourceVadMaskEn=1;	%only for Source Typt 0/2
Cfg.SourceVadMaskMode=1;	%0=Interference first,1=signal first
Cfg.SourceVadMaskPeriod=5;	%VAD Mask period
Cfg.SourceVadMaskLen=3;	%VAD Mask length of "1"
Cfg.SourceDuration=30;	%in unit of second,only for SourceType=0 & 2
Cfg.SourceBW=[300,3700];	%bandpass gaussian signal start/end freq
Cfg.SourcePower=0.1;	%only for SourceType 0 & 2
Cfg.SourceFilename='../source/wav/arctic_a0114-sin.wav';	%only for SourceType=1
%Cfg.SourceFs=16e3;	%voice source file sample rate,if the source file contain Fs, it will be overwrote
Cfg.SourcePos=[10,0];	%voice source distance and direction
Cfg.NoiseType=0;	%Interference typ,0=awgn,1=noise source
%Cfg.NoiseBW=8e3;	%only for NoiseType=0
Cfg.NoiseFilename='source/noise.wav';	%only for SourceType=1
%Cfg.NoiseFs=16e3;	%if the source file contain Fs, it will be overwrote
Cfg.InfType=1;	%0=single tone,1=lowpass awgn,2=voice source
Cfg.InfNum=0;	%number of interference
Cfg.InfFreq=1.7e3;	%only for InfType=0
Cfg.InfBW=4e3;	%only for InfType=1
%Cfg.InfFs=16e3;	%if the source file contain Fs, it will be overwrote
Cfg.InfFilename='source/wav/arctic_a0118-sin.wav';	%only for InfType=2
Cfg.InfPos=[20,140];	%voice source distance and direction
Cfg.InfVadMaskEn=0;		%
Cfg.GccEn=0;	%0=GCC disble, 1=GCC enable
Cfg.GccNotchEn=0;	%
Cfg.FBFSteerMode=1;	%0=delay sum,1=filter sum(sinc function)
Cfg.FBFSteerAngle=0;
Cfg.FBFfiltLen=15;	%for FBF mode=1
Cfg.FBFMode=0;	%0=1/N sum,1=cheby approx
Cfg.CCAF_u=0.1;	%adaptive beam forming training speed of CCAF
Cfg.CCAF_AdaptionU=1;	%CCAF u factor adaption enable,0=fix CCAF u,1=adaptive u
Cfg.CCAF_K=20;
Cfg.CCAF_dlyComp=15;	%delay comp on steering out to align CCAF in and FBF out
%Cfg.CCAF_K=8;
%Cfg.CCAF_dlyComp=7;	%delay comp on steering out to align CCAF in and FBF out
Cfg.CCAF_MaskEn=1;	%CCAF_Mask
Cfg.CCAF_MaskGen_MaxAngle=40;
Cfg.CCAF_MaskMaxAngle=10;
%Cfg.CCAF_MaskFileDir='../source/CCAF_MaskFile_4Mic_Dist4';
%Cfg.CCAF_MaskFileDir='../source/CCAF_MaskFile_3Mic_Dist1';
%Cfg.CCAF_MaskFileDir='../source/CCAF_MaskFile_3Mic_Dist1_32K';
Cfg.CCAF_MaskFileDir='../source/CCAF_MaskFile_3Mic_Dist1_32K';
%Cfg.CCAF_MaskUpperBound=[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
%Cfg.CCAF_MaskLowerBound=[-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1];
Cfg.CcafVadMaskEn=1;
Cfg.ANC_u=0.2;	%adaptive beam forming training speed of ANC
Cfg.ANC_AdaptionU=1;	%ANC u factor adaption enable,0=fix ANC u,1=adaptive u
Cfg.ANC_dlyComp=40;	%delay comp on FBF out to align CCAF out and FBF out
Cfg.ANC_K=20;
Cfg.BlockMatrixType=0;	%BM type for GJBF, 0=[1,-1,0..] cyclic vector, 1=partial hadamar matrix
Cfg.ANC_metric_NormEn=1;	%ANC normalization enable
Cfg.ANC_metric_NormTH=20;	%ANC normalization Threshold
Cfg.AncVadMaskEn=1;	%0=ANC training all the time, 1=ANC traininig only when VAD=0
Cfg.CCAF_TimerEn=0;
Cfg.CCAF_TrainLength=50000; %3*16e3+1000;
Cfg.ANC_TimerEn=0;
Cfg.ANC_TrainLength=150000; %2*16e3-1000;
Cfg.SnrWarmUp=200000;
