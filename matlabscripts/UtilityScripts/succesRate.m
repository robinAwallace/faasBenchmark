function [res] = succesRate(folder,replications,frameworks,functionName,tests,numberRequests)
%TEST Summary of this function goes here
%   Detailed explanation goes here

for r=1:length(replications)
    for i=1:length(frameworks)
        for t=1:length(tests)
            fileFramework=strcat(folder,"/",frameworks(i));
            nrReqFile=strcat("_",functionName,"_",string(replications(r)),"_",string(tests(t))); % Fix replication variable
            fileframeworknrReqFile=strcat(fileFramework,nrReqFile);
            fileName=strcat(fileframeworknrReqFile,"_*.csv");
            dataFiles = dir(fileName); 
            n=length(dataFiles);
            for k=1:n
                fileNumber=strcat("_",string(k));
                fileName=strcat(fileframeworknrReqFile,fileNumber);
                fileName=strcat(fileName,".csv");
                T=readtable(fileName,'Format','auto');                
                T(T.status_code > 200,:) = [];
                value = length(T{:,1});                
            end
            values(t,i) = (value/numberRequests)*100.0;
        end
    end
    res(r) = {values};
end
end

