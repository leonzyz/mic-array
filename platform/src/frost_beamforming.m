function beamformingout=frost_beamforming(mic_array_input)
global Cfg;
src_len=length(mic_array_input(1,:));

FiltL=16;
contraint_vector=zeros(1,FiltL);
contraint_vector(floor((FiltL-1)/2))=1;

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

%{
FBFSumVect=ones(1,Cfg.SimMicNum)/Cfg.SimMicNum;
beamformingout=FBFSumVect*mic_steer_out;
%}
beamformingout=zeros(1,src_len);
%ydebug=zeros(src_len,Cfg.SimMicNum);

reg_matrix=zeros(Cfg.SimMicNum,FiltL);
C_T=zeros(FiltL,Cfg.SimMicNum*FiltL);
for i=1:FiltL
	range_idx=[1:Cfg.SimMicNum]+(i-1)*Cfg.SimMicNum;
	C_T(i,range_idx)=ones(1,Cfg.SimMicNum);
end
C=C_T.';
if 0
	display(strcat('size of C=',num2str(size(C))));
	display(strcat('size of C_T=',num2str(size(C_T))));
end

F=contraint_vector.';
%init weight matrix
W0=C*inv(C_T*C)*F;
if 0
	display(strcat('size of W0=',num2str(size(W0))));
end

mean_error=zeros(1,FiltL);
u=Cfg.CCAF_u;
sim_len=src_len;
%figure;plot(mic_steer_out(1,:));
%figure;plot(mic_array_input(:,1:500).');
if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('10'))
	figure;plot(mic_steer_out(:,1:500).');
end

for mic_idx=1:Cfg.SimMicNum
	W(mic_idx,:)=W0(mic_idx:Cfg.SimMicNum:end);
end
%figure;plot(W.');
%figure;plot(F);

for i=1:sim_len

	%input phase
	for mic_idx=1:Cfg.SimMicNum
		reg_matrix(mic_idx,:)=[mic_steer_out(mic_idx,i),reg_matrix(mic_idx,1:end-1)];
	end
	y(i)=sum(sum(W.*reg_matrix));
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
Cfg.idealvad_fbfout(1:end-round((FiltL-1)/2))=Cfg.idealvad_steerout(1+round((FiltL-1)/2):end);
