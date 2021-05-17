function [] = succesRateGatewayPlot(folder,frameworks,gateway,functionName,tests,numberRequests,plot)
%TEST Summary of this function goes here
%   Detailed explanation goes here
for nNr=1:length(gateway)
    for i=1:length(frameworks)
        for t=1:length(tests)
            fileFramework=strcat(folder,"/",frameworks(i));
            nrReqFile=strcat("_",functionName,"_",string(gateway(nNr)),"_",string(tests(t))); % Fix replication variable
            fileframeworknrReqFile=strcat(fileFramework,nrReqFile);
            fileName=strcat(fileframeworknrReqFile,".csv");
            
            T=readtable(fileName,'Format','auto');                
            T(T.status_code > 200,:) = [];
            value = length(T{:,1});          
            
            values(t,i) = (value/numberRequests)*100.0;
        end
    end
    nexttile
    hold on
    %plot(valuesMin,tests,frameworks);
    plot(values,tests,frameworks);
    %plot(valuesMax,tests,frameworks);
    hold off
    titleName=strcat("Gateway: ", string(gateway(nNr)));
    title(titleName)
end

