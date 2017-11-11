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
mic_array_input=mapping_geo_chan(voice,interf,noise);
mic_array_power=zeros(1,Cfg.SimMicNum);
for i=1:Cfg.SimMicNum
	mic_array_power(i)=mean(abs(mic_array_input(i,:)).^2);
end
Cfg.MicArrayAvgPower=mean(mic_array_power);
beamformingout=fixbeamforming(mic_array_input);
outpower=mean(abs(beamformingout).^2);
powerratio_db=10*log10(outpower/Cfg.MicArrayAvgPower);
%}


phase_step=5;
idxrange=1:180/phase_step;
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
	beamformingout=fixbeamforming(mic_array_input);
	outpower=sum((abs(beamformingout).^2).*Cfg.idealvad_fbfout)./sum(Cfg.idealvad_fbfout);
	powerratio_db(idx)=10*log10(outpower/Cfg.MicArrayAvgPower);
end
angle_array=(idxrange-1)*phase_step;
theta_array=angle_array/180*pi;
if Cfg.SourceType==0
	beampattern=gen_ideal_beampattern(Cfg.SourceFreq,theta_array);
elseif Cfg.SourceType==2
	M=20;
	freq_step=(Cfg.SourceBW(2)-Cfg.SourceBW(1))/M;
	beampattern=zeros(1,length(theta_array));
	for i=1:M
		f=Cfg.SourceBW(1)+freq_step*(i-1);
		tmp_pattern=gen_ideal_beampattern(f,theta_array);
		beampattern=beampattern+abs(tmp_pattern);
	end
	beampattern=beampattern/M;
end
figure;plot(angle_array,powerratio_db);
hold on;plot(angle_array,20*log10(abs(beampattern)+eps),'r');
legend('sim result','ideal result');
