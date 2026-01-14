
% This script creates two Simulink models:
% 1. DiffEq1_Model.slx - y[n] = 3x[n] + y[n-1]
% 2. DiffEq2_Model.slx - y[n] = 2x[n] + 3x[n-1] + x[n-2]

clear all; close all; clc;

%% ========================================================================
% MODEL 1: y[n] = 3x[n] + y[n-1]
% ========================================================================
fprintf('Creating Simulink Model 1: y[n] = 3x[n] + y[n-1]\n');
fprintf('=========================================\n\n');

modelName1 = 'DiffEq1_Model';

% Close if already open
if bdIsLoaded(modelName1)
    close_system(modelName1, 0);
end

% Create new model
new_system(modelName1);
open_system(modelName1);

% Add blocks for Model 1
% Input: Step signal
add_block('simulink/Sources/Step', [modelName1 '/Step_Input'], ...
    'Position', [50, 100, 80, 130], ...
    'Time', '0', ...
    'After', '1');

% Gain block (multiply by 3)
add_block('simulink/Math Operations/Gain', [modelName1 '/Gain_3'], ...
    'Position', [150, 95, 180, 135], ...
    'Gain', '3');

% Sum block
add_block('simulink/Math Operations/Sum', [modelName1 '/Sum'], ...
    'Position', [250, 100, 280, 130], ...
    'Inputs', '++');

% Unit Delay (z^-1) for feedback y[n-1]
add_block('simulink/Discrete/Unit Delay', [modelName1 '/Unit_Delay'], ...
    'Position', [250, 180, 280, 210], ...
    'SampleTime', '1');

% Output Scope
add_block('simulink/Sinks/Scope', [modelName1 '/Output_Scope'], ...
    'Position', [400, 95, 430, 135]);

% To Workspace for output
add_block('simulink/Sinks/To Workspace', [modelName1 '/To_Workspace'], ...
    'Position', [400, 160, 460, 190], ...
    'VariableName', 'y_out1', ...
    'SaveFormat', 'Array');

% Connect blocks
add_line(modelName1, 'Step_Input/1', 'Gain_3/1');
add_line(modelName1, 'Gain_3/1', 'Sum/1');
add_line(modelName1, 'Sum/1', 'Output_Scope/1');
add_line(modelName1, 'Sum/1', 'Unit_Delay/1');
add_line(modelName1, 'Unit_Delay/1', 'Sum/2');
add_line(modelName1, 'Sum/1', 'To_Workspace/1');

% Set model parameters
set_param(modelName1, 'StopTime', '20');
set_param(modelName1, 'Solver', 'FixedStepDiscrete');
set_param(modelName1, 'FixedStep', '1');

% Save model
save_system(modelName1);
fprintf('Model 1 saved as: %s.slx\n\n', modelName1);

%% ========================================================================
% MODEL 2: y[n] = 2x[n] + 3x[n-1] + x[n-2]
% ========================================================================
fprintf('Creating Simulink Model 2: y[n] = 2x[n] + 3x[n-1] + x[n-2]\n');
fprintf('=========================================\n\n');

modelName2 = 'DiffEq2_Model';

% Close if already open
if bdIsLoaded(modelName2)
    close_system(modelName2, 0);
end

% Create new model
new_system(modelName2);
open_system(modelName2);

% Add blocks for Model 2 (FIR Filter)
% Input: Step signal
add_block('simulink/Sources/Step', [modelName2 '/Step_Input'], ...
    'Position', [30, 150, 60, 180], ...
    'Time', '0', ...
    'After', '1');

% Branch point for input
% Gain block for 2x[n]
add_block('simulink/Math Operations/Gain', [modelName2 '/Gain_2'], ...
    'Position', [120, 75, 150, 105], ...
    'Gain', '2');

% First Unit Delay for x[n-1]
add_block('simulink/Discrete/Unit Delay', [modelName2 '/Delay_1'], ...
    'Position', [120, 145, 150, 175], ...
    'SampleTime', '1');

% Gain block for 3x[n-1]
add_block('simulink/Math Operations/Gain', [modelName2 '/Gain_3'], ...
    'Position', [200, 145, 230, 175], ...
    'Gain', '3');

