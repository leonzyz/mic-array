%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gen_geo_chan: generate XY Pos of mic-array,source and interference

%	Input:
%		voice: source voice data
%		interf: interference data
%		noise: noise of each mic
%	Global Parma:Cfg, including ChanMode,channel geometry param etc.
%	Ouput:
%		mic_array_data: MicArray samples in Cfg.AdcFs(with interf & noise).
%	Global Param Out: reference data for segment SNR calculation
%		Cfg.mic_array_refdata: MicArray samples in Cfg.AdcFs(with only signal)
%		Cfg.mic_array_refnoise: MicArray samples in Cfg.AdcFs(with only noise)
%		Cfg.mic_array_refintf: MicArray samples in Cfg.AdcFs(with only interference)
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
	mic_array_data=zeros(Cfg.SimMicNum,floor(out_len),Cfg.SimMicRowNum);
	Cfg.SourceDelay=zeros(size(Cfg.DistS2M));
	Cfg.InfDelay=zeros(size(Cfg.DistI2M));
	Cfg.SourceDelaySample=zeros(size(Cfg.DistS2M));
	Cfg.InfDelaySample=zeros(size(Cfg.DistI2M));
	for r=1:Cfg.SimMicRowNum

		Cfg.SourceDelay(:,r)=Cfg.DistS2M(:,r)./Cfg.VoiceSpeed;
		Cfg.InfDelay(:,r)=Cfg.DistI2M(:,r)./Cfg.VoiceSpeed;
		Cfg.SourceDelaySample(:,r)=Cfg.SourceDelay(:,r)*Cfg.ChanFs;
		Cfg.InfDelaySample(:,r)=Cfg.InfDelay(:,r)*Cfg.ChanFs;
		SincFiltLen=15;
		SincFiltDly=(SincFiltLen-1);
		Cfg.SourceDelaySampleInt(:,r)=floor(Cfg.SourceDelaySample(:,r))-SincFiltDly;
		Cfg.InfDelaySampleInt(:,r)=floor(Cfg.InfDelaySample(:,r))-SincFiltDly;
		if Cfg.GenieEn==1
			Cfg.mic_array_refdata=zeros(Cfg.SimMicNum,floor(out_len),Cfg.SimMicRowNum);
			Cfg.mic_array_refnoise=zeros(Cfg.SimMicNum,floor(out_len),Cfg.SimMicRowNum);
			Cfg.mic_array_refintf=zeros(Cfg.SimMicNum,floor(out_len),Cfg.SimMicRowNum);
		end
		for i=1:Cfg.SimMicNum
			frac_dly=Cfg.SourceDelaySample(i,r)-floor(Cfg.SourceDelaySample(i,r));
			h_sinc=sinc([-SincFiltDly:1:SincFiltDly]+frac_dly);
			src_tmpin=zeros(1,src_len);
			src_tmpin(Cfg.SourceDelaySampleInt(i,r)+1:end)=voice(1:end-Cfg.SourceDelaySampleInt(i,r));
			src_tmpin=filter(h_sinc,1,src_tmpin);

			frac_dly=Cfg.InfDelaySample(i,r)-floor(Cfg.InfDelaySample(i,r));
			h_sinc=sinc([-SincFiltDly:1:SincFiltDly]+frac_dly);
			inf_tmpin=zeros(1,src_len);
			inf_tmpin(Cfg.InfDelaySampleInt(i,r)+1:end)=interf(1:end-Cfg.InfDelaySampleInt(i,r));
			inf_tmpin=filter(h_sinc,1,inf_tmpin);
			adcin=src_tmpin+inf_tmpin;
			mic_array_data(i,:,r)=adcin(1:AdcFsRatio:end)+noise(1:out_len);
			if Cfg.GenieEn==1
				Cfg.mic_array_refdata(i,:,r)=src_tmpin(1:AdcFsRatio:end);
				Cfg.mic_array_refintf(i,:,r)=inf_tmpin(1:AdcFsRatio:end);
				Cfg.mic_array_refnoise(i,:,r)=noise(1:out_len);
			end
		end
	end
	Cfg.SourceDlyChanOut=floor(((mean(mean(Cfg.SourceDelaySample))))/AdcFsRatio);
	Cfg.idealvad_chanout=zeros(1,out_len);
	Cfg.idealvad_chanout(1+Cfg.SourceDlyChanOut:end)=Cfg.idealvad(1:AdcFsRatio:end-Cfg.SourceDlyChanOut*AdcFsRatio);
	Cfg.cleanspeech_chandly=zeros(1,out_len);
	Cfg.cleanspeech_chandly(1+Cfg.SourceDlyChanOut:end)=Cfg.cleanspeech(1:AdcFsRatio:end-Cfg.SourceDlyChanOut*AdcFsRatio);
	if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('01'))
		figure;
		for r=1:Cfg.SimMicRowNum
			for i=1:Cfg.SimMicNum
				plot(mic_array_data(i,:,r));hold on;
			end
		end
		grid on;title('channel mapping debug out');
	end
end
