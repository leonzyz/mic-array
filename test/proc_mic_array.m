%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% platform: microphone array simple simulation scripts
% using GCC and CMU's data

%   Author: leonzyz
%   Date: 2017/10/21 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;close all;

addpath('../source','../cfg','../platform');

micarr_dis=3e-2;
data_set_prefix='an';
data_set_postfix={'arr3A','senn3'};
data_set_path='../source/'
fs_voice=16e3;
micarr_delta=micarr_dis/340;
max_delay=5

for dataidx=1:1:1
	%micarr_data_file=strcat(data_set_path,data_set_prefix,num2str(100+dataidx),'-mtms-',data_set_postfix{1},'.adc');
	%micref_data_file=strcat(data_set_path,data_set_prefix,num2str(100+dataidx),'-mtms-',data_set_postfix{2},'.adc');
	micarr_data_file=strcat(data_set_prefix,num2str(100+dataidx),'-mtms-',data_set_postfix{1},'.adc');
	micref_data_file=strcat(data_set_prefix,num2str(100+dataidx),'-mtms-',data_set_postfix{2},'.adc');

	[arr_datainfo,arr_data]=split_adc_data(micarr_data_file);
	[ref_datainfo,ref_data]=split_adc_data(micref_data_file);

	data1_ref=arr_data(8,:);
	figure;plot(data1_ref);grid on;title('raw data of mic-8');
	figure;plot(ref_data);grid on;title('clean speech');
	seglen=128*128;
	tao=[]
	for mic_idx=1:15
		data2=arr_data(mic_idx,:);
		[tao(mic_idx),rr_sum]=GCC_PHAT(data1_ref,data2,seglen,fs_voice);
		%figure;plot(abs(rr_sum));
	end
	figure;plot(tao);grid on;xlabel('mic-array idx');ylabel('delay in Sample');
end
