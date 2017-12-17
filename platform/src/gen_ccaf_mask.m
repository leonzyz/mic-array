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
upbuff=ones(Cfg.MicNum,filtL)*-10;
lowbuff=ones(Cfg.MicNum,filtL)*10;
figure;
for i=idxrange
	phase=(i-1)*phasestep-phasebound;
	filename=strcat(Cfg.CCAF_MaskFileDir,'/final_ABM_SteerErr',num2str(phase),'.mat');
	load(filename);
	for micidx=1:Cfg.MicNum
		upbuff(micidx,:)=max([ABM_W_final(micidx,:);upbuff(micidx,:)]);
		lowbuff(micidx,:)=min([ABM_W_final(micidx,:);lowbuff(micidx,:)]);
	end
	if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('40'))
		plot(ABM_W_final(1,:));hold on;
	end
end
upperbound=upbuff;
lowerbound=lowbuff;
%smooth
for k=1:5
	for i=2:filtL-1
		for micidx=1:Cfg.MicNum
			if upperbound(micidx,i)<upperbound(micidx,i-1) && upperbound(micidx,i)<upperbound(micidx,i+1)
				upperbound(micidx,i)=(upperbound(micidx,i-1)+upperbound(micidx,i+1))/2;
			end
			if lowerbound(micidx,i)>lowerbound(micidx,i-1) && lowerbound(micidx,i)>lowerbound(micidx,i+1)
				lowerbound(micidx,i)=(lowerbound(micidx,i-1)+lowerbound(micidx,i+1))/2;
			end
		end
	end
end
%upperbound=upperbound*1.1;
%lowerbound=lowerbound*1.1;
if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('40'))
	plot(upbuff(1,:),'rO-');hold on;
	plot(lowbuff(1,:),'gO-');hold on;
	plot(upperbound(1,:),'m');hold on;
	plot(lowerbound(1,:),'k');hold on;
end
