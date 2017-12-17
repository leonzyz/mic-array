%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% gen_geo_chan: generate XY Pos of mic-array,source and interference

%	Input:
%		None: use SourcePos/InfPos,MicNum,MicDist from Cfg
%		SourcePos/InfPos: position of Source and Inteference
%		%%MicNum/MicDist: mic-array number and distance
%		MicArrayType:0 ULA,1=RLA,etc
%	Global Parma:Cfg
%	Ouput:
%		Cfg.SourcePosXY: Source Position
%		Cfg.InfPosXY: Inf Position
%		Cfg.MicArrayPosXY: MicArray Position
%	
%   Author: leonzyz
%   Date: 2017/11/03 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%function gen_geo_chan(SourcePos,InfPos,MicNum,MicDist)
function gen_geo_chan(varargin)
narginchk(0,4)
global Cfg;
if nargin==0
	SourcePos=Cfg.SourcePos;
	InfPos=Cfg.InfPos;
	MicNum=Cfg.MicNum;
	MicDist=Cfg.MicDist;
elseif nargin==2
	SourcePos=varargin{1};
	InfPos=varargin{2};
	MicNum=Cfg.MicNum;
	MicDist=Cfg.MicDist;
else
	display('error argument number');return;
end
Cfg.SourceAngleVect=[cos(SourcePos(2)/180*pi),sin(SourcePos(2)/180*pi)];
Cfg.SourceR=SourcePos(1);
Cfg.SourcePosXY=Cfg.SourceR*Cfg.SourceAngleVect;
Cfg.InfAngleVect=[cos(InfPos(2)/180*pi),sin(InfPos(2)/180*pi)];
Cfg.InfR=InfPos(1);
Cfg.InfPosXY=Cfg.InfR*Cfg.InfAngleVect;
Cfg.MicArrayPosXY=zeros(2,MicNum,Cfg.MicRowNum);
Cfg.SimMicNum=MicNum;
Cfg.SimMicRowNum=Cfg.MicRowNum;
Cfg.SimMicDist=MicDist;
Cfg.DistS2M=zeros(MicNum,Cfg.MicRowNum);
Cfg.DistI2M=zeros(MicNum,Cfg.MicRowNum);
MicMaxRowDist=(Cfg.SimMicRowNum-1)/2*Cfg.MicRowDist;
MicRowDistArray=-MicMaxRowDist:Cfg.MicRowDist:MicMaxRowDist;
if Cfg.MicArrayType==0
	for r=1:Cfg.MicRowNum
		Cfg.MicArrayPosXY(2,:,r)=MicRowDistArray(r);
		MicMaxDist=(MicNum-1)/2*MicDist;
		Cfg.MicArrayPosXY(1,:,r)=-MicMaxDist:MicDist:MicMaxDist;
		for i=1:MicNum
			Cfg.DistS2M(i,r)=sqrt((Cfg.MicArrayPosXY(1,i,r)-Cfg.SourcePosXY(1))^2+(Cfg.MicArrayPosXY(2,i,r)-Cfg.SourcePosXY(2)).^2);
			Cfg.DistI2M(i,r)=sqrt((Cfg.MicArrayPosXY(1,i,r)-Cfg.InfPosXY(1))^2+(Cfg.MicArrayPosXY(2,i,r)-Cfg.InfPosXY(2)).^2);
		end
	end
end
