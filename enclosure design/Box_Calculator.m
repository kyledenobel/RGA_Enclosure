
% Authors: Marco, Kyle

%speaker_name = "supro_tb15";
speaker_name = "celestion_g12t_100";


%% Generating Plots from Data

%converting FRA data into a table
no_box_data_file_name = "driver data/" + speaker_name + ".dat";
FRA_Data = readtable(no_box_data_file_name,'VariableNamingRule','preserve');

ImpedanceValues = FRA_Data(:,2);
PhaseValues = FRA_Data(:,3);
FreqValues = FRA_Data(:,1);

FreqValues = table2array(FreqValues);
PhaseValues = table2array(PhaseValues);
ImpedanceValues = table2array(ImpedanceValues);
ImpedanceValues = 10.^(ImpedanceValues./20);



%plot of empirical data without points
figure(1);
hold on;
plt = plot(FreqValues,ImpedanceValues, color = 'r'); % Mock
xscale("log");
yscale("log");
title('Impedance Magnitude Responses Speaker 99');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title("Figure 3. Emperical and Calculated Voice Coil Impedance vs Frequency")
grid on;
hold off;

% These are lowkey busted.
p1 = datatip(plt, 4*10^3, 16);
p2 = datatip(plt, 10^4, 25);
p3 = datatip(plt, 25e4, 38);
%% Collecting Plot Data for Calculating Small Signal Parameters.

% R_E was measured with a DC ohmmeter
if speaker_name == "supro_tb15"
    R_E = 10.5;
elseif speaker_name == "celestion_g12t_100"
    R_E = 7.64;
else
    error("invalid speaker_name")
end

% R_ES is the maximum value the hump minus R_E
R_ES = max(ImpedanceValues(1:find(FreqValues > 200, 1))) - R_E; % ohms

R1 = sqrt(R_E*(R_E + R_ES)); % ohms

% f1 is the first value of the intersection of R1 and the data
f1 = FreqValues(find(ImpedanceValues(1:find(FreqValues > 200, 1)) > R1, 1)); % Hz

% f2 is the second value of the intersection of R1 and the data
% finding this involves searching the range of frequencies from 1 to 200 backwards
f2 = FreqValues(find(ImpedanceValues(1:find(FreqValues > 200, 1)) > R1, 1, 'last')); % Hz

% fs is the frequency where the max is at
fs = FreqValues(find(ImpedanceValues(1:find(FreqValues > 200, 1), 1) == max(ImpedanceValues(1:find(FreqValues > 200, 1))), 1));

% n for the lossy inductor is the slope of the high frequency portion of
% the graph
% get data points directly from the graph
% these get deleted when running individual sections and kinda breaks the
% matlab how fun.
figure(2);
plt3d = plot3(FreqValues, ImpedanceValues, PhaseValues);
p1_3d = datatip(plt3d, 4.04e3, 16.9, 35.6); %index 375
p2_3d = datatip(plt3d, 1.01e4, 25.58, 39.2); %index 432
p3_3d = datatip(plt3d, 2.51e4, 38.1, 41.32); %index 489

w1 = p2_3d.X*2*pi;
disp("-----------------------------")
disp("w1 = "+w1)
z1 = p2_3d.Y*exp(j*pi*p2_3d.Z/180);
disp("-----------------------------")
disp("z1 = "+z1)
w2 = p3_3d.X*2*pi;
disp("-----------------------------")
disp("w2 = "+w2)
z2 = p3_3d.Y*exp(j*pi*p3_3d.Z/180);
disp("-----------------------------")
disp("z2 = "+z2)

y1 = 1/z1;
y2 = 1/z2;

n = log10(p3_3d.Y/p2_3d.Y)/(log10(p3_3d.X/p2_3d.X));
%n = log10(real(y1)/real(y2))/(log10(p3_3d.X/p2_3d.X));

% calculate L_e
% L_e = abs((1/((j*p2.X*2*pi)^n)) * (p2.Y - R_E - K*((j*2*pi*p2.X/(ws*Qms))/((j*2*pi*p2.X/ws)^2+(j*2*pi*p2.X/(ws*Qms))+1))));
L_e = cos(n*pi/2)/(w1^n*real(y1));
disp("-----------------------------")
disp("L_e = "+L_e)

% calculate L_E
% L_E = p3.Y/p3.X; % non-lossy inductor = Z_measured / w

