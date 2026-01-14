%% Capture Problem 3 Simulink Diagrams
fprintf('Capturing Problem 3 Simulink Diagrams...\n\n');

% Single-phase inverter
fprintf('1. Opening single-phase inverter model...\n');
open_system('Problem3_SinglePhase_Inverter.slx');
pause(2);
fprintf('   Saving diagram as Problem3_SinglePhase_Diagram.png...\n');
print('-sProblem3_SinglePhase_Inverter', '-dpng', '-r300', 'Problem3_SinglePhase_Diagram.png');
close_system('Problem3_SinglePhase_Inverter', 0);
fprintf('   ✓ Single-phase diagram saved!\n\n');

% Three-phase inverter
fprintf('2. Opening three-phase inverter model...\n');
open_system('Problem3_ThreePhase_Inverter.slx');
pause(2);
fprintf('   Saving diagram as Problem3_ThreePhase_Diagram.png...\n');
print('-sProblem3_ThreePhase_Inverter', '-dpng', '-r300', 'Problem3_ThreePhase_Diagram.png');
close_system('Problem3_ThreePhase_Inverter', 0);
fprintf('   ✓ Three-phase diagram saved!\n\n');

fprintf('Both diagrams saved successfully!\n');
fprintf('Files: Problem3_SinglePhase_Diagram.png, Problem3_ThreePhase_Diagram.png\n');
