
clear all; close all; clc;

%% ========================================================================
% VAN DER POL OSCILLATOR
% Equation: d²x/dt² - μ(1-x²)(dx/dt) + x = 0
% Parameters: μ = 1 (damped system)
% Time interval: t ∈ [0, 25]
% Initial conditions: x(0) = 0, x'(0) = 2.5
% ========================================================================

fprintf('=== VAN DER POL OSCILLATOR ===\n');
fprintf('Equation: d²x/dt² - μ(1-x²)(dx/dt) + x = 0\n');
fprintf('μ = 1, t ∈ [0, 25], x(0) = 0, dx/dt(0) = 2.5\n\n');

% Parameters
mu = 1;  % Damping parameter

% Convert 2nd order ODE to system of 1st order ODEs:
% Let y1 = x and y2 = dx/dt
% Then: dy1/dt = y2
%       dy2/dt = μ(1-y1²)*y2 - y1

% Define the ODE system as a function
vanderpol = @(t, y) [y(2); mu*(1 - y(1)^2)*y(2) - y(1)];

% Initial conditions: x(0) = 0, x'(0) = 2.5
y0 = [0; 2.5];

% Time span
tspan = [0 25];

%% Solve using ODE23
fprintf('Solving with ODE23...\n');
tic;
[t_ode23, y_ode23] = ode23(vanderpol, tspan, y0);
time_ode23 = toc;
fprintf('ODE23 completed in %.4f seconds with %d steps\n', time_ode23, length(t_ode23));

%% Solve using ODE45
fprintf('Solving with ODE45...\n');
tic;
[t_ode45, y_ode45] = ode45(vanderpol, tspan, y0);
time_ode45 = toc;
fprintf('ODE45 completed in %.4f seconds with %d steps\n', time_ode45, length(t_ode45));

%% ========================================================================
% PLOT 1: Position vs Time (ODE23 vs ODE45)
% ========================================================================
figure('Name', 'Van der Pol - Position vs Time', 'Position', [100, 100, 1000, 700]);

subplot(2,2,1);
plot(t_ode23, y_ode23(:,1), 'b-', 'LineWidth', 1.5);
xlabel('Time (t)', 'FontSize', 12);
ylabel('Position x(t)', 'FontSize', 12);
title('ODE23: Position vs Time', 'FontSize', 14);
grid on;
text(0.05, 0.95, sprintf('Steps: %d', length(t_ode23)), 'Units', 'normalized', ...
    'FontSize', 10, 'BackgroundColor', 'white', 'EdgeColor', 'black');

subplot(2,2,2);
plot(t_ode45, y_ode45(:,1), 'g-', 'LineWidth', 1.5);
xlabel('Time (t)', 'FontSize', 12);
ylabel('Position x(t)', 'FontSize', 12);
title('ODE45: Position vs Time', 'FontSize', 14);
grid on;
text(0.05, 0.95, sprintf('Steps: %d', length(t_ode45)), 'Units', 'normalized', ...
    'FontSize', 10, 'BackgroundColor', 'white', 'EdgeColor', 'black');

subplot(2,2,[3,4]);
plot(t_ode23, y_ode23(:,1), 'b-', 'LineWidth', 1.5);
hold on;
plot(t_ode45, y_ode45(:,1), 'g--', 'LineWidth', 1.5);
xlabel('Time (t)', 'FontSize', 12);
ylabel('Position x(t)', 'FontSize', 12);
title('Comparison: ODE23 vs ODE45 - Position', 'FontSize', 14);
legend('ODE23', 'ODE45', 'Location', 'best');
grid on;

% Add annotations
annotation('textbox', [0.15, 0.02, 0.7, 0.05], ...
    'String', 'Van der Pol Oscillator: μ = 1, x(0) = 0, x''(0) = 2.5', ...
    'HorizontalAlignment', 'center', 'FontSize', 11, 'EdgeColor', 'none');

sgtitle('Van der Pol Oscillator: Position vs Time', 'FontSize', 16, 'FontWeight', 'bold');
saveas(gcf, 'VanDerPol_Position.png');

