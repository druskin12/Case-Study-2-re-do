function [policy_matrix] = sirpolicy(current_policy, slird_vals)

% this function returns a new policy (for the next time step) based on the current policy and current SLIRD values
% slird_vals: a 5 dimensional vector containing the current proportion of individuals in susceptible, lockdown, infected, recovered and deceased
% current_polc: a 5x5 matrix containing the current SLIRD policy (i.e., the state transition matrix)

if slird_vals(4) <= 0.8
    



policy_matrix = [1 - k_susc_lock - k_infections - k_vaccine  k_lock_susc                                    0                             0 0; 
                 k_susc_lock                                 1 - k_lock_susc - k_infections/10 - k_vaccine  0                             0 0;
                 k_infections                                k_infections/10                                1 - k_recover - k_fatality    0 0; 
                 k_vaccine                                   k_vaccine                                      k_recover                     1 0; 
                 0                                           0                                              k_fatality                    0 1];

end

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
