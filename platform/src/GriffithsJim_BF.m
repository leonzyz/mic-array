%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GriffithsJim beamforming: GSC beamforming based on GriffithsJim's paper

%	Input:
%		Microphone Array input
%	Global Parma:Cfg
%	Ouput:
%		frost adaptive beam forming out
%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function beamformingout=GriffithsJim_BF(mic_array_input)
global Cfg;
src_len=length(mic_array_input(1,:));

K=7; %Filter lenght=2*K+1
FiltL=K*2+1;

%Blocking Matrix, row number=microphone number-1
Ws=zeros(Cfg.SimMicNum-1,Cfg.SimMicNum);

if Cfg.BlockMatrixType==0
	b=zeros(1,Cfg.SimMicNum);
	b(1)=1;b(2)=-1;
	for i=1:Cfg.SimMicNum-1
		Ws(i,:)=b;
		b=[b(end) b(1:end-1)];
	end
else
	h=hadamard(Cfg.SimMicNum);
	Ws=h(2:end,:);
end

%X(t)
mic_steer_out=beampattern_steer(mic_array_input);

%yc(t)
FBFout=mean(mic_steer_out);
common_dly=K;
FBFout_dly=zeros(1,src_len);
FBFout_dly(1+common_dly:end)=FBFout(1:end-common_dly);

%X'(t)
BM_out=Ws*mic_steer_out;

beamformingout=zeros(1,src_len);
yA=zeros(1,src_len);

reg_matrix=zeros(Cfg.SimMicNum-1,FiltL);
ANC_matrix=zeros(Cfg.SimMicNum-1,FiltL);

Cfg.idealvad_fbfout=zeros(1,src_len);
Cfg.idealvad_fbfout(1+round((FiltL-1)/2):end)=Cfg.idealvad_steerout(1:end-round((FiltL-1)/2));
Cfg.cleanspeech_bfdly=zeros(1,src_len);
Cfg.cleanspeech_bfdly(1+round((FiltL-1)/2):end)=Cfg.cleanspeech_steerdly(1:end-round((FiltL-1)/2));

if Cfg.GenieEn==1
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
end


u=Cfg.ANC_u;
sim_len=src_len;
%figure;plot(mic_steer_out(1,:));
%figure;plot(mic_array_input(:,1:500).');
if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('8'))
	figure;plot(mic_steer_out(:,1:5000).');
end

ANC_W=zeros(1,src_len);
for i=1:sim_len

	%input phase
	for bm_idx=1:Cfg.SimMicNum-1
		reg_matrix(bm_idx,:)=[BM_out(bm_idx,i),reg_matrix(bm_idx,1:end-1)];
		if Cfg.GenieEn==1
			refdata_reg_matrix(bm_idx,:)=[refdata_BM_out(bm_idx,i),refdata_reg_matrix(bm_idx,1:end-1)];
			refintf_reg_matrix(bm_idx,:)=[refintf_BM_out(bm_idx,i),refintf_reg_matrix(bm_idx,1:end-1)];
			refnoise_reg_matrix(bm_idx,:)=[refnoise_BM_out(bm_idx,i),refnoise_reg_matrix(bm_idx,1:end-1)];
		end
	end

	%output phase
	yA(i)=sum(sum(ANC_matrix.*reg_matrix));
	y(i)=FBFout_dly(i)-yA(i);
	if Cfg.GenieEn==1
		tmp=sum(sum(ANC_matrix.*refdata_reg_matrix));
		Cfg.refdata_beamformingout(i)=refdata_FBFout_dly(i)-tmp;
		tmp=sum(sum(ANC_matrix.*refintf_reg_matrix));
		Cfg.refintf_beamformingout(i)=refintf_FBFout_dly(i)-tmp;
		tmp=sum(sum(ANC_matrix.*refnoise_reg_matrix));
		Cfg.refnoise_beamformingout(i)=refnoise_FBFout_dly(i)-tmp;
	end


	%{
	if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('8'))
		ydebug(i,:)=sum(ANC_matrix.*reg_matrix,2);
	end
	%}
	
	%update phase
	if Cfg.ANC_AdaptionU==0
		u=Cfg.ANC_u;
	else
		power=sum(sum(reg_matrix.^2));
		if power>1
			u=Cfg.ANC_u/power;
		else
			u=Cfg.ANC_u;
		end
	end
	if Cfg.AncVadMaskEn==0 || (Cfg.AncVadMaskEn==1 && Cfg.idealvad_fbfout(i)==0)
		for bm_idx=1:Cfg.SimMicNum-1
			ANC_matrix=ANC_matrix+u*y(i)*reg_matrix;
		end
		ANC_W(i)=sum(sum(ANC_matrix.^2));
		if Cfg.ANC_W_NormEn==1
			if ANC_W(i)>Cfg.ANC_W_NormTH
				ratio=sqrt(Cfg.ANC_W_NormTH/ANC_W(i));
				ANC_matrix=ANC_matrix*ratio;
			end
		end
	end
	if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('8'))
		u_trace(i)=u;
		BM_W(i)=sum(BM_out(:,i).^2);
		X_W(i)=sum(sum(reg_matrix.^2));
		ANC_W_TH(i)=sum(sum(ANC_matrix.^2));
	end
end
beamformingout=y;

if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('8'))
	figure;plot(mic_steer_out(:,1:sim_len).');title('steer out');
	hold on;plot(Cfg.idealvad_steerout(1:sim_len),'r');
	hold on;plot(FBFout_dly,'k');title('FBFout_dly');
	figure;plot(y,'r');
	figure;;plot(BM_out.');legend('1','2','3');title('BM out');
	figure;plot(ANC_matrix.');legend('1','2','3');title('ANC matrix');
	figure;plot(yA,'k');
	hold on;plot(FBFout_dly,'b');
	figure;plot(ANC_W,'r');hold on;plot(ANC_W_TH,'g');hold on;plot(X_W,'b');
	hold on;plot(BM_W,'m');
	if Cfg.ANC_AdaptionU==1
		figure;plot(u_trace);
	end
end

