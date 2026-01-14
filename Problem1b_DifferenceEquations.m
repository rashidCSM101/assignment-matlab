
clear all; close all; clc;

%% ========================================================================
% DIFFERENCE EQUATION 1: y[n] = 3x[n] + y[n-1]
% ========================================================================
fprintf('=== DIFFERENCE EQUATION 1: y[n] = 3x[n] + y[n-1] ===\n\n');

% Transfer Function Derivation:
% -----------------------------
% Taking Z-transform of both sides:
% Y(z) = 3X(z) + z^(-1)Y(z)
% Y(z) - z^(-1)Y(z) = 3X(z)
% Y(z)(1 - z^(-1)) = 3X(z)
% H(z) = Y(z)/X(z) = 3 / (1 - z^(-1))
% 
% Multiplying numerator and denominator by z:
% H(z) = 3z / (z - 1)

fprintf('Transfer Function Derivation for Equation 1:\n');
fprintf('  y[n] = 3x[n] + y[n-1]\n');
fprintf('  Taking Z-transform:\n');
fprintf('  Y(z) = 3X(z) + z^(-1)Y(z)\n');
fprintf('  Y(z)(1 - z^(-1)) = 3X(z)\n');
fprintf('  H1(z) = 3 / (1 - z^(-1)) = 3z / (z - 1)\n\n');

% Define coefficients for filter function
% y[n] = 3x[n] + y[n-1]
% Rearranging: y[n] - y[n-1] = 3x[n]
% filter(b, a, x) where: a(1)*y[n] + a(2)*y[n-1] + ... = b(1)*x[n] + b(2)*x[n-1] + ...
% So: b = [3], a = [1, -1]
b1 = [3];       % Numerator coefficients (feedforward)
a1 = [1, -1];   % Denominator coefficients (feedback)

fprintf('Filter coefficients:\n');
fprintf('  Numerator b = [3]\n');
fprintf('  Denominator a = [1, -1]\n\n');

%% Analysis of System 1
fprintf('=== ANALYSIS OF H1(z) ===\n');

% Calculate poles and zeros manually
zeros1 = roots(b1);
poles1 = roots(a1);

fprintf('Zeros: ');
if isempty(zeros1)
    fprintf('None (constant numerator)\n');
