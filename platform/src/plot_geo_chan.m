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
maxX=max([abs(Cfg.SourcePosXY(1)),abs(Cfg.InfPosXY(1))])*1.1;
maxY=max([abs(Cfg.SourcePosXY(2)),abs(Cfg.InfPosXY(2))])*1.1;
axis([-maxX,maxX,-maxY,maxY]);
