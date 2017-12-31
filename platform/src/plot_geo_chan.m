function plot_geo_chan()
global Cfg;
figure();
plot(Cfg.SourcePosXY(1),Cfg.SourcePosXY(2),'gO');hold on;
plot(Cfg.InfPosXY(1),Cfg.InfPosXY(2),'bO');hold on;
for r=1:Cfg.SimMicRowNum
	for i=1:Cfg.SimMicNum
		plot(Cfg.MicArrayPosXY(1,i,r),Cfg.MicArrayPosXY(2,i,r),'r*');hold on;
	end
end
grid on;
maxX=max([abs(Cfg.SourcePosXY(1)),abs(Cfg.InfPosXY(1))]);
maxY=max([abs(Cfg.SourcePosXY(2)),abs(Cfg.InfPosXY(2))]);

Wallpos=Cfg.Wallpos;
%plot wall
plot([Wallpos(1,1) Wallpos(1,2)],[Wallpos(2,1) Wallpos(2,2)],'k','LineWidth',2);
plot([Wallpos(1,2) Wallpos(1,3)],[Wallpos(2,2) Wallpos(2,3)],'k','LineWidth',2);
plot([Wallpos(1,3) Wallpos(1,4)],[Wallpos(2,3) Wallpos(2,4)],'k','LineWidth',2);
plot([Wallpos(1,4) Wallpos(1,1)],[Wallpos(2,4) Wallpos(2,1)],'k','LineWidth',2);
maxX=max([maxX,Wallpos(1,1),Wallpos(1,2),Wallpos(1,3),Wallpos(1,4)]);
maxY=max([maxY,Wallpos(2,1),Wallpos(2,2),Wallpos(2,3),Wallpos(2,4)]);

if Cfg.ChanMode==1
	for i=1:4
		plot(Cfg.SourceImagePosXY(i,1),Cfg.SourceImagePosXY(i,2),'mO');
		plot(Cfg.InfImagePosXY(i,1),Cfg.InfImagePosXY(i,2),'cO');

		maxX=max([maxX,abs(Cfg.SourceImagePosXY(i,1)),abs(Cfg.InfImagePosXY(i,1))]);
		maxY=max([maxY,abs(Cfg.SourceImagePosXY(i,2)),abs(Cfg.InfImagePosXY(i,2))]);
	end
end

maxX=maxX*1.1;
maxY=maxY*1.1;

axis([-maxX,maxX,-maxY,maxY]);
