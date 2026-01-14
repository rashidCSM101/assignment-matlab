%% ENG778 - Problem 3: Three-Phase Inverter Design
% Student Name: [Your Name]
% Student ID: [Your ID]
% Date: January 2026
% Description: Three-phase SCR-based inverter for UK industrial supply (400V, 50Hz)

clear all; close all; clc;

%% ========================================================================
% UK THREE-PHASE INDUSTRIAL SUPPLY SPECIFICATIONS
% ========================================================================
fprintf('=== THREE-PHASE INVERTER DESIGN ===\n\n');

% UK Industrial Supply Parameters
V_line_line = 400;              % Line-to-line RMS voltage (V)
V_phase = V_line_line / sqrt(3); % Phase voltage (230.94V)
V_peak_phase = V_phase * sqrt(2); % Peak phase voltage (326.6V)
f_supply = 50;                  % Frequency (Hz)
omega = 2 * pi * f_supply;      % Angular frequency (rad/s)

% DC Link Voltage (from three-phase rectified AC)
V_dc = 1.35 * V_line_line;      % Approximate DC voltage (540V)

% Load Parameters (per phase)
R_load = 15;                    % Resistive load per phase (Ohms)
L_load = 15e-3;                 % Inductive load per phase (15 mH)
P_load_rated = 10000;           % Total rated power (10 kW)

% Inverter Parameters
f_switching = 50;               % Output frequency (Hz)
T_switching = 1/f_switching;    % Switching period (20 ms)

fprintf('UK Industrial Supply:\n');
fprintf('  Line-Line Voltage: %.2f V\n', V_line_line);
fprintf('  Phase Voltage: %.2f V\n', V_phase);
fprintf('  Peak Phase Voltage: %.2f V\n', V_peak_phase);
fprintf('  Frequency: %d Hz\n', f_supply);
fprintf('  DC Link Voltage: %.2f V\n', V_dc);
fprintf('  Load per Phase: R = %d Ohms, L = %.2f mH\n', R_load, L_load*1000);
fprintf('  Total Rated Power: %.2f kW\n\n', P_load_rated/1000);

%% ========================================================================
% CREATE SIMULINK MODEL: THREE-PHASE INVERTER
% ========================================================================
modelName = 'ThreePhase_Inverter_UK';

% Close if already open
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end

% Create new model
new_system(modelName);
open_system(modelName);

fprintf('Creating Three-Phase Inverter Model...\n');

%% Add DC Voltage Source
add_block('fl_lib/Electrical/Electrical Sources/DC Voltage Source', ...
    [modelName '/DC_Source'], ...
    'Position', [50, 200, 80, 230], ...
    'v0', num2str(V_dc));

%% Add Three-Phase SCR Bridge (6 SCRs)
% Phase A - Upper SCR (S1)
add_block('powerlib/Power Electronics/Thyristor', ...
    [modelName '/SCR_A_upper'], ...
    'Position', [200, 100, 230, 130], ...
    'Ron', '0.001', ...
    'Lon', '0', ...
    'Vf', '0.8');

% Phase A - Lower SCR (S4)
add_block('powerlib/Power Electronics/Thyristor', ...
    [modelName '/SCR_A_lower'], ...
    'Position', [200, 250, 230, 280], ...
    'Ron', '0.001', ...
    'Lon', '0', ...
    'Vf', '0.8');

% Phase B - Upper SCR (S3)
add_block('powerlib/Power Electronics/Thyristor', ...
    [modelName '/SCR_B_upper'], ...
    'Position', [280, 100, 310, 130], ...
    'Ron', '0.001', ...
    'Lon', '0', ...
    'Vf', '0.8');

% Phase B - Lower SCR (S6)
add_block('powerlib/Power Electronics/Thyristor', ...
    [modelName '/SCR_B_lower'], ...
    'Position', [280, 250, 310, 280], ...
    'Ron', '0.001', ...
    'Lon', '0', ...
    'Vf', '0.8');

% Phase C - Upper SCR (S5)
add_block('powerlib/Power Electronics/Thyristor', ...
    [modelName '/SCR_C_upper'], ...
    'Position', [360, 100, 390, 130], ...
    'Ron', '0.001', ...
    'Lon', '0', ...
    'Vf', '0.8');

