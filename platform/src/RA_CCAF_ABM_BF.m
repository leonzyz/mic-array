%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CCAF_ABM_BF: Rectangular Array Adaptive Blocking Matrix with Coefficient 
%	Constrained Adatpive Filter

%	Input:
%		Microphone Array input(Rectangular Array)
%	Global Parma:Cfg
%	Ouput:
%		CCAF ABM adaptive beam forming out
%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function beamformingout=RA_CCAF_ABM_BF(mic_array_input)
global Cfg;
src_len=length(mic_array_input(1,:,1));

ANC_FiltL=Cfg.ANC_K*2+1;
CCAF_FiltL=Cfg.CCAF_K*2+1;

%{
if Cfg.FBFSteerMode==0
	steer_dly=0;
else
	steer_dly=round((Cfg.FBFfiltLen-1)/2);
end
%}
CCAF_delay=Cfg.CCAF_dlyComp;
ANC_delay=Cfg.ANC_dlyComp;

%Adaptive Blocking Matrix and delay regs
ABM_reg=zeros(Cfg.SimMicNum,CCAF_FiltL,Cfg.SimMicRowNum);
ABM_W=zeros(Cfg.SimMicNum,CCAF_FiltL,Cfg.SimMicRowNum);
ABM_W_pre=zeros(Cfg.SimMicNum,CCAF_FiltL,Cfg.SimMicRowNum);
ABM_MMSE=zeros(1,src_len);
%ABM_W_trace0=zeros(src_len,CCAF_FiltL);
%{
ABM_W_trace1=zeros(src_len,CCAF_FiltL);
ABM_W_trace2=zeros(src_len,CCAF_FiltL);
ABM_W_trace3=zeros(src_len,CCAF_FiltL);
%}
ANC_reg=zeros(Cfg.SimMicNum,ANC_FiltL,Cfg.SimMicRowNum);
ANC_W=zeros(Cfg.SimMicNum,ANC_FiltL,Cfg.SimMicRowNum);
M=-2:2;
%{
for i=1:Cfg.SimMicNum
	%ABM_W(i,Cfg.CCAF_dlyComp+1+M)=0.2;
	ABM_W(i,Cfg.CCAF_dlyComp+15)=1;
	%ABM_W(i,10)=1;
end
%}

%x(k)
mic_steer_out=beampattern_steer_RA(mic_array_input);
%{
figure;
for r=1:Cfg.SimMicRowNum
	for i=1:Cfg.SimMicNum
		plot(mic_array_input(i,1:1000,r));hold on;
	end
end
legend('1','2','3','4','5','6','7','8');
title('mic array input');
%}

%d(t)
FBFout=zeros(1,src_len);
for r=1:Cfg.SimMicRowNum
	FBFout=FBFout+mean(mic_steer_out(:,:,r));
end
FBFout=FBFout/Cfg.SimMicRowNum;

%{
figure;
for r=1:Cfg.SimMicRowNum
	for i=1:Cfg.SimMicNum
		plot(mic_steer_out(i,1:3000,r));hold on;
	end
end
hold on;plot(FBFout(1:3000),'k*-');
legend('1','2','3','4','5','6','FBF');
title('debug mic steer out');
%}

common_dly=ANC_delay;
FBFout_dly=zeros(1,src_len);
FBFout_dly(1+common_dly:end)=FBFout(1:end-common_dly);
%figure;plot(FBFout,'r');hold on;plot(Cfg.cleanspeech_steerdly,'g');title('debug FBF out');

%X'(t)
dly_steer_out=zeros(Cfg.SimMicNum,src_len,Cfg.SimMicRowNum);
for r=1:Cfg.SimMicRowNum
	for i=1:Cfg.SimMicNum
		dly_steer_out(i,1+CCAF_delay:end,r)=mic_steer_out(i,1:end-CCAF_delay,r);
	end
end

beamformingout=zeros(1,src_len);
z=zeros(1,src_len);
yA=zeros(Cfg.SimMicNum,src_len,Cfg.SimMicRowNum);
reb_y=zeros(Cfg.SimMicNum,src_len,Cfg.SimMicRowNum);

total_dly=Cfg.ANC_dlyComp;
idealvad_forCCAF=zeros(1,src_len);
idealvad_forANC=zeros(1,src_len);
Cfg.idealvad_fbfout=zeros(1,src_len);
Cfg.idealvad_fbfout(1+total_dly:end)=Cfg.idealvad_steerout(1:end-total_dly);
idealvad_forCCAF(1:end)=Cfg.idealvad_steerout(1:end);
idealvad_forANC(1+ANC_delay:end)=Cfg.idealvad_steerout(1:end-ANC_delay);
Cfg.cleanspeech_bfdly=zeros(1,src_len);
Cfg.cleanspeech_bfdly(1+total_dly:end)=Cfg.cleanspeech_steerdly(1:end-total_dly);

