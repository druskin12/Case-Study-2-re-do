clear
close all
load('COVIDdata.mat')
% Here is an example that reads in infection and fatalities from STL City
% and loads them into a new matrix covidstlcity_full
% In addition to this, you have other matrices for the other two regions in question

COVID_STLcity = zeros(584,2);
COVID_STLcity = COVID_MO([585:1168], [3:4]);
STL_population = populations_MO{2, 2};

covidstlcity_full = double(table2array(COVID_STLcity(:,[1:2])))./STL_population;

COVID_JEFFERSONcity = zeros(584,2);
COVID_JEFFERSONcity = COVID_MO([1:584], [3:4]);
JEFFERSON_population = populations_MO{1, 2};

covidjeffersoncity_full = double(table2array(COVID_JEFFERSONcity(:,[1:2])))./JEFFERSON_population;

COVID_SPRINGFIELDcity = zeros(584,2);
COVID_SPRINGFIELDcity = COVID_MO([1179:1762], [3:4]);
SPRINGFIELD_population = populations_MO{3, 2};

covidspringfieldcity_full = double(table2array(COVID_SPRINGFIELDcity(:,[1:2])))./SPRINGFIELD_population;

covid_full = [covidstlcity_full; covidjeffersoncity_full; covidspringfieldcity_full];

for i = 1:1752
    covid_full(i, 1) = 1 - covid_full(i, 1);
end

coviddata = covid_full; % TO SPECIFY
t = 584; % TO SPECIFY

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
     0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
b = [.15, .3, .03, .0003, 2.25, -.00015, 2.4, .05];
%% set up some fixed constraints
% Set Af and bf to impose a parameter constraint of the form Af*x = bf
% Hint: For example, the sum of the initial conditions should be
% constrained
% If you don't want such a constraint, keep these matrices empty.
Af = [0 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0;
      0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
bf = [1, 1, 1];

%% set up upper and lower bound constraints
% Set upper and lower bounds on the parameters
% lb < x < ub
% here, the inequality is imposed element-wise
% If you don't want such a constraint, keep these matrices empty.
ub = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]';
lb = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]';
%%
% Specify some initial parameters for the optimizer to start from
x0 = [.005; .005; .075; 0; 0; 0.01; 1 - 0.75 - 1/STL_population; 0.75; 1/STL_population; 0; 0; .005; .005; .075; 0; 0; 0.01; 1 - 0.75 - 1/JEFFERSON_population; 0.75; 1/JEFFERSON_population; 0; 0; .005; .005; .075; 0; 0; 0.01; 1 - 0.75 - 1/SPRINGFIELD_population; 0.75; 1/SPRINGFIELD_population; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0; 0]; 

% This is the key line that tries to opimize your model parameters in order to
% fit the data
% note tath you 
options = optimoptions(@fmincon,'MaxFunctionEvaluations', 200000);
nonlcon = [];
x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub, nonlcon, options)

