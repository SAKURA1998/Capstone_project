function [sound] = func_fakeSound(arrival_time, length)
%This func generate the fake sound based on the arrival_time, using barker
%code. The sound will be send to srplems.m for localization.

barker = [1 1 1 1 1 -1 -1 1 1 -1 1 -1 1];
sound = zeros(length,size(arrival_time,1));