L_E = (1)/((imag(y1)+(sin(n*pi/2)/(L_e*w1^n)))*w1);
disp("-----------------------------")
disp("L_E = "+L_E)

Qms = (fs/(f2-f1))*sqrt((R_E+R_ES)/(R_E));
Qes = Qms*(R_E/R_ES);
Qts = Qms*(R_E/(R_E+R_ES));
ws = 2*pi*fs;


%% Box Parameters and VAS Calculations

%Measured Box Volume.
if speaker_name == "supro_tb15"
    Vbox = 0.04417428; %this is in meters, 1ft^3
elseif speaker_name == "celestion_g12t_100"
    Vbox = 0.0283168; %this is in meters, 1ft^3
else
    error("invalid speaker_name")
end

%Radius Height and Volume Calculations of Box Opening.
Ropening = 0.1397; %5.5in
Hopening = 0.0254; %1in
Vopening = pi*(Ropening^2)*Hopening;

a_driver = 0.23/2;

%Vdriver uses the equation for the volume of a driver shared in lecture.
Vdriver = 6e-6*(12^4)*0.0283168;

VCT = Vbox + Vopening + Vdriver;
BOX_VAB = VCT;

% plot the data from the speaker pointed into the box
box_data_file_name = "driver data/" + speaker_name + "_box.dat";
BOX_FRA_Data = readtable(box_data_file_name, 'VariableNamingRule','preserve');

% snag the box data from the table and make it into arrays
BOX_ImpedanceValues = BOX_FRA_Data(:,2);
BOX_ImpedanceValues = 10.^(BOX_ImpedanceValues./20);
BOX_FreqValues = BOX_FRA_Data(:,1);
BOX_FreqValues = table2array(BOX_FreqValues);
BOX_ImpedanceValues = table2array(BOX_ImpedanceValues);

% plot the data
figure(3);
hold on;
plot(BOX_FreqValues,BOX_ImpedanceValues, color = 'r'); % Mock
xscale("log");
yscale("log");
title('Figure 4. BOX Impedance Magnitude Responses Speaker 99');
xlabel('Frequency (Hz)');
ylabel('Magnitude');
legend("BOX Empirical");
grid on;
hold off;

% VAS = BOX_VT * ((BOX_fs / fs) * (BOX_Qes / Qes) - 1)
% BOX_R_ES is the impedance value at BOX_fs after subtracting R_E
BOX_R_ES = max(BOX_ImpedanceValues(1:find(BOX_FreqValues > 200, 1))) - R_E; % ohms

BOX_R1 = sqrt(R_E*(R_E + BOX_R_ES)); % ohms

% BOX_f1 is the first value of the intersection of R1 and the data
BOX_f1 = BOX_FreqValues(find(BOX_ImpedanceValues(1:find(BOX_FreqValues > 200, 1)) > BOX_R1, 1)); % Hz

% BOX_f2 is the second value of the intersection of R1 and the data
% to find this, we search the range of frequencies from 1 to 200 backwards
BOX_f2 = BOX_FreqValues(find(BOX_ImpedanceValues(1:find(BOX_FreqValues > 200, 1)) > BOX_R1, 1, 'last')); % Hz

% BOX_fs is the frequency where the local maxima of the impedance data is
BOX_fs = BOX_FreqValues(find(BOX_ImpedanceValues(1:find(BOX_FreqValues > 200, 1), 1) == max(BOX_ImpedanceValues(1:find(BOX_FreqValues > 200, 1))), 1));


% (fs/(f2-f1))*sqrt((R_E+R_ES)/(R_E));
BOX_Qms = (BOX_fs/(BOX_f2-BOX_f1))*sqrt((R_E+BOX_R_ES)/(R_E));
BOX_Qes = BOX_Qms*(R_E/BOX_R_ES);

% Alpha represents the ratio of VAS to BOX_VAB and will be used to
% calculate VAS
alpha = ((BOX_fs / fs) * (BOX_Qes / Qes) - 1);
VAS = BOX_VAB * alpha;

%% Table of Small Signal Parameters
Parameter_Values = [ws;Qts;Qes;Qms;VAS];
parameter_names = {'ws';'Qts';'Qes';'Qms';'Vas'};
Small_Signal_Parameters_Table = table(Parameter_Values, RowNames=parameter_names);
disp("-----------------------------")
disp("Small_Signal_Parameters_Table")
disp(Small_Signal_Parameters_Table)


