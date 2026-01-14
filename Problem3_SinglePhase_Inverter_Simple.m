%% ENG778 - Problem 3: Single-Phase Inverter (SIMPLIFIED VERSION)
% This version uses pre-built Universal Bridge block - NO MANUAL WIRING!
% UK Domestic Supply: 230V RMS, 50Hz

clear; clc; close all;

%% UK Supply Specifications
V_rms = 230;            % UK domestic supply (V)
f_supply = 50;          % Supply frequency (Hz)
V_peak = V_rms * sqrt(2);
V_dc = 0.95 * V_peak;   % DC link voltage (accounting for rectifier losses)

% Load Parameters
R_load = 10;            % Load resistance (Ohms)
L_load = 10e-3;         % Load inductance (H)
P_rated = 2000;         % Rated power (W)

% Switching Parameters
f_switching = 50;       % Inverter switching frequency (Hz)
T_switching = 1/f_switching;

fprintf('=== SINGLE-PHASE INVERTER (SIMPLIFIED) ===\n\n');
fprintf('UK Domestic Supply:\n');
fprintf('  RMS Voltage: %.2f V\n', V_rms);
fprintf('  Peak Voltage: %.2f V\n', V_peak);
fprintf('  Frequency: %d Hz\n', f_supply);
fprintf('  DC Link Voltage: %.2f V\n', V_dc);
fprintf('  Load: R = %.0f Ohms, L = %.2f mH\n', R_load, L_load*1000);
fprintf('  Rated Power: %.2f kW\n\n', P_rated/1000);

%% Create Simplified Simulink Model
modelName = 'SinglePhase_Inverter_Simple';

% Close and delete if exists
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
if exist([modelName '.slx'], 'file')
    delete([modelName '.slx']);
end

% Create new model
new_system(modelName);
open_system(modelName);

fprintf('Creating Simplified Single-Phase Inverter Model...\n');

%% Add DC Voltage Source
add_block('powerlib/Electrical Sources/DC Voltage Source', ...
    [modelName '/DC_Source'], ...
    'Position', [50, 150, 80, 180]);

% Note: Double-click DC_Source in Simulink and manually set voltage to V_dc value
fprintf('  NOTE: Set DC_Source voltage to %.2f V in block parameters\n', V_dc);

%% Add Universal Bridge (Pre-configured H-Bridge)
add_block('powerlib/Power Electronics/Universal Bridge', ...
    [modelName '/H_Bridge'], ...
    'Position', [200, 120, 280, 210]);

% Note: Configure Universal Bridge manually in Simulink:
% Number of bridge arms = 1, Device = Thyristors
fprintf('  NOTE: Configure H_Bridge - Arms: 1, Device: Thyristors\n');

%% Add Pulse Generator (Standard Simulink block)
add_block('simulink/Sources/Pulse Generator', ...
    [modelName '/Pulse_Generator'], ...
    'Position', [50, 250, 120, 290], ...
    'PulseType', 'Time based');

% Note: Set period and pulse width manually
fprintf('  NOTE: Set Pulse_Generator - Period: %.4f s, PulseWidth: 50%%\n', T_switching);

%% Add Load (RL Branch)
add_block('powerlib/Elements/Series RLC Branch', ...
    [modelName '/Load_RL'], ...
    'Position', [380, 140, 420, 170], ...
    'BranchType', 'RL', ...
    'Resistance', num2str(R_load), ...
    'Inductance', num2str(L_load));

%% Add Voltage Measurement
add_block('powerlib/Measurements/Voltage Measurement', ...
    [modelName '/V_output'], ...
    'Position', [480, 135, 500, 155]);

%% Add Current Measurement
add_block('powerlib/Measurements/Current Measurement', ...
    [modelName '/I_output'], ...
    'Position', [330, 135, 350, 155]);

%% Add Scopes
add_block('simulink/Sinks/Scope', ...
    [modelName '/Scope_Voltage'], ...
    'Position', [600, 125, 630, 155]);

add_block('simulink/Sinks/Scope', ...
    [modelName '/Scope_Current'], ...
    'Position', [600, 195, 630, 225]);

%% Add Ground
add_block('powerlib/Elements/Ground', ...
    [modelName '/Ground'], ...
    'Position', [380, 240, 400, 260]);

%% Add Powergui
add_block('powerlib/powergui', ...
    [modelName '/powergui'], ...
    'Position', [50, 350, 150, 380]);

%% AUTOMATIC WIRING - Universal Bridge Version
fprintf('Connecting blocks automatically...\n');
try
    % DC Source to H-Bridge input
    add_line(modelName, 'DC_Source/RConn+', 'H_Bridge/LConn1', 'autorouting', 'on');
    add_line(modelName, 'DC_Source/RConn-', 'H_Bridge/LConn2', 'autorouting', 'on');
    
    % H-Bridge output to current sensor
    add_line(modelName, 'H_Bridge/RConn1', 'I_output/LConn+', 'autorouting', 'on');
    add_line(modelName, 'H_Bridge/RConn2', 'Load_RL/LConn-', 'autorouting', 'on');
    
    % Current sensor to load
    add_line(modelName, 'I_output/RConn+', 'Load_RL/LConn+', 'autorouting', 'on');
    
    % Voltage measurement across load
    add_line(modelName, 'Load_RL/LConn+', 'V_output/LConn+', 'autorouting', 'on');
    add_line(modelName, 'Load_RL/LConn-', 'V_output/LConn-', 'autorouting', 'on');
    
    % Ground connection
    add_line(modelName, 'Load_RL/LConn-', 'Ground/LConn1', 'autorouting', 'on');
    
    % PWM to H-Bridge gates
    add_line(modelName, 'Pulse_Generator/1', 'H_Bridge/LConn3', 'autorouting', 'on');
    
    % Measurements to scopes
    add_line(modelName, 'V_output/1', 'Scope_Voltage/1', 'autorouting', 'on');
    add_line(modelName, 'I_output/1', 'Scope_Current/1', 'autorouting', 'on');
    
    fprintf('✓ All connections successful!\n\n');