% Phase C - Lower SCR (S2)
add_block('powerlib/Power Electronics/Thyristor', ...
    [modelName '/SCR_C_lower'], ...
    'Position', [360, 250, 390, 280], ...
    'Ron', '0.001', ...
    'Lon', '0', ...
    'Vf', '0.8');

%% Add Pulse Generators for Six-Step Commutation
% Pulse for Phase A upper (S1) - 0° to 180°
add_block('simulink/Sources/Pulse Generator', ...
    [modelName '/Pulse_A_upper'], ...
    'Position', [50, 350, 80, 380], ...
    'PulseType', 'Time based', ...
    'Period', num2str(T_switching), ...
    'PulseWidth', '50', ...
    'PhaseDelay', '0');

% Pulse for Phase A lower (S4) - 180° to 360°
add_block('simulink/Sources/Pulse Generator', ...
    [modelName '/Pulse_A_lower'], ...
    'Position', [50, 400, 80, 430], ...
    'PulseType', 'Time based', ...
    'Period', num2str(T_switching), ...
    'PulseWidth', '50', ...
    'PhaseDelay', num2str(T_switching/2));

% Pulse for Phase B upper (S3) - 120° to 300°
add_block('simulink/Sources/Pulse Generator', ...
    [modelName '/Pulse_B_upper'], ...
    'Position', [150, 350, 180, 380], ...
    'PulseType', 'Time based', ...
    'Period', num2str(T_switching), ...
    'PulseWidth', '50', ...
    'PhaseDelay', num2str(T_switching/3));

% Pulse for Phase B lower (S6) - 300° to 120°
add_block('simulink/Sources/Pulse Generator', ...
    [modelName '/Pulse_B_lower'], ...
    'Position', [150, 400, 180, 430], ...
    'PulseType', 'Time based', ...
    'Period', num2str(T_switching), ...
    'PulseWidth', '50', ...
    'PhaseDelay', num2str(T_switching*5/6));

% Pulse for Phase C upper (S5) - 240° to 60°
add_block('simulink/Sources/Pulse Generator', ...
    [modelName '/Pulse_C_upper'], ...
    'Position', [250, 350, 280, 380], ...
    'PulseType', 'Time based', ...
    'Period', num2str(T_switching), ...
    'PulseWidth', '50', ...
    'PhaseDelay', num2str(T_switching*2/3));

% Pulse for Phase C lower (S2) - 60° to 240°
add_block('simulink/Sources/Pulse Generator', ...
    [modelName '/Pulse_C_lower'], ...
    'Position', [250, 400, 280, 430], ...
    'PulseType', 'Time based', ...
    'Period', num2str(T_switching), ...
    'PulseWidth', '50', ...
    'PhaseDelay', num2str(T_switching/6));

%% Add Three-Phase R-L Loads
add_block('powerlib/Elements/Series RLC Branch', ...
    [modelName '/Load_Phase_A'], ...
    'Position', [500, 120, 530, 150], ...
    'BranchType', 'RL', ...
    'Resistance', num2str(R_load), ...
    'Inductance', num2str(L_load));

add_block('powerlib/Elements/Series RLC Branch', ...
    [modelName '/Load_Phase_B'], ...
    'Position', [500, 180, 530, 210], ...
    'BranchType', 'RL', ...
    'Resistance', num2str(R_load), ...
    'Inductance', num2str(L_load));

add_block('powerlib/Elements/Series RLC Branch', ...
    [modelName '/Load_Phase_C'], ...
    'Position', [500, 240, 530, 270], ...
    'BranchType', 'RL', ...
    'Resistance', num2str(R_load), ...
    'Inductance', num2str(L_load));

%% Add Voltage Measurements
add_block('powerlib/Measurements/Voltage Measurement', ...
    [modelName '/V_Phase_A'], ...
    'Position', [600, 115, 620, 135]);

add_block('powerlib/Measurements/Voltage Measurement', ...
    [modelName '/V_Phase_B'], ...
    'Position', [600, 175, 620, 195]);

add_block('powerlib/Measurements/Voltage Measurement', ...
    [modelName '/V_Phase_C'], ...
    'Position', [600, 235, 620, 255]);

%% Add Scopes
add_block('simulink/Sinks/Scope', ...
    [modelName '/Scope_3Phase_Voltages'], ...
    'Position', [700, 150, 730, 180]);