%% ========================================================================
% PLOT 2: Velocity vs Time
% ========================================================================
figure('Name', 'Van der Pol - Velocity vs Time', 'Position', [150, 150, 1000, 700]);

subplot(2,2,1);
plot(t_ode23, y_ode23(:,2), 'b-', 'LineWidth', 1.5);
xlabel('Time (t)', 'FontSize', 12);
ylabel('Velocity dx/dt', 'FontSize', 12);
title('ODE23: Velocity vs Time', 'FontSize', 14);
grid on;

subplot(2,2,2);
plot(t_ode45, y_ode45(:,2), 'g-', 'LineWidth', 1.5);
xlabel('Time (t)', 'FontSize', 12);
ylabel('Velocity dx/dt', 'FontSize', 12);
title('ODE45: Velocity vs Time', 'FontSize', 14);
grid on;

subplot(2,2,[3,4]);
plot(t_ode23, y_ode23(:,2), 'b-', 'LineWidth', 1.5);
hold on;
plot(t_ode45, y_ode45(:,2), 'g--', 'LineWidth', 1.5);
xlabel('Time (t)', 'FontSize', 12);
ylabel('Velocity dx/dt', 'FontSize', 12);
title('Comparison: ODE23 vs ODE45 - Velocity', 'FontSize', 14);
legend('ODE23', 'ODE45', 'Location', 'best');
grid on;

sgtitle('Van der Pol Oscillator: Velocity vs Time', 'FontSize', 16, 'FontWeight', 'bold');
saveas(gcf, 'VanDerPol_Velocity.png');

%% ========================================================================
% PLOT 3: Phase Portrait (Velocity vs Position)
% ========================================================================
figure('Name', 'Van der Pol - Phase Portrait', 'Position', [200, 200, 1000, 500]);

