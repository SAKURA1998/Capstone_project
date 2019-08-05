function [output] = func_optimize(tau, tau_diff_est_1, tau_diff_est_2, ...
    a, h_diff_matrix, f_carrier, tau_diff_computed, alpha, ref_I)
%This file is for optimization to get absolute distance
%INPUTS
%tau : time delay to optimize
%tau_diff_est_1, 2, 3: to optimize
%a: amplitude change of the path to optimize
%h_diff_matrix: given
%f_carrier: given
%tau_diff_computed: given
%alpha: set to 100 by default
h_diff_matrix(2, :) = h_diff_matrix(1, :) + h_diff_matrix(2, :);
tau_diff_computed(2, 1) = tau_diff_computed(1, 1) + tau_diff_computed(2, 1);
tau_diff_est = [tau_diff_est_1; tau_diff_est_2];
output = 0;

for frame_num = 1: 2
    output = output + alpha* abs(tau_diff_est(frame_num, 1) - tau_diff_computed(frame_num, 1));
    for tap_num = (ref_I - 20): min((ref_I + 20),97) 
        output = output + (abs(h_diff_matrix(frame_num, tap_num)  ...
            - a* (exp(- 1i* 2* pi* f_carrier* (tau + tau_diff_est(frame_num, 1))) ...
            * sinc((tap_num- 49)/12 - (tau + tau_diff_est(frame_num, 1))* 4000) ...
            - exp(- 1i* 2* pi* f_carrier* tau) * sinc((tap_num- 49)/12- tau* 4000))))^2;
    end
end

% output = abs(output);