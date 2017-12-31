% test room channel
global Cfg;

[voice,interf,noise]=source_gen();
Cfg.cleanspeech=voice;
display(strcat('signal power=',num2str(Cfg.SigPow)));
display(strcat('interferece power=',num2str(Cfg.InfPow)));
display(strcat('noise power=',num2str(Cfg.NoisePow)));

if Cfg.SourceType==1
	Cfg.idealvad=G729(Cfg.cleanspeech,Cfg.ChanFs,0.005*Cfg.ChanFs*3,0.005*Cfg.ChanFs);%according to the G729.B
	figure;plot(Cfg.cleanspeech);hold on;plot(Cfg.idealvad*abs(max(Cfg.cleanspeech)),'r');grid on;
	%sound(Cfg.cleanspeech,Cfg.ChanFs);
else
	Cfg.idealvad=ones(1,length(Cfg.cleanspeech));
end

%figure;plot(voice,'r');hold on;plot(Cfg.idealvad,'k');

src_len=length(voice);
%figure;plot(voice);hold on;plot(interf,'r');hold on;plot(noise(1,:),'k');

%Cfg.DebugEn=1;Cfg.DebugMask=bin2dec('100000');
gen_geo_chan();
plot_geo_chan();
mic_array_input=mapping_geo_chan(voice,interf,noise);

figure;plot(mic_array_input(1,:,1));
sound(mic_array_input(1,:,1),Cfg.AdcFs);
