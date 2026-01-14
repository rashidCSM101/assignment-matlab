%% ========================================================================
% PROBLEM 4: HYBRID DER SYSTEM - SIMULINK MODEL
% Creates comprehensive Simulink model with:
% - Solar PV array with MPPT
% - Wind turbine with power curve
% - Battery energy storage with SOC management
% - Diesel generator backup
% - Energy management controller
% - Load demand profile
% ========================================================================

clear all; close all; clc;

fprintf('====================================================================\n');
fprintf('   CREATING HYBRID DER SIMULINK MODEL\n');
fprintf('====================================================================\n\n');

% Model name
modelName = 'Problem4_Hybrid_DER_System';

% Close if already open
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end

% Create new model
new_system(modelName);
open_system(modelName);

fprintf('Creating Simulink blocks for Hybrid DER System...\n\n');

%% ========================================================================
% SOLAR PV SUBSYSTEM
% ========================================================================
fprintf('1. Adding Solar PV Array subsystem...\n');

% Solar PV block (using Signal Builder for irradiance input)
add_block('simulink/Sources/Signal Builder', [modelName '/Solar_Irradiance'], ...
    'Position', [50, 50, 150, 100]);

% Solar PV calculation block (Gain for power calculation)
add_block('simulink/Math Operations/Gain', [modelName '/PV_Power_Calc'], ...
    'Position', [200, 60, 250, 90], ...
    'Gain', '0.15');  % 15% efficiency * 833 m² = 125 kW max

% MPPT efficiency
add_block('simulink/Math Operations/Gain', [modelName '/MPPT_Efficiency'], ...
    'Position', [300, 60, 350, 90], ...
    'Gain', '0.95');  % 95% MPPT efficiency

% Temperature correction
add_block('simulink/Math Operations/Product', [modelName '/Temp_Correction'], ...
    'Position', [400, 55, 430, 95]);

% Constant for temperature factor
add_block('simulink/Sources/Constant', [modelName '/Temp_Factor'], ...
    'Position', [350, 120, 380, 140], ...
    'Value', '0.98');  % 98% at average temperature

%% ========================================================================
% WIND TURBINE SUBSYSTEM
% ========================================================================
fprintf('2. Adding Wind Turbine subsystem...\n');

% Wind speed input
add_block('simulink/Sources/Signal Builder', [modelName '/Wind_Speed'], ...
    'Position', [50, 200, 150, 250]);

% Wind power curve (using Lookup Table)
add_block('simulink/Lookup Tables/1-D Lookup Table', [modelName '/Wind_Power_Curve'], ...
    'Position', [200, 205, 280, 245], ...
    'BreakpointsForDimension1', '[0 3 6 9 12 15 25]', ...
    'Table', '[0 0 5 15 30 30 0]');  % Power curve for 30 kW total

% Altitude correction factor
add_block('simulink/Math Operations/Gain', [modelName '/Altitude_Correction'], ...
    'Position', [320, 210, 370, 240], ...
    'Gain', '0.743');  % Air density ratio at 2500m

%% ========================================================================
% BATTERY ENERGY STORAGE SYSTEM
% ========================================================================
fprintf('3. Adding Battery Storage subsystem...\n');

% Battery SOC integrator
add_block('simulink/Continuous/Integrator', [modelName '/Battery_SOC'], ...
    'Position', [550, 300, 580, 330], ...
    'InitialCondition', '0.5', ...  % Start at 50%
    'UpperSaturationLimit', '1.0', ...
    'LowerSaturationLimit', '0.0');

% Battery capacity constant
add_block('simulink/Sources/Constant', [modelName '/Battery_Capacity'], ...
    'Position', [450, 340, 500, 360], ...
    'Value', '200');  % 200 kWh

% Battery power calculation
add_block('simulink/Math Operations/Gain', [modelName '/Battery_Power'], ...
    'Position', [480, 300, 530, 330], ...
    'Gain', '1/200');  % Normalize by capacity

% Round-trip efficiency
add_block('simulink/Math Operations/Gain', [modelName '/Battery_Efficiency'], ...
    'Position', [600, 300, 650, 330], ...
    'Gain', '0.9');  % 90% efficiency

%% ========================================================================
% DIESEL GENERATOR
% ========================================================================
fprintf('4. Adding Diesel Generator...\n');

% Diesel control logic (Switch based on battery SOC)
add_block('simulink/Signal Routing/Switch', [modelName '/Diesel_Control'], ...
    'Position', [700, 450, 730, 480], ...
    'Threshold', '0.2');  % Activate when SOC < 20%

% Diesel power output
add_block('simulink/Sources/Constant', [modelName '/Diesel_Power_Max'], ...
    'Position', [620, 440, 670, 460], ...
    'Value', '75');  % 75 kW output (75% of 100 kW capacity)

% Zero power when not running
add_block('simulink/Sources/Constant', [modelName '/Diesel_Off'], ...
    'Position', [620, 480, 670, 500], ...
    'Value', '0');

