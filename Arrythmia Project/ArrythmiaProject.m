% SPAM Final Project

%%
file = 100  ;

%% ECG graph

wfdb2mat(int2str(file));  % convert .dat file to .mat file
load([int2str(file), 'm.mat']);
[tm, signal, Fs, labels] = rdmat([int2str(file), 'm']);
signal = signal(:,1);

%% filter
filter = ones(1,10);
signal = conv(signal,filter);

%% analysis
figure(1)
avg = mean(signal);
signal = signal-avg;

brady = []; tachy = []; pre = []; supra = [];
R_inversion = 0;
P_inversion = 0;
for i = 1:129
    T = tm(i*5000:(i+1)*5000); SIGNAL = signal(i*5000:(i+1)*5000);
    [Rpeaks,pos_peaks] = findpeaks(SIGNAL,'MINPEAKDISTANCE',150,'MINPEAKHEIGHT',.5);
    % R peaks
    if length(Rpeaks) < 4
        [Rpeaks,pos_peaks] = findpeaks(-SIGNAL,'MINPEAKDISTANCE',150,'MINPEAKHEIGHT',max(-SIGNAL)/2);
        Rpeaks = -Rpeaks;
        R_inversion = 1;
    end
    % P wave peaks 
    [Ppeaks,pos_Ppeaks] = findpeaks(SIGNAL,'MINPEAKDISTANCE',50,'MINPEAKHEIGHT',0.2);
    if (length(Ppeaks)-length(Rpeaks)+1) ~= length(Rpeaks)
        [Ppeaks,pos_Ppeaks] = findpeaks(SIGNAL,'MINPEAKDISTANCE',50,'MINPEAKHEIGHT',0.05);
    elseif length(Ppeaks)/2<length(Rpeaks)
        [Ppeaks,pos_Ppeaks] = findpeaks(-SIGNAL,'minpeakdistance',100,'minpeakheight',max(-SIGNAL)/3);
        P_inversion = 1;
    end
    num_P = (length(Ppeaks)-length(Rpeaks))-1;
    % Heartrate   
    heartrate = length(Rpeaks)/14*60;
    % RR intervals
    RR_intervals = [];
    for i = 1:length(Rpeaks)-1
        t = (pos_peaks(i+1)-pos_peaks(i))/Fs;
        RR_intervals = [RR_intervals t];
    end
    RR_std = std(RR_intervals);
    % Diagnosis
    if heartrate<55
        brady = [brady i];
    end
    if heartrate>95 && P_inversion == false
        tachy = [tachy i];
    end
    if heartrate>95 && (P_inversion == true || R_inversion == true)
        supra = [supra i];
    end
    if num_P>length(Rpeaks) || RR_std>0.05 || P_inversion == true || R_inversion == true
        pre = [pre i];
    end
end

% ECG plot
% R peaks
t = tm(1:5000); signal = signal(1:5000); 
[Rpeaks,pos_peaks] = findpeaks(signal,'MINPEAKDISTANCE',150,'MINPEAKHEIGHT',.5);
R_inversion = 0;
if length(Rpeaks) < 4
    [Rpeaks,pos_peaks] = findpeaks(-signal,'MINPEAKDISTANCE',150,'MINPEAKHEIGHT',max(-signal)/2);
    Rpeaks = -Rpeaks;
    R_inversion = 1;
end
% P wave peaks 
[Ppeaks,pos_Ppeaks] = findpeaks(signal,'MINPEAKDISTANCE',50,'MINPEAKHEIGHT',0.2);
P_inversion = 0;
if (length(Ppeaks)-length(Rpeaks)+1) ~= length(Rpeaks)
    [Ppeaks,pos_Ppeaks] = findpeaks(signal,'MINPEAKDISTANCE',50,'MINPEAKHEIGHT',0.05);
elseif length(Ppeaks)/2<length(Rpeaks)
    [Ppeaks,pos_Ppeaks] = findpeaks(-signal,'minpeakdistance',100,'minpeakheight',max(-signal)/3);
    P_inversion = 1;
end
num_P = (length(Ppeaks)-length(Rpeaks));
subplot(2,1,1)
plot(t,signal,pos_peaks/Fs,Rpeaks,'ro',pos_Ppeaks/Fs,Ppeaks,'r*')
xlabel('time (sec)'); ylabel('amplitude (mV)');
title(['Record I from Lead ', labels(1).Description]); xlim([0 10]);
% frequency domain plot
subplot(2,1,2)
freq = -length(signal)/2:(length(signal)-1)/2;
plot(freq,abs(fft(signal)))

%% DIAGNOSIS and SUGGESTED TREATMENTS:
disp("Patient's heartrate:")
disp(heartrate)
% bradyarrhythmia
if length(brady)>40
    disp("Patient's heart rate is below the healthy limit of 60 bpm, which indicates BRADYARRHYTHMIA. ")

end
% tachycardia
if length(tachy)>3
    disp("Patient's heart rate is above the healthy limit of 100 bpm, which indicates VENTRICULAR ")
    disp('ARRHYTHMIA (TACHYCARDIA).')
end

% supraventricular arrythmia
if length(supra)>0
    disp("Patient's heart rate is above the healthy limit of 100 bpm and has P wave inversion, ")
    disp('which indicates SUPRAVENTRICULAR ARRYTHMIA.')
end

% premature or extra beat
if length(pre)>2
    disp("Patient has an abnormal P wave (double hump or inverted) or a broad QRS complex, which ")
    disp('indicates PREMATURE OR EXTRA BEAT.')
end
