function [detected] = func_detectEarlyPart(data, fParams, eParams, returnSize)

if ~isempty(fParams)
    filtered = filtfilt(fParams.b, fParams.a, data);
    energy = func_calcEnergy(filtered, eParams.size);    
else
    energy = func_calcEnergy(data, eParams.size);    
end

nData = size(energy, 2);
threshold = eParams.threshold * max(energy);

for cnt = 1:nData
    if energy(cnt) >= threshold
        detected = data(max(cnt - eParams.guard, 1) + (1:returnSize));
        break;
    end
end

end