add_block('simulink/Sinks/Scope', ...
    [modelName '/Scope_Line_Voltages'], ...
    'Position', [700, 220, 730, 250]);

%% Add Ground
add_block('powerlib/Elements/Ground', ...
    [modelName '/Ground'], ...
    'Position', [450, 320, 470, 340]);

%% Add Powergui Block
add_block('powerlib/powergui', ...
    [modelName '/powergui'], ...
    'Position', [50, 500, 150, 530]);

%% Connect Blocks - AUTOMATIC WIRING
fprintf('Attempting automatic wiring for three-phase inverter...\n');
try
    % DC Source to upper SCRs (S1, S3, S5)
    add_line(modelName, 'DC_Source/RConn+', 'S1/LConn1', 'autorouting', 'on');
    add_line(modelName, 'DC_Source/RConn+', 'S3/LConn1', 'autorouting', 'on');
    add_line(modelName, 'DC_Source/RConn+', 'S5/LConn1', 'autorouting', 'on');
    add_line(modelName, 'DC_Source/RConn-', 'Ground/LConn1', 'autorouting', 'on');
    
    % Phase A connections (S1 upper, S4 lower)
    add_line(modelName, 'S1/RConn1', 'Load_Phase_A/LConn+', 'autorouting', 'on');
    add_line(modelName, 'Load_Phase_A/LConn-', 'S4/LConn1', 'autorouting', 'on');
    add_line(modelName, 'S4/RConn1', 'Ground/LConn1', 'autorouting', 'on');
    
    % Phase B connections (S3 upper, S6 lower)
    add_line(modelName, 'S3/RConn1', 'Load_Phase_B/LConn+', 'autorouting', 'on');
    add_line(modelName, 'Load_Phase_B/LConn-', 'S6/LConn1', 'autorouting', 'on');
    add_line(modelName, 'S6/RConn1', 'Ground/LConn1', 'autorouting', 'on');
    
    % Phase C connections (S5 upper, S2 lower)
    add_line(modelName, 'S5/RConn1', 'Load_Phase_C/LConn+', 'autorouting', 'on');
    add_line(modelName, 'Load_Phase_C/LConn-', 'S2/LConn1', 'autorouting', 'on');
    add_line(modelName, 'S2/RConn1', 'Ground/LConn1', 'autorouting', 'on');
    
    % Pulse generators to gates
    add_line(modelName, 'Pulse_S1/1', 'S1/LConn2', 'autorouting', 'on');
    add_line(modelName, 'Pulse_S2/1', 'S2/LConn2', 'autorouting', 'on');
    add_line(modelName, 'Pulse_S3/1', 'S3/LConn2', 'autorouting', 'on');
    add_line(modelName, 'Pulse_S4/1', 'S4/LConn2', 'autorouting', 'on');
    add_line(modelName, 'Pulse_S5/1', 'S5/LConn2', 'autorouting', 'on');
    add_line(modelName, 'Pulse_S6/1', 'S6/LConn2', 'autorouting', 'on');
    
    % Voltage measurements
    add_line(modelName, 'Load_Phase_A/LConn+', 'V_Phase_A/LConn+', 'autorouting', 'on');
    add_line(modelName, 'Load_Phase_A/LConn-', 'V_Phase_A/LConn-', 'autorouting', 'on');
    add_line(modelName, 'Load_Phase_B/LConn+', 'V_Phase_B/LConn+', 'autorouting', 'on');
    add_line(modelName, 'Load_Phase_B/LConn-', 'V_Phase_B/LConn-', 'autorouting', 'on');
    add_line(modelName, 'Load_Phase_C/LConn+', 'V_Phase_C/LConn+', 'autorouting', 'on');
    add_line(modelName, 'Load_Phase_C/LConn-', 'V_Phase_C/LConn-', 'autorouting', 'on');
    
    % Connect measurements to scopes
    add_line(modelName, 'V_Phase_A/1', 'Scope_3Phase_Voltages/1', 'autorouting', 'on');
    add_line(modelName, 'V_Phase_B/1', 'Scope_3Phase_Voltages/2', 'autorouting', 'on');
    add_line(modelName, 'V_Phase_C/1', 'Scope_3Phase_Voltages/3', 'autorouting', 'on');
    
    fprintf('✓ Automatic wiring successful!\n\n');