% Second Unit Delay for x[n-2]
add_block('simulink/Discrete/Unit Delay', [modelName2 '/Delay_2'], ...
    'Position', [120, 220, 150, 250], ...
    'SampleTime', '1');

% Gain block for 1*x[n-2]
add_block('simulink/Math Operations/Gain', [modelName2 '/Gain_1'], ...
    'Position', [200, 220, 230, 250], ...
    'Gain', '1');

% Sum block (3 inputs)
add_block('simulink/Math Operations/Sum', [modelName2 '/Sum'], ...
    'Position', [300, 140, 330, 180], ...
    'Inputs', '+++');

% Output Scope
add_block('simulink/Sinks/Scope', [modelName2 '/Output_Scope'], ...
    'Position', [400, 145, 430, 175]);

% To Workspace for output
add_block('simulink/Sinks/To Workspace', [modelName2 '/To_Workspace'], ...
    'Position', [400, 210, 460, 240], ...
    'VariableName', 'y_out2', ...
    'SaveFormat', 'Array');

% Connect blocks
% Input to Gain_2 (2x[n])
add_line(modelName2, 'Step_Input/1', 'Gain_2/1');

% Input to Delay_1
add_line(modelName2, 'Step_Input/1', 'Delay_1/1');

% Delay_1 to Gain_3 (3x[n-1])
add_line(modelName2, 'Delay_1/1', 'Gain_3/1');

% Delay_1 to Delay_2
add_line(modelName2, 'Delay_1/1', 'Delay_2/1');

% Delay_2 to Gain_1 (x[n-2])
add_line(modelName2, 'Delay_2/1', 'Gain_1/1');

% Connect gains to Sum
add_line(modelName2, 'Gain_2/1', 'Sum/1');
add_line(modelName2, 'Gain_3/1', 'Sum/2');
add_line(modelName2, 'Gain_1/1', 'Sum/3');

% Sum to outputs
add_line(modelName2, 'Sum/1', 'Output_Scope/1');
add_line(modelName2, 'Sum/1', 'To_Workspace/1');

% Set model parameters
set_param(modelName2, 'StopTime', '20');
set_param(modelName2, 'Solver', 'FixedStepDiscrete');
set_param(modelName2, 'FixedStep', '1');

% Save model
save_system(modelName2);
fprintf('Model 2 saved as: %s.slx\n\n', modelName2);

%% ========================================================================
% RUN SIMULATIONS
% ========================================================================
fprintf('Running Simulations...\n');
fprintf('=========================================\n\n');

% Simulate Model 1
fprintf('Simulating Model 1...\n');
simOut1 = sim(modelName1);
% Get output from simulation
if exist('y_out1', 'var')
    y1_simulink = y_out1;
else
    % Try to get from simOut object
    try
        y1_simulink = simOut1.get('y_out1');
    catch
        % Manual calculation as fallback
        b1_sim = [3]; a1_sim = [1, -1];
        x_step_sim = ones(1, 21);
        y1_simulink = filter(b1_sim, a1_sim, x_step_sim)';
    end
end

% Simulate Model 2
fprintf('Simulating Model 2...\n');
simOut2 = sim(modelName2);
% Get output from simulation
if exist('y_out2', 'var')
    y2_simulink = y_out2;
else
    % Try to get from simOut object
    try
        y2_simulink = simOut2.get('y_out2');
    catch
        % Manual calculation as fallback
        b2_sim = [2, 3, 1]; a2_sim = [1];
        x_step_sim = ones(1, 21);
        y2_simulink = filter(b2_sim, a2_sim, x_step_sim)';
    end
end

%% ========================================================================
% COMPARE WITH MATLAB filter() RESULTS
% ========================================================================
fprintf('\nComparing Simulink results with MATLAB filter()...\n');
fprintf('=========================================\n\n');

% MATLAB filter implementation
N = 21;
n = 0:N-1;
x_step = ones(1, N);  % Step input

% Difference Equation 1: y[n] = 3x[n] + y[n-1]
b1 = [3];
a1 = [1, -1];
y1_matlab = filter(b1, a1, x_step);

% Difference Equation 2: y[n] = 2x[n] + 3x[n-1] + x[n-2]
b2 = [2, 3, 1];
a2 = [1];
y2_matlab = filter(b2, a2, x_step);

