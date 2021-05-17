function [] = replicationPlot(folder,replications,frameworks,functionName,tests,extractFromFile,fun,plot)
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
                value = extractFromFile(fileName);          
            end
            values(t,i) = fun(value);
            valuesMin(t,i) = min(value);
            valuesMax(t,i) = max(value);
        end
    end
    nexttile
    hold on
    %plot(valuesMin,tests,frameworks);
    plot(values,tests,frameworks);
    %plot(valuesMax,tests,frameworks);
    hold off
    titleName=strcat("Replication: ", string(replications(r)));
    title(titleName)
end
end

