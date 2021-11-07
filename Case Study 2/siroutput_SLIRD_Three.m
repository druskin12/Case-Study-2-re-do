%% This function takes three inputs
% x - a set of parameters
% t - the number of time-steps you wish to simulate
% data - actual data that you are attempting to fit

function f = siroutput_SLIRD_Three(x,t,data)

% set up transmission constants
k_infections_STL = x(1);
k_fatality_STL = x(2);
k_recover_STL = x(3);
k_vaccine_STL = x(4);
k_susc_lock_STL = x(5);
k_lock_susc_STL = x(6);

k_infections_Jeff = x(12);
k_fatality_Jeff = x(13);
k_recover_Jeff = x(14);
k_vaccine_Jeff = x(15);
k_susc_lock_Jeff = x(16);
k_lock_susc_Jeff = x(17);

k_infections_Spring = x(23);
k_fatality_Spring = x(24);
k_recover_Spring = x(25);
k_vaccine_Spring = x(26);
k_susc_lock_Spring = x(27);
k_lock_susc_Spring = x(28);

k_susc_STL_Jeff = x(34);
k_lock_STL_Jeff = x(35);
k_inf_STL_Jeff = x(36);
k_rec_STL_Jeff = x(37);

k_susc_STL_Spring = x(38);
k_lock_STL_Spring = x(39);
k_inf_STL_Spring = x(40);
k_rec_STL_Spring = x(41);

k_susc_Jeff_Spring = x(42);
k_lock_Jeff_Spring = x(43);
k_inf_Jeff_Spring = x(44);
k_rec_Jeff_Spring = x(45);

% set up initial conditions
ic_susc_STL = x(7);
ic_lockdown_STL = x(8);
ic_inf_STL = x(9);
ic_rec_STL = x(10);
ic_fatality_STL = x(11);

ic_susc_Jeff = x(18);
ic_lockdown_Jeff = x(19);
ic_inf_Jeff = x(20);
ic_rec_Jeff = x(21);
ic_fatality_Jeff = x(22);

ic_susc_Spring = x(29);
ic_lockdown_Spring = x(30);
ic_inf_Spring = x(31);
ic_rec_Spring = x(32);
ic_fatality_Spring = x(33);

