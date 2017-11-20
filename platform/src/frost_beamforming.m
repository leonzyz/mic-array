%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% frost beamforming: linear constrained coefficient beamforming based on frost's paper

%	Input:
%		Microphone Array input
%	Global Parma:Cfg
%	Ouput:
%		frost adaptive beam forming out
%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function beamformingout=frost_beamforming(mic_array_input)
global Cfg;
src_len=length(mic_array_input(1,:));

FiltL=17;
contraint_vector=zeros(1,FiltL);
contraint_vector(floor((FiltL-1)/2)+1)=1;

%{
fN=FiltL-1;
bwend=4e3/(Cfg.AdcFs/2);
ant=10^(-40/20);%-40dB anttenuation
delta=bwend*0.01;
f=[0,bwend,bwend+delta,1-delta];
a=[1,1,ant,ant];
h=firls(fN,f,a);
contraint_vector=h;
%}


W=zeros(Cfg.SimMicNum,FiltL);

mic_steer_out=beampattern_steer(mic_array_input);
if Cfg.GenieEn==1
	Cfg.refdata_steer_out=beampattern_steer(Cfg.mic_array_refdata);
	Cfg.refintf_steer_out=beampattern_steer(Cfg.mic_array_refintf);
	Cfg.refnoise_steer_out=beampattern_steer(Cfg.mic_array_refnoise);
end

beamformingout=zeros(1,src_len);
reg_matrix=zeros(Cfg.SimMicNum,FiltL);
if Cfg.GenieEn==1
	Cfg.refdata_beamformingout=zeros(1,src_len);
	Cfg.refintf_beamformingout=zeros(1,src_len);
	Cfg.refnoise_beamformingout=zeros(1,src_len);
	Cfg.refdata_reg_matrix=zeros(Cfg.SimMicNum,FiltL);
	Cfg.refintf_reg_matrix=zeros(Cfg.SimMicNum,FiltL);
	Cfg.refnoise_reg_matrix=zeros(Cfg.SimMicNum,FiltL);
end

C_T=zeros(FiltL,Cfg.SimMicNum*FiltL);
for i=1:FiltL
	range_idx=[1:Cfg.SimMicNum]+(i-1)*Cfg.SimMicNum;
	C_T(i,range_idx)=ones(1,Cfg.SimMicNum);
end
C=C_T.';

F=contraint_vector.';
%init weight matrix
W0=C*inv(C_T*C)*F;

mean_error=zeros(1,FiltL);
u=Cfg.CCAF_u;
sim_len=src_len;
if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('10'))
	figure;plot(mic_steer_out(:,1:500).');
end

for mic_idx=1:Cfg.SimMicNum
	W(mic_idx,:)=W0(mic_idx:Cfg.SimMicNum:end);
end

for i=1:sim_len

	%input phase
	for mic_idx=1:Cfg.SimMicNum
		reg_matrix(mic_idx,:)=[mic_steer_out(mic_idx,i),reg_matrix(mic_idx,1:end-1)];
		if Cfg.GenieEn==1
			Cfg.refdata_reg_matrix(mic_idx,:)=[Cfg.refdata_steer_out(mic_idx,i),Cfg.refdata_reg_matrix(mic_idx,1:end-1)];
			Cfg.refnoise_reg_matrix(mic_idx,:)=[Cfg.refnoise_steer_out(mic_idx,i),Cfg.refnoise_reg_matrix(mic_idx,1:end-1)];
			Cfg.refintf_reg_matrix(mic_idx,:)=[Cfg.refintf_steer_out(mic_idx,i),Cfg.refintf_reg_matrix(mic_idx,1:end-1)];
		end
	end
	y(i)=sum(sum(W.*reg_matrix));
	if Cfg.GenieEn==1
		Cfg.refdata_beamformingout(i)=sum(sum(W.*Cfg.refdata_reg_matrix));
		Cfg.refnoise_beamformingout(i)=sum(sum(W.*Cfg.refnoise_reg_matrix));
		Cfg.refintf_beamformingout(i)=sum(sum(W.*Cfg.refintf_reg_matrix));
	end
	if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('10'))
		ydebug(i,:)=sum(W.*reg_matrix,2);
	end

	for fil_idx=1:FiltL
		mean_error(fil_idx)=0;
		mean_error(fil_idx)=sum(W(:,fil_idx)-u*y(i)*reg_matrix(:,fil_idx))/Cfg.SimMicNum;
	end
	%figure;plot(mean_error);title('mean error');grid on;
	for mic_idx=1:Cfg.SimMicNum
		W(mic_idx,:)=W(mic_idx,:)-u*y(i)*reg_matrix(mic_idx,:)-mean_error+F.'/Cfg.SimMicNum;
	end
end
beamformingout=y;

if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('10'))
	figure;plot(mic_steer_out(:,1:sim_len).');title('steer out');
	hold on;plot(Cfg.idealvad_steerout(1:sim_len),'r');
	figure;plot(y,'r');
	hold on;plot(ydebug);legend('yout','1','2','3','4');
end

Cfg.idealvad_fbfout=zeros(1,src_len);
Cfg.idealvad_fbfout(1+round((FiltL-1)/2):end)=Cfg.idealvad_steerout(1:end-round((FiltL-1)/2));
Cfg.cleanspeech_bfdly=zeros(1,src_len);
Cfg.cleanspeech_bfdly(1+round((FiltL-1)/2):end)=Cfg.cleanspeech_steerdly(1:end-round((FiltL-1)/2));
