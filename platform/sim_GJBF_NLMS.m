global Cfg;

[voice,interf,noise]=source_gen();
Cfg.cleanspeech=voice;
display(strcat('signal power=',num2str(Cfg.SigPow)));
display(strcat('interferece power=',num2str(Cfg.InfPow)));
display(strcat('noise power=',num2str(Cfg.NoisePow)));
figure;plot(voice);hold on;plot(interf,'r');hold on;plot(noise(1,:),'k');

if Cfg.SourceType==1
	Cfg.idealvad=G729(Cfg.cleanspeech,Cfg.ChanFs,0.01*Cfg.ChanFs*3,0.01*Cfg.ChanFs);%according to the G729.B
	figure;plot(Cfg.cleanspeech);hold on;plot(Cfg.idealvad*abs(max(Cfg.cleanspeech)),'r');grid on;
else
	Cfg.idealvad=ones(1,length(Cfg.cleanspeech));
end

%figure;plot(voice,'r');hold on;plot(Cfg.idealvad,'k');


if Cfg.BFSimMode==0
	%Cfg.DebugEn=1;Cfg.DebugMask=bin2dec('100000');
	gen_geo_chan();
	plot_geo_chan();
	mic_array_input=mapping_geo_chan(voice,interf,noise);
	mic_array_power=zeros(1,Cfg.SimMicNum);
	%figure;plot(Cfg.cleanspeech_chandly,'r');hold on;plot(Cfg.idealvad_chanout,'k');hold on;plot(mic_array_input(2,:),'g');
	for i=1:Cfg.SimMicNum
		mic_array_power(i)=mean(abs(mic_array_input(i,:)).^2);
	end
	Cfg.MicArrayAvgPower=mean(mic_array_power);
	beamformingout=GriffithsJim_BF(mic_array_input);
	%figure;plot(Cfg.cleanspeech_chandly,'r');hold on;plot(Cfg.idealvad_chanout,'k');hold on;plot(mic_array_input(1,:),'g');
	if Cfg.DebugEn && Cfg.GenieEn
		figure;plot(mic_array_input(1,:),'r');
		hold on;plot(Cfg.mic_array_refdata(1,:),'g');
		hold on;plot(Cfg.mic_array_refintf(1,:),'k');
		hold on;plot(Cfg.mic_array_refnoise(1,:),'b');title('BF in')
		figure;plot(beamformingout,'r');
		hold on;plot(Cfg.refdata_beamformingout,'g');
		hold on;plot(Cfg.refintf_beamformingout,'k');
		hold on;plot(Cfg.refnoise_beamformingout,'b');title('BF out');
		figure;
		plot(Cfg.mic_array_refintf(1,:),'g');
		hold on;plot(Cfg.refintf_beamformingout,'k');

		figure;
		plot(Cfg.idealvad_fbfout,'k');
		hold on;plot(Cfg.cleanspeech_bfdly,'g');
		hold on;plot(beamformingout,'r');
		%combine=Cfg.refdata_beamformingout+Cfg.refintf_beamformingout+Cfg.refnoise_beamformingout+0.05;
		%hold on;plot(combine,'b');
		legend('vad','cleanspeech','bf out');
		grid on;title('dly clean speech vs beamforming out vs combine out');

		%figure;plot(Cfg.cleanspeech_chandly,'r');hold on;plot(Cfg.idealvad_chanout,'k');hold on;plot(mic_array_input(1,:),'g');
		SNR_est=snr_est(Cfg.cleanspeech_bfdly,beamformingout,Cfg.idealvad_fbfout);
		display(strcat('SNRout=',num2str(SNR_est)));
		%SNR_est=snr_est(Cfg.cleanspeech_chandly,mic_array_input(2,:),Cfg.idealvad_chanout);
		%display(strcat('SNRin=',num2str(SNR_est)));
		%SNR_est=snr_est(Cfg.cleanspeech_bfdly,Cfg.refdata_beamformingout,Cfg.idealvad_fbfout);
		%display(strcat('Distrotion=',num2str(SNR_est)));

		inf_outpower=sum((abs(Cfg.refintf_beamformingout).^2).*Cfg.idealvad_fbfout)./sum(Cfg.idealvad_fbfout);
		noise_outpower=mean((abs(Cfg.refnoise_beamformingout).^2));
		sig_outpower=sum((abs(Cfg.refdata_beamformingout).^2).*Cfg.idealvad_fbfout)./sum(Cfg.idealvad_fbfout);
		SIR_db=10*log10(sig_outpower/(inf_outpower));
		SNR_db=10*log10(sig_outpower/(noise_outpower));
		SINR_db=10*log10(sig_outpower/(inf_outpower+noise_outpower));
		display(strcat('SIR_ref=',num2str(SIR_db)));
		display(strcat('SNR_ref=',num2str(SNR_db)));
		display(strcat('SINR_ref=',num2str(SINR_db)));

	end