% Set up SLIRD within-population transmission matrix
A = [1 - k_susc_lock_STL - k_infections_STL - k_vaccine_STL - k_susc_STL_Jeff - k_susc_STL_Spring k_lock_susc_STL                                                                                  0                                                                      0                                     0 0                                                                              0                                                                                  0                                                        0                     0 0                                                               0                                                                   0                                        0 0; 
    k_susc_lock_STL                                                                               1 - k_lock_susc_STL - k_infections_STL/100 - k_vaccine_STL - k_lock_STL_Jeff - k_lock_STL_Spring 0                                                                      0                                     0 0                                                                              0                                                                                  0                                                        0                     0 0                                                               0                                                                   0                                        0 0;
    k_infections_STL                                                                              k_infections_STL/100                                                                             1 - k_recover_STL - k_fatality_STL - k_inf_STL_Jeff - k_inf_STL_Spring 0                                     0 0                                                                              0                                                                                  0                                                        0                     0 0                                                               0                                                                   0                                        0 0; 
    k_vaccine_STL                                                                                 k_vaccine_STL                                                                                    k_recover_STL                                                          1 - k_rec_STL_Jeff - k_rec_STL_Spring 0 0                                                                              0                                                                                  0                                                        0                     0 0                                                               0                                                                   0                                        0 0; 
    0                                                                                             0                                                                                                k_fatality_STL                                                         0                                     1 0                                                                              0                                                                                  0                                                        0                     0 0                                                               0                                                                   0                                        0 0;
    k_susc_STL_Jeff                                                                               0                                                                                                0                                                                      0                                     0 1 - k_susc_lock_Jeff - k_infections_Jeff - k_vaccine_Jeff - k_susc_Jeff_Spring k_lock_susc_Jeff                                                                   0                                                        0                     0 0                                                               0                                                                   0                                        0 0;
    0                                                                                             k_lock_STL_Jeff                                                                                  0                                                                      0                                     0 k_susc_lock_Jeff                                                               1 - k_lock_susc_Jeff - k_infections_Jeff/100 - k_vaccine_Jeff - k_lock_Jeff_Spring 0                                                        0                     0 0                                                               0                                                                   0                                        0 0;
    0                                                                                             0                                                                                                k_inf_STL_Jeff                                                         0                                     0 k_infections_Jeff                                                              k_infections_Jeff/100                                                              1 - k_recover_Jeff - k_fatality_Jeff - k_inf_Jeff_Spring 0                     0 0                                                               0                                                                   0                                        0 0;
    0                                                                                             0                                                                                                0                                                                      k_rec_STL_Jeff                        0 k_vaccine_Jeff                                                                 k_vaccine_Jeff                                                                     k_recover_Jeff                                           1 - k_rec_Jeff_Spring 0 0                                                               0                                                                   0                                        0 0;
    0                                                                                             0                                                                                                0                                                                      0                                     0 0                                                                              0                                                                                  k_fatality_Jeff                                          0                     1 0                                                               0                                                                   0                                        0 0;
    k_susc_STL_Spring                                                                             0                                                                                                0                                                                      0                                     0 k_susc_Jeff_Spring                                                             0                                                                                  0                                                        0                     0 1 - k_susc_lock_Spring - k_infections_Spring - k_vaccine_Spring k_lock_susc_Spring                                                  0                                        0 0;
    0                                                                                             k_lock_STL_Spring                                                                                0                                                                      0                                     0 0                                                                              k_lock_Jeff_Spring                                                                 0                                                        0                     0 k_susc_lock_Spring                                              1 - k_lock_susc_Spring - k_infections_Spring/100 - k_vaccine_Spring 0                                        0 0;
    0                                                                                             0                                                                                                k_inf_STL_Spring                                                       0                                     0 0                                                                              0                                                                                  k_inf_Jeff_Spring                                        0                     0 k_infections_Spring                                             k_infections_Spring/100                                             1 - k_recover_Spring - k_fatality_Spring 0 0;
    0                                                                                             0                                                                                                0                                                                      k_rec_STL_Spring                      0 0                                                                              0                                                                                  0                                                        k_rec_Jeff_Spring     0 k_vaccine_Spring                                                k_vaccine_Spring                                                    k_recover_Spring                         1 0;
    0                                                                                             0                                                                                                0                                                                      0                                     0 0                                                                              0                                                                                  0                                                        0                     0 0                                                               0                                                                   k_fatality_Spring                        0 1;];

% The next line creates a zero vector that will be used a few steps.
B = zeros(15,1);

% Set up the vector of initial conditions
x0 = [ic_susc_STL; ic_lockdown_STL; ic_inf_STL; ic_rec_STL; ic_fatality_STL; ic_susc_Jeff; ic_lockdown_Jeff; ic_inf_Jeff; ic_rec_Jeff; ic_fatality_Jeff; ic_susc_Spring; ic_lockdown_Spring; ic_inf_Spring; ic_rec_Spring; ic_fatality_Spring];

% simulate the SIRD model for t time-steps
sys_sir_base = ss(A,B,eye(15),zeros(15,1),1);
y = lsim(sys_sir_base,zeros(t,1),linspace(0,t-1,t),x0);

% return a "cost".  This is the quantitity that you want your model to
% minimize.  Basically, this should encapsulate the difference between your
% modeled data and the true data. Norms and distances will be useful here.
% Hint: This is a central part of this case study!  choices here will have
% a big impact!
f = norm(y(:, 1) + y(:, 2) + k_vaccine_STL*sum(y(:, 1)) + k_vaccine_STL*sum(y(:, 2)) + k_vaccine_Jeff*sum(y(:, 1)) + k_vaccine_Jeff*sum(y(:, 2)) + k_vaccine_Spring*sum(y(:, 1)) + k_vaccine_Spring*sum(y(:, 2)) - data(:, 1)) + norm(y(:, 5) - data(:, 2)); % can be one line - do based on infections and deaths

end