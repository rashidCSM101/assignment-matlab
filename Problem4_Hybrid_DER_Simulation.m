%% ========================================================================
% PROBLEM 4: HYBRID DER SYSTEM SIMULATION
% Annual Simulation with Hourly Resolution (8,760 hours)
% Location: Kaghan Valley, Pakistan
%
% This script simulates one full year of hybrid DER operation including:
% - Solar PV generation with temperature effects
% - Wind turbine power output with altitude correction
% - Battery state-of-charge management
% - Diesel generator dispatch logic
% - Supply-demand energy balance
% - Economic and environmental metrics
%
% ========================================================================

clear all; close all; clc;

fprintf('====================================================================\n');
fprintf('   HYBRID DER SYSTEM ANNUAL SIMULATION\n');
fprintf('   Kaghan Valley, Pakistan - 8,760 Hour Resolution\n');
fprintf('====================================================================\n\n');

% Load location data from previous analysis
if exist('Problem4_Location_Data.mat', 'file')
    load('Problem4_Location_Data.mat');
    fprintf('Loaded location data from Problem4_Location_Data.mat\n\n');
else
    error('Run Problem4_Location_Analysis.m first to generate location data');
end

%% ========================================================================
% SIMULATION PARAMETERS
% ========================================================================
fprintf('Initializing Simulation Parameters...\n');

% Time array: 1 year = 8,760 hours
hours_per_year = 8760;
time_hours = 0:1:(hours_per_year-1);  % Hourly resolution
dt = 1;  % Time step = 1 hour

% Month definitions (for seasonal variation)
days_per_month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
hours_per_month = days_per_month * 24;
month_start_hours = [0, cumsum(hours_per_month(1:end-1))];

fprintf('  Simulation Duration: %.0f hours (1 year)\n', hours_per_year);
fprintf('  Time Resolution: %.0f hour\n\n', dt);

%% ========================================================================
% SOLAR IRRADIANCE MODEL
% ========================================================================
fprintf('Generating Solar Irradiance Data...\n');

% Initialize arrays
solar_irradiance = zeros(1, hours_per_year);  % W/m²
solar_temp = zeros(1, hours_per_year);  % °C

for h = 1:hours_per_year
    % Determine current month
    month = find(h > month_start_hours, 1, 'last');
    day_of_year = floor(h / 24) + 1;
    hour_of_day = mod(h-1, 24);
    
    % Seasonal irradiance variation
    if month >= 5 && month <= 9  % Summer (May-Sep)
        daily_avg_irradiance = irradiance_summer * 1000;  % W/m²
        ambient_temp = avg_temp_summer;
    elseif month == 12 || month <= 2  % Winter (Dec-Feb)
        daily_avg_irradiance = irradiance_winter * 1000;  % W/m²
        ambient_temp = avg_temp_winter;
    else  % Spring/Autumn
        daily_avg_irradiance = irradiance_spring_autumn * 1000;  % W/m²
        ambient_temp = avg_temp_annual;
    end
    
    % Daily solar profile (sinusoidal approximation)
    % Peak at solar noon (hour 12), zero at night (before 6 and after 18)
    if hour_of_day >= 6 && hour_of_day <= 18
        % Sinusoidal curve from sunrise to sunset
        solar_angle = (hour_of_day - 6) * pi / 12;  % 0 to π over 12 hours
        solar_irradiance(h) = daily_avg_irradiance / 8 * sin(solar_angle);  % Peak = daily_avg/8
    else
        solar_irradiance(h) = 0;  % Night time
    end
    
    % Add random variability (cloud cover, weather)
    solar_irradiance(h) = solar_irradiance(h) * (0.7 + 0.3 * rand());
    
    % Panel temperature (affects efficiency)
    % T_panel = T_ambient + (NOCT - 20) / 800 × Irradiance
    NOCT = 45;  % Nominal Operating Cell Temperature (°C)
    solar_temp(h) = ambient_temp + (NOCT - 20) / 800 * solar_irradiance(h);
end

fprintf('  Annual Average Irradiance: %.0f W/m²\n', mean(solar_irradiance));
fprintf('  Peak Irradiance: %.0f W/m²\n', max(solar_irradiance));
fprintf('  Average Panel Temperature: %.1f°C\n\n', mean(solar_temp));

%% ========================================================================
% WIND SPEED MODEL
% ========================================================================
fprintf('Generating Wind Speed Data...\n');

wind_speed = zeros(1, hours_per_year);  % m/s

