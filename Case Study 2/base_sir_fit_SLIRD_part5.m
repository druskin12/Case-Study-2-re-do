clear
close all
load('COVIDdata.mat')
% Here is an example that reads in infection and fatalities from STL City
% and loads them into a new matrix covidstlcity_full
% In addition to this, you have other matrices for the other two regions in question

COVID_STLcity = zeros(594,2);
COVID_STLcity = COVID_MO([585:1178], [3:4]);
STL_population = populations_MO{2, 2};

covidstlcity_full = double(table2array(COVID_STLcity(:,[1:2])))./STL_population;
for i = 1:594
    covidstlcity_full(i, 1) = 1 - covidstlcity_full(i, 1);
end

% Stores day-to-day changes of cases and deaths in STLcity region in
% columns 1 and 2, respectively, of COVID_STLcity_dayChanges.
COVID_STLcity_dayChanges = zeros(594, 2);

for i = 2:594
    COVID_STLcity_dayChanges(i, 1) = (COVID_STLcity{i, 1} - COVID_STLcity{i-1, 1}) / STL_population;
    COVID_STLcity_dayChanges(i, 2) = (COVID_STLcity{i, 2} - COVID_STLcity{i-1, 2}) / STL_population;
end



COVID_JEFFERSONcity = zeros(584,2);
COVID_JEFFERSONcity = COVID_MO([1:584], [3:4]);
JEFFERSON_population = populations_MO{1, 2};

covidjeffersoncity_full = double(table2array(COVID_JEFFERSONcity(:,[1:2])))./JEFFERSON_population;

% Stores day-to-day changes of cases and deaths in JEFFERSONcity region in
% columns 1 and 2, respectively, of COVID_JEFFERSONcity_dayChanges.
COVID_JEFFERSONcity_dayChanges = zeros(584, 2);

for i = 2:584
    COVID_JEFFERSONcity_dayChanges(i, 1) = (COVID_JEFFERSONcity{i, 1} - COVID_JEFFERSONcity{i-1, 1}) / JEFFERSON_population;
    COVID_JEFFERSONcity_dayChanges(i, 2) = (COVID_JEFFERSONcity{i, 2} - COVID_JEFFERSONcity{i-1, 2}) / JEFFERSON_population;
end


COVID_SPRINGFIELDcity = zeros(589,2);
COVID_SPRINGFIELDcity = COVID_MO([1179:1767], [3:4]);
SPRINGFIELD_population = populations_MO{3, 2};

covidspringfieldcity_full = double(table2array(COVID_SPRINGFIELDcity(:,[1:2])))./SPRINGFIELD_population;


% Stores day-to-day changes of cases and deaths in SPRINGFIELDcity region in
% columns 1 and 2, respectively, of COVID_SPRINGFIELDcity_dayChanges.
COVID_SPRINGFIELDcity_dayChanges = zeros(589, 2);

for i = 2:589
    COVID_SPRINGFIELDcity_dayChanges(i, 1) = (COVID_SPRINGFIELDcity{i, 1} - COVID_SPRINGFIELDcity{i-1, 1}) / SPRINGFIELD_population;
    COVID_SPRINGFIELDcity_dayChanges(i, 2) = (COVID_SPRINGFIELDcity{i, 2} - COVID_SPRINGFIELDcity{i-1, 2}) / SPRINGFIELD_population;
end



coviddata = covidstlcity_full; % TO SPECIFY
t = 594; % TO SPECIFY

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
b = [.05, .1, .01, 0.0001, .75];

%% set up some fixed constraints
% Set Af and bf to impose a parameter constraint of the form Af*x = bf
% Hint: For example, the sum of the initial conditions should be
% constrained
% If you don't want such a constraint, keep these matrices empty.
Af = [0 0 0 0 0 0 1 1 1 1 1];
bf = 1;

%% set up upper and lower bound constraints
% Set upper and lower bounds on the parameters
% lb < x < ub
% here, the inequality is imposed element-wise
% If you don't want such a constraint, keep these matrices empty.
ub = [1 1 1 1 1 1 1 1 1 1 1]';
lb = [0 0 0 0 0 0 0 0 0 0 0]';
%%
% Specify some initial parameters for the optimizer to start from
x0 = [.005; .005; .075; 0; 0; 0.01; 1 - 0.75 - 1/STL_population; 0.75; 1/STL_population; 0; 0]; 

% This is the key line that tries to opimize your model parameters in order to
% fit the data
% note tath you 
x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)

