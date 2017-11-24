global Cfg;

[voice,interf,noise]=source_gen();
Cfg.cleanspeech=voice;
display(strcat('signal power=',num2str(Cfg.SigPow)));
display(strcat('interferece power=',num2str(Cfg.InfPow)));
display(strcat('noise power=',num2str(Cfg.NoisePow)));

if Cfg.SourceType==1
	Cfg.idealvad=G729(Cfg.cleanspeech,Cfg.ChanFs,0.01*Cfg.ChanFs*3,0.01*Cfg.ChanFs);%according to the G729.B
	%figure;plot(Cfg.cleanspeech);hold on;plot(Cfg.idealvad*abs(max(Cfg.cleanspeech)),'r');grid on;
else
	Cfg.idealvad=ones(1,length(Cfg.cleanspeech));
end

if Cfg.BeamformingMode==3 && Cfg.CCAF_MaskEn==1
	[upb,lowb]=gen_ccaf_mask(Cfg.CCAF_MaskMaxAngle);
	Cfg.CCAF_MaskUpperBound=upb;
	Cfg.CCAF_MaskLowerBound=lowb;
end

%figure;plot(voice,'r');hold on;plot(Cfg.idealvad,'k');

src_len=length(voice);
if Cfg.SourceVadMaskEn==1 && Cfg.SourceType~=1
	vadmask=zeros(1,src_len);
	maskperiod=Cfg.SourceVadMaskPeriod*Cfg.ChanFs;
	masklen1=Cfg.SourceVadMaskLen*Cfg.ChanFs;
	masklen0=maskperiod-masklen1;
	segnum=floor(src_len/maskperiod);
	for i=1:segnum
		if Cfg.SourceVadMaskMode==0
			rangeidx=(1:masklen1)+masklen0+(i-1)*maskperiod;
		else
			rangeidx=(1:masklen1)+(i-1)*maskperiod;
		end
		vadmask(rangeidx)=ones(1,masklen1);
	end
	s1=size(vadmask);s2=size(voice);s3=size(interf);
	Cfg.idealvad=Cfg.idealvad.*vadmask;
	if s1==s2
		voice=voice.*(vadmask);
	else
		voice=voice.*(vadmask).';
	end
	if Cfg.InfVadMaskEn
		if s1==s3
			interf=interf.*(1-vadmask);
		else
			interf=interf.*(1-vadmask).';
		end
	end
	Cfg.cleanspeech=voice;
	Cfg.SnrWarmUp=(maskperiod*2)*Cfg.AdcFs/Cfg.ChanFs;
end
%figure;plot(voice);hold on;plot(interf,'r');hold on;plot(noise(1,:),'k');


