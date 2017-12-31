%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% beampattern_steer: steering the beam pattern direction in RA beamforming

%	Input:
%		Microphone Array input
%	Global Parma:Cfg
%	Ouput:
%		Steered Microphone array output
%	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mic_steer_out=beampattern_steer_RA(mic_array_input)
global Cfg;
%mic_array_input=mic_array_input_in(:,:,1);

src_len=length(mic_array_input(1,:,1));
if Cfg.MicArrayType==0
	mic_steer_out=zeros(Cfg.SimMicNum,src_len,Cfg.SimMicRowNum);
	delay_vector=zeros(Cfg.SimMicNum,Cfg.SimMicRowNum);
	for r=1:Cfg.SimMicRowNum
		delay_vector(:,r)=-1*(cos(Cfg.FBFSteerAngle/180*pi)*Cfg.MicArrayPosXY(1,:,r)+sin(Cfg.FBFSteerAngle/180*pi)*Cfg.MicArrayPosXY(2,:,r))/Cfg.VoiceSpeed*Cfg.AdcFs;
		if Cfg.FBFSteerMode==0
			common_dly=floor((Cfg.FBFfiltLen-1)/2);
			for i=1:Cfg.SimMicNum
				mic_dly=-round(delay_vector(i,r))+common_dly;
				if mic_dly>Cfg.FBFfiltLen-1
					mic_dly=FBFfiltLen-1;
				elseif mic_dly<0
					mic_dly=0;
				end
				mic_steer_filter=zeros(1,Cfg.FBFfiltLen);
				mic_steer_filter(mic_dly+1)=1;
				mic_steer_out(i,:,r)=filter(mic_steer_filter,1,mic_array_input(i,:,r));
			end
		elseif Cfg.FBFSteerMode==1
			common_dly=(Cfg.FBFfiltLen-1)/2;
			for i=1:Cfg.SimMicNum
				mic_dly=delay_vector(i,r)+common_dly;
				mic_steer_filter=sinc([-common_dly:1:common_dly]+delay_vector(i,r));
				mic_steer_filter=mic_steer_filter/sum(mic_steer_filter);
				mic_steer_out(i,:,r)=filter(mic_steer_filter,1,mic_array_input(i,:,r));
			end
		end
	end
	%figure;plot(mic_steer_out(1,1:500,1),'bX-');hold on;plot(mic_array_input(1,1:500,1),'rX-');
	%hold on;plot(mic_steer_out(1,1:500,2),'bO-');hold on;plot(mic_array_input(1,1:500,2),'rO-');
end
if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('02'))
	figure;
	legend_str={};
	for i=1:Cfg.SimMicNum
		plot(mic_array_input(i,:,1));hold on;
		legend_str{i}=num2str(i);
	end
	legend(legend_str);grid on;title('mic array input debug out');
	figure;
	legend_str={};
	for i=1:Cfg.SimMicNum
		plot(mic_steer_out(i,:,1));hold on;
		legend_str{i}=num2str(i);
	end
	legend(legend_str);grid on;title('steer filter debug out');
end
Cfg.SourceDlySteerOut=Cfg.SourceDlyChanOut+round(common_dly);
Cfg.idealvad_steerout=zeros(1,src_len);
Cfg.idealvad_steerout(1+round(common_dly):end)=Cfg.idealvad_chanout(1:end-round(common_dly));
Cfg.cleanspeech_steerdly=zeros(1,src_len);
Cfg.cleanspeech_steerdly(1+round(common_dly):end)=Cfg.cleanspeech_chandly(1:end-round(common_dly));