%% ========================================================================
% LOAD DEMAND
% ========================================================================
fprintf('5. Adding Load Demand profile...\n');

% Load demand input (time-varying)
add_block('simulink/Sources/Signal Builder', [modelName '/Load_Demand'], ...
    'Position', [50, 350, 150, 400]);

%% ========================================================================
% ENERGY MANAGEMENT CONTROLLER
% ========================================================================
fprintf('6. Adding Energy Management System...\n');

% Sum of renewable generation
add_block('simulink/Math Operations/Add', [modelName '/Total_Renewable'], ...
    'Position', [500, 150, 530, 180], ...
    'Inputs', '++');

% Net power (generation - load)
add_block('simulink/Math Operations/Add', [modelName '/Net_Power'], ...
    'Position', [650, 200, 680, 230], ...
    'Inputs', '+-');

% Power balance
add_block('simulink/Math Operations/Add', [modelName '/Total_Supply'], ...
    'Position', [800, 300, 830, 330], ...
    'Inputs', '+++');

%% ========================================================================
% MEASUREMENT AND DISPLAY
% ========================================================================
fprintf('7. Adding Measurement blocks...\n');

% Display blocks
add_block('simulink/Sinks/Display', [modelName '/PV_Output_Display'], ...
    'Position', [450, 25, 530, 55]);

add_block('simulink/Sinks/Display', [modelName '/Wind_Output_Display'], ...
    'Position', [450, 175, 530, 205]);

add_block('simulink/Sinks/Display', [modelName '/Battery_SOC_Display'], ...
    'Position', [700, 270, 780, 300]);

add_block('simulink/Sinks/Display', [modelName '/Diesel_Output_Display'], ...
    'Position', [800, 420, 880, 450]);

% Scopes for visualization
add_block('simulink/Sinks/Scope', [modelName '/Power_Generation_Scope'], ...
    'Position', [900, 150, 930, 180]);

add_block('simulink/Sinks/Scope', [modelName '/Battery_SOC_Scope'], ...
    'Position', [900, 300, 930, 330]);

add_block('simulink/Sinks/Scope', [modelName '/Power_Balance_Scope'], ...
    'Position', [900, 450, 930, 480]);

% To Workspace blocks for data logging
add_block('simulink/Sinks/To Workspace', [modelName '/PV_Power_Log'], ...
    'Position', [450, 90, 530, 110], ...
    'VariableName', 'PV_power');

add_block('simulink/Sinks/To Workspace', [modelName '/Wind_Power_Log'], ...
    'Position', [450, 235, 530, 255], ...
    'VariableName', 'wind_power');

add_block('simulink/Sinks/To Workspace', [modelName '/Battery_SOC_Log'], ...
    'Position', [700, 330, 780, 350], ...
    'VariableName', 'battery_SOC');

add_block('simulink/Sinks/To Workspace', [modelName '/Diesel_Power_Log'], ...
    'Position', [800, 480, 880, 500], ...
    'VariableName', 'diesel_power');

%% ========================================================================
% ANNOTATIONS AND LABELS
% ========================================================================
fprintf('8. Adding annotations...\n');

% Add text annotations
add_block('built-in/Note', [modelName '/Title_Note'], ...
    'Position', [300, 10, 600, 30], ...
    'Text', 'HYBRID DER SYSTEM - Kaghan Valley, Pakistan');

add_block('built-in/Note', [modelName '/Solar_Note'], ...
    'Position', [50, 110, 200, 130], ...
    'Text', 'Solar PV: 150 kW');

add_block('built-in/Note', [modelName '/Wind_Note'], ...
    'Position', [50, 260, 200, 280], ...
    'Text', 'Wind: 3x10 kW (30 kW)');

add_block('built-in/Note', [modelName '/Battery_Note'], ...
    'Position', [550, 360, 700, 380], ...
    'Text', 'Battery: 200 kWh Li-ion');

add_block('built-in/Note', [modelName '/Diesel_Note'], ...
    'Position', [620, 510, 770, 530], ...
    'Text', 'Diesel: 100 kW (Backup)');

%% ========================================================================
% CONNECT BLOCKS
% ========================================================================
fprintf('9. Connecting blocks...\n');