%plot(Y);
%legend('S',L','I','R','D');
%xlabel('Time')
%%
Y_fit = siroutput_full_SLIRD(x,t);
Y_fit_sub_together = zeros(594, 5);

figure(1);
subplot(1, 3, 1);
hold on;
plot(Y_fit(:, 1) + Y_fit(:, 2) + x(4)*sum(Y_fit(:, 1)) + x(4)*sum(Y_fit(:, 2)));
plot(covidstlcity_full(:, 1));
hold off;
legend('S','Measured Susceptible');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Susceptible and Measured Susceptible as a Function of Time");

subplot(1, 3, 2);
hold on;
plot(Y_fit(:, 5));
plot(covidstlcity_full(:, 2));
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
% Make some plots that illustrate your findings.
% TO ADD

covidstlcity_first = covidstlcity_full(1:120, :);
coviddata = covidstlcity_first; % TO SPECIFY
t = 120; % TO SPECIFY
sirafun= @(x)siroutput_SLIRD(x,t,coviddata);

x0 = [.005; .005; .075; 0; 0; 0.01; 1 - 0.75 - 1/STL_population; 0.75; 1/STL_population; 0; 0];

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full_SLIRD(x,t);

Y_fit_sub_together([1:120], :) = Y_fit(:, :);

figure(2);
subplot(1, 3, 1);
hold on;
plot(Y_fit(:, 1) + Y_fit(:, 2) + x(4)*sum(Y_fit(:, 1)) + x(4)*sum(Y_fit(:, 2)));
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

covidstlcity_second = covidstlcity_full(121:240, :);
coviddata = covidstlcity_second; % TO SPECIFY
t = 120; % TO SPECIFY
sirafun= @(x)siroutput_SLIRD(x,t,coviddata);

x0 = x;

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full_SLIRD(x,t);
Y_fit_sub_together([121:240], :) = Y_fit(:, :);

figure(3);
subplot(1, 3, 1);
hold on;
plot(Y_fit(:, 1) + Y_fit(:, 2)+ x(4)*sum(Y_fit(:, 1)) + x(4)*sum(Y_fit(:, 2)));
plot(covidstlcity_second(:, 1));
hold off;
legend('S','Measured Susceptible');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Susceptible and Measured Susceptible as a Function of Time");

subplot(1, 3, 2);
hold on;
plot(Y_fit(:, 5));
plot(covidstlcity_second(:, 2));
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

x0 = x;

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full_SLIRD(x,t);
Y_fit_sub_together([241:330], :) = Y_fit(:, :);
figure(4);
subplot(1, 3, 1);
hold on;
plot(Y_fit(:, 1) + Y_fit(:, 2)+ x(4)*sum(Y_fit(:, 1)) + x(4)*sum(Y_fit(:, 2)));
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
covidstlcity_fourth = covidstlcity_full(331:500, :);
coviddata = covidstlcity_fourth; % TO SPECIFY
t = 170; % TO SPECIFY
sirafun= @(x)siroutput_SLIRD(x,t,coviddata);


x0 = x;

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full_SLIRD(x,t);
Y_fit_sub_together([331:500], :) = Y_fit(:, :);
figure(5);
subplot(1, 3, 1);
hold on;
plot(Y_fit(:, 1) + Y_fit(:, 2)+ x(4)*sum(Y_fit(:, 1)) + x(4)*sum(Y_fit(:, 2)));
plot(covidstlcity_fourth(:, 1));
hold off;
legend('S','Measured Susceptible');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Susceptible and Measured Susceptible as a Function of Time");

subplot(1, 3, 2);
hold on;
plot(Y_fit(:, 5));
plot(covidstlcity_fourth(:, 2));
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
covidstlcity_fifth = covidstlcity_full(501:594, :);
coviddata = covidstlcity_fifth; % TO SPECIFY
t = 94; % TO SPECIFY
sirafun= @(x)siroutput_SLIRD(x,t,coviddata);

A = [0 0 1 0 0 0 0 0 0 0 0;
     0 0 0 0 0 0 0 1 0 0 0;
     0 0 0 0 1 1 0 0 0 0 0;
     0 1 0 0 0 0 0 0 0 0 0;
     0 0 0 -1 0 0 0 0 0 0 0];
b = [.1, .75, .1, .005, -.001];

x0 = x;

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full_SLIRD(x,t);
Y_fit_sub_together([501:594], :) = Y_fit(:, :);
figure(6);
subplot(1, 3, 1);
hold on;
plot(Y_fit(:, 1) + Y_fit(:, 2)+ x(4)*sum(Y_fit(:, 1)) + x(4)*sum(Y_fit(:, 2)));
plot(covidstlcity_fifth(:, 1));
hold off;
legend('S','Measured Susceptible');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Susceptible and Measured Susceptible as a Function of Time");

subplot(1, 3, 2);
hold on;
plot(Y_fit(:, 5));
plot(covidstlcity_fifth(:, 2));
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
figure(7);
subplot(1, 3, 1);
hold on;
plot(Y_fit_sub_together(:, 1) + Y_fit_sub_together(:, 2));
plot(covidstlcity_full(:, 1));
hold off;
legend('S','Measured Susceptible');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Susceptible and Measured Susceptible as a Function of Time");

subplot(1, 3, 2);
hold on;
plot(Y_fit_sub_together(:, 5));
plot(covidstlcity_full(:, 2));
hold off;
legend('D','Measured Fatality Rate');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Fatality Rate and Measured Fatality Rate as a Function of Time");

subplot(1, 3, 3);
plot(Y_fit_sub_together(:, 2));
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Lockdown Rate as a Function of Time");