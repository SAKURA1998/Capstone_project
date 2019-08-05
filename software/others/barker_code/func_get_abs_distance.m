function [distance] = func_get_abs_distance(alpha, h_diff_matrix, tau_diff_computed, f_carrier, ref_I)

tau = optimvar('tau', 'LowerBound', (ref_I - 49 - 5)/48000, 'UpperBound', (ref_I - 49 + 5)/48000);
a = optimvar('a', 'LowerBound', 0, 'UpperBound', 1);
tau_diff_est_1 = optimvar('tau_diff_est_1', 'LowerBound', -0.7/34000, 'UpperBound', 0.7/34000);
tau_diff_est_2 = optimvar('tau_diff_est_2', 'LowerBound', -0.7/34000, 'UpperBound', 0.7/34000);

obj = fcn2optimexpr(@func_optimize, tau, tau_diff_est_1, tau_diff_est_2, ...
    a, h_diff_matrix, f_carrier, tau_diff_computed, alpha, ref_I, 'OutputSize',[1,1]);

prob = optimproblem('Objective', obj);
x0.tau = 0.1/34000;
x0.tau_diff_est_1 = 0.3/34000;
x0.tau_diff_est_2 = 0.3/34000;
x0.a = 0.5;
sol = solve(prob, x0);
distance = sol.tau * 34000;