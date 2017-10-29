%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% source_gen: generate target source,interference
% and noise for simulation

%	Input:
%		DebugEn: debug info enable
%	Global Parma:Cfg
%	Ouput:
%		voice: target signal source @ ChanFs
%		interf: interferece from another direction @ChanFs
%		noise: spatial noncorrelation noise of M mic @Fs
%	
%   Author: leonzyz
%   Date: 2017/10/21 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [voice,interf,noise]=source_gen(DebugEn)
global Cfg;
if Cfg.SourceType==0
	Cfg.SigPow=0.5;
	fs=Cfg.ChanFs;
	len=Cfg.SourceDuration*Cfg.ChanFs;
	voice=sin([0:len-1]*2*pi*Cfg.SourceFreq/fs);
else
	[voice_src,fs]=wavread(Cfg.SourceFilename);
	upsample_rate=Cfg.ChanFs/fs;
	%display(strcat('upsample_rate=',num2str(upsample_rate)))
	if upsample_rate<1
		voice=resample(voice_src,1,1/upsample_rate,64);
	else
		voice=resample(voice_src,upsample_rate,1,64);
	end
	vadflag=G729(voice,Cfg.ChanFs,0.01*Cfg.ChanFs*3,0.01*Cfg.ChanFs);
	Cfg.SigPow=mean(abs(voice).^2)*length(vadflag)/sum(vadflag);
end
Cfg.InfPow=Cfg.SigPow/10^(Cfg.SIR/10);
Cfg.NoisePow=Cfg.SigPow/10^(Cfg.SNR/10);

if Cfg.InfType==0
	len=Cfg.SourceDuration*Cfg.ChanFs;
	scaler=sqrt(Cfg.InfPow*2);
	interf=cos([0:len-1]*2*pi*Cfg.InfFreq/Cfg.ChanFs)*scaler;
elseif Cfg.InfType==1
	bwratio=Cfg.InfBW/(Cfg.ChanFs/2);
	len=Cfg.SourceDuration*Cfg.ChanFs;
	fN=126;
	delta=0.05*bwratio;
	ant=10^(-40/20);%-40dB anttenuation
	f=[0,bwratio,bwratio+delta,1-delta];
	a=[1,1,ant,ant];
	h=firls(fN,f,a);
	if DebugEn
		fvtool(h,1);
	end
	scaler=sqrt(Cfg.InfPow/bwratio);
	tmp_noise=randn(1,len+2*fN)*scaler;
	noise_filter=filter(h,1,tmp_noise);
	interf=(noise_filter(fN:fN+len-1)).';
else
	[interf_src,fs]=wavread(Cfg.InfFilename);
	upsample_rate=Cfg.ChanFs/fs;
	%display(strcat('upsample_rate=',num2str(upsample_rate)))
	if upsample_rate>1
		interf_tmp=resample(interf_src,upsample_rate,1,64);
	else
		interf_tmp=resample(interf_src,1,1/upsample_rate,64);
	end
	vadflag=G729(interf_tmp,Cfg.ChanFs,0.01*Cfg.ChanFs*3,0.01*Cfg.ChanFs);
	interf_pow=mean(abs(interf_tmp).^2)*length(vadflag)/sum(vadflag);
	scaler=sqrt(Cfg.InfPow/interf_pow);
	interf=interf*scaler;
end
if length(interf)>length(voice)
	interf=interf(1:length(voice));
elseif length(interf)<length(voice);
	interf=[interf,zeros(1,length(voice)-length(interf))];
end

len=Cfg.SourceDuration*Cfg.AdcFs;
noise=zeros(Cfg.MicNum,len);
if Cfg.NoiseType==0
	scaler=sqrt(Cfg.NoisePow);
	for i=1:Cfg.MicNum
		noise(i,:)=randn(1,len)*scaler;
	end
else
	[noise_src,fs]=readwave(Cfg.NoiseFilename);
	upsample_rate=Cfg.AdcFs/fs;
	if upsample_rate>1
		noise_tmp=resample(noise_src,upsample_rate,1,64);
	else
		noise_tmp=resample(noise_src,1,1/upsample_rate,64);
	end
	noise_pow=mean(abs(noise_tmp).^2);
	scaler=sqrt(Cfg.NoisePow/noise_pow);
	if length(noise_tmp)<Cfg.MicNum*len
		display('error! noise source length is too short');
	end
	for i=1:Cfg.MicNum
		range_idx=(i-1)*len+[1:len];
		noise(i,:)=noise_tmp(range_idx);
	end
end

