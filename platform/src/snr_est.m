function SNR_out=snr_est(cleanspeech,bfout,vad)
global Cfg;
srclen=length(bfout);
seglen=2048;
segnum=2^floor((log2(srclen)))/seglen;

if 0
	figure;plot(cleanspeech,'g')
	hold on;plot(bfout,'r');
	title('SNR debug 1');
end
corr=mean(cleanspeech.*bfout)/mean(cleanspeech.^2);
%[tao,rr_sum]=GCC_PHAT(cleanspeech,bfout,seglen,16e3);
display(strcat('corr=',num2str(corr)));
%display(strcat('tao=',num2str(tao)));
ratio=sqrt(abs(corr));
effect_segnum=0;
SNR_acc=0;
for idx=1:segnum
	rangeidx=1:seglen+(idx-1)*seglen;
	if sum(vad(rangeidx))<1/2*seglen
		continue;
	end
	data=bfout(rangeidx);
	refdata=cleanspeech(rangeidx);
	noise=data-refdata*ratio;
	sig_pow=mean((cleanspeech*ratio).^2);
	noise_pow=mean(noise.^2);
	SNR_tmp=10*log10(sig_pow/noise_pow);
	SNR_acc=SNR_acc+SNR_tmp;
	effect_segnum=effect_segnum+1;
end
SNR_out=SNR_acc/effect_segnum;
%[tao,rr_sum]=GCC_PHAT(cleanspeech,bfout,seglen,2e3);
%tao
%{%}
%if Cfg.DebugEn
if 0
	ratio
	figure;plot(cleanspeech*ratio,'g')
	hold on;plot(bfout,'r');
	hold on;plot(bfout-cleanspeech*ratio,'k');
	title('SNR debug');
end
