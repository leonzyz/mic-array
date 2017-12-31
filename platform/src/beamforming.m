function beamformingout=beamforming(mic_array_input)
global Cfg;

if Cfg.BeamformingMode==0
	beamformingout=fixbeamforming(mic_array_input(:,:,1));
elseif Cfg.BeamformingMode==1
	beamformingout=frost_beamforming(mic_array_input(:,:,1));
elseif Cfg.BeamformingMode==2
	beamformingout=GriffithsJim_BF(mic_array_input(:,:,1));
elseif Cfg.BeamformingMode==3
	beamformingout=CCAF_ABM_BF(mic_array_input(:,:,1));
elseif Cfg.BeamformingMode==4
	beamformingout=RA_CCAF_ABM_BF(mic_array_input);
elseif Cfg.BeamformingMode==5
	beamformingout=RA_CCAF_ABM_BF_2x1D(mic_array_input);
end



