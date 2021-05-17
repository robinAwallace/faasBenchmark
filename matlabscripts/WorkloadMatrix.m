folder = "/home/robin/Documents/university/exjobb/data/increasingWorkload";
if ~exist('./images/workload/matrix', 'dir')
   mkdir('./images/workload/matrix')
end
frameworks=["openfaas","kubeless","fission"]; %
pass = @(x) x;
boxplotFun = @(x) {x};

n = 100;

height=1;%ceil(length(replications))
width=1;

%Matrix
testValues=(100:100:1000);
functionName = "matrix";


%responsetime
fig=figure('visible','off');
tileFigure=tiledlayout(height,width); % Requires R2019b or later

extract = @(fileName) extractDataFromCSVOK(fileName,1,1,'auto');
boxPlotLimit = @(values,tests,frameworks) boxPlot(values,tests,frameworks,[0 inf],n); % 12 2.2
graphPlotLimit = @(values,tests,frameworks) graphPlot(values,tests,frameworks,[0 inf]);
workloadPlot(folder,frameworks,functionName,testValues,extract,boxplotFun,boxPlotLimit);
title(tileFigure,'Boxplot response time (Matrix)')
xlabel(tileFigure,'Matrix size(M x M)')
ylabel(tileFigure,'Response time (s)')
fig.Position = [0,0,1024,1024];
tileFigure.OuterPosition = [0.0 0.0 1 1];
legend('boxoff');
lgd = legend(frameworks);
lgd.NumColumns = length(frameworks);
lgd.Layout.Tile = 'south';
exportgraphics(tileFigure,'./images/workload/matrix/reponseTime-fission.png')
exportgraphics(tileFigure,'./images/workload/matrix/reponseTime-fission.pdf','ContentType','vector')

%cpu
fig=figure('visible','off');
tileFigure=tiledlayout(height,width); % Requires R2019b or later

functionNameCPU = strcat(functionName,"_cpu");
extract = @(fileName) extractDataFromCSV(fileName,2,1000,'%s%f%s');
barPlotLimit = @(values,tests,frameworks) barPlot(values,tests,frameworks,[0 1000]);
workloadPlot(folder,frameworks,functionNameCPU,testValues,extract,@max,barPlotLimit);

title(tileFigure,'The max cpu usage for frameworks')
xlabel(tileFigure,'Matrix size(M x M)')
ylabel(tileFigure,'Millicpu')
fig.Position = [0,0,1024,360];
tileFigure.OuterPosition = [0.0 0.0 1 1];
legend('boxoff');
lgd = legend(frameworks);
lgd.NumColumns = length(frameworks);
lgd.Layout.Tile = 'south';
exportgraphics(tileFigure,'./images/workload/matrix/maxCpu.png')
exportgraphics(tileFigure,'./images/workload/matrix/maxCpu.pdf','ContentType','vector')

%Memory
fig=figure('visible','off');
tileFigure=tiledlayout(height,width); % Requires R2019b or later

functionNameMemory = strcat(functionName,"_memory");
extract = @(fileName) extractDataFromCSV(fileName,2,1/(1024*1024*1024),'%s%f%s');
barPlotLimit = @(values,tests,frameworks) barPlot(values,tests,frameworks,[0 0.25]);
workloadPlot(folder,frameworks,functionNameMemory,testValues,extract,@max,barPlotLimit);

title(tileFigure,'The max memory usage for frameworks')
xlabel(tileFigure,'Matrix size(M x M)')
ylabel(tileFigure,'GiB')
fig.Position = [0,0,1024,360];
tileFigure.OuterPosition = [0.0 0.0 1 1];
legend('boxoff');
lgd = legend(frameworks);
lgd.NumColumns = length(frameworks);
lgd.Layout.Tile = 'south';
exportgraphics(tileFigure,'./images/workload/matrix/maxMemory.png')
exportgraphics(tileFigure,'./images/workload/matrix/maxMemory.pdf','ContentType','vector')


% fig=figure('visible','off');
% tileFigure=tiledlayout(height,width); % Requires R2019b or later
% barPlotLimit = @(values,tests,frameworks) barPlot(values,tests,frameworks,[0 110]); % 12 2.2
% succesRateWorkloadPlot(folder,frameworks,functionName,testValues,n,barPlotLimit);
% title(tileFigure,'The success rate of 100 requests')
% xlabel(tileFigure,'n')
% ylabel(tileFigure,'Success in rate (%)')
% fig.Position = [0,0,1024,360];
% tileFigure.OuterPosition = [0.0 0.0 1 1];
% legend('boxoff');
% lgd = legend(frameworks);
% lgd.NumColumns = length(frameworks);
% lgd.Layout.Tile = 'south';
% exportgraphics(tileFigure,'./images/workload/matrix/successRate.png')

res = succesRateWorkload(folder,frameworks,functionName,testValues);
cHeader = frameworks; %dummy header
commaHeader = [cHeader;repmat({','},1,numel(cHeader))]; %insert commaas
commaHeader = commaHeader(:)';
textHeader = cell2mat(commaHeader); %cHeader in text with commas
%write header to file
fid = fopen('./images/workload/matrix/successRate.csv','w'); 
fprintf(fid,'%s\n',textHeader);
fclose(fid);
%write data to end of file
dlmwrite('./images/workload/matrix/successRate.csv',res,'-append');