for h = 1:hours_per_year
    month = find(h > month_start_hours, 1, 'last');
    
    % Seasonal wind speed variation
    if month >= 5 && month <= 9  % Summer
        avg_speed = wind_speed_summer;
    elseif month == 12 || month <= 2  % Winter
        avg_speed = wind_speed_winter;
    else  % Spring/Autumn
        avg_speed = wind_speed_spring_autumn;
    end
    
    % Weibull distribution approximation (k=2 shape parameter)
    % Use random variation around average
    wind_speed(h) = avg_speed * (0.5 + rand());
    
    % Ensure within reasonable bounds
    wind_speed(h) = max(0, min(wind_speed(h), 25));
end

fprintf('  Annual Average Wind Speed: %.2f m/s\n', mean(wind_speed));
fprintf('  Max Wind Speed: %.2f m/s\n\n', max(wind_speed));

%% ========================================================================
% LOAD DEMAND MODEL
% ========================================================================
fprintf('Generating Load Demand Data...\n');

load_demand = zeros(1, hours_per_year);  % kW

for h = 1:hours_per_year
    month = find(h > month_start_hours, 1, 'last');
    hour_of_day = mod(h-1, 24);
    
    % Seasonal load profile
    if month >= 5 && month <= 9  % Summer
        daily_profile = load_summer;
    else  % Winter
        daily_profile = load_winter;
    end
    
    load_demand(h) = daily_profile(hour_of_day + 1);
    
    % Add random variation (±10%)
    load_demand(h) = load_demand(h) * (0.9 + 0.2 * rand());
end

fprintf('  Annual Average Load: %.1f kW\n', mean(load_demand));
fprintf('  Peak Load: %.1f kW\n', max(load_demand));
fprintf('  Total Annual Energy Demand: %.0f MWh\n\n', sum(load_demand) / 1000);

%% ========================================================================
% RENEWABLE ENERGY GENERATION
% ========================================================================
fprintf('Calculating Renewable Energy Generation...\n');

% Solar PV Generation
PV_power = zeros(1, hours_per_year);  % kW

for h = 1:hours_per_year
    % PV power output with temperature correction
    temp_factor = 1 + PV_temperature_coeff * (solar_temp(h) - 25);
    
    % P_PV = Irradiance × Area × Efficiency × Temp_factor × (1 - System_losses)
    PV_power(h) = solar_irradiance(h) * PV_area * PV_efficiency * temp_factor * ...
                  (1 - PV_system_losses) / 1000;  % Convert to kW
    
    % Inverter clipping at rated capacity
    PV_power(h) = min(PV_power(h), PV_capacity);
end

fprintf('  Solar PV:\n');
fprintf('    Annual Energy: %.0f MWh\n', sum(PV_power) / 1000);
fprintf('    Capacity Factor: %.1f%%\n', mean(PV_power) / PV_capacity * 100);
fprintf('    Peak Output: %.1f kW\n\n', max(PV_power));

% Wind Turbine Generation
wind_power = zeros(1, hours_per_year);  % kW

for h = 1:hours_per_year
    v = wind_speed(h);  % m/s
    
    % Power curve for small wind turbine
    if v < turbine_cut_in_speed
        % Below cut-in: no power
        P_turbine = 0;
    elseif v >= turbine_cut_in_speed && v < turbine_rated_speed
        % Between cut-in and rated: cubic relationship
        % P = 0.5 × ρ × A × v³ × Cp × η
        % Simplified: Linear ramp from 0 to rated power
        P_turbine = turbine_rated_power * ((v - turbine_cut_in_speed) / ...
                    (turbine_rated_speed - turbine_cut_in_speed))^3;
    elseif v >= turbine_rated_speed && v < turbine_cut_out_speed
        % Rated power region
        P_turbine = turbine_rated_power;
    else
        % Above cut-out: turbine shuts down for safety
        P_turbine = 0;
    end
    
    % Total power from all turbines with altitude correction
    altitude_factor = air_density_altitude / air_density_sea_level;
    wind_power(h) = num_turbines * P_turbine * altitude_factor;
end

fprintf('  Wind Turbines:\n');
fprintf('    Annual Energy: %.0f MWh\n', sum(wind_power) / 1000);
fprintf('    Capacity Factor: %.1f%%\n', mean(wind_power) / wind_capacity * 100);
fprintf('    Peak Output: %.1f kW\n\n', max(wind_power));

% Total Renewable Generation
renewable_power = PV_power + wind_power;

