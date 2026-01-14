%% ========================================================================
% PROBLEM 4: HYBRID DER SYSTEM FOR REMOTE LOCATION
% Location: Kaghan Valley, Mansehra District, Pakistan
% Coordinates: 34.8°N, 73.5°E, Altitude: 2,500m
% 
% CONTEXT:
% Kaghan Valley is a remote mountainous tourist region in northern Pakistan
% with severe energy challenges. Grid connectivity is unreliable (18-20 hour
% daily load-shedding in winter). The region experiences:
% - Heavy snowfall (Nov-Mar) limiting road access
% - High solar irradiance (1,800 kWh/m²/year at altitude)
% - Moderate wind speeds (avg 5-7 m/s on ridges)
% - Seasonal tourism demand (peak: May-Sep, low: Dec-Feb)
%
% SELECTED LOCATION: Mountain Resort Complex (50 rooms + facilities)
% Annual Energy Demand: ~350 MWh
% Peak Load: 120 kW (summer evenings)
% Base Load: 25 kW (winter nights)
%
% HYBRID DER COMPONENTS:
% 1. Solar PV Array: 150 kW (rooftop + ground-mounted)
% 2. Small Wind Turbines: 30 kW (3× 10kW units on ridge)
% 3. Battery Energy Storage: 200 kWh (Lithium-ion)
% 4. Diesel Generator (Backup): 100 kW (existing, to be minimized)
%
% DESIGN OBJECTIVES:
% - Achieve 85% renewable energy fraction
% - Reduce diesel consumption by 80%
% - Ensure 99.5% supply reliability
% - Payback period < 8 years
%
% ========================================================================

clear all; close all; clc;

fprintf('====================================================================\n');
fprintf('   HYBRID DER SYSTEM DESIGN FOR KAGHAN VALLEY, PAKISTAN\n');
fprintf('====================================================================\n\n');

%% ========================================================================
% STEP 1: LOCATION PARAMETERS AND RESOURCE ASSESSMENT
% ========================================================================
fprintf('STEP 1: Resource Assessment\n');
fprintf('----------------------------\n');

% Geographic Parameters
latitude = 34.8;        % degrees North
longitude = 73.5;       % degrees East
altitude = 2500;        % meters above sea level
timezone_offset = 5;    % UTC+5 (Pakistan Standard Time)

% Solar Resource Data (Kaghan Valley)
% Annual average: 1,800 kWh/m²/year at 2,500m altitude
annual_solar_irradiance = 1800;  % kWh/m²/year
avg_daily_irradiance = annual_solar_irradiance / 365;  % kWh/m²/day

% Seasonal variation (higher in summer, lower in winter due to snow cover)
% Summer (May-Sep): 6.5 kWh/m²/day
% Winter (Dec-Feb): 2.8 kWh/m²/day
% Spring/Autumn: 5.0 kWh/m²/day
irradiance_summer = 6.5;    % kWh/m²/day
irradiance_winter = 2.8;    % kWh/m²/day
irradiance_spring_autumn = 5.0;  % kWh/m²/day

fprintf('Solar Resource:\n');
fprintf('  Annual Irradiance: %.0f kWh/m²/year\n', annual_solar_irradiance);
fprintf('  Summer Daily: %.1f kWh/m²/day\n', irradiance_summer);
fprintf('  Winter Daily: %.1f kWh/m²/day\n', irradiance_winter);

% Wind Resource Data
% Ridge-top measurements show moderate wind speeds
avg_wind_speed = 6.2;       % m/s (annual average at 10m height)
wind_speed_summer = 7.5;    % m/s (May-Sep, thermal winds)
wind_speed_winter = 4.5;    % m/s (Dec-Feb, calm periods)
wind_speed_spring_autumn = 6.0;  % m/s

