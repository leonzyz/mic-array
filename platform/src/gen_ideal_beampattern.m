function beampattern=gen_ideal_beampattern(f,theta)
global Cfg;
N=Cfg.SimMicNum;
lambda=Cfg.VoiceSpeed/f;
d=Cfg.SimMicDist;
thetaT=Cfg.FBFSteerAngle/180*pi;
beampattern=1/N*sin(N/2*2*pi/lambda*(cos(theta)-cos(thetaT))*d)./sin(1/2*2*pi/lambda*(cos(theta)-cos(thetaT))*d);
