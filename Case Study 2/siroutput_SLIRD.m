%% This function takes three inputs
% x - a set of parameters
% t - the number of time-steps you wish to simulate
% data - actual data that you are attempting to fit

function f = siroutput_SLIRD(x,t,data)

% set up transmission constants
k_infections = x(1);
k_fatality = x(2);
k_recover = x(3);
k_vaccine = x(4); % Vaccination rate for both susceptible and lockdown.
k_susc_lock = x(5); % Rate of people going from susceptible to lockdown.
k_lock_susc = x(6); % Rate of people going from lockdown to susceptible.

% set up initial conditions
ic_susc = x(7);
ic_lockdown = x(8);
ic_inf = x(9);
ic_rec = x(10);
ic_fatality = x(11);

% Set up SLIRD within-population transmission matrix
A = [1 - k_susc_lock - k_infections - k_vaccine              k_lock_susc                                   0                             0 0; 
    k_susc_lock                                              1 - k_lock_susc - k_infections/10 - k_vaccine 0                             0 0;
    k_infections                                             k_infections/10                               1 - k_recover - k_fatality    0 0; 
    k_vaccine                                                k_vaccine                                     k_recover                     1 0; 
    0                                                        0                                             k_fatality                    0 1];

% The next line creates a zero vector that will be used a few steps.
B = zeros(5,1);

% Set up the vector of initial conditions
x0 = [ic_susc; ic_lockdown; ic_inf; ic_rec; ic_fatality];

% simulate the SIRD model for t time-steps
sys_sir_base = ss(A,B,eye(5),zeros(5,1),1);
y = lsim(sys_sir_base,zeros(t,1),linspace(0,t-1,t),x0);

% return a "cost".  This is the quantitity that you want your model to
% minimize.  Basically, this should encapsulate the difference between your
% modeled data and the true data. Norms and distances will be useful here.
% Hint: This is a central part of this case study!  choices here will have
% a big impact!
f = norm(y(:, 1) + y(:, 2) + k_vaccine*sum(y(:, 1)) + k_vaccine*sum(y(:, 2)) - data(:, 1)) + norm(y(:, 5) - data(:, 2));
% Cost is norm(modeled susceptible + lockdown + vaccinated susceptible + vaccinated
% lockdown - actual non-case rate) + norm(modeled death rate - actual death
% rate).

end