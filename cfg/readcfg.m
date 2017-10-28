%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% readcfg: Read configuretion patarmeter for platform
%   Example:
%   Cfg.XXX=Value;	%Comment

%   Author: leonzyz
%   Date: 2017/10/21 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Cfg.MicNum=4;	%microphone number
Cfg.MicDist=4.1e-2;	%microphone distance
Cfg.SourceType=0;	%0=single tone,1=voice
Cfg.SourceFreq=1e3;	%only for SourceType=0
Cfg.SourceLen=1e3;	%only for SourceType=0
Cfg.SourceFilename="test.adc";	%only for SourceType=1
Cfg.NoiseTpye=0;	%Interference typ,0=awgn,1=noise source
Cfg.NoiseFilename="noise.wav";	%only for SourceType=1
Cfg.SNR=10;	%SNR of single microphone
Cfg.SIR=10;	%SIR of single microphone
