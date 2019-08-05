clc;
clear;
s1=serial('COM7','BaudRate',115200);
fopen(s1);
out = fscanf(s1);
vector = [];
tic
for i= 1:1:100
    out = fscanf(s1,'%f');
    vector = [vector;out];
end
toc
fclose(s1);
delete(s1);
clear s1;
if ~isempty(instrfind)
     fclose(instrfind);
      delete(instrfind);
end