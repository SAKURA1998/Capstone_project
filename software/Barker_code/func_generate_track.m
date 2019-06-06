function [track] = func_generate_track(path_length_two_mic)

%Let's suppose that we have a 21 inch 16:9 screen, which is 47.6cm x 26.8cm
%Then suppose that we have following microphone and speaker setting:
%               Speaker--------------------Mic
%               ------------------------------
%               ------------------------------
%               ------------------------------
%               Mic---------------------------
%Then we calculate the 2D location based on above settings
%The calculation is based on the assumption that the second peak of correlation
%is the signal reflected by the finger/hand.

width = 29.7; %cm
height = 21; %cm

track = zeros(size(path_length_two_mic, 1),2);

for frame_num = 1: size(path_length_two_mic, 1)
    a = path_length_two_mic(frame_num, 1);
    b = path_length_two_mic(frame_num, 2);
    syms x y
    eqns = [(x^2)/((a/2)^2-(height/2)^2) + (y - height/2)^2/(a/2)^2 == 1,...
                (x- width/2)^2/(b/2)^2 + (y- height)^2/((b/2)^2 - (width/2)^2) == 1];
    intersection = solve(eqns, [x, y]);
    % Find the points of intersection
    X = double(intersection.x);
    Y = double(intersection.y);
    mask = ~any(imag(X), 2) | ~any(imag(Y), 2);
    X = X(mask); Y = Y(mask);
    for i=1:2
        if(X(i,1)>0&&X(i,1)<width&&Y(i,1)>0&&Y(i,1)<height)
            track(frame_num, 1) = X(i, 1);
            track(frame_num, 2) = Y(i, 1);
        end
    end
end

figure()
plot(track(:,1),track(:,2),'-o','LineStyle', 'none')
axis([0 width 0 height])