% Air density correction for altitude (affects wind power)
% ρ = ρ₀ × exp(-g×h/(R×T))
air_density_sea_level = 1.225;  % kg/m³
air_density_altitude = air_density_sea_level * exp(-9.81 * altitude / (287 * 288));
fprintf('\nWind Resource:\n');
fprintf('  Annual Avg Wind Speed: %.1f m/s\n', avg_wind_speed);
fprintf('  Air Density at %.0fm: %.3f kg/m³ (%.1f%% of sea level)\n', ...
    altitude, air_density_altitude, (air_density_altitude/air_density_sea_level)*100);

% Temperature Data (affects PV efficiency)
avg_temp_summer = 22;   % °C (May-Sep)
avg_temp_winter = -5;   % °C (Dec-Feb)
avg_temp_annual = 10;   % °C

fprintf('\nTemperature Profile:\n');
fprintf('  Summer Average: %.0f°C\n', avg_temp_summer);
fprintf('  Winter Average: %.0f°C\n', avg_temp_winter);
fprintf('  Annual Average: %.0f°C\n\n', avg_temp_annual);

%% ========================================================================
% STEP 2: LOAD DEMAND PROFILE
% ========================================================================
fprintf('STEP 2: Load Demand Analysis\n');
fprintf('----------------------------\n');

% Mountain Resort Load Profile (50 rooms, restaurants, facilities)
% Components:
% - Guest rooms: 50 rooms × 1.5 kW avg = 75 kW
% - Kitchen/Restaurant: 15 kW
% - Water heating (electric): 12 kW
% - Lighting: 8 kW
% - HVAC: 20 kW (summer cooling, winter heating)
% - Miscellaneous (office, Wi-Fi, etc.): 10 kW

% Peak load occurs during summer evening (all guests, full services)
peak_load = 120;  % kW

% Base load (winter night, minimal occupancy)
base_load = 25;   % kW

% Typical daily load curve (24 hours)
% Modeled as combination of base load + variable load
hours = 0:23;

% Summer load profile (high occupancy: 80-100%)
load_summer = base_load + ...
    30 * (hours >= 6 & hours < 8) + ...      % Morning peak (breakfast)
    25 * (hours >= 8 & hours < 12) + ...     % Daytime activities
    35 * (hours >= 12 & hours < 14) + ...    % Lunch peak
    30 * (hours >= 14 & hours < 18) + ...    % Afternoon activities
    50 * (hours >= 18 & hours < 23);         % Evening peak (dinner + leisure)

% Winter load profile (low occupancy: 30-40%, higher heating demand)
load_winter = base_load + ...
    20 * (hours >= 6 & hours < 9) + ...      % Morning peak (heating + breakfast)
    15 * (hours >= 9 & hours < 17) + ...     % Daytime (minimal activity)
    35 * (hours >= 17 & hours < 22);         % Evening peak (heating + dinner)

% Annual energy demand calculation
% Summer: 150 days × average summer load
% Winter: 120 days × average winter load
% Spring/Autumn: 95 days × average load

avg_load_summer = mean(load_summer);
avg_load_winter = mean(load_winter);
avg_load_spring_autumn = (avg_load_summer + avg_load_winter) / 2;

annual_energy_demand = (150 * 24 * avg_load_summer + ...
                        120 * 24 * avg_load_winter + ...
                        95 * 24 * avg_load_spring_autumn) / 1000;  % MWh

fprintf('Load Characteristics:\n');
fprintf('  Peak Load: %.0f kW\n', peak_load);
fprintf('  Base Load: %.0f kW\n', base_load);
fprintf('  Average Summer Load: %.1f kW\n', avg_load_summer);
fprintf('  Average Winter Load: %.1f kW\n', avg_load_winter);
fprintf('  Annual Energy Demand: %.0f MWh\n\n', annual_energy_demand);

