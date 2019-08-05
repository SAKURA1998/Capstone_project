% tau = 20 / 34000;
% tau_diff_est = 0.7 / 34000;
% f_carrier = 20000;
% tap_num = 1 : 48 * 2 + 1;
% diff = exp(- 1i* 2* pi* f_carrier* (tau + tau_diff_est)) ...
%             * sinc((tap_num- 49)/12 - (tau + tau_diff_est)* 4000)...
%             - exp(- 1i* 2* pi* f_carrier* tau) * sinc((tap_num- 49)/12- tau* 4000);
% hold on
% plot(tap_num, abs(diff))

phase_rot = -2*pi:0.00001:2*pi;
h_d = abs(exp(-1i*phase_rot)-1);
plot(phase_rot,h_d)