subplot(1,2,1);
plot(y_ode23(:,1), y_ode23(:,2), 'b-', 'LineWidth', 1.5);
hold on;
plot(y_ode23(1,1), y_ode23(1,2), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
plot(y_ode23(end,1), y_ode23(end,2), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
xlabel('Position x', 'FontSize', 12);
ylabel('Velocity dx/dt', 'FontSize', 12);
title('ODE23: Phase Portrait', 'FontSize', 14);
legend('Trajectory', 'Start Point', 'End Point', 'Location', 'best');
grid on;
axis equal;

subplot(1,2,2);
plot(y_ode45(:,1), y_ode45(:,2), 'g-', 'LineWidth', 1.5);
hold on;
plot(y_ode45(1,1), y_ode45(1,2), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
plot(y_ode45(end,1), y_ode45(end,2), 'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
xlabel('Position x', 'FontSize', 12);
ylabel('Velocity dx/dt', 'FontSize', 12);
title('ODE45: Phase Portrait', 'FontSize', 14);
legend('Trajectory', 'Start Point', 'End Point', 'Location', 'best');
grid on;
axis equal;

sgtitle('Van der Pol Oscillator: Phase Portrait (Limit Cycle)', 'FontSize', 16, 'FontWeight', 'bold');
saveas(gcf, 'VanDerPol_PhasePortrait.png');

%% ========================================================================
% PLOT 4: Combined Phase Portrait Comparison
% ========================================================================
figure('Name', 'Van der Pol - Combined Phase Portrait', 'Position', [250, 250, 800, 600]);

plot(y_ode23(:,1), y_ode23(:,2), 'b-', 'LineWidth', 2);
hold on;
plot(y_ode45(:,1), y_ode45(:,2), 'g--', 'LineWidth', 2);
plot(0, 2.5, 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r', 'DisplayName', 'Initial Point');

xlabel('Position x', 'FontSize', 14);
ylabel('Velocity dx/dt', 'FontSize', 14);
title('Van der Pol Phase Portrait: ODE23 vs ODE45', 'FontSize', 16, 'FontWeight', 'bold');
legend('ODE23 Solution', 'ODE45 Solution', 'Initial Point (0, 2.5)', 'Location', 'best');
grid on;
axis equal;

% Add annotation explaining limit cycle
annotation('textbox', [0.15, 0.02, 0.7, 0.08], ...
    'String', {'The trajectory spirals outward and converges to a stable limit cycle.', ...
               'This demonstrates the self-sustaining oscillation characteristic of Van der Pol oscillator.'}, ...
    'HorizontalAlignment', 'center', 'FontSize', 10, 'EdgeColor', 'black', 'BackgroundColor', 'white');

saveas(gcf, 'VanDerPol_Combined.png');

%% ========================================================================
% PLOT 5: 3D Visualization (Position, Velocity, Time)
% ========================================================================
figure('Name', 'Van der Pol - 3D Plot', 'Position', [300, 300, 900, 600]);

plot3(t_ode45, y_ode45(:,1), y_ode45(:,2), 'b-', 'LineWidth', 1.5);
hold on;
plot3(t_ode45(1), y_ode45(1,1), y_ode45(1,2), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
xlabel('Time (t)', 'FontSize', 12);
ylabel('Position x', 'FontSize', 12);
zlabel('Velocity dx/dt', 'FontSize', 12);
title('Van der Pol Oscillator: 3D Trajectory', 'FontSize', 16, 'FontWeight', 'bold');
legend('Trajectory', 'Start Point', 'Location', 'best');
grid on;
view(45, 30);
saveas(gcf, 'VanDerPol_3D.png');

%% ========================================================================
% SUMMARY AND STATISTICS
% ========================================================================
fprintf('\n========== SUMMARY ==========\n');
fprintf('Van der Pol Oscillator Parameters:\n');
fprintf('  μ (damping) = %d\n', mu);
fprintf('  Time span = [0, 25]\n');
fprintf('  Initial: x(0) = 0, x''(0) = 2.5\n\n');

fprintf('Solver Comparison:\n');
fprintf('%-15s %-15s %-15s\n', 'Solver', 'Steps', 'Time (s)');
fprintf('%-15s %-15d %-15.4f\n', 'ODE23', length(t_ode23), time_ode23);
fprintf('%-15s %-15d %-15.4f\n', 'ODE45', length(t_ode45), time_ode45);
fprintf('==============================\n');

% Calculate amplitude of limit cycle
fprintf('\nLimit Cycle Analysis:\n');
fprintf('  Max Position (ODE45): %.4f\n', max(y_ode45(:,1)));
fprintf('  Min Position (ODE45): %.4f\n', min(y_ode45(:,1)));
fprintf('  Max Velocity (ODE45): %.4f\n', max(y_ode45(:,2)));
fprintf('  Min Velocity (ODE45): %.4f\n', min(y_ode45(:,2)));

%% ========================================================================
% DISCUSSION AND ANALYSIS
% ========================================================================
%
% VAN DER POL OSCILLATOR BEHAVIOUR:
% ---------------------------------
% The Van der Pol oscillator is a non-conservative oscillator with nonlinear
% damping. The parameter μ controls the nonlinearity and damping strength.
%
% With μ = 1 (weakly nonlinear case):
% 1. The system exhibits a stable LIMIT CYCLE
% 2. Starting from initial conditions (0, 2.5), the trajectory spirals
%    and converges to this limit cycle
% 3. The limit cycle is an attractor - all trajectories eventually reach it
%
% PHASE PORTRAIT ANALYSIS:
% - The closed loop in the phase portrait represents the limit cycle
% - Inside the limit cycle: trajectories spiral outward
% - Outside the limit cycle: trajectories spiral inward
% - This self-regulating behaviour makes it useful in electronic oscillators
%
% ODE23 vs ODE45 COMPARISON:
% - ODE23: Uses Runge-Kutta (2,3) method - lower order
%   * Requires more steps for same accuracy
%   * Better for stiff problems or discontinuities
%
% - ODE45: Uses Runge-Kutta (4,5) method - higher order
%   * More efficient for smooth problems
%   * Fewer function evaluations needed
%   * MATLAB's default and recommended solver
%
% Both solvers produce nearly identical results, confirming the solution
% accuracy. The phase portraits from both methods overlap precisely,
% demonstrating numerical convergence.
%
% PHYSICAL SIGNIFICANCE:
% The Van der Pol oscillator models:
% - Electronic oscillator circuits (original application by van der Pol)
% - Cardiac pacemaker cells
% - Certain biological rhythms
% - Self-excited oscillations in mechanical systems
%
