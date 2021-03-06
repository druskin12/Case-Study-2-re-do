clear
close all
load('COVIDdata.mat')

COVID_STLcity = COVID_MO([595:1178], [3:4]);
% We skip the first 10 days of the STL data because we only need the last
% 584 days for comparison.
STL_population = populations_MO{2, 2};

covidstlcity_full = double(table2array(COVID_STLcity(:,[1:2])))./STL_population;

COVID_JEFFERSONcity = COVID_MO([1:584], [3:4]);
% We take all 584 days from the Jefferson data.
JEFFERSON_population = populations_MO{1, 2};

covidjeffersoncity_full = double(table2array(COVID_JEFFERSONcity(:,[1:2])))./JEFFERSON_population;

COVID_SPRINGFIELDcity = COVID_MO([1184:1767], [3:4]);
% We skip the first 5 days of the Sprinfield data because we only need the
% last 584 days for comparison.
SPRINGFIELD_population = populations_MO{3, 2};

covidspringfieldcity_full = double(table2array(COVID_SPRINGFIELDcity(:,[1:2])))./SPRINGFIELD_population;

covid_full = [covidstlcity_full; covidjeffersoncity_full; covidspringfieldcity_full];
% Concatenates STL, Jeff, and Spring data on top of one another (with STL
% on top)

for i = 1:1752
    covid_full(i, 1) = 1 - covid_full(i, 1); % Establishes non case rate
end

covid_no_vaccine = [covid_full(1:230, :); covid_full(585:814, :); covid_full(1169:1398, :)];
coviddata = covid_no_vaccine; % Takes data from first 230 days of each region
t = 230; % We will first model the first 230 days, when there is no vaccine.

% The following line creates an 'anonymous' function that will return the cost (i.e., the model fitting error) given a set
% of parameters.  There are some technical reasons for setting this up in this way.
% Feel free to peruse the MATLAB help at
% https://www.mathworks.com/help/optim/ug/fmincon.html
% and see the sectiono on 'passing extra arguments'
% Basically, 'sirafun' is being set as the function siroutput (which you
% will be designing) but with t and coviddata specified.
sirafun= @(x)siroutput_SLIRD_Three(x,t,coviddata);

%% set up rate and initial condition constraints
% Set A and b to impose a parameter inequality constraint of the form A*x < b
% Note that this is imposed element-wise
% If you don't want such a constraint, keep these matrices empty.
A = [0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     -1 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;
     0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
b = [.03, .3, .03, 0.000001, 3, -.00015, 0.5, -.2, -.2, -.2];
% Constraints done on lockdown-susceptible movement, recovery rate,
% fatality rate, vaccine rate (no vaccines in this time period), and lockdown
% rate. These constraints are based on the sum of the 3 regions' values. 
% Also, a lower bound is set for the infection rate, an upper bound is set
% on the sum of all the transport values, and each region's susceptible
% rate must be at least .2 at all times.
%% set up some fixed constraints
% Set Af and bf to impose a parameter constraint of the form Af*x = bf
% Hint: For example, the sum of the initial conditions should be
% constrained
% If you don't want such a constraint, keep these matrices empty.
Af = [0 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
bf = [1, 1, 1];
% Ensures that S + L + I + R + D = 1 for each region
%% set up upper and lower bound constraints
% Set upper and lower bounds on the parameters
% lb < x < ub
% here, the inequality is imposed element-wise
% If you don't want such a constraint, keep these matrices empty.
ub = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]';
lb = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]';
% All rates must be between 0 and 1.
%%
% Specify some initial parameters for the optimizer to start from
x0 = [.005; .005; .05; 0; 0; 0.01; 1 - 0.75 - 1/STL_population; 0.75; 1/STL_population; 0; 0; .005; .005; .05; 0; 0; 0.01; 1 - 0.75 - 1/JEFFERSON_population; 0.75; 1/JEFFERSON_population; 0; 0; .005; .005; .05; 0; 0; 0.01; 1 - 0.75 - 1/SPRINGFIELD_population; 0.75; 1/SPRINGFIELD_population; 0; 0; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01; 0.01]; 
% Designating every initial transport entry as .01 produced the best model.

% This is the key line that tries to opimize your model parameters in order to
% fit the data
% note tath you 
options = optimoptions(@fmincon,'MaxFunctionEvaluations', 20000, 'MaxIterations', 20000);
nonlcon = [];
x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub, nonlcon, options)
% We had to increase 'MaxFunctionEvaluations' and 'MaxIterations' to allow
% fmincon to be done on such a large matrix.