%% Sanity Checking; Plotting Modeled System on top of Empirical

K = R_ES;

% frequencies in radians
w = 2*pi*FreqValues;

% complex variable s
s = j*w;

Tf0 = R_E*ones(size(w)); %base Re that is added to everything

Tf1 = K*((s/(ws*Qms))./((s/ws).^2+(s/(ws*Qms))+1)); %second order BP for Zmot

Tf2 = ((L_E*s).*(L_e*(s.^n)))./((L_E*s)+(L_e*(s.^n))); %parallel combination of lossy and non-lossy inductors

Model = abs(Tf0+Tf1+Tf2);

figure(4);
hold on;
plot(FreqValues,ImpedanceValues, color = 'r'); % Mock
xscale("log");
yscale("log");
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title("Figure 5. Emperical and Calculated Voice Coil Impedance vs Frequency")
grid on;
plot(FreqValues, Model, color = 'g');
legend("Empirical", 'Reconstruction from data');
hold off


%% Tweaking Our Model for Best Fit

% these values were obtained by observing and perturbing the values and
% continually tweaking until best fit was achieved.
L_e = 0.059;
L_E = 0.0021;

% recalculating our functions
Tf2 = ((L_E*s).*(L_e*(s.^n)))./((L_E*s)+(L_e*(s.^n)));
Model = abs(Tf0+Tf1+Tf2);

% re-plotting with fixed L_e
figure(5)
hold on
plot(FreqValues,ImpedanceValues, color = 'r');
plot(FreqValues, Model, color = 'g');
hold off
xscale('log')
yscale('log')
ylabel("Impedance Magnitude (Ohms)")
xlabel("Frequency (Hz)")
legend("Empirical", 'MATLAB model', 'Multi-sim model');
title("Figure 7. Emperical and Calculated Voice Coil Impedance with tweaked L_e vs Frequency")

%% Plots of Our Inductor Impedances

% Individual transfer functions of the lossless and lossy inductors.
Tf3 = L_E*s; 
Tf4 = L_e*(s.^n);

figure(6)
hold on
plot(FreqValues,abs(Tf3))  % plot of Loss-less inductor
plot(FreqValues, abs(Tf4)) % plot of the lossy inductor

% this is the parallel combination of the lossy and lossless inductors
Tf5 = Tf3.*Tf4./(Tf3+Tf4);
plot(FreqValues, abs(Tf5))
plot(FreqValues, (ImpedanceValues-R_E)) % plot of measured data
hold off
xscale('log')
yscale('log')
title("Figure 6. Inductor impedances and Measured Impedacne vs frequency")
legend('loss-less inductor', 'lossy inductor', 'parallel combination', 'measured')
xlabel("frequency [Hz]")
xlim([5*10^2 max(FreqValues)])
%% Calculation of 3 Part Model Circuit Parameters

% Some definitions to help us in the calculations
p0 = 1.18; % SI units
c = 345;   % SI units
a = 0.12;  % meters
S_D = pi*(a^2);

% Next is getting M_MS and C_MS as they are required to find Bl
C_AS = VAS/(p0*c^2);
M_AS = 1/(C_AS*ws^2); % use ws from above

% Now finding BL
Bl = sqrt(((R_E)/(Qes)) * S_D^2 * sqrt(M_AS/C_AS));

% calculate C_MS
C_MS = C_AS/(S_D^2);

% calculate R_MS
R_MS = (1/Qms)* S_D^2 * sqrt(M_AS/C_AS);

% calculate M_MD
M_MD = (M_AS - (16*p0)/(3*a*pi^2))*(S_D^2);

%% Table of Three Part Model Parameters
Parameter_Values = [S_D;R_E;(L_E*L_e)/(L_E+L_e);Bl;R_MS;C_MS;M_MD];
parameter_names = {'S_D';'R_E';'L_E||L_e';'Bl';'R_MS';'C_MS';'M_MD'};
Three_Part_Model_Parameters_Table = table(Parameter_Values, RowNames=parameter_names);
disp("-----------------------------")
disp("Three_Part_Model_Parameters_Table")
disp(Three_Part_Model_Parameters_Table)


%% Calculate box_alpha
% Qts*alpha = Qtc = 1/sqrt(2)
box_alpha = 1/(sqrt(2)*Qts);
VAB = VAS/box_alpha;
disp("-----------------------------")
disp("VAB = "+VAB+" m^2")
disp("-----------------------------")
disp("VAB = "+(VAB*35.3147)+" ft^2")

