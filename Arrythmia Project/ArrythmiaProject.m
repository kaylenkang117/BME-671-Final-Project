% SPAM Final Project

%%
file = 100;
wfdb2mat(int2str(file));  % convert .dat file to .mat file
load([int2str(file), 'm.mat']);
% val = stored ECG signal
[tm, signal, Fs, labels] = rdmat([int2str(file), 'm']);
% Fs = sampling frequency, which is 360 Hz in this case (for FIR filter)
% signal = the ECG signal values 
% tm = corresponding sampling time 
% labels = related information about the signal
signal(:,1);
% sample 20 sec of data
ECG = signal(1:20*Fs);
t = tm(1:20*Fs);
plot(t,ECG)
FT = fft(ECG);
freq = -length(ECG)/2:(length(ECG)-1)/2;
plot(freq, abs(FT))
order = 50;

[Xk, f0, Series, f] = ComplexExpFourierSeriesLibby(ECG,order,t);

bpm = f0*60/20