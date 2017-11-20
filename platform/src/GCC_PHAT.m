function [tao,rr_sum]=GCC_PHAT(data1,data2,seglen,fs_voice)
global Cfg;
len=2^floor(log2(length(data1)));
tone_freq=freq_est(data1,len,fs_voice);
segnum=floor(min(length(data1),length(data2))/seglen);
rr_sum=zeros(1,seglen);
for segidx=1:segnum
%for segidx=1:1
	range_idx=[(segidx-1)*seglen+1:segidx*seglen];
	data1_set=data1(range_idx);
	data2_set=data2(range_idx);

	%tone_freq=freq_est(data1_set,seglen,fs_voice)
	ref_sig1=sin(2*pi*tone_freq*[0:seglen-1]/fs_voice);
	ref_sig2=cos(2*pi*tone_freq*[0:seglen-1]/fs_voice);

	corr_cos=mean(data1_set.*ref_sig1);
	corr_sin=mean(data1_set.*ref_sig2);
	corr_tan=corr_sin/corr_cos;
	theta1=atan(corr_tan);
	A1=2*corr_cos/cos(theta1);

	corr_cos=mean(data2_set.*ref_sig1);
	corr_sin=mean(data2_set.*ref_sig2);
	corr_tan=corr_sin/corr_cos;
	theta2=atan(corr_tan);
	A2=2*corr_cos/cos(theta2);

	data1_set_notch=data1_set-A1*sin(2*pi*tone_freq*[0:seglen-1]/fs_voice+theta1);
	data2_set_notch=data2_set-A2*sin(2*pi*tone_freq*[0:seglen-1]/fs_voice+theta2);

	%{
	if segidx==1
		figure;plot(data1_set);hold on; plot(A1*sin(2*pi*tone_freq*[0:seglen-1]/fs_voice+theta1),'r');
		hold on;plot(data2_set);hold on; plot(A2*sin(2*pi*tone_freq*[0:seglen-1]/fs_voice+theta2),'g');
		figure;plot(data1_set_notch);
	end
	%}

	if Cfg.GccNotchEn==0
		f_data1=fft(data1_set-mean(data1_set));
		f_data2=fft(data2_set-mean(data2_set));
	else
		f_data1=fft(data1_set_notch-mean(data1_set_notch));
		f_data2=fft(data2_set_notch-mean(data2_set_notch));
		%f_data1=fft(data1_set_notch);
		%f_data2=fft(data2_set_notch);
	end
	f_tot=f_data2.*conj(f_data1);
	power=mean(abs(f_tot).^2);
	%f_tot=f_tot./abs(f_tot+eps)*sqrt(power);
	f_tot=f_tot./abs(f_tot+eps);
	rr=ifft(f_tot);
	rr_sum=rr_sum+rr;
end
rr_sum=rr_sum/segnum;
[peak,tao]=max(abs(rr_sum));
if tao>seglen/2
	tao=tao-seglen;
end
tao=tao-1;

