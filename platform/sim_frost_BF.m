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


if Cfg.BFSimMode==0
	Cfg.DebugEn=1;Cfg.DebugMask=bin2dec('010000');
	gen_geo_chan();
	plot_geo_chan();
	mic_array_input=mapping_geo_chan(voice,interf,noise);
	mic_array_power=zeros(1,Cfg.SimMicNum);
	for i=1:Cfg.SimMicNum
		mic_array_power(i)=mean(abs(mic_array_input(i,:)).^2);
	end
	Cfg.MicArrayAvgPower=mean(mic_array_power);
	beamformingout=frost_beamforming(mic_array_input);
	figure;plot(beamformingout);
else
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
		%plot_geo_chan();
		mic_array_input=mapping_geo_chan(voice,interf,noise);
		mic_array_power=zeros(1,Cfg.SimMicNum);
		for i=1:Cfg.SimMicNum
			mic_array_power(i)=sum(abs(mic_array_input(i,:).^2).*Cfg.idealvad_chanout)./sum(Cfg.idealvad_chanout);
		end
		Cfg.MicArrayAvgPower=mean(mic_array_power);
		beamformingout=frost_beamforming(mic_array_input);
		outpower=sum((abs(beamformingout(warmup_sample+1:end)).^2).*Cfg.idealvad_fbfout(warmup_sample+1:end))./sum(Cfg.idealvad_fbfout(warmup_sample+1:end));
		powerratio_db(idx)=10*log10(outpower/Cfg.MicArrayAvgPower);
		if Cfg.GenieEn==1
			inf_outpower=sum((abs(Cfg.refintf_beamformingout).^2).*Cfg.idealvad_fbfout)./sum(Cfg.idealvad_fbfout);
			noise_outpower=mean((abs(Cfg.refnoise_beamformingout).^2));
			sig_outpower=sum((abs(Cfg.refdata_beamformingout).^2).*Cfg.idealvad_fbfout)./sum(Cfg.idealvad_fbfout);
			powerratio2_db(idx)=10*log10(outpower/sig_outpower);
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
		plot(angle_array,-powerratio_db,'r');
		hold on;plot(angle_array,-powerratio2_db,'b');
		legend('output sig power/ output total power','input/output total power')
		title('Fix Beamforming power');
	end
	figure;plot(angle_array,powerratio_db);
	title('Fix Beamforming Output Power');
end