else
    disp(zeros1');
end
fprintf('Poles: '); disp(poles1');

% Stability Analysis
fprintf('Stability Analysis:\n');
if all(abs(poles1) < 1)
    fprintf('  System is STABLE (all poles inside unit circle)\n\n');
elseif any(abs(poles1) == 1)
    fprintf('  System is MARGINALLY STABLE (pole on unit circle)\n');
    fprintf('  Pole at z = 1 means integrator/accumulator behaviour\n\n');
else
    fprintf('  System is UNSTABLE (poles outside unit circle)\n\n');
end

%% Generate responses manually
n_samples = 20;
n = 0:n_samples-1;

% Impulse response using filter function
impulse_input = [1, zeros(1, n_samples-1)];
h1_imp = filter(b1, a1, impulse_input);

% Step response using filter function
step_input = ones(1, n_samples);
h1_step = filter(b1, a1, step_input);

% Frequency response (manual calculation without freqz)
N_freq = 512;
w = linspace(0, pi, N_freq);
H1_freq = zeros(1, N_freq);
for k = 1:N_freq
    z = exp(1j * w(k));
    % H(z) = 3 / (1 - z^(-1)) = 3z / (z - 1)
    H1_freq(k) = 3 / (1 - z^(-1));
end

%% Plots for System 1
figure('Name', 'Difference Equation 1 Analysis', 'Position', [100, 100, 1200, 800]);

% Pole-Zero Plot (Manual - no zplane needed)
subplot(2,3,1);
theta = linspace(0, 2*pi, 100);
plot(cos(theta), sin(theta), 'k--', 'LineWidth', 1); % Unit circle
hold on;
if ~isempty(zeros1)
    plot(real(zeros1), imag(zeros1), 'bo', 'MarkerSize', 10, 'LineWidth', 2);
end
plot(real(poles1), imag(poles1), 'rx', 'MarkerSize', 12, 'LineWidth', 2);
plot(0, 0, 'k+', 'MarkerSize', 8); % Origin
xlabel('Real Part', 'FontSize', 11);
ylabel('Imaginary Part', 'FontSize', 11);
title('Pole-Zero Plot: H1(z) = 3z/(z-1)', 'FontSize', 12);
legend('Unit Circle', 'Poles', 'Location', 'best');
grid on;
axis equal;
xlim([-2 2]); ylim([-2 2]);

% Impulse Response
subplot(2,3,2);
stem(n, h1_imp, 'b', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
xlabel('n (samples)', 'FontSize', 11);
ylabel('h[n]', 'FontSize', 11);
title('Impulse Response', 'FontSize', 12);
grid on;

% Step Response
subplot(2,3,3);
stem(n, h1_step, 'r', 'LineWidth', 1.5, 'MarkerFaceColor', 'r');
xlabel('n (samples)', 'FontSize', 11);
ylabel('y[n]', 'FontSize', 11);
title('Step Response', 'FontSize', 12);
grid on;

% Frequency Response - Magnitude
subplot(2,3,4);
plot(w/pi, 20*log10(abs(H1_freq)), 'b', 'LineWidth', 1.5);
xlabel('Normalized Frequency (\times\pi rad/sample)', 'FontSize', 11);
ylabel('Magnitude (dB)', 'FontSize', 11);
title('Magnitude Response', 'FontSize', 12);
grid on;

% Frequency Response - Phase
subplot(2,3,5);
plot(w/pi, angle(H1_freq)*180/pi, 'g', 'LineWidth', 1.5);
xlabel('Normalized Frequency (\times\pi rad/sample)', 'FontSize', 11);
ylabel('Phase (degrees)', 'FontSize', 11);
title('Phase Response', 'FontSize', 12);
grid on;

% Filter Output
subplot(2,3,6);
y_output1 = filter(b1, a1, impulse_input);
stem(n, y_output1, 'm', 'LineWidth', 1.5, 'MarkerFaceColor', 'm');
xlabel('n (samples)', 'FontSize', 11);
ylabel('y[n]', 'FontSize', 11);
title('Filter Output (Impulse Input)', 'FontSize', 12);
grid on;

sgtitle('Difference Equation 1: y[n] = 3x[n] + y[n-1]', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, 'DiffEq1_Analysis.png');

%% ========================================================================
% DIFFERENCE EQUATION 2: y[n] = 2x[n] + 3x[n-1] + x[n-2]
% ========================================================================
fprintf('\n=== DIFFERENCE EQUATION 2: y[n] = 2x[n] + 3x[n-1] + x[n-2] ===\n\n');

% Transfer Function Derivation:
% -----------------------------
% Taking Z-transform of both sides:
% Y(z) = 2X(z) + 3z^(-1)X(z) + z^(-2)X(z)
% Y(z) = X(z)(2 + 3z^(-1) + z^(-2))
% H(z) = Y(z)/X(z) = 2 + 3z^(-1) + z^(-2)
%
% Multiplying by z^2:
% H(z) = (2z^2 + 3z + 1) / z^2

fprintf('Transfer Function Derivation for Equation 2:\n');
fprintf('  y[n] = 2x[n] + 3x[n-1] + x[n-2]\n');
fprintf('  Taking Z-transform:\n');
fprintf('  Y(z) = 2X(z) + 3z^(-1)X(z) + z^(-2)X(z)\n');
fprintf('  Y(z) = X(z)(2 + 3z^(-1) + z^(-2))\n');
fprintf('  H2(z) = 2 + 3z^(-1) + z^(-2)\n\n');

% Define coefficients for filter function
% This is a FIR filter (no feedback)
% b = [2, 3, 1], a = [1]
b2 = [2, 3, 1];  % Numerator coefficients
a2 = [1];        % Denominator (FIR = 1)

fprintf('Filter coefficients:\n');
fprintf('  Numerator b = [2, 3, 1]\n');
fprintf('  Denominator a = [1] (FIR filter)\n\n');

%% Analysis of System 2
fprintf('=== ANALYSIS OF H2(z) ===\n');

% Calculate zeros manually
zeros2 = roots(b2);
poles2 = [];  % No poles for FIR (or poles at origin)

fprintf('Zeros: '); disp(zeros2');
fprintf('Poles: None (FIR filter - poles at origin)\n');

% Factor the numerator: 2z^2 + 3z + 1 = (2z + 1)(z + 1)
fprintf('\nFactored form: H2(z) = (2z + 1)(z + 1) / z^2\n');
fprintf('Zeros at z = %.2f and z = %.2f\n', zeros2(1), zeros2(2));

% Stability Analysis
fprintf('\nStability Analysis:\n');
fprintf('  This is a FIR filter - inherently STABLE\n');
fprintf('  (No feedback, finite impulse response)\n\n');

%% Generate responses for System 2
% Impulse response
h2_imp = filter(b2, a2, impulse_input);

% Step response
h2_step = filter(b2, a2, step_input);

% Frequency response (manual calculation)
H2_freq = zeros(1, N_freq);
for k = 1:N_freq
    z = exp(1j * w(k));
    % H(z) = 2 + 3z^(-1) + z^(-2)
    H2_freq(k) = 2 + 3*z^(-1) + z^(-2);
end

%% Plots for System 2
figure('Name', 'Difference Equation 2 Analysis', 'Position', [150, 150, 1200, 800]);

% Pole-Zero Plot (Manual)
subplot(2,3,1);
plot(cos(theta), sin(theta), 'k--', 'LineWidth', 1); % Unit circle
hold on;
plot(real(zeros2), imag(zeros2), 'bo', 'MarkerSize', 10, 'LineWidth', 2);
plot(0, 0, 'rx', 'MarkerSize', 12, 'LineWidth', 2); % Poles at origin for z^(-2)
plot(0, 0, 'k+', 'MarkerSize', 8);
xlabel('Real Part', 'FontSize', 11);
ylabel('Imaginary Part', 'FontSize', 11);
title('Pole-Zero Plot: H2(z) = 2 + 3z^{-1} + z^{-2}', 'FontSize', 12);
legend('Unit Circle', 'Zeros', 'Poles (origin)', 'Location', 'best');
grid on;
axis equal;
xlim([-2 2]); ylim([-2 2]);

% Impulse Response
subplot(2,3,2);
stem(n, h2_imp, 'b', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
xlabel('n (samples)', 'FontSize', 11);
ylabel('h[n]', 'FontSize', 11);
title('Impulse Response (FIR)', 'FontSize', 12);
grid on;

% Step Response
subplot(2,3,3);
stem(n, h2_step, 'r', 'LineWidth', 1.5, 'MarkerFaceColor', 'r');
xlabel('n (samples)', 'FontSize', 11);
ylabel('y[n]', 'FontSize', 11);
title('Step Response', 'FontSize', 12);
grid on;

% Frequency Response - Magnitude
subplot(2,3,4);
plot(w/pi, 20*log10(abs(H2_freq)), 'b', 'LineWidth', 1.5);
xlabel('Normalized Frequency (\times\pi rad/sample)', 'FontSize', 11);
ylabel('Magnitude (dB)', 'FontSize', 11);
title('Magnitude Response', 'FontSize', 12);
grid on;

% Frequency Response - Phase
subplot(2,3,5);
plot(w/pi, angle(H2_freq)*180/pi, 'g', 'LineWidth', 1.5);
xlabel('Normalized Frequency (\times\pi rad/sample)', 'FontSize', 11);
ylabel('Phase (degrees)', 'FontSize', 11);
title('Phase Response', 'FontSize', 12);
grid on;

% Filter Output
subplot(2,3,6);
y_output2 = filter(b2, a2, impulse_input);
stem(n, y_output2, 'm', 'LineWidth', 1.5, 'MarkerFaceColor', 'm');
xlabel('n (samples)', 'FontSize', 11);
ylabel('y[n]', 'FontSize', 11);
title('Filter Output (Impulse Input)', 'FontSize', 12);
grid on;

sgtitle('Difference Equation 2: y[n] = 2x[n] + 3x[n-1] + x[n-2]', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, 'DiffEq2_Analysis.png');

%% ========================================================================
% COMPARISON OF BOTH SYSTEMS
% ========================================================================
figure('Name', 'System Comparison', 'Position', [200, 200, 1000, 600]);

% Impulse Response Comparison
subplot(2,2,1);
stem(n, h1_imp, 'b', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
hold on;
stem(n, h2_imp, 'r--', 'LineWidth', 1.5, 'MarkerFaceColor', 'r');
xlabel('n (samples)', 'FontSize', 11);
ylabel('h[n]', 'FontSize', 11);
title('Impulse Response Comparison', 'FontSize', 12);
legend('H1(z): IIR', 'H2(z): FIR', 'Location', 'best');
grid on;

% Step Response Comparison
subplot(2,2,2);
stem(n, h1_step, 'b', 'LineWidth', 1.5, 'MarkerFaceColor', 'b');
hold on;
stem(n, h2_step, 'r--', 'LineWidth', 1.5, 'MarkerFaceColor', 'r');
xlabel('n (samples)', 'FontSize', 11);
ylabel('y[n]', 'FontSize', 11);
title('Step Response Comparison', 'FontSize', 12);
legend('H1(z): IIR', 'H2(z): FIR', 'Location', 'best');
grid on;

% Magnitude Response Comparison
subplot(2,2,3);
plot(w/pi, 20*log10(abs(H1_freq)), 'b', 'LineWidth', 1.5);
hold on;
plot(w/pi, 20*log10(abs(H2_freq)), 'r--', 'LineWidth', 1.5);
xlabel('Normalized Frequency (\times\pi rad/sample)', 'FontSize', 11);
ylabel('Magnitude (dB)', 'FontSize', 11);
title('Magnitude Response Comparison', 'FontSize', 12);
legend('H1(z)', 'H2(z)', 'Location', 'best');
grid on;

% Phase Response Comparison
subplot(2,2,4);
plot(w/pi, angle(H1_freq)*180/pi, 'b', 'LineWidth', 1.5);
hold on;
plot(w/pi, angle(H2_freq)*180/pi, 'r--', 'LineWidth', 1.5);
xlabel('Normalized Frequency (\times\pi rad/sample)', 'FontSize', 11);
ylabel('Phase (degrees)', 'FontSize', 11);
title('Phase Response Comparison', 'FontSize', 12);
legend('H1(z)', 'H2(z)', 'Location', 'best');
grid on;

sgtitle('Comparison: IIR vs FIR Digital Filters', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, 'DiffEq_Comparison.png');

%% ========================================================================
% SIMULATION WITH DIFFERENT INPUTS
% ========================================================================
figure('Name', 'Input-Output Simulation', 'Position', [250, 250, 1200, 500]);

N = 50;
n_long = 0:N-1;

% Test Input 1: Unit Step
x_step_long = ones(1, N);
y1_step_long = filter(b1, a1, x_step_long);
y2_step_long = filter(b2, a2, x_step_long);

% Test Input 2: Sinusoidal
x_sin = sin(2*pi*0.1*n_long);
y1_sin = filter(b1, a1, x_sin);
y2_sin = filter(b2, a2, x_sin);

subplot(2,3,1);
stem(n_long, x_step_long, 'k', 'LineWidth', 1);
xlabel('n'); ylabel('x[n]');
title('Input: Unit Step', 'FontSize', 11);
grid on; ylim([0 1.5]);

subplot(2,3,2);
stem(n_long, y1_step_long, 'b', 'LineWidth', 1);
xlabel('n'); ylabel('y[n]');
title('H1(z) Output (Step)', 'FontSize', 11);
grid on;

subplot(2,3,3);
stem(n_long, y2_step_long, 'r', 'LineWidth', 1);
xlabel('n'); ylabel('y[n]');
title('H2(z) Output (Step)', 'FontSize', 11);
grid on;

subplot(2,3,4);
plot(n_long, x_sin, 'k', 'LineWidth', 1.5);
xlabel('n'); ylabel('x[n]');
title('Input: Sinusoid (f = 0.1)', 'FontSize', 11);
grid on;

subplot(2,3,5);
plot(n_long, y1_sin, 'b', 'LineWidth', 1.5);
xlabel('n'); ylabel('y[n]');
title('H1(z) Output (Sinusoid)', 'FontSize', 11);
grid on;

subplot(2,3,6);
plot(n_long, y2_sin, 'r', 'LineWidth', 1.5);
xlabel('n'); ylabel('y[n]');
title('H2(z) Output (Sinusoid)', 'FontSize', 11);
grid on;

sgtitle('System Response to Different Inputs', 'FontSize', 14, 'FontWeight', 'bold');
saveas(gcf, 'DiffEq_Simulation.png');

%% ========================================================================
% SUMMARY
% ========================================================================
fprintf('\n============ SUMMARY ============\n\n');

fprintf('DIFFERENCE EQUATION 1:\n');
fprintf('  y[n] = 3x[n] + y[n-1]\n');
fprintf('  Transfer Function: H1(z) = 3 / (1 - z^(-1)) = 3z / (z - 1)\n');
fprintf('  Type: IIR (Infinite Impulse Response)\n');
fprintf('  Pole at z = 1 (marginally stable - integrator)\n');
fprintf('  Behaviour: Accumulator/Integrator\n\n');

fprintf('DIFFERENCE EQUATION 2:\n');
fprintf('  y[n] = 2x[n] + 3x[n-1] + x[n-2]\n');
fprintf('  Transfer Function: H2(z) = 2 + 3z^(-1) + z^(-2)\n');
fprintf('  Type: FIR (Finite Impulse Response)\n');
fprintf('  Zeros at z = -0.5 and z = -1\n');
fprintf('  Behaviour: Moving average filter\n\n');

fprintf('=================================\n');
fprintf('All figures saved as PNG files.\n');

%% ========================================================================
% COMMENTS AND DISCUSSION
% ========================================================================
%
% DIFFERENCE EQUATION 1 ANALYSIS:
% -------------------------------
% - This is an IIR (Infinite Impulse Response) filter
% - Has feedback term y[n-1], creating recursive behaviour
% - Pole at z = 1 makes it act as a discrete-time integrator
% - Marginally stable (pole on unit circle)
% - Impulse response: h[n] = 3, 3, 3, 3, ... (constant)
% - Step response grows linearly: 3, 6, 9, 12, ...
% - Used in: Accumulators, integrators, running sum applications
%
% DIFFERENCE EQUATION 2 ANALYSIS:
% -------------------------------
% - This is a FIR (Finite Impulse Response) filter
% - No feedback terms - only depends on current and past inputs
% - Inherently stable (no poles outside origin)
% - Finite impulse response: h[n] = [2, 3, 1, 0, 0, ...]
% - Only 3 non-zero coefficients
% - Acts as a weighted moving average
% - Used in: Signal smoothing, anti-aliasing, noise reduction
%
% Z-TRANSFORM METHOD:
% ------------------
% 1. Replace y[n] with Y(z)
% 2. Replace y[n-k] with z^(-k)Y(z)
% 3. Replace x[n] with X(z)
% 4. Replace x[n-k] with z^(-k)X(z)
% 5. Solve for H(z) = Y(z)/X(z)
%
% IIR vs FIR COMPARISON:
% ----------------------
% IIR Filters:
%   - Have feedback (recursive)
%   - Can be unstable
%   - Infinite impulse response
%   - More efficient for sharp cutoffs
%
% FIR Filters:
%   - No feedback (non-recursive)
%   - Always stable
%   - Finite impulse response
%   - Linear phase possible
%