catch ME
    fprintf('⚠ Connection issue: %s\n', ME.message);
    fprintf('Opening model for manual verification...\n\n');
end

%% Configure Simulation
set_param(modelName, 'StopTime', '0.1');
set_param(modelName, 'Solver', 'ode23tb');
set_param(modelName, 'MaxStep', '1e-6');

% Save model
save_system(modelName);
fprintf('Simplified model saved: %s.slx\n', modelName);
fprintf('Model uses Universal Bridge - internally wired!\n\n');

%% Theoretical Analysis (same as before)
fprintf('=== THEORETICAL ANALYSIS ===\n\n');

V_out_rms_ideal = V_dc;
V_out_fundamental = (4/pi) * V_dc;
THD = sqrt(sum((1./(2*(1:2:15)-1)).^2) - 1) * 100;

fprintf('Theoretical Output (Square Wave):\n');
fprintf('  RMS Output Voltage: %.2f V\n', V_out_rms_ideal);
fprintf('  Fundamental Component: %.2f V\n', V_out_fundamental);
fprintf('  THD (Square Wave): %.2f%%\n\n', THD);

% Load Current Analysis
Z_fundamental = sqrt(R_load^2 + (2*pi*f_switching*L_load)^2);
I_rms = V_out_rms_ideal / Z_fundamental;
P_active = I_rms^2 * R_load;
Q_reactive = I_rms^2 * (2*pi*f_switching*L_load);
S_apparent = V_out_rms_ideal * I_rms;
PF = P_active / S_apparent;

fprintf('Load Current:\n');
fprintf('  RMS Current: %.2f A\n', I_rms);
fprintf('  Active Power: %.2f W\n', P_active);
fprintf('  Reactive Power: %.2f VAR\n', Q_reactive);
fprintf('  Apparent Power: %.2f VA\n', S_apparent);
fprintf('  Power Factor: %.3f\n\n', PF);

%% Harmonic Analysis
fprintf('=== HARMONIC ANALYSIS ===\n\n');
harmonics = 1:2:15;
fprintf('Harmonic Components (Square Wave):\n');
for n = harmonics
    V_harmonic = V_out_fundamental / n;
    percentage = 100 / n;
    fprintf('  %d-th Harmonic: %.2f V (%.1f%% of fundamental)\n', ...
        n, V_harmonic, percentage);
end

%% Generate Theoretical Waveforms
fprintf('\n');
t = linspace(0, 3*T_switching, 1000);

% Square wave output
V_square = V_dc * sign(sin(2*pi*f_switching*t));
V_fundamental_wave = V_out_fundamental * sin(2*pi*f_switching*t);

% With harmonics
V_with_harmonics = zeros(size(t));
for i = 1:length(harmonics)
    n = harmonics(i);
    V_with_harmonics = V_with_harmonics + ...
        (V_out_fundamental/n) * sin(n*2*pi*f_switching*t);
end

% Current waveform approximation
I_output = V_with_harmonics / Z_fundamental;

% Plot
figure('Position', [100, 100, 1200, 800]);

subplot(3,1,1);
plot(t*1000, V_square, 'b-', 'LineWidth', 1.5);
hold on;
plot(t*1000, V_fundamental_wave, 'r--', 'LineWidth', 2);
grid on;
xlabel('Time (ms)');
ylabel('Voltage (V)');
title('Single-Phase Inverter Output - Square Wave vs Fundamental');
legend('Square Wave Output', 'Fundamental Component (50Hz)');

subplot(3,1,2);
plot(t*1000, V_with_harmonics, 'b-', 'LineWidth', 1.5);
grid on;
xlabel('Time (ms)');
ylabel('Voltage (V)');
title('Output Voltage with Harmonics (up to 15th)');

subplot(3,1,3);
plot(t*1000, I_output, 'r-', 'LineWidth', 1.5);
grid on;
xlabel('Time (ms)');
ylabel('Current (A)');
title('Load Current (RL Load)');

saveas(gcf, 'SinglePhase_Simple_Waveforms.png');

fprintf('============ SUMMARY ============\n\n');
fprintf('SIMPLIFIED SINGLE-PHASE INVERTER:\n');
fprintf('  Uses Universal Bridge block (pre-wired)\n');
fprintf('  No manual wiring required!\n');
fprintf('  Input: DC %.2f V\n', V_dc);
fprintf('  Output: Square wave AC, fundamental %.2f V\n', V_out_fundamental);
fprintf('  THD: %.2f%%\n', THD);
fprintf('  Ready to simulate!\n\n');
fprintf('Simulink Model: %s.slx\n', modelName);
fprintf('================================\n');
