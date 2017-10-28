global Cfg;

[voice,interf,noise]=source_gen(0);
display(strcat('signal power=',num2str(Cfg.SigPow)));
display(strcat('interferece power=',num2str(Cfg.InfPow)));
display(strcat('noise power=',num2str(Cfg.NoisePow)));
figure;plot(voice);hold on;plot(interf,'r');hold on;plot(noise(1,:),'k');
size(voice)
size(interf)
%noisy_voice=voice+interf;
noisy_voice=voice;
vad_flag=vad_simple(noisy_voice,0.01,Cfg.ChanFs);
%am=abs(noisy_voice+j*hilbert(noisy_voice));
%figure;plot(am);
%figure;plot(noisy_voice);hold on;plot(vad_flag*abs(max(noisy_voice)),'r');
%plot_goe_chan()
%mic_array_input=geo_chan(Cfg,voice,interf);