else
	Cfg.DebugMask=0;
	phase_step=10;
	idxrange=1:180/phase_step;
	warmup_sample=5000;
	for idx=idxrange
		if Cfg.BFSimMode==1
			%change source position
			SourcePos=[Cfg.SourcePos(1),(idx-1)*phase_step];InfPos=Cfg.InfPos;
		else
			%change interference position
			SourcePos=Cfg.SourcePos;InfPos=[Cfg.InfPos(1),(idx-1)*phase_step];
		end
		gen_geo_chan(SourcePos,InfPos);
		mic_array_input=mapping_geo_chan(voice,interf,noise);
		mic_array_power=zeros(1,Cfg.SimMicNum);
		if Cfg.GenieEn
			mic_array_refdata_power=zeros(1,Cfg.SimMicNum);
			mic_array_refnoise_power=zeros(1,Cfg.SimMicNum);
			mic_array_refinf_power=zeros(1,Cfg.SimMicNum);
		end
		for i=1:Cfg.SimMicNum
			mic_array_power(i)=sum(abs(mic_array_input(i,:).^2).*Cfg.idealvad_chanout)./sum(Cfg.idealvad_chanout);
			if Cfg.GenieEn
				mic_array_refdata_power(i)=sum(abs(Cfg.mic_array_refdata(i,:).^2).*Cfg.idealvad_chanout)./sum(Cfg.idealvad_chanout);
				mic_array_refintf_power(i)=sum(abs(Cfg.mic_array_refintf(i,:).^2).*Cfg.idealvad_chanout)./sum(Cfg.idealvad_chanout);
				mic_array_refnoise_power(i)=sum(abs(Cfg.mic_array_refnoise(i,:).^2).*Cfg.idealvad_chanout)./sum(Cfg.idealvad_chanout);
			end
		end
		Cfg.MicArrayAvgPower=mean(mic_array_power);
		if Cfg.GenieEn
			Cfg.MicArrayRefDataAvgPower=mean(mic_array_refdata_power);
			Cfg.MicArrayRefIntfAvgPower=mean(mic_array_refintf_power);
			Cfg.MicArrayRefNoiseAvgPower=mean(mic_array_refnoise_power);
		end
		beamformingout=GriffithsJim_BF(mic_array_input);
		outpower=sum((abs(beamformingout(warmup_sample+1:end)).^2).*Cfg.idealvad_fbfout(warmup_sample+1:end))./sum(Cfg.idealvad_fbfout(warmup_sample+1:end));
		powerratio_db(idx)=10*log10(outpower/Cfg.MicArrayAvgPower);
		SNR_est(idx)=snr_est(Cfg.cleanspeech_bfdly,beamformingout,Cfg.idealvad_fbfout);
		if Cfg.GenieEn==1
			inf_outpower=sum((abs(Cfg.refintf_beamformingout).^2).*Cfg.idealvad_fbfout)./sum(Cfg.idealvad_fbfout);
			noise_outpower=mean((abs(Cfg.refnoise_beamformingout).^2));
			sig_outpower=sum((abs(Cfg.refdata_beamformingout).^2).*Cfg.idealvad_fbfout)./sum(Cfg.idealvad_fbfout);
			powerratio2_db(idx)=10*log10(outpower/sig_outpower);
			powerratio2_refdata_db(idx)=10*log10(sig_outpower/Cfg.MicArrayRefDataAvgPower);
			powerratio2_refintf_db(idx)=10*log10(inf_outpower/Cfg.MicArrayRefIntfAvgPower);
			powerratio2_refnoise_db(idx)=10*log10(noise_outpower/Cfg.MicArrayRefNoiseAvgPower);
			SIR_db(idx)=10*log10(sig_outpower/(inf_outpower));
			SNR_db(idx)=10*log10(sig_outpower/(noise_outpower));
			SINR_db(idx)=10*log10(sig_outpower/(inf_outpower+noise_outpower));
		end
	end
	angle_array=(idxrange-1)*phase_step;
	if Cfg.GenieEn==1
		figure;plot(angle_array,SNR_db);
		hold on;plot(angle_array,Cfg.SNR*ones(1,length(angle_array)),'g');
		legend('SNR','input SNR');
		title('Fix Beamforming SNR');
		figure;plot(angle_array,SIR_db,'r');
		hold on;plot(angle_array,Cfg.SIR*ones(1,length(angle_array)),'m');
		legend('output SIR','input SIR')
		title('Fix Beamforming SIR');
		figure;plot(angle_array,SINR_db,'k');
		title('Fix Beamforming Output SINR');
		figure;
		plot(angle_array,powerratio_db,'r');
		hold on;plot(angle_array,powerratio2_db,'b');
		hold on;plot(angle_array,powerratio2_refdata_db,'k');
		hold on;plot(angle_array,powerratio2_refintf_db,'g');
		hold on;plot(angle_array,powerratio2_refnoise_db,'m');
		legend('output/input total power','output total power/output sig power','output signal power/input signal power','output inf power/input inf power','output noise power/input noise power');
		title('Fix Beamforming power');
	end
	figure;plot(angle_array,powerratio_db);grid on;xlabel('angle(degree)');ylabel('att(dB)');
	title('Griffiths&Jim NLMS beam pattern');
	size(SNR_est)
	size(angle_array)
	figure;plot(angle_array,SNR_est);
	SNR_est
	title('Beamforming Output SINR');
end
