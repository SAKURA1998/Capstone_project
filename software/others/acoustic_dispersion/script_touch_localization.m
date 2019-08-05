clear;

%% Just for test

load('stylus_test_data.mat');
load('stylus_global_params.mat');

cur.nData = size(test.raw.bl);
cur.idx = randperm(cur.nData(1), 1); 

cur.pos = test.pos.bl(cur.idx, :);
cur.raw = zeros(globalParams.mic.num, cur.nData(2));
for cnt = 1:globalParams.mic.num
    cur.raw(cnt, :) = test.raw.(char(globalParams.mic.idx(cnt)))(cur.idx, :);
end

tic

%% Actual localization
% == Input ==
% cur.raw: detected touchsound (double [# of microphones][length of touchsound])
% == Output ==
% result: 2D location of touch inputs
% distance: 1D distance of touch inputs from microphones
[result, distance] = func_touch_localization(cur.raw);

%% Print results
disp([' > Elapsed time: ', num2str(toc), ' sec.'])
disp([' > ', num2str(cur.idx), ': True: (', num2str(cur.pos(1)), ' ', num2str(cur.pos(2)), '), Measured: (', num2str(result(1)), ' ', num2str(result(2)) '), Error: ', num2str(norm(cur.pos - result)), ' cm']);

for cnt = 1:globalParams.mic.num
    distance(cnt, 2) = norm(cur.pos - globalParams.mic.pos(cnt, :));
end