if Cfg.GenieEn==1
	%{
	refdata_steer_out=beampattern_steer(Cfg.mic_array_refdata);
	refdata_FBFout=mean(refdata_steer_out);
	refdata_FBFout_dly=zeros(1,src_len);
	refdata_FBFout_dly(1+common_dly:end)=refdata_FBFout(1:end-common_dly);
	refdata_BM_out=Ws*refdata_steer_out;
	Cfg.refdata_beamformingout=zeros(1,src_len);
	refdata_reg_matrix=zeros(Cfg.SimMicNum-1,FiltL);

	refintf_steer_out=beampattern_steer(Cfg.mic_array_refintf);
	refintf_FBFout=mean(refintf_steer_out);
	refintf_FBFout_dly=zeros(1,src_len);
	refintf_FBFout_dly(1+common_dly:end)=refintf_FBFout(1:end-common_dly);
	refintf_BM_out=Ws*refintf_steer_out;
	Cfg.refintf_beamformingout=zeros(1,src_len);
	refintf_reg_matrix=zeros(Cfg.SimMicNum-1,FiltL);

	refnoise_steer_out=beampattern_steer(Cfg.mic_array_refnoise);
	refnoise_FBFout=mean(refnoise_steer_out);
	refnoise_FBFout_dly=zeros(1,src_len);
	refnoise_FBFout_dly(1+common_dly:end)=refnoise_FBFout(1:end-common_dly);
	refnoise_BM_out=Ws*refnoise_steer_out;
	Cfg.refnoise_beamformingout=zeros(1,src_len);
	refnoise_reg_matrix=zeros(Cfg.SimMicNum-1,FiltL);
	%}
end


