clear all; close all; clc;

%% ========================================================================
% EQUATION 1: dy/dt = t^2, y(0) = 1, t ∈ [0, 10]
% ========================================================================
fprintf('=== EQUATION 1: dy/dt = t^2 ===\n');

% Define the ODE function
ode1 = @(t, y) t^2;

% Initial condition and time span
y0_1 = 1;
tspan1 = [0 10];

% Solve using ode23
[t_ode23_1, y_ode23_1] = ode23(ode1, tspan1, y0_1);

% Solve using ode45
[t_ode45_1, y_ode45_1] = ode45(ode1, tspan1, y0_1);

% Analytical solution: y = t^3/3 + 1
t_analytical1 = linspace(0, 10, 100);
y_analytical1 = (t_analytical1.^3)/3 + 1;

% Plot Equation 1
figure('Name', 'Equation 1: dy/dt = t^2', 'Position', [100, 100, 900, 600]);

subplot(2,2,1);
plot(t_ode23_1, y_ode23_1, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
hold on;
plot(t_analytical1, y_analytical1, 'r--', 'LineWidth', 2);
xlabel('Time (t)', 'FontSize', 12);
ylabel('y(t)', 'FontSize', 12);
title('ODE23 Solver: dy/dt = t^2', 'FontSize', 14);
legend('ODE23 Solution', 'Analytical: y = t^3/3 + 1', 'Location', 'northwest');
grid on;
annotation('textbox', [0.15, 0.85, 0.2, 0.05], 'String', sprintf('Steps: %d', length(t_ode23_1)), 'FitBoxToText', 'on');

subplot(2,2,2);
plot(t_ode45_1, y_ode45_1, 'g-s', 'LineWidth', 1.5, 'MarkerSize', 4);
hold on;
plot(t_analytical1, y_analytical1, 'r--', 'LineWidth', 2);
xlabel('Time (t)', 'FontSize', 12);
ylabel('y(t)', 'FontSize', 12);
title('ODE45 Solver: dy/dt = t^2', 'FontSize', 14);
legend('ODE45 Solution', 'Analytical: y = t^3/3 + 1', 'Location', 'northwest');
grid on;
annotation('textbox', [0.58, 0.85, 0.2, 0.05], 'String', sprintf('Steps: %d', length(t_ode45_1)), 'FitBoxToText', 'on');

subplot(2,2,[3,4]);
plot(t_ode23_1, y_ode23_1, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
hold on;
plot(t_ode45_1, y_ode45_1, 'g-s', 'LineWidth', 1.5, 'MarkerSize', 4);
plot(t_analytical1, y_analytical1, 'r--', 'LineWidth', 2);
xlabel('Time (t)', 'FontSize', 12);
ylabel('y(t)', 'FontSize', 12);
title('Comparison: ODE23 vs ODE45 vs Analytical Solution', 'FontSize', 14);
legend('ODE23', 'ODE45', 'Analytical', 'Location', 'northwest');
grid on;

sgtitle('Equation 1: dy/dt = t^2, y(0) = 1', 'FontSize', 16, 'FontWeight', 'bold');
saveas(gcf, 'Equation1_Results.png');

fprintf('Equation 1 - ODE23 steps: %d, ODE45 steps: %d\n', length(t_ode23_1), length(t_ode45_1));

%% ========================================================================
% EQUATION 2: dy/dt = t^2/y, y(0) = 1, t ∈ [0, 5]
% ========================================================================
fprintf('\n=== EQUATION 2: dy/dt = t^2/y ===\n');

% Define the ODE function
ode2 = @(t, y) t^2 / y;

% Initial condition and time span
y0_2 = 1;
tspan2 = [0 5];

% Solve using ode23
[t_ode23_2, y_ode23_2] = ode23(ode2, tspan2, y0_2);

% Solve using ode45
[t_ode45_2, y_ode45_2] = ode45(ode2, tspan2, y0_2);

% Analytical solution: y*dy = t^2*dt => y^2/2 = t^3/3 + C
% With y(0) = 1: C = 1/2, so y = sqrt(2t^3/3 + 1)
t_analytical2 = linspace(0, 5, 100);
y_analytical2 = sqrt(2*t_analytical2.^3/3 + 1);

% Plot Equation 2
figure('Name', 'Equation 2: dy/dt = t^2/y', 'Position', [150, 150, 900, 600]);

subplot(2,2,1);
plot(t_ode23_2, y_ode23_2, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
hold on;
plot(t_analytical2, y_analytical2, 'r--', 'LineWidth', 2);
xlabel('Time (t)', 'FontSize', 12);
ylabel('y(t)', 'FontSize', 12);
title('ODE23 Solver: dy/dt = t^2/y', 'FontSize', 14);
legend('ODE23 Solution', 'Analytical: y = √(2t³/3 + 1)', 'Location', 'northwest');
grid on;
annotation('textbox', [0.15, 0.85, 0.2, 0.05], 'String', sprintf('Steps: %d', length(t_ode23_2)), 'FitBoxToText', 'on');

subplot(2,2,2);
plot(t_ode45_2, y_ode45_2, 'g-s', 'LineWidth', 1.5, 'MarkerSize', 4);
hold on;
plot(t_analytical2, y_analytical2, 'r--', 'LineWidth', 2);
xlabel('Time (t)', 'FontSize', 12);
ylabel('y(t)', 'FontSize', 12);
title('ODE45 Solver: dy/dt = t^2/y', 'FontSize', 14);
legend('ODE45 Solution', 'Analytical: y = √(2t³/3 + 1)', 'Location', 'northwest');
grid on;
annotation('textbox', [0.58, 0.85, 0.2, 0.05], 'String', sprintf('Steps: %d', length(t_ode45_2)), 'FitBoxToText', 'on');

subplot(2,2,[3,4]);
plot(t_ode23_2, y_ode23_2, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
hold on;
plot(t_ode45_2, y_ode45_2, 'g-s', 'LineWidth', 1.5, 'MarkerSize', 4);
plot(t_analytical2, y_analytical2, 'r--', 'LineWidth', 2);
xlabel('Time (t)', 'FontSize', 12);
ylabel('y(t)', 'FontSize', 12);
title('Comparison: ODE23 vs ODE45 vs Analytical Solution', 'FontSize', 14);
legend('ODE23', 'ODE45', 'Analytical', 'Location', 'northwest');
grid on;

sgtitle('Equation 2: dy/dt = t²/y, y(0) = 1', 'FontSize', 16, 'FontWeight', 'bold');
saveas(gcf, 'Equation2_Results.png');

fprintf('Equation 2 - ODE23 steps: %d, ODE45 steps: %d\n', length(t_ode23_2), length(t_ode45_2));

%% ========================================================================
% EQUATION 3: dy/dt + 2y/t = t^4, y(1) = 1, t ∈ [1, 8]
% ========================================================================
fprintf('\n=== EQUATION 3: dy/dt + 2y/t = t^4 ===\n');

% Rearrange: dy/dt = t^4 - 2y/t
ode3 = @(t, y) t^4 - (2*y)/t;

% Initial condition and time span
y0_3 = 1;
tspan3 = [1 8];

% Solve using ode23
[t_ode23_3, y_ode23_3] = ode23(ode3, tspan3, y0_3);

% Solve using ode45
[t_ode45_3, y_ode45_3] = ode45(ode3, tspan3, y0_3);

% Analytical solution using integrating factor method
% Integrating factor: μ(t) = t^2
% Solution: y = t^5/7 + C/t^2, with y(1) = 1: C = 6/7
% So: y = t^5/7 + 6/(7*t^2)
t_analytical3 = linspace(1, 8, 100);
y_analytical3 = t_analytical3.^5/7 + 6./(7*t_analytical3.^2);

% Plot Equation 3
figure('Name', 'Equation 3: dy/dt + 2y/t = t^4', 'Position', [200, 200, 900, 600]);

subplot(2,2,1);
plot(t_ode23_3, y_ode23_3, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
hold on;
plot(t_analytical3, y_analytical3, 'r--', 'LineWidth', 2);
xlabel('Time (t)', 'FontSize', 12);
ylabel('y(t)', 'FontSize', 12);
title('ODE23 Solver: dy/dt + 2y/t = t^4', 'FontSize', 14);
legend('ODE23 Solution', 'Analytical', 'Location', 'northwest');
grid on;
annotation('textbox', [0.15, 0.85, 0.2, 0.05], 'String', sprintf('Steps: %d', length(t_ode23_3)), 'FitBoxToText', 'on');

subplot(2,2,2);
plot(t_ode45_3, y_ode45_3, 'g-s', 'LineWidth', 1.5, 'MarkerSize', 4);
hold on;
plot(t_analytical3, y_analytical3, 'r--', 'LineWidth', 2);
xlabel('Time (t)', 'FontSize', 12);
ylabel('y(t)', 'FontSize', 12);
title('ODE45 Solver: dy/dt + 2y/t = t^4', 'FontSize', 14);
legend('ODE45 Solution', 'Analytical', 'Location', 'northwest');
grid on;
annotation('textbox', [0.58, 0.85, 0.2, 0.05], 'String', sprintf('Steps: %d', length(t_ode45_3)), 'FitBoxToText', 'on');

subplot(2,2,[3,4]);
plot(t_ode23_3, y_ode23_3, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
hold on;
plot(t_ode45_3, y_ode45_3, 'g-s', 'LineWidth', 1.5, 'MarkerSize', 4);
plot(t_analytical3, y_analytical3, 'r--', 'LineWidth', 2);
xlabel('Time (t)', 'FontSize', 12);
ylabel('y(t)', 'FontSize', 12);
title('Comparison: ODE23 vs ODE45 vs Analytical Solution', 'FontSize', 14);
legend('ODE23', 'ODE45', 'Analytical', 'Location', 'northwest');
grid on;

sgtitle('Equation 3: dy/dt + 2y/t = t⁴, y(1) = 1', 'FontSize', 16, 'FontWeight', 'bold');
saveas(gcf, 'Equation3_Results.png');

fprintf('Equation 3 - ODE23 steps: %d, ODE45 steps: %d\n', length(t_ode23_3), length(t_ode45_3));

%% ========================================================================
% SUMMARY TABLE
% ========================================================================
fprintf('\n========== SUMMARY ==========\n');
fprintf('%-15s %-15s %-15s\n', 'Equation', 'ODE23 Steps', 'ODE45 Steps');
fprintf('%-15s %-15d %-15d\n', 'Equation 1', length(t_ode23_1), length(t_ode45_1));
fprintf('%-15s %-15d %-15d\n', 'Equation 2', length(t_ode23_2), length(t_ode45_2));
fprintf('%-15s %-15d %-15d\n', 'Equation 3', length(t_ode23_3), length(t_ode45_3));
fprintf('==============================\n');

%% ========================================================================
% COMMENTS AND ANALYSIS
% ========================================================================
% 
% ODE23 vs ODE45 Comparison:
% --------------------------
% 1. ODE23 uses Runge-Kutta (2,3) pair - lower order method
%    - Faster computation per step
%    - More steps required for same accuracy
%    - Better for problems with discontinuities
%
% 2. ODE45 uses Runge-Kutta (4,5) pair - higher order method  
%    - More accurate per step
%    - Fewer steps for smooth problems
%    - MATLAB's recommended default solver
%
% Equation 1 Analysis:
% - Simple polynomial ODE, both solvers converge well
% - ODE45 typically uses fewer steps due to higher accuracy
%
% Equation 2 Analysis:
% - Nonlinear separable ODE (y in denominator)
% - Solution grows as t increases
% - Both solvers handle the nonlinearity well
%
% Equation 3 Analysis:
% - First-order linear ODE with variable coefficients
% - Solution grows rapidly (t^5 term dominates)
% - ODE45 more efficient for this smooth problem
%
