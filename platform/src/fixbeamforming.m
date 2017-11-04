function fixbeamforminout=fixbeamforming(mic_array_input)
global Cfg;


src_len=length(mic_array_input(1,:));
if Cfg.MicArrayType==0
	delay_vector=-1*cos(Cfg.FBFSteerAngle/180*pi)*Cfg.MicArrayPosXY(1,:)/Cfg.VoiceSpeed*Cfg.AdcFs;
	%mic_steer_filter=zeros(Cfg.SimMicNum,Cfg.FBFfiltLen);
	mic_steer_out=zeros(Cfg.SimMicNum,src_len);
	if Cfg.FBFSteerMode==0
		common_dly=floor((Cfg.FBFfiltLen-1)/2);
		for i=1:Cfg.SimMicNum
			mic_dly=-round(delay_vector(i))+common_dly;
			if mic_dly>Cfg.FBFfiltLen-1
				mic_dly=FBFfiltLen-1;
			elseif mic_dly<0
				mic_dly=0;
			end
			mic_steer_filter=zeros(1,Cfg.FBFfiltLen);
			mic_steer_filter(mic_dly+1)=1;
			mic_steer_out(i,:)=filter(mic_steer_filter,1,mic_array_input(i,:));
		end
	elseif Cfg.FBFSteerMode==1
		common_dly=(Cfg.FBFfiltLen-1)/2;
		for i=1:Cfg.SimMicNum
			mic_dly=delay_vector(i)+common_dly;
			mic_steer_filter=sinc([-common_dly:1:common_dly]+delay_vector(i));
			mic_steer_out(i,:)=filter(mic_steer_filter,1,mic_array_input(i,:));
		end
	end
	if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('02'))
		figure;
		legend_str={};
		for i=1:Cfg.SimMicNum
			plot(mic_array_input(i,:));hold on;
			legend_str{i}=num2str(i);
		end
		legend(legend_str);grid on;title('mic array input debug out');
		figure;
		legend_str={};
		for i=1:Cfg.SimMicNum
			plot(mic_steer_out(i,:));hold on;
			legend_str{i}=num2str(i);
		end
		legend(legend_str);grid on;title('steer filter debug out');
	end
	Cfg.SourceDlyFBFOut=Cfg.SourceDlyChanOut+round(common_dly);
	Cfg.idealvad_fbfout=zeros(1,src_len);
	Cfg.idealvad_fbfout=Cfg.idealvad_chanout(1+round(common_dly):end-round(common_dly));

	if Cfg.FBFMode==0
		FBFSumVect=ones(1,Cfg.SimMicNum)/Cfg.SimMicNum;
	else
		FBFSumVect=ones(1,Cfg.SimMicNum)/Cfg.SimMicNum;
	end
	fixbeamforminout=FBFSumVect*mic_steer_out;

	if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('03'))
		figure;
		plot(fixbeamforminout,'r');hold on;
		delay_clean_speech=zeros(1,src_len);
		delay_clean_speech(Cfg.SourceDlyFBFOut+1:end)=Cfg.cleanspeech(1:Cfg.ChanAdcFsRatio:end-Cfg.ChanAdcFsRatio*Cfg.SourceDlyFBFOut);
		plot(delay_clean_speech,'g');
		grid on;legend('fbf out','delay clean speech');
		title('fixbeamforming debug out');
	end
end