error("End of Script. No Multisim Data!");

%% SPL plots and Calcs
multiSim_data1 = readtable('pressure_no_vc_inductance.csv','VariableNamingRule','preserve');

ms_SPL1 = multiSim_data1(:,2);
ms_freq1 = multiSim_data1(:,1);

ms_SPL1 = table2array(ms_SPL1);
ms_freq1 = table2array(ms_freq1);

ms_SPL1 = 20*log10(ms_SPL1/0.00002);

multiSim_data2 = readtable('pressure_with_vc_inductors.csv','VariableNamingRule','preserve');

ms_SPL2 = multiSim_data2(:,2);
ms_freq2 = multiSim_data2(:,1);

ms_SPL2 = table2array(ms_SPL2);
ms_freq2 = table2array(ms_freq2);

ms_SPL2 = 20*log10(ms_SPL2/0.00002);

% save for later
ms_infinite_baffle_SPL = ms_SPL2;
ms_infinite_baffle_freqs = ms_freq2;

figure(10)
hold on
plt1 = plot(ms_freq1, ms_SPL1, color = 'b');
plt2 =plot(ms_freq2, ms_SPL2, color = 'r');
hold off
xscale('log')
yscale('log')
ylabel("SPL (dB)")
xlabel("Frequency (Hz)")
legend("SPL no VC inductance", "SPL with VC inductance")
title("Driver SPL response with and without voice coil inductance.")

datatip(plt1, 40.84, 76.8);
datatip(plt1, 1000, 79.9);

%expected midband SPL
midband_SPL = 20*log10(((p0/(2*pi))*((Bl*1)/(S_D*R_E*M_AS)))/0.00002)
%leach's potpourri
fc = ws*(1/(2*pi))/sqrt((1-(1/(2*Qts^2)))+sqrt((1-(1/(2*Qts^2))^2+1)))

%% pressure plots and Calcs
multiSim_data1 = readtable('pressure_no_vc_inductance.csv','VariableNamingRule','preserve');

ms_SPL1 = multiSim_data1(:,2);
ms_freq1 = multiSim_data1(:,1);

ms_SPL1 = table2array(ms_SPL1);
ms_freq1 = table2array(ms_freq1);

multiSim_data2 = readtable('pressure_with_vc_inductors.csv','VariableNamingRule','preserve');

ms_SPL2 = multiSim_data2(:,2);
ms_freq2 = multiSim_data2(:,1);

ms_SPL2 = table2array(ms_SPL2);
ms_freq2 = table2array(ms_freq2);

figure(11)
hold on
plot(ms_freq1, ms_SPL1, color = 'b');
plot(ms_freq2, ms_SPL2, color = 'r');
hold off
xscale('log')
yscale('log')
ylabel("Pressure (Pa)")
xlabel("Frequency (Hz)")
legend("Pressure no VC inductance", "Pressure with VC inductance")
title("On axis pressure response with and without voice coil inductance.")

%% Volume Velocity Plots and Calcs
multiSim_data = readtable('volume_velocity.csv','VariableNamingRule','preserve');

ms_volume_velocity = multiSim_data(:,2);
ms_freq = multiSim_data(:,1);

ms_volume_velocity = table2array(ms_volume_velocity);
ms_freq = table2array(ms_freq);

figure(12)
hold on
plt1 = plot(ms_freq, ms_volume_velocity, color = 'b');
hold off
xscale('log')
yscale('log')
ylabel("Volume Velocity (m^3/s)")
xlabel("Frequency (Hz)")
title("Volume Velocity response of driver.")
datatip(plt1, 51.0897, 0.003);
fl = datatip(plt1, 29.1929, 0.0021);
fu = datatip(plt1, 87.9923, 0.0021);

bandwidth = fu.X-fl.X;

%% Displacement Plots and Calcs
multiSim_data = readtable('driver_displacement.csv','VariableNamingRule','preserve');

ms_displacement = multiSim_data(:,2);
ms_freq = multiSim_data(:,1);

ms_displacement = table2array(ms_displacement);
ms_freq = table2array(ms_freq);

figure(13)
hold on
plt1 = plot(ms_freq, ms_displacement, color = 'b');
hold off
xscale('log')
yscale('log')
ylabel("Driver Displacement (m)")
xlabel("Frequency (Hz)")
title("Driver Displacement Response")
datatip(plt1, 10, 2.3846e-4);
datatip(plt1, 60.9147, 1.6695e-4);

