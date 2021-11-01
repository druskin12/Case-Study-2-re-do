% initial conditions (i.e., values of S, I, R, D at t=0).
x0 = [0.9; 0.1; 0; 0];

% The following matrix implements the SIR dynamics example from Chapter 9.3
% of the textbook.
A = [0.95 0.04 0 0; 0.05 0.85 0 0; 0 0.1 1 0; 0 0.01 0 1];

% Initializes a 4x1000 array. Columns represent times and rows represent S,
% I, R, D, respectively. 
x = zeros(4,1000);

% Sets first column of |x| equal to the initial SIRD conditions (t=0).
x(:, 1) = x0(:);

% Fills |x| array by doing matrix mulitplication, multiplying the A matrix
% by the matrix given by the previous time's SIRD values and filling the
% current time with the result. Goes from t=0 to t=999
for i = 2:1000
    x(:, i) = A*x(:, i-1);
end

% Creates plot with all SIRD values as a function of time. 
figure;
hold on
plot(x(1, :));
plot(x(2, :));
plot(x(3, :));
plot(x(4, :));
xlabel("Time");
ylabel("Population Fraction");
title("SIRD Values as a Function of Time");
hold off
legend("S", "I", "R", "D");