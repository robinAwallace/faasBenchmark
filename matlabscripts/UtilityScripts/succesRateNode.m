function [res] = succesRateNode(folder,frameworks,replications,nodes,functionName,tests)
%TEST Summary of this function goes here
%   Detailed explanation goes here

for nNr=1:length(nodes)
    for r=1:length(replications)
        for i=1:length(frameworks)
            for t=1:length(tests)
                fileFramework=strcat(folder,"/",frameworks(i));
                nrReqFile=strcat("_",functionName,"_",string(nodes(nNr)),"_",string(replications(r)),"_",string(tests(t))); % Fix replication variable
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
                values(t,i) = value;
            end
        end
        res(nNr,r) = {values};
    end
end


