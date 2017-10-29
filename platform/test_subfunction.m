global Cfg;

[voice,interf,noise]=source_gen(0);
Cfg.cleanspeech=voice;
display(strcat('signal power=',num2str(Cfg.SigPow)));
display(strcat('interferece power=',num2str(Cfg.InfPow)));
display(strcat('noise power=',num2str(Cfg.NoisePow)));
figure;plot(voice);hold on;plot(interf,'r');hold on;plot(noise(1,:),'k');
seglen=2048;
segnum=floor(length(voice)/seglen);
segsnr=[];
for i=1:segnum
	rangeidx=(1:seglen)+(i-1)*seglen;
	segsnr(i)=10*log10(sum(abs(voice(rangeidx)).^2)/sum(abs(interf(rangeidx)).^2));
end
figure;plot(segsnr);

size(voice)
size(interf)
noisy_voice=voice+interf;
%noisy_voice=voice;
%sound(noisy_voice,Cfg.ChanFs);
%vad_flag=vad_simple(noisy_voice,0.01,Cfg.ChanFs);
%figure;plot(noisy_voice);hold on;plot(vad_flag*abs(max(noisy_voice)),'r');
%am=abs(noisy_voice+j*hilbert(noisy_voice));
%figure;plot(am);
%plot_goe_chan()
%mic_array_input=geo_chan(Cfg,voice,interf);

vad_flag=G729(noisy_voice,Cfg.ChanFs,0.01*Cfg.ChanFs*3,0.01*Cfg.ChanFs);
figure;plot(noisy_voice);hold on;plot(vad_flag*abs(max(noisy_voice)),'r');