box_alpha = 2.00351;
Qtc = 1/sqrt(2);
wc = sqrt(1+box_alpha)*ws;

%leach's potpourri
fc_box = wc*(1/(2*pi))*sqrt((1-(1/(2*Qtc^2)))+sqrt((1-(1/(2*Qtc^2)))^2+1))

xd = (VAS/(p0*c^2*S_D^2*R_E*ws*Qes))^0.5
%% Box SPL plots
% alpha used for all following plots. alpha = 2.00351

% get with inductor
multiSim_data = readtable('kyles csvs/new_box_pressure_with_vc_inductor.csv','VariableNamingRule','preserve');
ms_boxPressure = multiSim_data(:,2);
ms_freq = multiSim_data(:,1);
ms_boxPressure1 = table2array(ms_boxPressure);
ms_freq1 = table2array(ms_freq);

% get without inductor
multiSim_data = readtable('kyles csvs/new_box_pressure_NO_vc_inductor.csv','VariableNamingRule','preserve');
ms_boxPressure = multiSim_data(:,2);
ms_freq = multiSim_data(:,1);
ms_boxPressure2 = table2array(ms_boxPressure);
ms_freq2 = table2array(ms_freq);

% calculate SPL
ms_boxSPL1 = 20*log10(ms_boxPressure1/(0.00002));
ms_boxSPL2 = 20*log10(ms_boxPressure2/(0.00002));

% save for later
ms_box_SPL = ms_boxSPL1;
ms_box_freqs = ms_freq1;

figure(14)
hold on
plt1 = plot(ms_freq1, ms_boxSPL1, color = 'b');
plt2 = plot(ms_freq2, ms_boxSPL2, color = 'r');
hold off
xscale('log')
yscale('log')
ylabel("SPL(dB)")
legend('with inductor', 'without inductor')
xlabel("Frequency (Hz)")
title("Box SPL vs Frequency")

% data tips of mid-band SPL without inductor
box_midband_SPL_datatip = datatip(plt2, 11930.7, 79.8421);
box_midband_SPL = box_midband_SPL_datatip.Y;
% this should be the same as the mid-band SPL from before
box_midband_SPL__percent_error = (abs(box_midband_SPL-midband_SPL)/midband_SPL)*100;

% get the -3 db frequencies and fundamental resonance frequency
datatip(plt1, 87.0964, 77.0);
datatip(plt2, 87.0964, 77.0);
% fundamental resonance frequency calcs
Cab = 0.13521*10^-6;
Mab = 3.1882;
expected_resonance = 1/(2*pi*sqrt(Cab*2*Mab));  % 2 Mab because of front and back
[ms_resonacne_magnitude, f_resonance_index] = max(ms_boxSPL1);
ms_resonance = ms_freq1(f_resonance_index);
resonance_percent_error = (abs(expected_resonance-ms_resonance)/expected_resonance)*100;
resonance_inductor_datatip = datatip(plt1, ms_resonance, ms_resonacne_magnitude);
resonance_no_inductor_datatip = datatip(plt2, ms_resonance, ms_resonacne_magnitude);


%% Box SPL of different boxes

figure(15)
hold on
plt1 = plot(ms_freq1, ms_boxSPL1, color = 'b');
plt2 = plot(ms_freq2, ms_boxSPL2, color = 'r');

% larger box
multiSim_data = readtable('kyles csvs/new_box_pressure_4_times_larger.csv','VariableNamingRule','preserve');
ms_boxPressure = multiSim_data(:,2);
ms_freq = multiSim_data(:,1);
ms_boxPressure1 = table2array(ms_boxPressure);
ms_freq1 = table2array(ms_freq);

% smaller box
multiSim_data = readtable('kyles csvs/new_box_pressure_4_times_smaller.csv','VariableNamingRule','preserve');
ms_boxPressure = multiSim_data(:,2);
ms_freq = multiSim_data(:,1);
ms_boxPressure2 = table2array(ms_boxPressure);
ms_freq2 = table2array(ms_freq);

% calculate SPL
ms_boxLargerSPL1 = 20*log10(ms_boxPressure1/(0.00002));
ms_boxSmallerSPL2 = 20*log10(ms_boxPressure2/(0.00002));


