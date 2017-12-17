function [upperbound,lowerbound]=gen_ccaf_mask_RA(max_phase_err)
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
upbuff=ones(Cfg.MicNum,filtL,Cfg.MicRowNum)*-10;
lowbuff=ones(Cfg.MicNum,filtL,Cfg.MicRowNum)*10;
figure;
for i=idxrange
	phase=(i-1)*phasestep-phasebound;
	filename=strcat(Cfg.CCAF_MaskFileDir,'/final_ABM_SteerErr',num2str(phase),'.mat');
	load(filename);
	for r=1:Cfg.MicRowNum
		for micidx=1:Cfg.MicNum
			upbuff(micidx,:,r)=max([ABM_W_final(micidx,:,r);upbuff(micidx,:,r)]);
			lowbuff(micidx,:,r)=min([ABM_W_final(micidx,:,r);lowbuff(micidx,:,r)]);
		end
	end
	if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('40'))
		plot(ABM_W_final(1,:,1));hold on;
	end
end
upperbound=upbuff;
lowerbound=lowbuff;
%smooth
for k=1:5
	for i=2:filtL-1
		for r=1:Cfg.MicRowNum
			for micidx=1:Cfg.MicNum
				if upperbound(micidx,i,r)<upperbound(micidx,i-1,r) && upperbound(micidx,i,r)<upperbound(micidx,i+1,r)
					upperbound(micidx,i,r)=(upperbound(micidx,i-1,r)+upperbound(micidx,i+1,r))/2;
				end
				if lowerbound(micidx,i,r)>lowerbound(micidx,i-1,r) && lowerbound(micidx,i,r)>lowerbound(micidx,i+1,r)
					lowerbound(micidx,i,r)=(lowerbound(micidx,i-1,r)+lowerbound(micidx,i+1,r))/2;
				end
			end
		end
	end
end
%upperbound=upperbound*1.1;
%lowerbound=lowerbound*1.1;
if Cfg.DebugEn && bitand(Cfg.DebugMask,hex2dec('40'))
	plot(upbuff(1,:,1),'rO-');hold on;
	plot(lowbuff(1,:,1),'gO-');hold on;
	plot(upperbound(1,:,1),'m');hold on;
	plot(lowerbound(1,:,1),'k');hold on;
end