% Plot load profiles
figure('Name', 'Load Demand Profiles', 'Position', [100, 100, 1000, 400]);
plot(hours, load_summer, 'r-', 'LineWidth', 2); hold on;
plot(hours, load_winter, 'b-', 'LineWidth', 2);
plot([0 23], [peak_load peak_load], 'k--', 'LineWidth', 1);
plot([0 23], [base_load base_load], 'k:', 'LineWidth', 1);
grid on;
xlabel('Hour of Day', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Load Demand (kW)', 'FontSize', 12, 'FontWeight', 'bold');
title('Seasonal Load Demand Profiles - Kaghan Valley Resort', 'FontSize', 14, 'FontWeight', 'bold');
legend('Summer (May-Sep)', 'Winter (Dec-Feb)', 'Peak Load', 'Base Load', 'Location', 'northwest');
xlim([0 23]);
ylim([0 130]);
set(gca, 'FontSize', 11);
saveas(gcf, 'Problem4_Load_Profiles.png');
fprintf('  Saved: Problem4_Load_Profiles.png\n\n');

%% ========================================================================
% STEP 3: HYBRID DER SYSTEM COMPONENT SIZING
% ========================================================================
fprintf('STEP 3: Component Sizing\n');
fprintf('------------------------\n');

% Component 1: Solar PV Array
% Target: Cover 60% of annual demand
PV_capacity = 150;  % kW (DC rated power at STC)
PV_efficiency = 0.18;  % Module efficiency (18% polycrystalline)
PV_area = (PV_capacity * 1000) / (1000 * PV_efficiency);  % m²
PV_temperature_coeff = -0.004;  % Power loss per °C above 25°C
PV_system_losses = 0.15;  % 15% (inverter, wiring, soiling, shading)

fprintf('Solar PV System:\n');
fprintf('  Capacity: %.0f kW DC\n', PV_capacity);
fprintf('  Array Area: %.0f m²\n', PV_area);
fprintf('  Module Efficiency: %.0f%%\n', PV_efficiency*100);
fprintf('  System Losses: %.0f%%\n\n', PV_system_losses*100);

% Component 2: Wind Turbines
% Target: Cover 15% of annual demand (complementary to solar)
wind_capacity = 30;  % kW (3× 10kW turbines)
num_turbines = 3;
turbine_rated_power = 10;  % kW per turbine
turbine_cut_in_speed = 3.0;  % m/s
turbine_rated_speed = 12.0;  % m/s
turbine_cut_out_speed = 25.0;  % m/s
turbine_efficiency = 0.35;  % 35% (realistic for small turbines)

fprintf('Wind Turbine System:\n');
fprintf('  Total Capacity: %.0f kW (%.0f × %.0f kW)\n', wind_capacity, num_turbines, turbine_rated_power);
fprintf('  Cut-in Speed: %.1f m/s\n', turbine_cut_in_speed);
fprintf('  Rated Speed: %.1f m/s\n', turbine_rated_speed);
fprintf('  Turbine Efficiency: %.0f%%\n\n', turbine_efficiency*100);

% Component 3: Battery Energy Storage System (BESS)
% Target: 8 hours of base load (overnight autonomy)
battery_capacity = 200;  % kWh (usable capacity)
battery_voltage = 400;  % V DC (nominal)
battery_DOD_max = 0.80;  % 80% depth of discharge (Lithium-ion)
battery_efficiency_rt = 0.90;  % 90% round-trip efficiency
battery_charge_rate = 0.5;  % C-rate (50 kW charge power)
battery_discharge_rate = 0.5;  % C-rate (100 kW discharge power)
battery_cycles_lifetime = 5000;  % cycles at 80% DOD

fprintf('Battery Energy Storage:\n');
fprintf('  Usable Capacity: %.0f kWh\n', battery_capacity);
fprintf('  Voltage: %.0f V DC\n', battery_voltage);
fprintf('  Max Depth of Discharge: %.0f%%\n', battery_DOD_max*100);
fprintf('  Round-Trip Efficiency: %.0f%%\n', battery_efficiency_rt*100);
fprintf('  Autonomy: %.1f hours at base load\n\n', battery_capacity / base_load);

% Component 4: Diesel Generator (Backup)
% Existing generator, to be used minimally
diesel_capacity = 100;  % kW
diesel_efficiency = 0.30;  % 30% fuel efficiency (typical)
diesel_fuel_consumption = 0.25;  % L/kWh at 75% load
diesel_fuel_cost = 2.50;  % USD/liter (Pakistan remote area pricing)
diesel_CO2_emission = 2.68;  % kg CO2/liter diesel

fprintf('Diesel Generator (Backup):\n');
fprintf('  Capacity: %.0f kW\n', diesel_capacity);
fprintf('  Fuel Consumption: %.2f L/kWh\n', diesel_fuel_consumption);
fprintf('  Fuel Cost: $%.2f/L\n', diesel_fuel_cost);
fprintf('  CO2 Emissions: %.2f kg/L\n\n', diesel_CO2_emission);

%% ========================================================================
% STEP 4: SYSTEM SCHEMATIC DIAGRAM
% ========================================================================
fprintf('STEP 4: System Architecture\n');
fprintf('----------------------------\n');

% System schematic (text-based description for MATLAB comment)
fprintf('System Configuration:\n');
fprintf('  [Solar PV Array] ───► [DC/DC MPPT] ─┐\n');
fprintf('                                      │\n');
fprintf('  [Wind Turbines]  ───► [Rectifier]  ├───► [DC Bus 400V] ───► [Inverter] ───► [AC Load]\n');
fprintf('                                      │         ▲                  │\n');
fprintf('  [Battery Bank]   ◄──────────────────┘         │                  │\n');
fprintf('                                                 │                  │\n');
fprintf('  [Diesel Generator] ───────────────────────────┴──────────────────┘\n');
fprintf('                                          (Emergency Backup Only)\n\n');

fprintf('Control Strategy:\n');
fprintf('  1. Solar + Wind → Primary sources (feed DC bus via MPPT)\n');
fprintf('  2. Battery → Charge when surplus, discharge when deficit\n');
fprintf('  3. Diesel → Activate only when Battery SOC < 20%% and Load > Renewable\n');
fprintf('  4. Load Shedding → If all sources insufficient, shed non-critical loads\n\n');

%% ========================================================================
% STEP 5: SUMMARY AND NEXT STEPS
% ========================================================================
fprintf('====================================================================\n');
fprintf('   LOCATION ANALYSIS COMPLETE\n');
fprintf('====================================================================\n\n');

fprintf('Key Design Parameters Summary:\n');
fprintf('  Location: Kaghan Valley, Pakistan (34.8°N, 73.5°E, 2500m)\n');
fprintf('  Annual Energy Demand: %.0f MWh\n', annual_energy_demand);
fprintf('  Solar PV: %.0f kW (%.0f m²)\n', PV_capacity, PV_area);
fprintf('  Wind Turbines: %.0f kW (%.0f units)\n', wind_capacity, num_turbines);
fprintf('  Battery Storage: %.0f kWh\n', battery_capacity);
fprintf('  Diesel Backup: %.0f kW\n\n', diesel_capacity);

fprintf('Next Steps:\n');
fprintf('  1. Build Simulink model (Problem4_Hybrid_DER_Model.slx)\n');
fprintf('  2. Simulate 1-year operation with hourly resolution\n');
fprintf('  3. Analyze renewable fraction, diesel usage, battery cycles\n');
fprintf('  4. Perform economic analysis (CAPEX, OPEX, payback period)\n');
fprintf('  5. Calculate CO2 emissions avoided vs diesel-only baseline\n\n');

fprintf('Location analysis data saved to workspace.\n');
fprintf('Run Problem4_Hybrid_DER_Simulation.m for detailed modeling.\n\n');

% Save workspace for next script
save('Problem4_Location_Data.mat');
