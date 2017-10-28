%
clear all;close all

%fp=fopen('an102-mtms-senn3.adc','r');
fp=fopen('an102-mtms-arr3A.adc','r');
%fp=fopen('cen2-mgil-sen.adc','r');
%fp=fopen('an121-mdik-senn.adc','r');

ad_hdrsize=fread(fp,1,'int16','b')
ad_version=fread(fp,1,'int16','b')
ad_channels=fread(fp,1,'int16','b')
ad_rate=fread(fp,1,'uint16','b')
ad_samples=fread(fp,1,'int32','b')
little_indian=fread(fp,1,'int32','b')
div_per_sec=fread(fp,1,'uint32','b')

data=fread(fp,Inf,'int16','b');

fs_voice=16e3;
for i=1:5
	data1=data(i:15:end)/2^16;
	figure;plot(data1)
	sound(data1,fs_voice);
end

fclose(fp)


%{
[voice,fs_voice]=wavread('voice_source.wav');
figure;plot(voice)
sound(voice,fs_voice);
%}