%plot(Y);
%legend('S',L','I','R','D');
%xlabel('Time')
%%
Y_fit = siroutput_full_SLIRD_Three(x,t);

figure(1);
subplot(1, 3, 1);
hold on;
plot(Y_fit(:, 1) + Y_fit(:, 2) + x(4)*sum(Y_fit(:, 1)) + x(4)*sum(Y_fit(:, 2)))
plot(covid_full(1:584, 1));
plot(Y_fit(:, 6) + Y_fit(:, 7) + x(15)*sum(Y_fit(:, 6)) + x(15)*sum(Y_fit(:, 7)));
plot(covid_full(585:1168, 1));
plot(Y_fit(:, 11) + Y_fit(:, 11) + x(26)*sum(Y_fit(:, 11)) + x(15)*sum(Y_fit(:, 12)));
plot(covid_full(1169:1752, 1));
hold off;
legend('S-STL','Measured Susceptible-STL', 'S-Jeff','Measured Susceptible-Jeff', 'S-Spring','Measured Susceptible-Spring');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Susceptible and Measured Susceptible as a Function of Time");

subplot(1, 3, 2);
hold on;
plot(Y_fit(:, 5));
plot(covid_full(1:584, 2));
plot(Y_fit(:, 10));
plot(covid_full(585:1168, 2));
plot(Y_fit(:, 15));
plot(covid_full(1169:1752, 2));
hold off;
legend('D-STL','Measured Fatality Rate-STL', 'D-Jeff','Measured Fatality Rate-Jeff', 'D-Spring','Measured Fatality Rate-Spring');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Fatality Rate and Measured Fatality Rate as a Function of Time");
%%
subplot(1, 3, 3);
hold on;
plot(Y_fit(:, 2));
plot(Y_fit(:, 7));
plot(Y_fit(:, 12));
legend('L-STL', 'L-Jeff', 'L-Spring');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Lockdown Rate as a Function of Time");
%%
% Make some plots that illustrate your findings.
% TO ADD

covidstlcity_first = covid_full(1:240, :);
coviddata = covidstlcity_first; % TO SPECIFY
t = 240; % TO SPECIFY
sirafun= @(x)siroutput_SLIRD(x,t,coviddata);

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full_SLIRD(x,t);

Y_fit_sub_together([1:240], :) = Y_fit(:, :);

figure(2);
subplot(1, 3, 1);
hold on;
plot(Y_fit(1:594, 1) + Y_fit(1:594, 2) + x(4)*sum(Y_fit(1:594, 1)) + x(4)*sum(Y_fit(1:594, 2)));
plot(covidstlcity_first(:, 1));
hold off;
legend('S','Measured Susceptible');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Susceptible and Measured Susceptible as a Function of Time");

subplot(1, 3, 2);
hold on;
plot(Y_fit(:, 5));
plot(covidstlcity_first(:, 2));
hold off;
legend('D','Measured Fatality Rate');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Fatality Rate and Measured Fatality Rate as a Function of Time");

subplot(1, 3, 3);
plot(Y_fit(:, 2));
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Lockdown Rate as a Function of Time");

%%
covidstlcity_third = covidstlcity_full(241:594, :);
coviddata = covidstlcity_third; % TO SPECIFY
t = 354; % TO SPECIFY
sirafun= @(x)siroutput_SLIRD(x,t,coviddata);

A = [0 0 0 0 1 1 0 0 0 0 0;
     0 0 1 0 0 0 0 0 0 0 0;
     0 1 0 0 0 0 0 0 0 0 0;
     0 0 0 -1 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 1 0 0 0;
     -1 0 0 0 0 0 0 0 0 0 0];
b = [.05, .1, .01, -.0012, .75, -.00005];

x0 = x;

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full_SLIRD(x,t);
Y_fit_sub_together([241:594], :) = Y_fit(:, :);
figure(4);
subplot(1, 3, 1);
hold on;
plot(Y_fit(:, 1) + Y_fit(:, 2) + x(4)*sum(Y_fit(1:594, 1)) + x(4)*sum(Y_fit(1:594, 2)) + x(15)*sum(Y_fit(595:1178, 1)) + x(15)*sum(Y_fit(595:1178, 2)) + x(26)*sum(Y_fit(1178:1767, 1)) + x(26)*sum(Y_fit(1178:1767, 2)));
plot(covidstlcity_third(:, 1));
hold off;
legend('S','Measured Susceptible');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Susceptible and Measured Susceptible as a Function of Time");

subplot(1, 3, 2);
hold on;
plot(Y_fit(:, 5));
plot(covidstlcity_third(:, 2));
hold off;
legend('D','Measured Fatality Rate');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Fatality Rate and Measured Fatality Rate as a Function of Time");

subplot(1, 3, 3);
plot(Y_fit(:, 2));
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Lockdown Rate as a Function of Time");

%%
figure(3);

subplot(1, 3, 2);
plot(Y_fit_sub_together(:, 4));
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Recovery Rate");

subplot(1, 3, 3);
plot(Y_fit_sub_together(:, 2));
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Lockdown Rate");