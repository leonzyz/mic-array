function SNR_out=snr_est(cleanspeech,bfout,vad)
global Cfg;
srclen=length(bfout);
seglen=2048;
segnum=floor((srclen-Cfg.SnrWarmUp)/seglen);

if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('20'))
	figure;plot(cleanspeech,'g')
	hold on;plot(bfout,'r');
	title('SNR debug 1');
end
corr=mean(cleanspeech.*bfout.*vad)/mean((cleanspeech.*vad).^2);
%[tao,rr_sum]=GCC_PHAT(cleanspeech,bfout,seglen,16e3);
display(strcat('corr=',num2str(corr)));
%display(strcat('tao=',num2str(tao)));
ratio=sqrt(abs(corr));
effect_segnum=0;
SNR_acc=0;
SNR_seg=zeros(1,segnum);
[est_delay,rr_sum]=GCC_PHAT(cleanspeech,bfout,seglen,Cfg.AdcFs);
filtL=15;
common_dly=(filtL-1)/2;
delay_h=sinc([-common_dly:1:common_dly]-est_delay);
cleanspeech_dly=filter(delay_h,1,cleanspeech);
bfout_dly=zeros(1,length(bfout));
bfout_dly(1+common_dly:end)=bfout(1:end-common_dly);

for idx=1:segnum
	rangeidx=1:seglen+(idx-1)*seglen+Cfg.SnrWarmUp;
	if sum(vad(rangeidx))<1/2*seglen
		continue;
	end
	data=bfout_dly(rangeidx);
	refdata=cleanspeech_dly(rangeidx);
	vad_t=vad(rangeidx);
	noise=data-refdata*ratio;
	sig_pow=mean((refdata*ratio).^2);
	noise_pow=mean((noise.*vad_t).^2);
	SNR_tmp=10*log10(sig_pow/noise_pow);
	SNR_acc=SNR_acc+SNR_tmp;
	effect_segnum=effect_segnum+1;
	SNR_seg(idx)=SNR_tmp;
end
SNR_out=SNR_acc/effect_segnum;
%[tao,rr_sum]=GCC_PHAT(cleanspeech,bfout,seglen,2e3);
%tao
%{%}
%if Cfg.DebugEn
if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('20'))
	ratio
	figure;plot(cleanspeech_dly*ratio,'g')
	hold on;plot(bfout_dly,'r');
	hold on;plot(bfout_dly-cleanspeech_dly*ratio,'k');
	title('SNR debug');
	figure;plot(SNR_seg);title('SNR trace');
end
