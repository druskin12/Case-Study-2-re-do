clear
close all
load('COVIDdata.mat')

COVID_SPRINGFIELDcity = zeros(589,2);
COVID_SPRINGFIELDcity = COVID_MO([1179:1767], [3:4]);
SPRINGFIELD_population = populations_MO{3, 2};

covidspringfieldcity_full = double(table2array(COVID_SPRINGFIELDcity(:,[1:2])))./SPRINGFIELD_population;
for i = 1:589
    covidspringfieldcity_full(i, 1) = 1 - covidspringfieldcity_full(i, 1);
end

% Stores day-to-day changes of cases and deaths in SPRINGFIELDcity region in
% columns 1 and 2, respectively, of COVID_SPRINGFIELDcity_dayChanges.


coviddata = covidspringfieldcity_full; % TO SPECIFY
t = 589; % TO SPECIFY

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
     0 0 0 0 0 0 0 1 0 0 0;
     -1 0 0 0 0 0 0 0 0 0 0];
b = [.05, .1, .01, 0.0001, .75, -.00005];

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
x0 = [.005; .005; .075; 0; 0; 0.01; 1 - 0.75 - 1/SPRINGFIELD_population; 0.75; 1/SPRINGFIELD_population; 0; 0]; 

% This is the key line that tries to opimize your model parameters in order to
% fit the data
% note tath you 
x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)

%plot(Y);
%legend('S',L','I','R','D');
%xlabel('Time')
%%
Y_fit = siroutput_full_SLIRD(x,t);
Y_fit_sub_together = zeros(589, 5);

figure(1);
subplot(1, 3, 1);
hold on;
plot(Y_fit(:, 1) + Y_fit(:, 2) + x(4)*sum(Y_fit(:, 1)) + x(4)*sum(Y_fit(:, 2)));
plot(covidspringfieldcity_full(:, 1));
hold off;
legend('S','Measured Susceptible');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Susceptible and Measured Susceptible as a Function of Time");

subplot(1, 3, 2);
hold on;
plot(Y_fit(:, 5));
plot(covidspringfieldcity_full(:, 2));
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

covidspringfieldcity_first = covidspringfieldcity_full(1:240, :);
coviddata = covidspringfieldcity_first; % TO SPECIFY
t = 240; % TO SPECIFY
sirafun= @(x)siroutput_SLIRD(x,t,coviddata);

x0 = [.005; .005; .075; 0; 0; 0.01; 1 - 0.75 - 1/SPRINGFIELD_population; 0.75; 1/SPRINGFIELD_population; 0; 0];

x = fmincon(sirafun,x0,A,b,Af,bf,lb,ub)
Y_fit = siroutput_full_SLIRD(x,t);

Y_fit_sub_together([1:240], :) = Y_fit(:, :);

figure(2);
subplot(1, 3, 1);
hold on;
plot(Y_fit(:, 1) + Y_fit(:, 2) + x(4)*sum(Y_fit(:, 1)) + x(4)*sum(Y_fit(:, 2)));
plot(covidspringfieldcity_first(:, 1));
hold off;
legend('S','Measured Susceptible');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Susceptible and Measured Susceptible as a Function of Time");

subplot(1, 3, 2);
hold on;
plot(Y_fit(:, 5));
plot(covidspringfieldcity_first(:, 2));
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
covidspringfieldcity_third = covidspringfieldcity_full(241:589, :);
coviddata = covidspringfieldcity_third; % TO SPECIFY
t = 349; % TO SPECIFY
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
Y_fit_sub_together([241:589], :) = Y_fit(:, :);
figure(4);
subplot(1, 3, 1);
hold on;
plot(Y_fit(:, 1) + Y_fit(:, 2)+ x(4)*sum(Y_fit(:, 1)) + x(4)*sum(Y_fit(:, 2)));
plot(covidspringfieldcity_third(:, 1));
hold off;
legend('S','Measured Susceptible');
xlabel('Time');
ylabel('Population Fraction');
title("Modeled Susceptible and Measured Susceptible as a Function of Time");

subplot(1, 3, 2);
hold on;
plot(Y_fit(:, 5));
plot(covidspringfieldcity_third(:, 2));
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