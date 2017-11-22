function [upperbound,lowerbound]=gen_ccaf_mask(max_phase_err)
global Cfg;
phasestep=2;
max_phase=40;
max_phase_err=abs(max_phase_err);
if max_phase_err>max_phase
	phasebound=max_phase;
else
	phasebound=round(max_phase_err/phasestep)*phasestep;
end
filtL=Cfg.CCAF_K*2+1;

idxrange=1:(phasebound/phasestep)*2+1;
upbuff=ones(1,filtL)*-10;
lowbuff=ones(1,filtL)*10;
figure;
for i=idxrange
	phase=(i-1)*phasestep-phasebound;
	filename=strcat('final_ABM_SteerErr',num2str(phase),'.mat');
	load(filename);
	upbuff=max([ABM_W_final;upbuff]);
	lowbuff=min([ABM_W_final;lowbuff]);
	if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('40'))
		plot(ABM_W_final(1,:));hold on;
	end
end
upperbound=upbuff;
lowerbound=lowbuff;
%smooth
for k=1:5
	for i=2:filtL-1
		if upperbound(i)<upperbound(i-1) && upperbound(i)<upperbound(i+1)
			upperbound(i)=(upperbound(i-1)+upperbound(i+1))/2;
		end
		if lowerbound(i)>lowerbound(i-1) && lowerbound(i)>lowerbound(i+1)
			lowerbound(i)=(lowerbound(i-1)+lowerbound(i+1))/2;
		end
	end
end
if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('40'))
	plot(upbuff,'rO-');hold on;
	plot(lowbuff,'gO-');hold on;
	plot(upperbound,'m');hold on;
	plot(lowerbound,'k');hold on;
end