if Cfg.BFSimMode==0
	%Cfg.DebugEn=1;Cfg.DebugMask=bin2dec('100000');
	gen_geo_chan();
	%plot_geo_chan();
	mic_array_input=mapping_geo_chan(voice,interf,noise);
	mic_array_power=zeros(1,Cfg.SimMicNum);
	%figure;plot(Cfg.cleanspeech_chandly,'r');hold on;plot(Cfg.idealvad_chanout,'k');hold on;plot(mic_array_input(2,:),'g');
	for i=1:Cfg.SimMicNum
		mic_array_power(i)=mean(abs(mic_array_input(i,:)).^2);
	end
	if Cfg.CCAF_TimerEn && Cfg.ANC_TimerEn
		warmup_sample=Cfg.CCAF_TrainLength+Cfg.ANC_TrainLength;
	else
		warmup_sample=Cfg.SnrWarmUp;
	end
	warmup_sample
	Cfg.MicArrayAvgPower=mean(mic_array_power);
	beamformingout=beamforming(mic_array_input);
	outpower=sum((abs(beamformingout(warmup_sample+1:end)).^2).*Cfg.idealvad_fbfout(warmup_sample+1:end))./sum(Cfg.idealvad_fbfout(warmup_sample+1:end));
	outpower
	powerratio_db=10*log10(outpower/Cfg.MicArrayAvgPower);
	if Cfg.SourceVadMaskEn && Cfg.InfVadMaskEn
		infpowerin=sum(abs(interf(warmup_sample+1:end)).^2.*((1-Cfg.idealvad(warmup_sample+1:end))).')./sum(1-Cfg.idealvad(warmup_sample+1:end));
		infpowerout=sum((abs(beamformingout(warmup_sample+1:end)).^2).*(1-Cfg.idealvad_fbfout(warmup_sample+1:end)))./sum((1-Cfg.idealvad_fbfout(warmup_sample+1:end)));
		infpowerratio_db=10*log10(infpowerout/infpowerin);
	end
	%figure;plot(Cfg.cleanspeech_chandly,'r');hold on;plot(Cfg.idealvad_chanout,'k');hold on;plot(mic_array_input(1,:),'g');
	if Cfg.DebugEn 
		if Cfg.GenieEn
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

		figure;
		err=Cfg.cleanspeech_bfdly-beamformingout;
		plot(Cfg.idealvad_fbfout,'b');
		hold on;plot(Cfg.cleanspeech_bfdly,'g');
		hold on;plot(beamformingout,'r');
		hold on;plot(err,'k');
		legend('vad','cleanspeech','bf out','error');
		grid on;title('dly clean speech vs beamforming out vs combine out vs error');
		%figure;
		%plot(Cfg.cleanspeech_chandly);hold on;plot(mic_array_input(1,:),'r');
		%legend('cleanspeech','mic in');grid on;title('cleanspeech vs mic in');

		%figure;plot(Cfg.cleanspeech_chandly,'r');hold on;plot(Cfg.idealvad_chanout,'k');hold on;plot(mic_array_input(1,:),'g');
		SNR_est=snr_est(Cfg.cleanspeech_bfdly,beamformingout,Cfg.idealvad_fbfout);
		display(strcat('SNRout=',num2str(SNR_est)));
		SNR_est=snr_est(Cfg.cleanspeech_chandly,mic_array_input(1,:),Cfg.idealvad_chanout);
		display(strcat('SNRin=',num2str(SNR_est)));
		display(strcat('power ratio=',num2str(powerratio_db)));
		figure;plot(Cfg.ABM_W_final.');title('ABM final')
		figure;plot(Cfg.ANC_W_final.');title('ANC final')
		if Cfg.SourceVadMaskEn && Cfg.InfVadMaskEn
			display(strcat('inf power ratio=',num2str(infpowerratio_db)));
		end

	end
	if Cfg.BeamformingMode==3
		figure;plot(Cfg.ABM_W_final.');
		figure;plot(Cfg.ABM_MMSE);
	end
else
	Cfg.DebugMask=0;
	phase_step=Cfg.BFSimPhaseStep;
	idxrange=1:180/phase_step;
	if Cfg.BFSimMode==3
		phase_step=2;
		maxstep_idx=Cfg.CCAF_MaskGen_MaxAngle/phase_step;
		idxrange=1:(maxstep_idx*2+1);
	end
	if Cfg.CCAF_TimerEn && Cfg.ANC_TimerEn
		warmup_sample=Cfg.CCAF_TrainLength+Cfg.ANC_TrainLength;
	else
		warmup_sample=Cfg.SnrWarmUp;
	end
	for idx=idxrange
		if Cfg.BFSimMode==1 
			%change source position
			SourcePos=[Cfg.SourcePos(1),(idx-1)*phase_step];InfPos=Cfg.InfPos;
		elseif Cfg.BFSimMode==2
			%change interference position
			SourcePos=Cfg.SourcePos;InfPos=[Cfg.InfPos(1),(idx-1)*phase_step];
		elseif Cfg.BFSimMode==3
			%change source position
			SourcePos=[Cfg.SourcePos(1),(idx-1-maxstep_idx)*phase_step+90];InfPos=Cfg.InfPos;
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
		beamformingout=beamforming(mic_array_input);
		outpower=sum((abs(beamformingout(warmup_sample+1:end)).^2).*Cfg.idealvad_fbfout(warmup_sample+1:end))./sum(Cfg.idealvad_fbfout(warmup_sample+1:end));
		powerratio_db(idx)=10*log10(outpower/Cfg.MicArrayAvgPower);
		if Cfg.SourceVadMaskEn && Cfg.InfVadMaskEn && Cfg.BFSimMode==2
			infpowerin=sum(abs(interf(warmup_sample+1:end)).^2.*((1-Cfg.idealvad(warmup_sample+1:end))).')./sum(1-Cfg.idealvad(warmup_sample+1:end));
			infpowerout=sum((abs(beamformingout(warmup_sample+1:end)).^2).*(1-Cfg.idealvad_fbfout(warmup_sample+1:end)))./sum((1-Cfg.idealvad_fbfout(warmup_sample+1:end)));
			infpowerratio_db(i)=10*log10(infpowerout/infpowerin);
		end

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

		if Cfg.BFSimMode==3
			filename=strcat('final_ABM_SteerErr',num2str((idx-1-maxstep_idx)*phase_step),'.mat');
			filename
			ABM_W_final=Cfg.ABM_W_final;
			save(filename,'ABM_W_final');
		end
	end
	if Cfg.BFSimMode==3
		angle_array=(idxrange-1-maxstep_idx)*phase_step;
	else
		angle_array=(idxrange-1)*phase_step;
	end
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
	title('beamforming beam pattern');
	if Cfg.SourceVadMaskEn && Cfg.InfVadMaskEn && Cfg.BFSimMode==2
		figure;plot(angle_array,infpowerratio_db);grid on;xlabel('angle(degree)');ylabel('Inf att(dB)');
		title('Inf att pattern');
	end
	size(SNR_est)
	size(angle_array)
	figure;plot(angle_array,SNR_est);
	SNR_est
	title('Beamforming Output SINR');
end