fprintf('  Total Renewable:\n');
fprintf('    Annual Energy: %.0f MWh\n', sum(renewable_power) / 1000);
fprintf('    Peak Combined Output: %.1f kW\n\n', max(renewable_power));

%% ========================================================================
% BATTERY AND DIESEL DISPATCH SIMULATION
% ========================================================================
fprintf('Simulating Energy Management System...\n');

% Initialize arrays
battery_SOC = zeros(1, hours_per_year);  % State of Charge (0-1)
battery_power = zeros(1, hours_per_year);  % kW (positive = discharge, negative = charge)
diesel_power = zeros(1, hours_per_year);  % kW
load_shed = zeros(1, hours_per_year);  % kW (load not served)
curtailment = zeros(1, hours_per_year);  % kW (renewable energy wasted)

% Initial battery SOC
battery_SOC(1) = 0.50;  % Start at 50% charge

for h = 1:hours_per_year
    % Energy balance: Generation - Load
    net_power = renewable_power(h) - load_demand(h);  % kW
    
    if net_power > 0
        % Surplus power: charge battery or curtail
        
        % Calculate available battery charge capacity
        SOC_current = battery_SOC(max(1, h-1));
        available_charge_capacity = battery_capacity * (1 - SOC_current);  % kWh
        max_charge_power = battery_capacity * battery_charge_rate;  % kW
        
        % Charge battery at maximum rate or available surplus
        charge_power = min([net_power, max_charge_power, available_charge_capacity / dt]);
        
        battery_power(h) = -charge_power;  % Negative for charge
        curtailment(h) = max(0, net_power - charge_power);
        diesel_power(h) = 0;
        load_shed(h) = 0;
        
        % Update battery SOC
        energy_charged = charge_power * dt * battery_efficiency_rt;  % kWh
        battery_SOC(h) = min(1.0, SOC_current + energy_charged / battery_capacity);
        
    else
        % Deficit power: discharge battery or use diesel
        
        deficit = abs(net_power);  % kW needed
        SOC_current = battery_SOC(max(1, h-1));
        
        % Calculate available battery discharge capacity
        available_discharge_energy = (SOC_current - (1 - battery_DOD_max)) * battery_capacity;  % kWh
        max_discharge_power = battery_capacity * battery_discharge_rate;  % kW
        
        % Try to meet deficit from battery first
        discharge_power = min([deficit, max_discharge_power, available_discharge_energy / dt]);
        
        battery_power(h) = discharge_power;  % Positive for discharge
        remaining_deficit = deficit - discharge_power;
        
        % Update battery SOC
        energy_discharged = discharge_power * dt / battery_efficiency_rt;  % kWh
        battery_SOC(h) = max(0, SOC_current - energy_discharged / battery_capacity);
        
        % If battery cannot meet full deficit, use diesel generator
        if remaining_deficit > 1.0  % 1 kW threshold
            % Diesel operates at 75% of capacity for efficiency
            diesel_output = min(remaining_deficit, diesel_capacity * 0.75);
            diesel_power(h) = diesel_output;
            remaining_deficit = remaining_deficit - diesel_output;
        else
            diesel_power(h) = 0;
        end
        
        % If still deficit, shed load (blackout)
        if remaining_deficit > 0.1
            load_shed(h) = remaining_deficit;
        else
            load_shed(h) = 0;
        end
        
        curtailment(h) = 0;
    end
end

fprintf('  Battery Performance:\n');
fprintf('    Annual Cycles: %.0f (at 80%% DOD)\n', sum(abs(battery_power)) / (2 * battery_capacity * battery_DOD_max));
fprintf('    Energy Throughput: %.0f MWh\n', sum(abs(battery_power)) / 1000);
fprintf('    Average SOC: %.1f%%\n', mean(battery_SOC) * 100);
fprintf('    Min SOC: %.1f%%\n\n', min(battery_SOC) * 100);

fprintf('  Diesel Generator:\n');
fprintf('    Operating Hours: %.0f hours\n', sum(diesel_power > 0));
fprintf('    Annual Energy: %.0f MWh\n', sum(diesel_power) / 1000);
fprintf('    Fuel Consumption: %.0f liters\n', sum(diesel_power) * diesel_fuel_consumption);
fprintf('    Capacity Factor: %.1f%%\n\n', mean(diesel_power) / diesel_capacity * 100);

fprintf('  System Reliability:\n');
fprintf('    Load Shed Events: %.0f hours\n', sum(load_shed > 0));
fprintf('    Total Energy Not Served: %.2f MWh (%.3f%% of demand)\n', ...
        sum(load_shed) / 1000, sum(load_shed) / sum(load_demand) * 100);
