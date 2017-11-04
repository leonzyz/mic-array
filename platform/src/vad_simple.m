function vad_flag=vad_simple(voice,th,fs)
abs_th=sqrt(mean(abs(voice).^2))*th
vad_flag=abs(voice)>abs_th;

VMAX=1;
seg_period=0.01;%10ms
Ni=10;
InitTh=10^((15-20*log10(2048))/20);

design_fs=8e3;
ratio=fs/design_fs;
%may need to shrink according to fs
if fs>design_fs
	%b =[0.989113683852466  -1.978227367704931   0.989113683852466]
	%a =[1.000000000000000  -1.978108852314193   0.978345883095670]

	%@60Hz, -20dB
	b =[0.986947790321107  -1.973895580642213   0.986947790321107];
	a =[1.000000000000000  -1.973725213208446   0.974065948075981];
else
	b=[0.46363718,-0.92724705,0.46363718];
	a=[1,-1.9059465,0.9114024];
end
if fs<design_fs
	display('warming! signal sample rate is less than 8kHz!');
end

seglen=seg_period*fs;
hamming_window=(0.54-0.46*cos(2*pi*[0:seglen-1]/seglen));


%zeros_cross_rate
zcrate_lowth=30*ratio;
zcrate_highth=70*ratio;

%enegry threshold
energy_th=0.1;
energy_lowth=energy_th*10^(-12/10);
energy_highth=energy_th*10^(12/10);
segvad=[];
initvad=[];
segenergy=[];
segzcr=[];
avgEnBuff=zeros(1,10);
avgZcBuff=zeros(1,10);
avgEn=0;
avgZc=0;

segnum=floor(length(voice)/seglen);
highpass_voice=filter(b,a,voice)*2;

proc_delay=seglen/2;
for i=1:segnum
	rangeidx=(1:seglen)+(i-1)*seglen;
	rangeidx_add1=rangeidx+1;
	if rangeidx(end)>=length(voice)
		break;
	end
	segvoice=highpass_voice(rangeidx);
	winvoice=segvoice.*(hamming_window.');
	segenergy(i)=mean(abs(winvoice));
	segzcr(i)=sum(abs(sign(segvoice)-sign(voice(rangeidx_add1))))/(2*seglen);

	if i<Ni
		if segenergy(i)>InitTh
			initvad(i)=1;
		else
			initvad(i)=0;
		end
	elseif i==Ni
		initvad(i)=0;
	else
		initvad(i)=0;
	end
end
figure;plot(voice);hold on;plot(highpass_voice,'r');
%figure;plot(abs(fft(voice(1+2048:2048+2048))));
%figure;plot(abs(fft(highpass_voice(1+2048:2048+2048))));
figure;plot([1:seglen:seglen*length(segenergy)],segenergy);hold on;plot([1:seglen:seglen*length(segenergy)],ones(1,length(segenergy))*InitTh,'r');
figure;plot([1:seglen:seglen*length(segzcr)],segzcr);