ccaf_u=Cfg.CCAF_u;
anc_u=Cfg.ANC_u;
sim_len=src_len;
CCAF_train_timer=Cfg.CCAF_TrainLength;
ANC_train_timer=Cfg.ANC_TrainLength;
%figure;plot(mic_steer_out(1,:));
%figure;plot(mic_array_input(:,1:500).');
%if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('10'))
%	figure;plot(mic_steer_out(:,1:5000).');
%end

ANC_metric=zeros(1,src_len);
for i=1:sim_len
	%input phase
	for r=1:Cfg.SimMicRowNum
		for mic_idx=1:Cfg.SimMicNum
			ABM_reg(mic_idx,:,r)=[FBFout(i),ABM_reg(mic_idx,1:end-1,r)];
			if Cfg.GenieEn==1
				%{
				refdata_reg_matrix(bm_idx,:)=[refdata_BM_out(bm_idx,i),refdata_reg_matrix(bm_idx,1:end-1)];
				refintf_reg_matrix(bm_idx,:)=[refintf_BM_out(bm_idx,i),refintf_reg_matrix(bm_idx,1:end-1)];
				refnoise_reg_matrix(bm_idx,:)=[refnoise_BM_out(bm_idx,i),refnoise_reg_matrix(bm_idx,1:end-1)];
				%}
			end
		end
	end

	%ABM output phase
	reb_y(:,i,:)=sum(ABM_W.*ABM_reg,2);
	yA(:,i,:)=dly_steer_out(:,i,:)-reb_y(:,i,:);
	if Cfg.GenieEn==1
		%{
		tmp=sum(sum(ANC_matrix.*refdata_reg_matrix));
		Cfg.refdata_beamformingout(i)=refdata_FBFout_dly(i)-tmp;
		tmp=sum(sum(ANC_matrix.*refintf_reg_matrix));
		Cfg.refintf_beamformingout(i)=refintf_FBFout_dly(i)-tmp;
		tmp=sum(sum(ANC_matrix.*refnoise_reg_matrix));
		Cfg.refnoise_beamformingout(i)=refnoise_FBFout_dly(i)-tmp;
		%}
	end

	%ANC input phase
	for r=1:Cfg.SimMicRowNum
		for mic_idx=1:Cfg.SimMicNum
			ANC_reg(mic_idx,:,r)=[yA(mic_idx,i,r),ANC_reg(mic_idx,1:end-1,r)];
		end
	end


	%ANC output phase
	c(i)=sum(sum(sum(ANC_W.*ANC_reg)));
	z(i)=FBFout_dly(i)-c(i);

	ABM_W_pre=ABM_W;
	%CCAF update phase
	if Cfg.CCAF_AdaptionU==0
		ccaf_u=Cfg.CCAF_u;
	else
		power=sum(sum(sum(ABM_reg.^2)));
		ccaf_u=Cfg.CCAF_u/(power+eps);
		if ccaf_u>Cfg.CCAF_u
			ccaf_u=Cfg.CCAF_u;
		end
	end
	if Cfg.CCAF_TimerEn==1
		flag=i<CCAF_train_timer;
	else
		flag=(Cfg.CcafVadMaskEn==0 || (Cfg.CcafVadMaskEn==1 && idealvad_forCCAF(i)==1));
	end
	%if Cfg.CcafVadMaskEn==0 || (Cfg.CcafVadMaskEn==1 && idealvad_forCCAF(i)==1)
	%if i<CCAF_train_timer
	if flag
		for r=1:Cfg.SimMicRowNum
			for mic_idx=1:Cfg.SimMicNum
				ABM_W(mic_idx,:,r)=ABM_W(mic_idx,:,r)+ccaf_u*yA(mic_idx,i,r)*ABM_reg(mic_idx,:,r);
			end
		end
		if Cfg.CCAF_MaskEn
			for r=1:Cfg.SimMicRowNum
				for mic_idx=1:Cfg.SimMicNum
					for k=1:CCAF_FiltL
						if ABM_W(mic_idx,k,r)>Cfg.CCAF_MaskUpperBound_RA(mic_idx,k,r)
							ABM_W(mic_idx,k,r)=Cfg.CCAF_MaskUpperBound_RA(mic_idx,k,r);
						elseif ABM_W(mic_idx,k,r)<Cfg.CCAF_MaskLowerBound_RA(mic_idx,k,r)
							ABM_W(mic_idx,k,r)=Cfg.CCAF_MaskLowerBound_RA(mic_idx,k,r);
						end
					end
				end
			end
		end
	end
	ABM_MMSE(i)=sum(sum(sum((ABM_W-ABM_W_pre).^2)));
	%{
	ABM_W_trace1(i,:)=ABM_W(2,:);
	ABM_W_trace2(i,:)=ABM_W(3,:);
	ABM_W_trace3(i,:)=ABM_W(4,:);
	%}


	%ANC update phase
	if Cfg.ANC_AdaptionU==0
		anc_u=Cfg.ANC_u;
	else
		power=sum(sum(sum(ANC_reg.^2)));
		if power>1
			anc_u=Cfg.ANC_u/power;
		else
			anc_u=Cfg.ANC_u;
		end
	end
	if Cfg.ANC_TimerEn==1
		flag=(i>CCAF_train_timer && i<(CCAF_train_timer+ANC_train_timer) );
	else
		flag=( Cfg.AncVadMaskEn==0 || (Cfg.AncVadMaskEn==1 && idealvad_forANC(i)==0) );
	end
	%if Cfg.AncVadMaskEn==0 || (Cfg.AncVadMaskEn==1 && idealvad_forANC(i)==0)
	%if i>CCAF_train_timer && i<(CCAF_train_timer+ANC_train_timer)
	if flag
		ANC_W=ANC_W+anc_u*z(i)*ANC_reg;

		ANC_metric(i)=sum(sum(sum(ANC_W.^2)));
		if Cfg.ANC_metric_NormEn==1
			if ANC_metric(i)>Cfg.ANC_metric_NormTH
				ratio=sqrt(Cfg.ANC_metric_NormTH/ANC_metric(i));
				ANC_W=ANC_W*ratio;
			end
		end
	end
	if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('10'))
		ccaf_u_trace(i)=ccaf_u;
		anc_u_trace(i)=anc_u;
		ANC_W_TH(i)=sum(sum(sum(ANC_W.^2)));
	end
end
beamformingout=z;
Cfg.ABM_W_final=ABM_W;
Cfg.ABM_MMSE=ABM_MMSE;
Cfg.ANC_W_final=ANC_W;
%{
figure;plot(beamformingout,'r');hold on;plot(Cfg.cleanspeech_bfdly,'g');
hold on;plot(c,'b');
title('BF out')
%}