fprintf('    System Availability: %.2f%%\n\n', (1 - sum(load_shed > 0) / hours_per_year) * 100);

fprintf('  Renewable Energy Utilization:\n');
fprintf('    Renewable Energy Produced: %.0f MWh\n', sum(renewable_power) / 1000);
fprintf('    Curtailment: %.1f MWh (%.1f%% of renewable)\n', ...
        sum(curtailment) / 1000, sum(curtailment) / sum(renewable_power) * 100);
fprintf('    Renewable Fraction: %.1f%% (of total supply)\n\n', ...
        sum(renewable_power) / (sum(renewable_power) + sum(diesel_power)) * 100);

%% ========================================================================
% ECONOMIC ANALYSIS
% ========================================================================
fprintf('Performing Economic Analysis...\n');

% Capital Costs (CAPEX)
PV_cost_per_kW = 1000;  % USD/kW (2024 pricing)
wind_cost_per_kW = 2500;  % USD/kW (small turbines more expensive)
battery_cost_per_kWh = 400;  % USD/kWh (Lithium-ion)
inverter_cost = 150 * 200;  % 200 kW inverter @ 150 USD/kW
balance_of_system = 50000;  % USD (wiring, structures, installation)

CAPEX_PV = PV_capacity * PV_cost_per_kW;
CAPEX_wind = wind_capacity * wind_cost_per_kW;
CAPEX_battery = battery_capacity * battery_cost_per_kWh;
CAPEX_total = CAPEX_PV + CAPEX_wind + CAPEX_battery + inverter_cost + balance_of_system;

fprintf('  Capital Costs (CAPEX):\n');
fprintf('    Solar PV: $%.0f\n', CAPEX_PV);
fprintf('    Wind Turbines: $%.0f\n', CAPEX_wind);
fprintf('    Battery Storage: $%.0f\n', CAPEX_battery);
fprintf('    Inverter: $%.0f\n', inverter_cost);
fprintf('    Balance of System: $%.0f\n', balance_of_system);
fprintf('    TOTAL CAPEX: $%.0f\n\n', CAPEX_total);

% Operating Costs (OPEX)
diesel_fuel_annual = sum(diesel_power) * diesel_fuel_consumption;  % liters
diesel_fuel_cost_annual = diesel_fuel_annual * diesel_fuel_cost;  % USD

PV_OM_cost = PV_capacity * 20;  % $20/kW/year
wind_OM_cost = wind_capacity * 50;  % $50/kW/year
battery_OM_cost = battery_capacity * 10;  % $10/kWh/year

OPEX_annual = diesel_fuel_cost_annual + PV_OM_cost + wind_OM_cost + battery_OM_cost;

fprintf('  Annual Operating Costs (OPEX):\n');
fprintf('    Diesel Fuel: $%.0f\n', diesel_fuel_cost_annual);
fprintf('    PV O&M: $%.0f\n', PV_OM_cost);
fprintf('    Wind O&M: $%.0f\n', wind_OM_cost);
fprintf('    Battery O&M: $%.0f\n', battery_OM_cost);
fprintf('    TOTAL OPEX: $%.0f/year\n\n', OPEX_annual);

% Diesel-Only Baseline (for comparison)
diesel_only_energy = sum(load_demand) / 1000;  % MWh
diesel_only_fuel = diesel_only_energy * 1000 * diesel_fuel_consumption;  % liters
diesel_only_cost_annual = diesel_only_fuel * diesel_fuel_cost;

fprintf('  Diesel-Only Baseline:\n');
fprintf('    Annual Fuel Consumption: %.0f liters\n', diesel_only_fuel);
fprintf('    Annual Fuel Cost: $%.0f\n', diesel_only_cost_annual);
fprintf('    Fuel Cost Reduction: $%.0f/year (%.1f%%)\n\n', ...
        diesel_only_cost_annual - diesel_fuel_cost_annual, ...
        (1 - diesel_fuel_cost_annual / diesel_only_cost_annual) * 100);

% Payback Period Calculation
annual_savings = diesel_only_cost_annual - OPEX_annual;
simple_payback = CAPEX_total / annual_savings;

fprintf('  Financial Metrics:\n');
fprintf('    Annual Savings: $%.0f\n', annual_savings);
fprintf('    Simple Payback Period: %.1f years\n', simple_payback);