try
    % Solar PV connections
    add_line(modelName, 'Solar_Irradiance/1', 'PV_Power_Calc/1', 'autorouting', 'on');
    add_line(modelName, 'PV_Power_Calc/1', 'MPPT_Efficiency/1', 'autorouting', 'on');
    add_line(modelName, 'MPPT_Efficiency/1', 'Temp_Correction/1', 'autorouting', 'on');
    add_line(modelName, 'Temp_Factor/1', 'Temp_Correction/2', 'autorouting', 'on');
    add_line(modelName, 'Temp_Correction/1', 'Total_Renewable/1', 'autorouting', 'on');
    add_line(modelName, 'Temp_Correction/1', 'PV_Output_Display/1', 'autorouting', 'on');
    add_line(modelName, 'Temp_Correction/1', 'PV_Power_Log/1', 'autorouting', 'on');
    
    % Wind turbine connections
    add_line(modelName, 'Wind_Speed/1', 'Wind_Power_Curve/1', 'autorouting', 'on');
    add_line(modelName, 'Wind_Power_Curve/1', 'Altitude_Correction/1', 'autorouting', 'on');
    add_line(modelName, 'Altitude_Correction/1', 'Total_Renewable/2', 'autorouting', 'on');
    add_line(modelName, 'Altitude_Correction/1', 'Wind_Output_Display/1', 'autorouting', 'on');
    add_line(modelName, 'Altitude_Correction/1', 'Wind_Power_Log/1', 'autorouting', 'on');
    
    % Load demand connection
    add_line(modelName, 'Load_Demand/1', 'Net_Power/2', 'autorouting', 'on');
    
    % Renewable to net power
    add_line(modelName, 'Total_Renewable/1', 'Net_Power/1', 'autorouting', 'on');
    
    % Net power to battery
    add_line(modelName, 'Net_Power/1', 'Battery_Power/1', 'autorouting', 'on');
    add_line(modelName, 'Battery_Power/1', 'Battery_SOC/1', 'autorouting', 'on');
    add_line(modelName, 'Battery_SOC/1', 'Battery_Efficiency/1', 'autorouting', 'on');
    add_line(modelName, 'Battery_Efficiency/1', 'Battery_SOC_Display/1', 'autorouting', 'on');
    add_line(modelName, 'Battery_Efficiency/1', 'Battery_SOC_Log/1', 'autorouting', 'on');
    add_line(modelName, 'Battery_SOC/1', 'Battery_SOC_Scope/1', 'autorouting', 'on');
    
    % Diesel control
    add_line(modelName, 'Battery_SOC/1', 'Diesel_Control/2', 'autorouting', 'on');
    add_line(modelName, 'Diesel_Power_Max/1', 'Diesel_Control/1', 'autorouting', 'on');
    add_line(modelName, 'Diesel_Off/1', 'Diesel_Control/3', 'autorouting', 'on');
    add_line(modelName, 'Diesel_Control/1', 'Diesel_Output_Display/1', 'autorouting', 'on');
    add_line(modelName, 'Diesel_Control/1', 'Diesel_Power_Log/1', 'autorouting', 'on');
    
    % Total supply
    add_line(modelName, 'Total_Renewable/1', 'Total_Supply/1', 'autorouting', 'on');
    add_line(modelName, 'Battery_Efficiency/1', 'Total_Supply/2', 'autorouting', 'on');
    add_line(modelName, 'Diesel_Control/1', 'Total_Supply/3', 'autorouting', 'on');
    add_line(modelName, 'Total_Supply/1', 'Power_Balance_Scope/1', 'autorouting', 'on');
    
    % Renewable to scope
    add_line(modelName, 'Total_Renewable/1', 'Power_Generation_Scope/1', 'autorouting', 'on');
    
    fprintf('  All blocks connected successfully!\n');
catch ME
    fprintf('  Warning: Some automatic connections failed.\n');
    fprintf('  Error: %s\n', ME.message);
    fprintf('  Manual connection in Simulink GUI may be required.\n');
end

%% ========================================================================
% CONFIGURE SIMULATION PARAMETERS
% ========================================================================
fprintf('\n10. Configuring simulation parameters...\n');

% Set solver
set_param(modelName, 'Solver', 'ode45');
set_param(modelName, 'StopTime', '24');  % 24 hours simulation
set_param(modelName, 'FixedStep', 'auto');
set_param(modelName, 'MaxStep', '0.1');  % 0.1 hour = 6 minutes

% Save model
save_system(modelName);

fprintf('\n====================================================================\n');
fprintf('   SIMULINK MODEL CREATED SUCCESSFULLY\n');
fprintf('====================================================================\n\n');

fprintf('Model File: %s.slx\n', modelName);
fprintf('Simulation Time: 24 hours (one day)\n');
fprintf('Solver: ode45 (Dormand-Prince)\n');
fprintf('Max Time Step: 0.1 hour (6 minutes)\n\n');

fprintf('COMPONENTS:\n');
fprintf('  - Solar PV Array (150 kW with MPPT)\n');
fprintf('  - Wind Turbines (30 kW with power curve)\n');
fprintf('  - Battery Storage (200 kWh with SOC tracking)\n');
fprintf('  - Diesel Generator (100 kW backup)\n');
fprintf('  - Energy Management Controller\n');
fprintf('  - Data Logging to MATLAB workspace\n\n');

fprintf('NEXT STEPS:\n');
fprintf('1. Open model: open_system(''%s'')\n', modelName);
fprintf('2. Configure Signal Builder blocks with actual data\n');
fprintf('3. Run simulation: sim(''%s'')\n', modelName);
fprintf('4. Take screenshot for report\n');
fprintf('5. Export to PNG: print -dpng -s Problem4_Simulink_Diagram.png\n\n');

% Display model
fprintf('Opening Simulink model in editor...\n');
open_system(modelName);
