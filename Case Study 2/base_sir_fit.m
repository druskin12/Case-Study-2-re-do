clear
close all
load('COVIDdata.mat')

COVID_STLcity = COVID_MO([585:1178], [3:4]); % Takes the St. Louis data
% from the overall dataset.
STL_population = populations_MO{2, 2};

covidstlcity_full = double(table2array(COVID_STLcity(:,[1:2])))./STL_population;
% Creates the rates per St. Louis population.
for i = 1:594
    covidstlcity_full(i, 1) = 1 - covidstlcity_full(i, 1); % Changes the
    % case rate in the actual dataset to the non-case rate, which allows
    % for use in the cost function (as specified in the report).
end

coviddata = covidstlcity_full; % We're only analyzing the St. Louis data.
t = 594; % There's 594 available days in the St. Louis data. At first
% we want to find a model for all days, so that we can determine key points
% to split out model into different time intervals.

% The following line creates an 'anonymous' function that will return the cost (i.e., the model fitting error) given a set
% of parameters.  There are some technical reasons for setting this up in this way.
% Feel free to peruse the MATLAB help at
% https://www.mathworks.com/help/optim/ug/fmincon.html
% and see the sectiono on 'passing extra arguments'
% Basically, 'sirafun' is being set as the function siroutput (which you
% will be designing) but with t and coviddata specified.
sirafun= @(x)siroutput(x,t,coviddata);

%% set up rate and initial condition constraints
% Set A and b to impose a parameter inequality constraint of the form A*x < b
% Note that this is imposed element-wise
% If you don't want such a constraint, keep these matrices empty.
A = [0 0 1 0 0 0 0];
b = [.1]; % Recovery rate kept fluctuating to over .6 so we kept it <= .1

%% set up some fixed constraints
% Set Af and bf to impose a parameter constraint of the form Af*x = bf
% Hint: For example, the sum of the initial conditions should be
% constrained
% If you don't want such a constraint, keep these matrices empty.
Af = [0 0 0 1 1 1 1];
bf = 1; % Sum of S, I, R, D is 1.

%% set up upper and lower bound constraints
% Set upper and lower bounds on the parameters
% lb < x < ub
% here, the inequality is imposed element-wise
% If you don't want such a constraint, keep these matrices empty.
ub = [1 1 1 1 1 1 1]'; 
lb = [0 0 0 0 0 0 0]';
% Rates must be between 0 and 1.

% Specify some initial parameters for the optimizer to start from
x0 = [.005; .005; .075; (STL_population - 1)/STL_population; 1/STL_population; 0; 0]; 

% This is the key line that tries to opimize your model parameters in order to
% fit the data
% note tath you 
x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)

Y_fit = siroutput_full(x,t);
Y_fit_sub_together = zeros(594, 4); % This will be used to view the models 
% from every time interval in one graph.

figure();
subplot(1, 2, 1);
hold on;
plot(Y_fit(:, 1));
plot(covidstlcity_full(:, 1));
hold off;
legend('S','Measured Susceptible');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Susceptible and Measured Susceptible as a Function of Time");

subplot(1, 2, 2);
hold on;
plot(Y_fit(:, 4));
plot(covidstlcity_full(:, 2));
hold off;
legend('D','Measured Fatality Rate');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Fatality Rate and Measured Fatality Rate as a Function of Time");

covidstlcity_first = covidstlcity_full(1:120, :);
coviddata = covidstlcity_first; 
t = 120; % Now we only create a model for the first 120 days.

sirafun= @(x)siroutput(x,t,coviddata);

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full(x,t);

Y_fit_sub_together([1:120], :) = Y_fit(:, :);

figure();
subplot(1, 10, 1);
hold on;
plot(Y_fit(:, 1));
plot(covidstlcity_first(:, 1));
hold off;
legend('S','Measured S');
xlabel('Time');
ylabel('Population Fraction');
title("S, 1-120");

