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
t = 594; % There's 594 available days in the St. Louis data. We first will 
% find a model for all days.

% The following line creates an 'anonymous' function that will return the cost (i.e., the model fitting error) given a set
% of parameters.  There are some technical reasons for setting this up in this way.
% Feel free to peruse the MATLAB help at
% https://www.mathworks.com/help/optim/ug/fmincon.html
% and see the sectiono on 'passing extra arguments'
% Basically, 'sirafun' is being set as the function siroutput (which you
% will be designing) but with t and coviddata specified.
sirafun= @(x)siroutput_SLIRD(x,t,coviddata);

%% set up rate and initial condition constraints
% Set A and b to impose a parameter inequality constraint of the form A*x < b
% Note that this is imposed element-wise
% If you don't want such a constraint, keep these matrices empty.
A = [0 0 0 0 1 1 0 0 0 0 0;
     0 0 1 0 0 0 0 0 0 0 0;
     0 1 0 0 0 0 0 0 0 0 0;
     0 0 0 1 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 1 0 0 0];
b = [.05, .1, .01, 0.000001, .75];
% Sum of the rates of those going between S and L is < 0.05.
% Recovery rate is < 0.1.
% Fatality rate is < 0.01.
% Vaccination rate is essentially zero.
% Lockdown rate is < 0.75.

%% set up some fixed constraints
% Set Af and bf to impose a parameter constraint of the form Af*x = bf
% Hint: For example, the sum of the initial conditions should be
% constrained
% If you don't want such a constraint, keep these matrices empty.
Af = [0 0 0 0 0 0 1 1 1 1 1];
bf = 1;
% Sum of S, L, I, R, D is 1.
%% set up upper and lower bound constraints
% Set upper and lower bounds on the parameters
% lb < x < ub
% here, the inequality is imposed element-wise
% If you don't want such a constraint, keep these matrices empty.
ub = [1 1 1 1 1 1 1 1 1 1 1]';
lb = [0 0 0 0 0 0 0 0 0 0 0]';
% Rates are between 0 and 1.
%%
% Specify some initial parameters for the optimizer to start from
x0 = [.005; .005; .075; 0; 0; 0.01; 1 - 0.75 - 1/STL_population; 0.75; 1/STL_population; 0; 0]; 
% Initial lockdown rate is 0.75.

% This is the key line that tries to opimize your model parameters in order to
% fit the data
x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)

%%
Y_fit = siroutput_full_SLIRD(x,t);
Y_fit_sub_together = zeros(594, 5); % This will be used to view the models 
% from every time interval in one graph.

figure();
subplot(1, 3, 1);
hold on;
plot(Y_fit(:, 1) + Y_fit(:, 2) + x(4)*sum(Y_fit(:, 1)) + x(4)*sum(Y_fit(:, 2)));
plot(covidstlcity_full(:, 1));
hold off;
legend('Modeled Non Cases','Measured Non Cases');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Non Cases and Measured Non Cases");

subplot(1, 3, 2);
hold on;
plot(Y_fit(:, 5));
plot(covidstlcity_full(:, 2));
hold off;
legend('D','Measured Fatality Rate');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Fatality Rate and Measured Fatality Rate");

subplot(1, 3, 3);
plot(Y_fit(:, 2));
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Lockdown Rate");

covidstlcity_first = covidstlcity_full(1:120, :);
coviddata = covidstlcity_first; 
t = 120; 
sirafun= @(x)siroutput_SLIRD(x,t,coviddata);

x0 = [.005; .005; .075; 0; 0; 0.01; 1 - 0.75 - 1/STL_population; 0.75; 1/STL_population; 0; 0];

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full_SLIRD(x,t);

Y_fit_sub_together([1:120], :) = Y_fit(:, :);


covidstlcity_second = covidstlcity_full(121:240, :);
coviddata = covidstlcity_second; % TO SPECIFY
t = 120; % TO SPECIFY
sirafun= @(x)siroutput_SLIRD(x,t,coviddata);

x0 = x;

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full_SLIRD(x,t);
Y_fit_sub_together([121:240], :) = Y_fit(:, :);


covidstlcity_third = covidstlcity_full(241:330, :);
coviddata = covidstlcity_third; % TO SPECIFY
t = 90; % TO SPECIFY
sirafun= @(x)siroutput_SLIRD(x,t,coviddata);

A = [0 0 0 0 1 1 0 0 0 0 0;
     0 0 1 0 0 0 0 0 0 0 0;
     0 1 0 0 0 0 0 0 0 0 0;
     0 0 0 -1 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 1 0 0 0];
b = [.05, .1, .01, -.001, .75];
% Now the vaccination rate is set to at least .001 each day.

x0 = x;

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full_SLIRD(x,t);
Y_fit_sub_together([241:330], :) = Y_fit(:, :);


covidstlcity_fourth = covidstlcity_full(331:500, :);
coviddata = covidstlcity_fourth; 
t = 170;
sirafun= @(x)siroutput_SLIRD(x,t,coviddata);

A = [0 0 0 0 1 1 0 0 0 0 0;
     0 0 1 0 0 0 0 0 0 0 0;
     0 1 0 0 0 0 0 0 0 0 0;
     0 0 0 -1 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 1 0 0 0];
b = [.05, .1, .01, -.002, .75];
% Vaccination rate is increased to at least .002 each day, to reflect
% increasing vaccine eligibility among St. Louis population.
x0 = x;

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full_SLIRD(x,t);
Y_fit_sub_together([331:500], :) = Y_fit(:, :);


covidstlcity_fifth = covidstlcity_full(501:594, :);
coviddata = covidstlcity_fifth; 
t = 94;
sirafun= @(x)siroutput_SLIRD(x,t,coviddata);

A = [0 0 1 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 1 0 0 0;
     0 0 0 0 1 1 0 0 0 0 0;
     0 1 0 0 0 0 0 0 0 0 0;
     0 0 0 -1 0 0 0 0 0 0 0];
b = [.1, .75, .1, .005, -.001];
% Vaccination rate is lowered to at least 0.001 per day, as the rush for
% vaccines has subsided recently.

x0 = x;

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full_SLIRD(x,t);
Y_fit_sub_together([501:594], :) = Y_fit(:, :);

subplot(1, 2, 1);
hold on;
plot(Y_fit_sub_together(:, 5));
plot(covidstlcity_full(:, 2));
hold off;
legend('D','Measured D');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled and Measured Fatalities for all Models");

subplot(1, 2, 2);
plot(Y_fit_sub_together(:, 2));
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Lockdown Rate for all Models");