% Net Present Value (NPV) calculation (20-year lifetime, 8% discount rate)
discount_rate = 0.08;
lifetime_years = 20;
NPV = -CAPEX_total;
for year = 1:lifetime_years
    NPV = NPV + annual_savings / (1 + discount_rate)^year;
end
fprintf('    Net Present Value (20 years, 8%% discount): $%.0f\n\n', NPV);

%% ========================================================================
% ENVIRONMENTAL ANALYSIS
% ========================================================================
fprintf('Performing Environmental Analysis...\n');

% CO2 Emissions
CO2_hybrid = diesel_fuel_annual * diesel_CO2_emission;  % kg CO2
CO2_diesel_only = diesel_only_fuel * diesel_CO2_emission;  % kg CO2
CO2_avoided = CO2_diesel_only - CO2_hybrid;  % kg CO2

fprintf('  CO2 Emissions:\n');
fprintf('    Hybrid System: %.1f tonnes CO2/year\n', CO2_hybrid / 1000);
fprintf('    Diesel-Only: %.1f tonnes CO2/year\n', CO2_diesel_only / 1000);
fprintf('    Emissions Avoided: %.1f tonnes CO2/year (%.1f%% reduction)\n\n', ...
        CO2_avoided / 1000, (1 - CO2_hybrid / CO2_diesel_only) * 100);

fprintf('  Environmental Benefits (20-year lifetime):\n');
fprintf('    Total CO2 Avoided: %.0f tonnes\n', CO2_avoided * lifetime_years / 1000);
fprintf('    Equivalent to: %.0f acres of forest\n', CO2_avoided * lifetime_years / 1000 / 0.84);
fprintf('    Or: %.0f cars off the road for 1 year\n\n', CO2_avoided * lifetime_years / 1000 / 4.6);

%% ========================================================================
% VISUALIZATION
% ========================================================================
fprintf('Generating Visualizations...\n');

% Figure 1: One Week Sample (Summer)
sample_start = 120 * 24;  % May 1st
sample_hours = 7 * 24;  % One week
sample_time = time_hours(sample_start:(sample_start + sample_hours - 1));
sample_idx = sample_start:(sample_start + sample_hours - 1);

figure('Name', 'One Week Operation (Summer)', 'Position', [100, 100, 1400, 800]);

