function [] = gatewayPlot(folder,frameworks,gateway,functionName,tests,extractFromFile,fun,plot)
%TEST Summary of this function goes here
%   Detailed explanation goes here
for t=1:length(tests)
    for i=1:length(frameworks)
        for nNr=1:length(gateway)
            fileFramework=strcat(folder,"/",frameworks(i));
            nrReqFile=strcat("_",functionName,"_",string(gateway(nNr)),"_",string(tests(t))); % Fix replication variable
            fileframeworknrReqFile=strcat(fileFramework,nrReqFile);
            fileName=strcat(fileframeworknrReqFile,".csv");

            value = extractFromFile(fileName);          

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
    plot(values,gateway,frameworks);
    %plot(valuesMax,tests,frameworks);
    hold off
    titleName=strcat("Clients: ", string(tests(t)));
    title(titleName)
end



