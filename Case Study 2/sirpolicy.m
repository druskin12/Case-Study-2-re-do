function [policy_matrix] = sirpolicy(current_policy, slird_vals)

STL_population = 2805473;   % Given in COVID_MO
plausible_vaccinate_per_day = 30000 % Taken from average of first few months of vaccination rate in STL city. 
plausible_vaccinate_per_day_fraction = plausible_vaccinate_per_day/STL_population; % Conversion of above to fraction.
threshold = plausible_vaccinate_per_day_fraction / 2; % In case neither of 
% first two conditions below are met, will be able to vaccinate all 
% remaining individuals in S and L categories since able to vaccinate 
% 30,000 individuals/day.

% From 1/13 to 4/27, STL city averaged about 37000 doses given/day, or
% 22000 fully vaccinated per day. Use value between these for moving people
% to recovered (via vaccination). Want to prioritize susceptible, then move
% on to vaccinating lockdown citizens once no more susceptible citizens.

% According to mayoclinic, herd immunity for Covid will occur when 
% approximately 70% of the population is immune. Thus, will want to keep 
% moving people to Recovered (via vaccinations) until reaches this value. 
% If herd immunity value met, maintain status quo.
if slird_vals(4) < 0.7
    % If at least about 15000 people are still in susceptible category, 
    % want to prioritize moving them to recovered over lockdown citizens.
    if slird_vals(1) >= threshold   
        current_policy(1, 4) = plausible_vaccinate_per_day/slird_vals(1); % makes S-->R values such that 30000 susceptible citizens get vaccinated this day.
    % If below threshold for remaining individuals in susceptible, check if
    % above same threshold of 15000 people in lockdown.
    elseif slird_vals(2) >= threshold
        current_policy(2, 4) = plausible_vaccinate_per_day/slird_vals(2); % makes L-->R values such that 30000 lockdown citizens get vaccinated this day.       
    % If below threshold for both of these values, vaccinate all remaining
    % un-vaccinated and un-infected individuals (since able to vaccinate
    % 30,000 per day).
    else
        current_policy(1, 4) = 1;
        current_policy(2, 4) = 1;
    end
% If herd immunity met, allow all lockdown individuals to leave lockdown,
% thus joining susceptible category. 
else
    current_policy(1, 2) = 1;
    current_policy(2, 2) = 0;
    current_policy(3, 2) = 0;
    current_policy(4, 2) = 0;
end

% Sets policy matrix using values from conditions checked above and keeping
% all other values the same. Makes sure that all columns still add up to 1.
policy_matrix = [1-current_policy(2,1)-current_policy(3,1)-current_policy(4,1)  current_policy(1,2)                                             0                                           0   0;
                 current_policy(2,1)                                            1-current_policy(1,2)-current_policy(3,2)-current_policy(4,2)   0                                           0   0;
                 current_policy(3,1)                                            current_policy(3,2)                                             1-current_policy(4,3)-current_policy(5,3)   0   0;
                 current_policy(4,1)                                            current_policy(4,2)                                             current_policy(4,3)                         1   0;
                 0                                                              0                                                               current_policy(5,3)                         0   1];

end


