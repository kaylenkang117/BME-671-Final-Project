% go to mcode file location, type addpath(pwd); savepath; in Command Window
% to add whole folder to MATLAB default path.
%% Read .dat file
file = 100;
wfdb2mat(int2str(file));  % convert .dat file to .mat file
load([int2str(file), 'm.mat']);
% val = stored ECG signal
[tm, signal, Fs, labels] = rdmat([int2str(file), 'm']);
% Fs = sampling frequency, which is 360 Hz in this case (for FIR filter)
% signal = the ECG signal values 
% tm = corresponding sampling time 
% labels = related information about the signal. 
signal(:,1);

%% filtering
x_axis = (-length(signal)/2:length(signal)/2-1)*Fs;
fourier = fftshift(abs(fft(signal)));
figure (1)
subplot(211)
plot(x_axis,fourier)
title('Fourier: Raw ECG data');xlabel('Frequency (Hz)')
hold on
signal = highpass(signal,.5,360);
filtered_fourier = fftshift(abs(fft(signal)));
subplot(212)
plot(x_axis,filtered_fourier)
title('Fourier: Filtered ECG data');xlabel('Frequency (Hz)')

%%
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
    num_P = (length(Ppeaks)-length(Rpeaks));
    % Heartrate   
    heartrate = length(Rpeaks)/t(end)*60;
    % RR intervals
    RR_intervals = [];
    for i = 1:length(Rpeaks)-1
        t = (pos_peaks(i+1)-pos_peaks(i))/Fs;
        RR_intervals = [RR_intervals t];
    end
    RR_std = std(RR_intervals);
    % Diagnosis
    if heartrate<59
        brady = [brady i];
    end
    if heartrate>95
        tachy = [tachy i];
    end
    if heartrate>95 && P_inversion == true
        supra = [supra i];
    end
    if num_P>length(Rpeaks) || RR_std>0.5 || P_inversion == true || R_inversion == true
        pre = [pre i];
    end
end
if length(brady)>0
    disp('brady')
end
if length(tachy)>0
    disp('tachy')
end
if length(pre)>0
    disp('pre')
end
if length(supra)>0
    disp('supra')
end
%% 
% R peaks
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

% ECG plot
plot(t,signal,pos_peaks/Fs,Rpeaks,'ro',pos_Ppeaks/Fs,Ppeaks,'r*')
xlabel('time (sec)'); ylabel('amplitude (mV)');
title(['Record I from Lead ', labels(1).Description]);
xlim([0 10])
% Heartrate   
heartrate = length(Rpeaks)/t(end)*60;

% RR intervals
RR_intervals = [];
for i = 1:length(Rpeaks)-1
    t = (pos_peaks(i+1)-pos_peaks(i))/Fs;
    RR_intervals = [RR_intervals t];
end
RR_std = std(RR_intervals);
%% Diagnosis
% bradyarrhythmia
if heartrate<50 
    disp('Your heart rate is below the healthy limit of 60 bpm, which indicates BRADYARRHYTHMIA.') 
    disp('Possible treatments include, a pacemaker to send an electrical signal to fix irregular heartbeat or medications')
    disp('There are also 3 medications that are commonly used: Atropine increase heart rate by blocking the effects of the vagus nerve,')
    disp('and epinephrine or dopamine through IV injections.')
end
% tachycardia
if heartrate>95
    disp('Your heart rate is above the healthy limit of 100 bpm, which indicates VENTRICULAR ARRHYTHMIA (TACHYCARDIA)') 
    disp('Possible treatments include cardiodiversion, implantable cardiovector-defibrillator, or anti-arrhythmic drugs.')
end

% supraventricular arrythmia
if heartrate>95 && P_inversion == true
    disp('Your heart rate is above the healthy limit of 100 bpm and have P wave inversion, which indicate ')
    disp('SUPRAVENTRICULAR ARRYTHMIA.')
    disp('Possible treatments includes calcium channel and beta blockers, antiarrhythmic drugs such as ')
    disp('flecainide or propafenone, electrical cardioversion, or catheter ablation.')
end

% premature or extra beat
if num_P>length(Rpeaks) || RR_std>0.05 || P_inversion == true || R_inversion == true
    disp('You have an abnormal P wave (double hump or inverted) or a broad QRS complex, which inidicates PREMATURE OR EXTRA BEAT.')
    disp('Possible treatments include antiarrhythmics, beta-blockers, calcium channel blockers.')
    disp('If very mild, no treatment is required.')
    disp('However, if very severe, radiofrequency ablation surgery may be performed.')
end

disp('Please consult a doctor about further diagnosis and treatment plans.')