catch ME
    fprintf('⚠ Automatic wiring failed: %s\n', ME.message);
    fprintf('Manual wiring required in Simulink GUI.\n');
    fprintf('Please connect:\n');
    fprintf('  1. DC Source to three-phase SCR bridge\n');
    fprintf('  2. SCR bridge outputs to respective phase loads\n');
    fprintf('  3. Pulse generators to SCR gate terminals\n');
    fprintf('  4. Measurement blocks to Scopes\n');
    fprintf('  5. Ground connections (neutral/common point)\n\n');
end

%% Set Simulation Parameters
set_param(modelName, 'StopTime', '0.1');  % 100ms simulation
set_param(modelName, 'Solver', 'ode23tb');  % Stiff solver
set_param(modelName, 'MaxStep', '1e-6');

% Save model
save_system(modelName);
fprintf('Three-Phase Inverter model saved: %s.slx\n\n', modelName);

%% ========================================================================
% THEORETICAL ANALYSIS - THREE-PHASE INVERTER
% ========================================================================
fprintf('=== THEORETICAL ANALYSIS ===\n\n');

% Six-Step Inverter Output (per phase)
V_out_phase_fundamental = (2*sqrt(6)/pi) * (V_dc/2);  % Fundamental component
V_out_line_line = sqrt(3) * V_out_phase_fundamental;

fprintf('Theoretical Output (Six-Step Operation):\n');
fprintf('  Phase Voltage (fundamental): %.2f V\n', V_out_phase_fundamental);
fprintf('  Line-Line Voltage: %.2f V\n', V_out_line_line);

% THD for Six-Step Inverter
% Dominant harmonics: 5th, 7th, 11th, 13th
THD_six_step = sqrt((1/5)^2 + (1/7)^2 + (1/11)^2 + (1/13)^2) * 100;
fprintf('  THD (Six-Step): %.2f%%\n\n', THD_six_step);

% Output Current per Phase
Z_phase = sqrt(R_load^2 + (omega*L_load)^2);
I_phase_rms = V_out_phase_fundamental / Z_phase;

fprintf('Load Current (per phase):\n');
fprintf('  RMS Current: %.2f A\n', I_phase_rms);

% Power Calculations
P_phase = I_phase_rms^2 * R_load;
P_total = 3 * P_phase;
Q_phase = I_phase_rms^2 * omega * L_load;
Q_total = 3 * Q_phase;
S_total = sqrt(P_total^2 + Q_total^2);
PF = P_total / S_total;

fprintf('  Active Power (per phase): %.2f W\n', P_phase);
fprintf('  Total Active Power: %.2f kW\n', P_total/1000);
fprintf('  Total Reactive Power: %.2f kVAR\n', Q_total/1000);
fprintf('  Total Apparent Power: %.2f kVA\n', S_total/1000);
fprintf('  Power Factor: %.3f\n\n', PF);

%% ========================================================================
% HARMONIC ANALYSIS
% ========================================================================
fprintf('=== HARMONIC ANALYSIS ===\n\n');

% Six-step harmonics (exclude triplen harmonics: 3, 9, 15, ...)
harmonics = [1, 5, 7, 11, 13, 17, 19, 23, 25];
V_harmonics_phase = V_out_phase_fundamental ./ harmonics;

fprintf('Phase Voltage Harmonic Components (Six-Step):\n');
for i = 1:length(harmonics)
    fprintf('  %d-th Harmonic: %.2f V (%.1f%% of fundamental)\n', ...
        harmonics(i), V_harmonics_phase(i), (V_harmonics_phase(i)/V_harmonics_phase(1))*100);
end
fprintf('\n');

%% ========================================================================
% PLOT: THREE-PHASE WAVEFORMS
% ========================================================================
figure('Name', 'Three-Phase Inverter - Theoretical Waveforms', 'Position', [100, 100, 1400, 700]);

% Time vector
t = linspace(0, 3*T_switching, 1000);

% Three-phase voltages (120° phase shift)
V_A = V_out_phase_fundamental * sin(2*pi*f_switching*t);
V_B = V_out_phase_fundamental * sin(2*pi*f_switching*t - 2*pi/3);
V_C = V_out_phase_fundamental * sin(2*pi*f_switching*t + 2*pi/3);

