global Cfg;

[voice,interf,noise]=source_gen(1);
display(strcat('signal power=',num2str(Cfg.SigPow)));
display(strcat('interferece power=',num2str(Cfg.InfPow)));
display(strcat('noise power=',num2str(Cfg.NoisePow)));
figure;plot(voice);hold on;plot(interf,'r');hold on;plot(noise(1,:),'k');
%mic_array_input=geo_chan(Cfg,voice,interf);
