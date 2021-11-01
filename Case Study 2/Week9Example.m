%% Clean up the environment
clc;
clearvars;
close all

%% SIRD model
% x = [S; I; R; D];
A = [0.95 0.04 0 0; 0.05 0.85 0 0; 0 0.1 1 0; 0 0.01 0 1]; % Values that dictate how the linear system evolves
x0 = [1; 0; 0; 0]; % Initially everyone is susceptible

x = zeros(4,1000); % x values for 1000 days
x(:,1) = x0;
for i=2:1000
    x(:,i) = A*x(:,i-1);
end

% Plotting
figure;
plot(x(1,:));
hold on
plot(x(2,:));
plot(x(3,:));
plot(x(4,:));
legend('S','I','R','D');
xlabel('Time (days)');
ylabel('Percentage of Population');
title('SIRD (matrix multiplication)');

%% SIRD with generalized parameters
sS = 0.95; % amount of susceptible that remain susceptible
sI = 0.05; % amount of susceptible that get infected
% Susceptible people cannot become deceased or recovered without first
% being infected, so sR and sD will always be 0. No need to make variables
iS = 0.04; % amount of infected that don't gain immunity
iI = 0.85; % amount of infected that remain infected
iR = 0.1; % amount of infected that recover
iD = 0.01; % amount of infected that die
% Recovered people have immunity, so they are not susceptible, cannot
% become infected, and cannot become deceased. Therefore rR will be 1 and
% rS, rI, and rD will be 0. No variables needed. Same for deceased people.
% They stay deceased and can't become susceptible, infected, or recovered.

A = [sS iS 0 0; sI iI 0 0; 0 iR 1 0; 0 iD 0 1];
x0 = [1; 0; 0; 0];
x(:,1) = x0;
for i=2:1000
    x(:,i) = A*x(:,i-1);
end

% Plotting
figure;
plot(x(1,:));
hold on
plot(x(2,:));
plot(x(3,:));
plot(x(4,:));
legend('S','I','R','D');
xlabel('Time (days)');
ylabel('Percentage of Population');
title('SIRD (generalized variables)');

% You can change the plot by adjusting the parameter values defined above
% the A matrix. Since it's Halloween, how would you model a zombie outbreak
% where dead people could become infected?

%% State space and Lsim
% State space assumes equations of the form x(k) = Ax(k-1) + Bu, y(k) =
% Cx(k-1) + Du. x values are the values of the system state, and y values
% are the outputs. In this case, we can just output the entire state and
% none of the output, i.e., y(k) = x(k-1) + 0u. Thus C is the identity and
% D is a vector of 0s.

A = [0.95 0.04 0 0; 0.05 0.85 0 0; 0 0.1 1 0; 0 0.01 0 1]; % You can also set this using variables like in the last section
B = zeros(4,1); % There's no input, so our B matrix can just be a vector of zeros
C = eye(4);
D = zeros(4,1);
x0 = [1; 0; 0; 0];

sir = ss(A,B,C,D,1); % Setting the last argument to 1 indicates a discrete time system

tspan = 0:999; % Time from day 0 to day 999, i.e., 1000 days
u = zeros(1000,1); % u is the input. We have no input, so we can set it to 0 for each time point

y = lsim(sir,u,tspan,x0); % lsim takes in the state space representation of the system, the input (zeros in our case), the time vector, and the initial condition

figure;
plot(tspan,y);
legend('S','I','R','D');
xlabel('Time (days)');
ylabel('Percentage of Population');
title('SIRD (lsimzoom)');