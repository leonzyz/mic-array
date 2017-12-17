function beamformingout=RA_CCAF_ABM_BF_2x1D(mic_array_input)
global Cfg;
size(mic_array_input)
src_len=length(mic_array_input(1,:,1));
leftbeamforming=CCAF_ABM_BF(mic_array_input(:,:,1));
SNR_est=snr_est(Cfg.cleanspeech_bfdly,leftbeamforming,Cfg.idealvad_fbfout);
tmp=Cfg.cleanspeech_bfdly;
display(strcat('SNR left out=',num2str(SNR_est)));
rightbeamforming=CCAF_ABM_BF(mic_array_input(:,:,2));
SNR_est=snr_est(Cfg.cleanspeech_bfdly,rightbeamforming,Cfg.idealvad_fbfout);
display(strcat('SNR right out=',num2str(SNR_est)));

maxdely=Cfg.MicRowDist*sin(pi*Cfg.CCAF_MaskMaxAngle/180.0)/Cfg.VoiceSpeed*Cfg.AdcFs;

alpha=0.125;
seglen=2048; 
filtL=15;
curr_dly=0;
common_dly=(filtL-1)/2;
segnum=floor(src_len/seglen);
left_h=zeros(1,filtL);
right_h=zeros(1,filtL);
leftdelayout=zeros(1,src_len+filtL);
rightdelayout=zeros(1,src_len+filtL);

est_delay_trace=zeros(1,segnum);
filt_delay_trace=zeros(1,segnum);
halfdely=curr_dly/2;
for idx=1:segnum
	range_start=(idx-1)*seglen+1;
	range_idx=range_start:range_start+seglen-1;
	left_buff=zeros(1,seglen+filtL);
	right_buff=zeros(1,seglen+filtL);
	left_buff(1:seglen)=leftbeamforming(range_idx);
	right_buff(1:seglen)=rightbeamforming(range_idx);
	left_h=sinc([-common_dly:1:common_dly]-halfdely);
	right_h=sinc([-common_dly:1:common_dly]+halfdely);
	leftfiltout=filter(left_h,1,left_buff);
	rightfiltout=filter(right_h,1,right_buff);
	%{
	size(leftdelayout(range_start:range_start+seglen+filtL-1))
	size(leftfiltout)
	size(rightdelayout(range_start:range_start+seglen+filtL-1))
	size(rightfiltout)
	%}
	leftdelayout(range_start:range_start+seglen+filtL-1)=leftdelayout(range_start:range_start+seglen+filtL-1)+leftfiltout(1:seglen+filtL);
	rightdelayout(range_start:range_start+seglen+filtL-1)=rightdelayout(range_start:range_start+seglen+filtL-1)+rightfiltout(1:seglen+filtL);

	[est_delay,rr_sum]=GCC_PHAT(leftbeamforming(range_idx),rightbeamforming(range_idx),seglen,Cfg.AdcFs);
	metric=sum(Cfg.idealvad_fbfout(range_idx))/seglen;
	est_delay_trace(idx)=est_delay;
	if metric>0.8
		curr_dly=curr_dly+(est_delay-curr_dly)*alpha;
		if curr_dly>maxdely
			curr_dly=maxdely;
		elseif curr_dly<-maxdely
			curr_dly=-maxdely;
		end
		halfdely=curr_dly/2;
	end
	filt_delay_trace(idx)=curr_dly;
end
mean_dly=mean(filt_delay_trace);
%{
figure;plot(leftdelayout,'g');hold on;plot(rightdelayout,'r');
hold on;plot(leftbeamforming,'b');hold on;plot(rightbeamforming,'k');
title('GCC delay out');
figure;plot(est_delay_trace);hold on;plot(filt_delay_trace,'g');title('delaytrace');
%}

%[delay,rr_sum]=GCC_PHAT(leftbeamforming,rightbeamforming,seglen,Cfg.AdcFs);
%beamformingout=(leftbeamforming+rightbeamforming)/2;
beamformingout=(leftdelayout(1:src_len)+rightdelayout(1:src_len))/2;
tmp=zeros(1,src_len);
tmp(1+common_dly:end)=Cfg.cleanspeech_bfdly(1:end-common_dly);
Cfg.cleanspeech_bfdly=tmp;
tmp=zeros(1,src_len);
tmp(1+common_dly:end)=Cfg.idealvad_fbfout(1:end-common_dly);
Cfg.idealvad_fbfout=tmp;
%figure;plot(beamformingout,'r');hold  on;plot(Cfg.cleanspeech_bfdly,'g');title('BF out');



%{
figure;plot(leftbeamforming,'g');hold on;plot(rightbeamforming,'r');
hold on;plot(tmp,'m*-');hold on;plot(Cfg.cleanspeech_bfdly,'kO-');
hold on;plot(beamformingout,'bS-');
%}