subplot(1, 10, 2);
hold on;
plot(Y_fit(:, 4));
plot(covidstlcity_first(:, 2));
hold off;
legend('D','Measured D');
xlabel('Time');
ylabel('Population Fraction');
title("D, 1-120");

covidstlcity_second = covidstlcity_full(121:240, :);
coviddata = covidstlcity_second;
t = 120; 

sirafun= @(x)siroutput(x,t,coviddata);
x0 = x; % This continues the model from where it was left off in the last
% time interval.
x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full(x,t);
Y_fit_sub_together([121:240], :) = Y_fit(:, :);

subplot(1, 10, 3);
hold on;
plot(Y_fit(:, 1));
plot(covidstlcity_second(:, 1));
hold off;
legend('S','Measured S');
xlabel('Time');
ylabel('Population Fraction');
title("S, 121-240");

subplot(1, 10, 4);
hold on;
plot(Y_fit(:, 4));
plot(covidstlcity_second(:, 2));
hold off;
legend('D','Measured D');
xlabel('Time');
ylabel('Population Fraction');
title("D, 121-240");

covidstlcity_third = covidstlcity_full(241:330, :);
coviddata = covidstlcity_third; 
t = 90; 

sirafun= @(x)siroutput(x,t,coviddata);
x0 = x;
x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full(x,t);
Y_fit_sub_together([241:330], :) = Y_fit(:, :);

subplot(1, 10, 5);
hold on;
plot(Y_fit(:, 1));
plot(covidstlcity_third(:, 1));
hold off;
legend('S','Measured S');
xlabel('Time');
ylabel('Population Fraction');
title("S, 241-330");

subplot(1, 10, 6);
hold on;
plot(Y_fit(:, 4));
plot(covidstlcity_third(:, 2));
hold off;
legend('D','Measured D');
xlabel('Time');
ylabel('Population Fraction');
title("D, 241-330");

covidstlcity_fourth = covidstlcity_full(331:500, :);
coviddata = covidstlcity_fourth; 
t = 170; 

sirafun= @(x)siroutput(x,t,coviddata);
x0 = x;
x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full(x,t);
Y_fit_sub_together([331:500], :) = Y_fit(:, :);

subplot(1, 10, 7);
hold on;
plot(Y_fit(:, 1));
plot(covidstlcity_fourth(:, 1));
hold off;
legend('S','Measured S');
xlabel('Time');
ylabel('Population Fraction');
title("S, 331-500");

subplot(1, 10, 8);
hold on;
plot(Y_fit(:, 4));
plot(covidstlcity_fourth(:, 2));
hold off;
legend('D','Measured D');
xlabel('Time');
ylabel('Population Fraction');
title("D, 331-500");

covidstlcity_fifth = covidstlcity_full(501:594, :);
coviddata = covidstlcity_fifth; % TO SPECIFY
t = 94; % TO SPECIFY

sirafun= @(x)siroutput(x,t,coviddata);
x0 = x;
x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full(x,t);
Y_fit_sub_together([501:594], :) = Y_fit(:, :);

subplot(1, 10, 9);
hold on;
plot(Y_fit(:, 1));
plot(covidstlcity_fifth(:, 1));
hold off;
legend('S','Measured S');
xlabel('Time');
ylabel('Population Fraction');
title("S, 501-594");

subplot(1, 10, 10);
hold on;
plot(Y_fit(:, 4));
plot(covidstlcity_fifth(:, 2));
hold off;
legend('D','Measured D');
xlabel('Time');
ylabel('Population Fraction');
title("D, 501-594");

figure();
subplot(1, 2, 1);
hold on;
plot(Y_fit_sub_together(:, 1)); % These two plots will show all the time
% intervals' models.
plot(covidstlcity_full(:, 1));
hold off;
legend('S','Measured Susceptible');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled and Measured Susceptible, All Models");

subplot(1, 2, 2);
hold on;
plot(Y_fit_sub_together(:, 4));
plot(covidstlcity_full(:, 2));
hold off;
legend('D','Measured Fatality Rate');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled and  Measured Fatalities, All Models");