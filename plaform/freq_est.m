function freq=freq_est(data,len,fs)
fftout=fft(data(1:len)-mean(data));
%figure;plot(abs(fftout));
delta_f=fs/len;
[peak,pos]=max(abs(fftout(1:len/2)));
freq=(pos-1)*delta_f;


