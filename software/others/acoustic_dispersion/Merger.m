clear;

dir_content = dir;
filenames = {dir_content.name};
current_files = filenames;
while true
  dir_content = dir;
  filenames = {dir_content.name};

  new_files = setdiff(filenames,current_files);
  if ~isempty(new_files)
    % deal with the new files
    %current_files = filenames;
    try 
    [data1,fs]=audioread('BL.wav');
    [data2,fs]=audioread('BR.wav');
    [data3,fs]=audioread('TL.wav');
    [data4,fs]=audioread('TR.wav');
    
    
    merged(1,:) = transpose(data1);
    merged(2,:) = transpose(data2);
    merged(3,:) = transpose(data3);
    merged(4,:) = transpose(data4);
     
    result = func_touch_localization(merged);
    disp(result);
    
    catch e
          e;
    end
    
    %pl1=plot(subplot(2,2,1),data1);
    %pl2=plot(subplot(2,2,2),data2);
    %pl3=plot(subplot(2,2,3),data3);
    %pl4=plot(subplot(2,2,4),data4);

    pause(0.011);
    
  else
   
  end
end