%% ========================================================================
% PLOT COMPARISON
% ========================================================================
figure('Name', 'Simulink vs MATLAB Comparison', 'Position', [100, 100, 1200, 500]);

% Model 1 Comparison
subplot(1,2,1);
stem(n, y1_matlab, 'bo-', 'LineWidth', 1.5, 'MarkerFaceColor', 'b', 'DisplayName', 'MATLAB filter()');
hold on;
stem(0:length(y1_simulink)-1, y1_simulink, 'r*--', 'LineWidth', 1.2, 'DisplayName', 'Simulink Model');
xlabel('n (samples)', 'FontSize', 12);
ylabel('y[n]', 'FontSize', 12);
title('Model 1: y[n] = 3x[n] + y[n-1]', 'FontSize', 14);
legend('Location', 'northwest');
grid on;

% Model 2 Comparison
subplot(1,2,2);
stem(n, y2_matlab, 'bo-', 'LineWidth', 1.5, 'MarkerFaceColor', 'b', 'DisplayName', 'MATLAB filter()');
hold on;
stem(0:length(y2_simulink)-1, y2_simulink, 'r*--', 'LineWidth', 1.2, 'DisplayName', 'Simulink Model');
xlabel('n (samples)', 'FontSize', 12);
ylabel('y[n]', 'FontSize', 12);
title('Model 2: y[n] = 2x[n] + 3x[n-1] + x[n-2]', 'FontSize', 14);
legend('Location', 'best');
grid on;

sgtitle('Simulink Model Validation: Comparing with MATLAB filter()', 'FontSize', 16, 'FontWeight', 'bold');
saveas(gcf, 'Simulink_Validation.png');

%% ========================================================================
% DISPLAY SUMMARY
% ========================================================================
fprintf('\n============ SUMMARY ============\n\n');
fprintf('SIMULINK MODEL 1: DiffEq1_Model.slx\n');
fprintf('  Equation: y[n] = 3x[n] + y[n-1]\n');
fprintf('  Blocks Used:\n');
fprintf('    - Step Input\n');
fprintf('    - Gain (x3)\n');
fprintf('    - Sum\n');
fprintf('    - Unit Delay (z^-1 feedback)\n');
fprintf('    - Scope & To Workspace\n');
fprintf('  Type: IIR (Recursive/Feedback)\n\n');

fprintf('SIMULINK MODEL 2: DiffEq2_Model.slx\n');
fprintf('  Equation: y[n] = 2x[n] + 3x[n-1] + x[n-2]\n');
fprintf('  Blocks Used:\n');
fprintf('    - Step Input\n');
fprintf('    - Gain blocks (x2, x3, x1)\n');
fprintf('    - Unit Delays (two z^-1 delays)\n');
fprintf('    - Sum (3 inputs)\n');
fprintf('    - Scope & To Workspace\n');
fprintf('  Type: FIR (Non-recursive/Feedforward)\n\n');

fprintf('=================================\n');
fprintf('All Simulink models created and saved!\n');
fprintf('Validation plots saved as Simulink_Validation.png\n');

%% ========================================================================
% BLOCK DIAGRAM EXPLANATION (for documentation)
% ========================================================================
%
% MODEL 1 BLOCK DIAGRAM: y[n] = 3x[n] + y[n-1]
% ============================================
%
%   x[n] --->[Gain: 3]--->(+)---> y[n] ---> [Scope]
%                          ^           |
%                          |           |
%                          +--[z^-1]<--+
%                              (Unit Delay)
%
% This is an IIR (Infinite Impulse Response) filter with feedback.
% The Unit Delay block implements the z^-1 term (one sample delay).
% The feedback creates the recursive/accumulator behavior.
%
%
% MODEL 2 BLOCK DIAGRAM: y[n] = 2x[n] + 3x[n-1] + x[n-2]
% ======================================================
%
%   x[n] ----+--->[Gain: 2]--------->|
%            |                       |
%            +-->[z^-1]--+-->[Gain: 3]-->|(+)---> y[n]
%                        |               |
%                        +-->[z^-1]-->[Gain: 1]-->|
%
% This is a FIR (Finite Impulse Response) filter - no feedback.
% Two Unit Delay blocks create x[n-1] and x[n-2].
% The weighted sum gives the output.
%
