%% Testing function:

% Table for storing SLIRD from 1/1/2021 to 10/1/2021:
model_storage = zeros(5, 274); 

% initial conditions, taken from day 301 of base_sir_fit_SLIRD (as this is 
% 1/1/2021).
model_storage(:, 1) = [0.318011318127167, 0.528477691044034, ...
    0.0195279782636173, 0.132795851123924, 0.00118716144125437]; 

%Model.mat
% A0 = [0.9751     0.01009        0         0      0;
%       0.02386    0.9889         0         0      0;
%       4.04e-06   4.04e-07       0.9481    0      0;
%       0.001002   0.001002       0.0506    1      0;
%       0          0              0.001292  0      1];
% A0 = 0.9767    0.01176          0          0          0;
%        0.02229     0.9872          0          0          0;
%       3.22e-07   3.22e-08     0.9978          0          0;
%          0.001      0.001   0.001732          1          0;
%             0          0  0.0004636          0          1];

  model =           [0.9724   0.008617          0          0          0;
      0.02556     0.9894          0          0          0;
     2.56e-07   2.56e-08     0.9857          0          0;
        0.002      0.002    0.01395          1          0;
            0          0  0.0003982          0          1];
save model;
next_A = sirpolicy(model, model_storage(:, 1));
model_storage(:, 2) = next_A * model_storage(:, 1);

for i = 3:274
    next_A = sirpolicy(next_A, model_storage(:, i-1));
    model_storage(:, i) = next_A * model_storage(:, i-1);
end


figure();
title("Given COVID-19 Data vs sirpolicy Data");
subplot(1, 2, 1);
hold on;
plot(covidstlcity_full([301:574], 1));
plot(model_storage(1, :) + model_storage(2, :));
hold off;
title("Actual Susceptible vs sirpolicy Susceptible + sirpolicy Lockdown as Functions of Time");
legend("Actual S", "sirpolicy S + sirpolicy L");
xlabel("Time (days)");
ylabel("Population fraction");

subplot(1, 2, 2);
hold on;
plot(covidstlcity_full([301:574], 2));
plot(model_storage(5, :)); 
hold off;
title("Actual Deceased vs sirpolicy Deceased as Functions of Time");
legend("Actual D", "sirpolicy D");
xlabel("Time (days)");
ylabel("Population fraction");


figure(2);
subplot(2, 3, 1);
hold on;
plot(Y_fit_sub_together([301:574], 1));
plot(model_storage(1, :));
hold off;
title("STL SLIRD Susceptible vs sirpolicy Susceptible as Functions of Time");
legend("SLIRD S", "sirpolicy S");
xlabel("Time (days)");
ylabel("Population fraction");

subplot(2, 3, 2);
hold on;
plot(Y_fit_sub_together([301:574], 2));
plot(model_storage(2, :));
hold off;
title("STL SLIRD Lockdown vs sirpolicy Lockdown as Functions of Time");
legend("SLIRD L", "sirpolicy L");
xlabel("Time (days)");
ylabel("Population fraction");

subplot(2, 3, 3);
hold on;
plot(Y_fit_sub_together([301:574], 1));
plot(model_storage(1, :));
hold off;
title("STL SLIRD Infected vs sirpolicy Infected as Functions of Time");
legend("SLIRD I", "sirpolicy I");
xlabel("Time (days)");
ylabel("Population fraction");

subplot(2, 3, 4);
hold on;
plot(Y_fit_sub_together([301:574], 4));
plot(model_storage(4, :));
hold off;
title("STL SLIRD Recovered vs sirpolicy Recovered as Functions of Time");
legend("SLIRD R", "sirpolicy R");
xlabel("Time (days)");
ylabel("Population fraction");

subplot(2, 3, 5);
hold on;
plot(Y_fit_sub_together([301:574], 5));
plot(model_storage(5, :));
hold off;
title("STL SLIRD Deceased vs sirpolicy Deceased as Functions of Time");
legend("SLIRD D", "sirpolicy D");
xlabel("Time (days)");
ylabel("Population fraction");

%%


%{
ideas:
- if recovered rate is less than some constant (probably in the range of 0.6-0.8), use some combination of 
    more lockdown and more vaccinations. Or, could keep lockdown high until recovered gets to this value. 
    The reason for this is that herd immunity is likely achieved somewhere in this range. Downside: lots of
    lost productivity during this time.
- model of TED talk idea where everyone works/goes to school for 4 days, stays home for 10, repeat. People may become
infected during these days of work but will likely recover by end of 10 day period. Downside: large wobble

Could combine these strategies. Will (most likely) largely lower covid rates but have lots of costs and wobble.


%% Part 5 --> didn't realize we had sirpolicy, so below doesn't really apply. 
intervention_model_together = zeros(594, 5);

change_L_norm = norm(Y_fit_sub_together(:, 2) - intervention_model_together(:, 2));
change_I_norm = norm(Y_fit_sub_together(:, 3) - intervention_model_together(:, 3));
change_D_norm = norm(Y_fit_sub_together(:, 5) - intervention_model_together(:, 5));
mean_rel_change_I = mean(Y_fit_sub_together(:, 3)) / mean(intervention_model_together(:, 3));
mean_rel_change_D = mean(Y_fit_sub_together(:, 5)) / mean(intervention_model_together(:, 5));

Jbenefit = 10*change_I_norm + 10*change_D_norm;  % want large
Jcosts = 100*(change_L_norm)^2 + 800*(1-lambda)*(change_I_norm)^2 + 800*(1-mean_rel_change_D)*(change_D_norm)^2; % want small

Jrelative = Jbenefit - alpha*Jcosts - Wobble;
%}

