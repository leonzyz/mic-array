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


%{
gen_geo_chan();
plot_geo_chan();
mic_array_input=mapping_geo_chan(voice,interf,noise);
mic_array_power=zeros(1,Cfg.SimMicNum);
for i=1:Cfg.SimMicNum
	mic_array_power(i)=mean(abs(mic_array_input(i,:)).^2);
end
Cfg.MicArrayAvgPower=mean(mic_array_power);
beamformingout=GriffithsJim_BF(mic_array_input);
%FiltKfigure;plot(beamformingout);
%outpower=mean(abs(beamformingout).^2);
%powerratio_db=10*log10(outpower/Cfg.MicArrayAvgPower);
%}


phase_step=10;
idxrange=1:180/phase_step;
warmup_sample=5000;
for idx=idxrange
	SourcePos=[Cfg.SourcePos(1),(idx-1)*phase_step];InfPos=[1.2,30];
	gen_geo_chan(SourcePos,InfPos);
	%plot_geo_chan();
	mic_array_input=mapping_geo_chan(voice,interf,noise);
	mic_array_power=zeros(1,Cfg.SimMicNum);
	for i=1:Cfg.SimMicNum
		%mic_array_power(i)=mean(abs(mic_array_input(i,:)).^2);
		mic_array_power(i)=sum(abs(mic_array_input(i,:).^2).*Cfg.idealvad_chanout)./sum(Cfg.idealvad_chanout);
	end
	Cfg.MicArrayAvgPower=mean(mic_array_power);
	beamformingout=GriffithsJim_BF(mic_array_input);
	outpower=sum((abs(beamformingout(warmup_sample+1:end)).^2).*Cfg.idealvad_fbfout(warmup_sample+1:end))./sum(Cfg.idealvad_fbfout(warmup_sample+1:end));
	powerratio_db(idx)=10*log10(outpower/Cfg.MicArrayAvgPower);
end
angle_array=(idxrange-1)*phase_step;
figure;plot(angle_array,powerratio_db);
%{
%}
