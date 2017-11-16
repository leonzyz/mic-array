function fixbeamformingout=fixbeamforming(mic_array_input)
global Cfg;


src_len=length(mic_array_input(1,:));
if Cfg.MicArrayType==0
	mic_steer_out=beampattern_steer(mic_array_input);
	Cfg.SourceDlyFBFOut=Cfg.SourceDlySteerOut;
	if Cfg.FBFMode==0
		FBFSumVect=ones(1,Cfg.SimMicNum)/Cfg.SimMicNum;
	else
		%FIXME:unfinished
		FBFSumVect=ones(1,Cfg.SimMicNum)/Cfg.SimMicNum;
	end
	fixbeamformingout=FBFSumVect*mic_steer_out;

	if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('04'))
		figure;
		plot(fixbeamformingout,'r');hold on;
		delay_clean_speech=zeros(1,src_len);
		delay_clean_speech(Cfg.SourceDlyFBFOut+1:end)=Cfg.cleanspeech(1:Cfg.ChanAdcFsRatio:end-Cfg.ChanAdcFsRatio*Cfg.SourceDlyFBFOut);
		plot(delay_clean_speech,'g');
		grid on;legend('fbf out','delay clean speech');
		title('fixbeamforming debug out');
	end
	Cfg.idealvad_fbfout=zeros(1,src_len);
	Cfg.idealvad_fbfout=Cfg.idealvad_steerout;
end
