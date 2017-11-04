%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gen_geo_chan: generate XY Pos of mic-array,source and interference

%	Input:
%		voice: source voice data
%		interf: interference data
%		noise: noise of each mic
%	Global Parma:Cfg, including ChanMode,channel geometry param etc.
%	Ouput:
%		mic_array_data: MicArray samples in Cfg.AdcFs(with interf & noise).
%	
%   Author: leonzyz
%   Date: 2017/11/03 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function mic_array_data=mapping_geo_chan(voice,interf,noise)
global Cfg;
src_len=length(voice);
AdcFsRatio=floor(Cfg.ChanFs/Cfg.AdcFs);
out_len=floor(src_len/AdcFsRatio);
Cfg.ChanAdcFsRatio=AdcFsRatio;

if Cfg.ChanMode==0
	Cfg.SourceDelay=Cfg.DistS2M./Cfg.VoiceSpeed;
	Cfg.InfDelay=Cfg.DistI2M./Cfg.VoiceSpeed;
	Cfg.SourceDelaySample=Cfg.SourceDelay*Cfg.ChanFs;
	Cfg.InfDelaySample=Cfg.InfDelay*Cfg.ChanFs;
	SincFiltLen=15;
	SincFiltDly=(SincFiltLen-1);
	Cfg.SourceDelaySampleInt=floor(Cfg.SourceDelaySample)-SincFiltDly;
	Cfg.InfDelaySampleInt=floor(Cfg.InfDelaySample)-SincFiltDly;
	mic_array_data=zeros(Cfg.SimMicNum,floor(out_len));
	for i=1:Cfg.SimMicNum
		frac_dly=Cfg.SourceDelaySample(i)-floor(Cfg.SourceDelaySample(i));
		h_sinc=sinc([-SincFiltDly:1:SincFiltDly]+frac_dly);
		src_tmpin=zeros(1,src_len);
		src_tmpin(Cfg.SourceDelaySampleInt(i)+1:end)=voice(1:end-Cfg.SourceDelaySampleInt(i));
		src_tmpin=filter(h_sinc,1,src_tmpin);

		frac_dly=Cfg.InfDelaySample(i)-floor(Cfg.InfDelaySample(i));
		h_sinc=sinc([-SincFiltDly:1:SincFiltDly]+frac_dly);
		inf_tmpin=zeros(1,src_len);
		inf_tmpin(Cfg.InfDelaySampleInt(i)+1:end)=interf(1:end-Cfg.InfDelaySampleInt(i));
		inf_tmpin=filter(h_sinc,1,inf_tmpin);
		adcin=src_tmpin+inf_tmpin;
		mic_array_data(i,:)=adcin(1:AdcFsRatio:end)+noise(1:out_len);
	end
	Cfg.SourceDlyChanOut=floor(((mean(Cfg.SourceDelaySample))+SincFiltDly)/AdcFsRatio);
	Cfg.idealvad_chanout=zeros(1,out_len);
	Cfg.idealvad_chanout(1+Cfg.SourceDlyChanOut:end)=Cfg.idealvad(1:AdcFsRatio:end-Cfg.SourceDlyChanOut*AdcFsRatio);
	if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('01'))
		figure;
		for i=1:Cfg.SimMicNum
			plot(mic_array_data(i,:));hold on;
		end
		grid on;title('channel mapping debug out');
	end
end