plt3 = plot(ms_freq1, ms_boxLargerSPL1, color = 'g');
plt4 = plot(ms_freq2, ms_boxSmallerSPL2, color = 'magenta');
hold off
xscale('log')
yscale('log')
ylabel("SPL(dB)")
legend('with inductor', 'without inductor', 'larger', 'smaller')
xlabel("Frequency (Hz)")
title("4 times larger and smaller box vs Frequency")

% labeling of significant values
datatip(plt2, 7025.33, 79.8421);
datatip(plt1, 87.0964, 77.0);
datatip(plt2, 87.0964, 77.0);
minus_3_db_4_times_larger = datatip(plt3, 112.0, 77.0);
minus_3_db_4_times_smaller = datatip(plt4, 112.0, 77.0);

%% Box Volume Velocity Plots and Calcs
figure(16)

% volume velocity
multiSim_data = readtable('kyles csvs/new_box_volume_velocity.csv','VariableNamingRule','preserve');
ms_velocity = multiSim_data(:,2);
ms_freq = multiSim_data(:,1);
ms_velocity = table2array(ms_velocity);
ms_freq1 = table2array(ms_freq);

plt = plot(ms_freq1, ms_velocity, color = 'r');
hold off
xscale('log')
yscale('log')
ylabel("Volume Velocity (m^3/s")
xlabel("Frequency (Hz)")
title("Volume velocity of dirver and box vs frequency")

% get fundamental resonance frequency
[max_velocity, index] = max(ms_velocity);
freq_max_velocity = ms_freq2(index);
% resonance
datatip(plt, freq_max_velocity, max_velocity);
% -3 db datatips
datatip(plt, 31.381, 0.000689317);
datatip(plt, 232.631, 0.000684475);



%% Box Displacement Plots and Calcs
figure(17)

% displacement
multiSim_data = readtable('kyles csvs/new_box_driver_displacement.csv','VariableNamingRule','preserve');
ms_displacement = multiSim_data(:,2);
ms_freq = multiSim_data(:,1);
ms_displacement = table2array(ms_displacement);
ms_freq2 = table2array(ms_freq);

plt = plot(ms_freq2, ms_displacement, color = 'g');
hold off
xscale('log')
yscale('log')
ylabel("driver displacement (m)")
xlabel("Frequency (Hz)")
title("Driver displacement vs frequency")

% get fundamental resonance frequency
[max_displacement, index] = max(ms_displacement);
freq_max_displacement = ms_freq2(index);
% resonance
datatip(plt, freq_max_displacement, max_displacement);
% minus 3 db = 1/2 of resonance
datatip(plt, 113.066, 3.98806e-05);

%% both infinite baffle and box SPL 
figure(18)

hold on
plt1 = plot(ms_infinite_baffle_freqs, ms_infinite_baffle_SPL);
plt2 = plot(ms_box_freqs, ms_box_SPL);
hold off
xscale('log')
yscale('log')
title("Infinite Baffle and Closed Box SPL vs Frequency")
legend('infinite baffle', 'closed box')
xlabel('Frequency (Hz)')
ylabel('SPL (dB)')
% datatips for -3 dB frequencies
datatip(plt1, 40.84, 76.8);
datatip(plt2, 87.0964, 77.0);



figure(19)
hold on
plt1 = plot(ms_infinite_baffle_freqs, ms_infinite_baffle_SPL);
plt2 = plot(ms_box_freqs, ms_box_SPL);
hold off
xscale('log')
yscale('log')
title("Infinite Baffle and Closed Box SPL Lower Cutoff Regions vs Frequency")
legend('infinite baffle', 'closed box')
xlabel('Frequency (Hz)')
ylabel('SPL (dB)')
xlim([35, 500])
ylim([75, 82])
% datatips for -3 dB frequencies
datatip(plt1, 40.84, 76.8);
datatip(plt2, 87.0964, 77.0);


%% Generic Csv plotting block (for reuse only)
% 
% multiSim_data = readtable('kyles csvs/box_driver_displacement.csv','VariableNamingRule','preserve');
% 
% ms_<varname> = multiSim_data(:,2);
% ms_freq = multiSim_data(:,1);
% 
% ms_<varname> = table2array(ms_<varname>);
% ms_freq = table2array(ms_freq);
% 
% figure(<#>)
% hold on
% plt1 = plot(ms_freq, ms_<varname>, color = 'b');
% hold off
% xscale('log')
% yscale('log')
% ylabel("<label>")
% xlabel("Frequency (Hz)")
% title("<title>")