%%
Y_fit = siroutput_full_SLIRD_Three(x,t); % Model for non-vaccine period is done.

figure();
subplot(1, 3, 1);
hold on;
plot(Y_fit(:, 1) + Y_fit(:, 2) + x(4)*sum(Y_fit(:, 1)) + x(4)*sum(Y_fit(:, 2)))
plot(covid_no_vaccine(1:t, 1));
plot(Y_fit(:, 6) + Y_fit(:, 7) + x(15)*sum(Y_fit(:, 6)) + x(15)*sum(Y_fit(:, 7)));
plot(covid_no_vaccine((t + 1):2*t, 1));
plot(Y_fit(:, 11) + Y_fit(:, 12) + x(26)*sum(Y_fit(:, 11)) + x(26)*sum(Y_fit(:, 12)));
plot(covid_no_vaccine((2*t + 1):3*t, 1));
hold off;
legend('Modeled STL','Measured STL', 'Modeled Jeff','Measured Jeff', 'Modeled Spring','Measured Spring');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled and Measured Non Cases, Pre-Vax");

subplot(1, 3, 2);
hold on;
plot(Y_fit(:, 5));
plot(covid_no_vaccine(1:t, 2));
plot(Y_fit(:, 10));
plot(covid_no_vaccine((t + 1):2*t, 2));
plot(Y_fit(:, 15));
plot(covid_no_vaccine((2*t + 1):3*t, 2));
hold off;
legend('D-STL','Measured D-STL', 'D-Jeff','Measured D-Jeff', 'D-Spring','Measured D-Spring');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled and Measured D, Pre-Vax");

subplot(1, 3, 3);
hold on;
plot(Y_fit(:, 2));
plot(Y_fit(:, 7));
plot(Y_fit(:, 12));
legend('L-STL', 'L-Jeff', 'L-Spring');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Lockdown Rate, Pre-Vax");

%%
covid_vaccine = [covid_full(231:584, :); covid_full(815:1168, :); covid_full(1399:1752, :)];
coviddata = covid_vaccine; % Data after vaccine
t = 354; % Model will be taken for time after vaccine.

sirafun= @(x)siroutput_SLIRD_Three(x,t,coviddata);

A = [0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 -1 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     -1 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1;
     0 0 0 0 0 0 -1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
b = [.03, .3, .03, -.006, 3, -.00015, 0.5, -.2];
% Vaccine rate per day of at least .006 is set. 
x0 = x;

% This is the key line that tries to opimize your model parameters in order to
% fit the data
% note tath you 
options = optimoptions(@fmincon,'MaxFunctionEvaluations', 200000, 'MaxIterations', 20000);
nonlcon = [];
x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub, nonlcon, options)

Y_fit = siroutput_full_SLIRD_Three(x,t);
Y_fit_sub_together([231:584], :) = Y_fit(:, :);

figure();
subplot(1, 3, 1);
hold on;
plot(Y_fit(:, 1) + Y_fit(:, 2) + x(4)*sum(Y_fit(:, 1)) + x(4)*sum(Y_fit(:, 2)))
plot(covid_vaccine(1:t, 1));
plot(Y_fit(:, 6) + Y_fit(:, 7) + x(15)*sum(Y_fit(:, 6)) + x(15)*sum(Y_fit(:, 7)));
plot(covid_vaccine((t + 1):2*t, 1));
plot(Y_fit(:, 11) + Y_fit(:, 12) + x(26)*sum(Y_fit(:, 11)) + x(26)*sum(Y_fit(:, 12)));
plot(covid_vaccine((2*t + 1):3*t, 1));
hold off;
legend('Modeled STL','Measured STL', 'Modeled Jeff','Measured Jeff', 'Modeled Spring','Measured Spring');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled and Measured Non Cases, Post-Vax");

subplot(1, 3, 2);
hold on;
plot(Y_fit(:, 5));
plot(covid_vaccine(1:t, 2));
plot(Y_fit(:, 10));
plot(covid_vaccine((t + 1):2*t, 2));
plot(Y_fit(:, 15));
plot(covid_vaccine((2*t + 1):3*t, 2));
hold off;
legend('D-STL','Measured D-STL', 'D-Jeff','Measured D-Jeff', 'D-Spring','Measured D-Spring');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled and Measured D, Post-Vax");

subplot(1, 3, 3);
hold on;
plot(Y_fit(:, 2));
plot(Y_fit(:, 7));
plot(Y_fit(:, 12));
legend('L-STL', 'L-Jeff', 'L-Spring');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Lockdown Rate, Post-Vax");