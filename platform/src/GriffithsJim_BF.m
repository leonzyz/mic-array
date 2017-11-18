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

u=Cfg.ANC_u;
sim_len=src_len;
%figure;plot(mic_steer_out(1,:));
%figure;plot(mic_array_input(:,1:500).');
if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('20'))
	figure;plot(mic_steer_out(:,1:5000).');
end

ANC_W=zeros(1,src_len);
for i=1:sim_len

	%input phase
	for bm_idx=1:Cfg.SimMicNum-1
		reg_matrix(bm_idx,:)=[BM_out(bm_idx,i),reg_matrix(bm_idx,1:end-1)];
	end

	%output phase
	yA(i)=sum(sum(ANC_matrix.*reg_matrix));
	y(i)=FBFout_dly(i)-yA(i);

	%{
	if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('20'))
		ydebug(i,:)=sum(ANC_matrix.*reg_matrix,2);
	end
	%}
	
	%update phase
	%{
	if Cfg.adaptionU==0
		u=Cfg.ANC_u;
	else
		u=0.05
	end
	%}
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
beamformingout=y;

if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('20'))
	figure;plot(mic_steer_out(:,1:sim_len).');title('steer out');
	hold on;plot(Cfg.idealvad_steerout(1:sim_len),'r');
	hold on;plot(FBFout_dly,'k');title('FBFout_dly');
	figure;plot(y,'r');
	figure;;plot(BM_out.');legend('1','2','3');title('BM out');
	figure;plot(ANC_matrix.');legend('1','2','3');title('ANC matrix');
	figure;plot(yA,'k');
	hold on;plot(FBFout_dly,'b');
	figure;plot(ANC_W,'r');
end

Cfg.idealvad_fbfout=zeros(1,src_len);
Cfg.idealvad_fbfout(1:end-round((FiltL-1)/2))=Cfg.idealvad_steerout(1+round((FiltL-1)/2):end);
