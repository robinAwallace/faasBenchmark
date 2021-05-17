function [res] = succesRateGateway(folder,frameworks,gateway,functionName,tests,numberRequests)
%TEST Summary of this function goes here
%   Detailed explanation goes here

for r=1:length(gateway)
    for i=1:length(frameworks)
        for t=1:length(tests)
            fileFramework=strcat(folder,"/",frameworks(i));
            nrReqFile=strcat("_",functionName,"_",string(gateway(r)),"_",string(tests(t))); % Fix replication variable
            fileframeworknrReqFile=strcat(fileFramework,nrReqFile);
            fileName=strcat(fileframeworknrReqFile,".csv");

            T=readtable(fileName,'Format','auto');                
            T(T.status_code > 200,:) = [];
            value = length(T{:,1});                
            
            values(t,i) = value;
        end
    end
    res(r) = {values};
end