subplot(3, 1, 1);
area(sample_time, [PV_power(sample_idx)', wind_power(sample_idx)', diesel_power(sample_idx)']);
hold on;
plot(sample_time, load_demand(sample_idx), 'k-', 'LineWidth', 2);
grid on;
legend('Solar PV', 'Wind', 'Diesel', 'Load Demand', 'Location', 'northwest');
xlabel('Hour of Year');
ylabel('Power (kW)');
title('Hybrid DER System - One Week Operation (May)');
ylim([0 150]);

subplot(3, 1, 2);
plot(sample_time, battery_SOC(sample_idx) * 100, 'b-', 'LineWidth', 2);
hold on;
plot([sample_time(1) sample_time(end)], [20 20], 'r--', 'LineWidth', 1);
grid on;
legend('Battery SOC', 'Min SOC (20%)', 'Location', 'northwest');
xlabel('Hour of Year');
ylabel('State of Charge (%)');
title('Battery State of Charge');
ylim([0 100]);

subplot(3, 1, 3);
bar(sample_time, battery_power(sample_idx), 'FaceColor', [0.3 0.7 0.3]);
grid on;
xlabel('Hour of Year');
ylabel('Battery Power (kW)');
title('Battery Charge/Discharge (Positive = Discharge, Negative = Charge)');

saveas(gcf, 'Problem4_One_Week_Operation.png');
fprintf('  Saved: Problem4_One_Week_Operation.png\n');

% Figure 2: Monthly Energy Balance
monthly_PV = zeros(1, 12);
monthly_wind = zeros(1, 12);
monthly_diesel = zeros(1, 12);
monthly_load = zeros(1, 12);

for month = 1:12
    month_start = month_start_hours(month) + 1;
    month_end = month_start + hours_per_month(month) - 1;
    
    monthly_PV(month) = sum(PV_power(month_start:month_end)) / 1000;
    monthly_wind(month) = sum(wind_power(month_start:month_end)) / 1000;
    monthly_diesel(month) = sum(diesel_power(month_start:month_end)) / 1000;
    monthly_load(month) = sum(load_demand(month_start:month_end)) / 1000;
end

figure('Name', 'Monthly Energy Balance', 'Position', [100, 100, 1200, 600]);
months = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
bar(1:12, [monthly_PV', monthly_wind', monthly_diesel'], 'stacked');
hold on;
plot(1:12, monthly_load, 'k-o', 'LineWidth', 2, 'MarkerSize', 8);
grid on;
legend('Solar PV', 'Wind', 'Diesel', 'Load Demand', 'Location', 'northwest');
xlabel('Month');
ylabel('Energy (MWh)');
title('Monthly Energy Balance - Hybrid DER System');
set(gca, 'XTickLabel', months);

saveas(gcf, 'Problem4_Monthly_Energy_Balance.png');
fprintf('  Saved: Problem4_Monthly_Energy_Balance.png\n');

% Figure 3: System Performance Metrics
figure('Name', 'Annual Performance Summary', 'Position', [100, 100, 1000, 700]);

subplot(2, 2, 1);
pie([sum(PV_power), sum(wind_power), sum(diesel_power)], ...
    {'Solar PV', 'Wind', 'Diesel'});
title('Annual Energy Generation by Source');

subplot(2, 2, 2);
diesel_hours = sum(diesel_power > 0);
renewable_hours = hours_per_year - diesel_hours;
pie([renewable_hours, diesel_hours], ...
    {sprintf('100%% Renewable\n%.0f hrs', renewable_hours), ...
     sprintf('Diesel Assist\n%.0f hrs', diesel_hours)});
title('Operating Hours Distribution');

subplot(2, 2, 3);
bar([CAPEX_PV, CAPEX_wind, CAPEX_battery, inverter_cost, balance_of_system] / 1000);
set(gca, 'XTickLabel', {'Solar', 'Wind', 'Battery', 'Inverter', 'BOS'});
ylabel('Cost ($1000)');
title('Capital Cost Breakdown');
grid on;

subplot(2, 2, 4);
emissions_data = [CO2_diesel_only, CO2_hybrid] / 1000;
bar(emissions_data);
set(gca, 'XTickLabel', {'Diesel-Only', 'Hybrid System'});
ylabel('Annual CO2 (tonnes)');
title('CO2 Emissions Comparison');
grid on;

saveas(gcf, 'Problem4_Performance_Summary.png');
fprintf('  Saved: Problem4_Performance_Summary.png\n\n');

%% ========================================================================
% FINAL SUMMARY
% ========================================================================
fprintf('====================================================================\n');
fprintf('   SIMULATION COMPLETE\n');
fprintf('====================================================================\n\n');

fprintf('KEY RESULTS SUMMARY:\n');
fprintf('--------------------\n');
fprintf('Energy Performance:\n');
fprintf('  - Renewable Energy Fraction: %.1f%%\n', sum(renewable_power) / (sum(renewable_power) + sum(diesel_power)) * 100);
fprintf('  - Diesel Fuel Reduction: %.1f%% (vs diesel-only)\n', (1 - diesel_fuel_annual / diesel_only_fuel) * 100);
fprintf('  - System Reliability: %.2f%%\n', (1 - sum(load_shed > 0) / hours_per_year) * 100);
fprintf('\n');
fprintf('Economic Performance:\n');
fprintf('  - Total Investment: $%.0f\n', CAPEX_total);
fprintf('  - Annual Savings: $%.0f\n', annual_savings);
fprintf('  - Payback Period: %.1f years\n', simple_payback);
fprintf('  - NPV (20 years): $%.0f\n', NPV);
fprintf('\n');
fprintf('Environmental Impact:\n');
fprintf('  - Annual CO2 Reduction: %.0f tonnes\n', CO2_avoided / 1000);
fprintf('  - 20-year CO2 Avoided: %.0f tonnes\n', CO2_avoided * lifetime_years / 1000);
fprintf('\n');
fprintf('Component Utilization:\n');
fprintf('  - Solar Capacity Factor: %.1f%%\n', mean(PV_power) / PV_capacity * 100);
fprintf('  - Wind Capacity Factor: %.1f%%\n', mean(wind_power) / wind_capacity * 100);
fprintf('  - Battery Annual Cycles: %.0f\n', sum(abs(battery_power)) / (2 * battery_capacity * battery_DOD_max));
fprintf('  - Diesel Operating Hours: %.0f (%.1f%% of year)\n', sum(diesel_power > 0), sum(diesel_power > 0) / hours_per_year * 100);
fprintf('\n');

fprintf('All simulation data saved to Problem4_Simulation_Results.mat\n');
save('Problem4_Simulation_Results.mat');

fprintf('\nNext: Write comprehensive technical report for Problem 4.\n');