if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('10'))
	%{
	figure;plot(mic_steer_out(:,1:sim_len).');title('steer out');
	hold on;plot(Cfg.idealvad_steerout(1:sim_len),'r');
	hold on;plot(FBFout,'k');title('FBFout');
	figure;plot(reb_y.');legend('1','2','3','4');title('CCAF out');
	figure;plot(dly_steer_out.');legend('1','2','3','4');title('dly steer out');
	figure;plot(dly_steer_out(1,:),'g');hold on;plot(yA(1,:),'r');hold on;plot(FBFout,'k');hold on;plot(reb_y(1,:),'b');hold on;plot(idealvad_forCCAF,'m');legend('x','y','d','b','vad');title('CCAF comp');
	%}
	%{
	figure;
	hold on;plot(FBFout_dly,'k');
	hold on;plot(Cfg.cleanspeech_bfdly,'g');
	plot(z,'r');
	%figure;;plot(yA.');legend('1','2','3','4');title('BM out');
	%figure;plot(ABM_W.');legend('1','2','3','4');title('CCAF matrix');
	%figure;plot(ANC_W.');legend('1','2','3','4');title('ANC matrix');
	figure;plot(yA,'k');
	hold on;plot(FBFout_dly,'b');
	figure;plot(ANC_metric,'r');hold on;plot(ANC_W_TH,'g');title('ANC metric')
	%}
	%hold on;plot(BM_W,'m');
	%{
	if Cfg.ANC_AdaptionU==1
		figure;plot(ccaf_u_trace);
		figure;plot(anc_u_trace);
	end
	%}
	%[xx,yy]=meshgrid([1:5000:src_len],[1:CCAF_FiltL]);
	%size(xx)
	%size(yy)
	%size(ABM_W_trace0)
	%figure;surf(xx,yy,ABM_W_trace0(1:5000:end,:).');
	%{%}
	%{
	figure;surf(ABM_W_trace1);
	figure;surf(ABM_W_trace2);
	figure;surf(ABM_W_trace3);
	%}

	%{
	figure;plot(ABM_W.');
	figure;plot(FBFout,'k');hold on;plot(mic_steer_out(1,:),'g');

	tmp=filter(ABM_W(1,:),1,FBFout);
	figure;plot(reb_y(1,:),'r');hold on;plot(tmp,'g');hold on;plot(dly_steer_out(1,:),'k');
	figure;plot(ABM_W(1,:));
	rangeidx=14000:14000+1024-1;
	figure;plot(abs(fft(FBFout(1,rangeidx))));
	figure;plot(abs(fft(dly_steer_out(1,rangeidx))));
	figure;plot(abs(fft(ABM_W(1,:),1024)));
	%}

	%{
	figure;plot(idealvad_forCCAF,'k');
	hold on;plot(FBFout_dly,'g');
	hold on;plot(c,'r');
	hold on;plot(yA(1,:),'b');
	hold on;plot(reb_y(1,:),'r*-');
	hold on;plot(FBFout,'g*-');
	hold on;plot(dly_steer_out(1,:),'b*-');
	figure;plot(c,'r');
	figure;plot(mic_array_input(1,:));
	%}
	figure;
	figure;plot(idealvad_forCCAF,'k');
	hold on;plot(yA(1,:,1),'b');
	hold on;plot(FBFout,'r');
	hold on;plot(dly_steer_out(1,:,1),'m');
	hold on;plot(reb_y(1,:,1),'g');
	%{
	tmp=filter(ABM_W(1,:),1,FBFout);
	hold on;plot(tmp,'gO-');
	h=[0.0434    0.0429    0.0428    0.0428    0.0424    0.0410    0.0391    0.0365    0.0341    0.0318    0.0301    0.0287    0.0272    0.0253    0.0227    0.0208    0.0148    0.0103    0.0060 ...
	0.0026   -0.0004   -0.0028   -0.0051   -0.0078   -0.0109   -0.0146   -0.0184   -0.0219   -0.0249    0.9714   -0.0282   -0.0292   -0.0305   -0.0321   -0.0343   -0.0369   -0.0394   -0.0414 ...
	-0.0429   -0.0435   -0.0438];
	h2=zeros(1,41);
	h2(30)=1;
	tmp2=filter(h,1,FBFout);
	hold on;plot(tmp2,'gX-');
	tmp3=filter(h2,1,FBFout);
	figure;plot(FBFout);hold on;plot(tmp2,'r');hold on;plot(tmp3,'k');
	%}
	%[xx,yy]=meshgrid([1:500:src_len],[1:CCAF_FiltL]);
	%size(xx)
	%size(yy)
	%size(ABM_W_trace0)
	%figure;surf(xx,yy,ABM_W_trace0(1:500:end,:).');
	%figure;plot(ABM_W(1,:));

	figure;plot(ANC_metric,'r');title('ANC metric')
	figure;plot(ABM_MMSE,'r');title('ABM MMSE')

end

