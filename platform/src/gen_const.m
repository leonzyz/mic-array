%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%	gen_const.m
%		script to generate const param, param constraint and valid check
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


global Cfg;
Cfg.VoiceSpeed=340;
if Cfg.BeamformingMode~=4 && Cfg.BeamformingMode~=5
	Cfg.MicRowNum=1;
	Cfg.MicRowDist=1e-2;
elseif ~(exist('Cfg') && isfield(Cfg,'MicRowNum'))
	Cfg.MicRowNum=1;
	Cfg.MicRowDist=1e-2;
end
