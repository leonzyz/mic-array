function [datainfo,data]=split_adc_data(adc_data_file)
fp=fopen(adc_data_file,'r');
adc_data_file

datainfo.ad_hdrsize=fread(fp,1,'int16','b');
datainfo.ad_version=fread(fp,1,'int16','b');
datainfo.ad_channels=fread(fp,1,'int16','b');
datainfo.ad_rate=fread(fp,1,'uint16','b');
datainfo.ad_samples=fread(fp,1,'int32','b');
datainfo.little_indian=fread(fp,1,'int32','b');
datainfo.div_per_sec=fread(fp,1,'uint32','b');

data_tmp=fread(fp,Inf,'int16','b');
fclose(fp);
datalen=length(data_tmp)/datainfo.ad_channels;
data=reshape(data_tmp,datainfo.ad_channels,datalen);

end