% Line-to-line voltages
V_AB = sqrt(3) * V_out_phase_fundamental * sin(2*pi*f_switching*t + pi/6);
V_BC = sqrt(3) * V_out_phase_fundamental * sin(2*pi*f_switching*t + pi/6 - 2*pi/3);
V_CA = sqrt(3) * V_out_phase_fundamental * sin(2*pi*f_switching*t + pi/6 + 2*pi/3);

subplot(2,3,1);
plot(t*1000, V_A, 'r', 'LineWidth', 1.5); hold on;
plot(t*1000, V_B, 'g', 'LineWidth', 1.5);
plot(t*1000, V_C, 'b', 'LineWidth', 1.5);
xlabel('Time (ms)', 'FontSize', 11);
ylabel('Voltage (V)', 'FontSize', 11);
title('Three-Phase Voltages (Phase-Neutral)', 'FontSize', 12);
legend('Phase A', 'Phase B', 'Phase C', 'Location', 'best');
grid on;

subplot(2,3,2);
plot(t*1000, V_AB, 'r', 'LineWidth', 1.5); hold on;
plot(t*1000, V_BC, 'g', 'LineWidth', 1.5);
plot(t*1000, V_CA, 'b', 'LineWidth', 1.5);
xlabel('Time (ms)', 'FontSize', 11);
ylabel('Voltage (V)', 'FontSize', 11);
title('Line-to-Line Voltages', 'FontSize', 12);
legend('V_{AB}', 'V_{BC}', 'V_{CA}', 'Location', 'best');
grid on;

subplot(2,3,3);
stem(harmonics, V_harmonics_phase, 'filled', 'LineWidth', 1.5);
xlabel('Harmonic Order', 'FontSize', 11);
ylabel('Voltage Magnitude (V)', 'FontSize', 11);
title('Harmonic Spectrum (Phase Voltage)', 'FontSize', 12);
grid on;

subplot(2,3,4);
% Phasor diagram
angles = [0, -2*pi/3, 2*pi/3];
for i = 1:3
    quiver(0, 0, V_out_phase_fundamental*cos(angles(i)), ...
        V_out_phase_fundamental*sin(angles(i)), ...
        'LineWidth', 2, 'MaxHeadSize', 0.5);
    hold on;
end
axis equal;
grid on;
xlabel('Real', 'FontSize', 11);
ylabel('Imaginary', 'FontSize', 11);
title('Phasor Diagram (Balanced)', 'FontSize', 12);
legend('Phase A', 'Phase B', 'Phase C', 'Location', 'best');

subplot(2,3,5);
% Power flow
bar([P_total/1000, Q_total/1000, S_total/1000]);
set(gca, 'XTickLabel', {'Active (P)', 'Reactive (Q)', 'Apparent (S)'});
ylabel('Power (kW, kVAR, kVA)', 'FontSize', 11);
title('Power Distribution', 'FontSize', 12);
grid on;

subplot(2,3,6);
stem(harmonics, (V_harmonics_phase/V_harmonics_phase(1))*100, 'filled', 'LineWidth', 1.5, 'Color', 'r');
xlabel('Harmonic Order', 'FontSize', 11);
ylabel('Percentage of Fundamental (%)', 'FontSize', 11);
title('Harmonic Content (% of Fundamental)', 'FontSize', 12);
grid on;

sgtitle('Three-Phase Inverter: Theoretical Waveform Analysis', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, 'ThreePhase_Theoretical_Waveforms.png');

%% ========================================================================
% SUMMARY
% ========================================================================
fprintf('============ SUMMARY ============\n\n');
fprintf('THREE-PHASE INVERTER (UK Industrial 400V Supply):\n');
fprintf('  Input: DC %.2f V (from rectified 400V 3-phase AC)\n', V_dc);
fprintf('  Output: Phase voltage %.2f V, Line-line %.2f V\n', V_out_phase_fundamental, V_out_line_line);
fprintf('  Switching: Six-step commutation, %d Hz\n', f_switching);
fprintf('  THD: %.2f%% (improved over single-phase)\n', THD_six_step);
fprintf('  Total Power: %.2f kW\n', P_total/1000);
fprintf('  Power Factor: %.3f\n', PF);
fprintf('  Configuration: Six-pulse bridge (6 SCRs)\n\n');
fprintf('Simulink Model: %s.slx\n', modelName);
fprintf('================================\n');
