function [] = nodePlot(folder,replications,frameworks,nodes,functionName,tests,extractFromFile,fun,plot)
%TEST Summary of this function goes here
%   Detailed explanation goes here
for t=1:length(tests)
    for r=1:length(replications)
        for i=1:length(frameworks)
            for nNr=1:length(nodes)
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
                    value = extractFromFile(fileName);          
                end
                if(isempty(value))
                    fileName
                end
                values(nNr,i) = fun(value);
                valuesMin(nNr,i) = min(value);
                valuesMax(nNr,i) = max(value);
            end
        end
    nexttile
    hold on
    %plot(valuesMin,tests,frameworks);
    plot(values,nodes,frameworks);
    %plot(valuesMax,tests,frameworks);
    hold off
    titleName=strcat("Replication: ", string(replications(r)), " Clients: ", string(tests(t)));
    title(titleName)
    xlabel("Cluster size (Node)")
    end
    
end



