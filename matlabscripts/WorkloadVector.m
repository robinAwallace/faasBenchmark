folder = "/home/robin/Documents/university/exjobb/data/increasingWorkload";
if ~exist('./images/workload/vector', 'dir')
   mkdir('./images/workload/vector')
end
frameworks=["openfaas","kubeless"]; %
pass = @(x) x;
boxplotFun = @(x) {x};

t = 12:20;
testValues=2.^t;

functionName = "vector";
n = 100;

height=1;%ceil(length(replications))
width=1;

fig=figure('visible','off');
tileFigure=tiledlayout(height,width); % Requires R2019b or later

extract = @(fileName) extractDataFromCSVOK(fileName,1,1,'auto');
boxPlotLimit = @(values,tests,frameworks) boxPlot(values,tests,frameworks,[0 inf],n); % 12 2.2

workloadPlot(folder,frameworks,functionName,testValues,extract,boxplotFun,boxPlotLimit);
title(tileFigure,'Boxplot response time (Vector)')
xlabel(tileFigure,'Vector size (n)')
ylabel(tileFigure,'Response time (s)')
fig.Position = [0,0,1024,1024];
tileFigure.OuterPosition = [0.0 0.0 1 1];
legend('boxoff');
lgd = legend(frameworks);
lgd.NumColumns = length(frameworks);
lgd.Layout.Tile = 'south';
exportgraphics(tileFigure,'./images/workload/vector/reponseTime.png')
exportgraphics(tileFigure,'./images/workload/vector/reponseTime.pdf','ContentType','vector')

frameworks=["openfaas","kubeless","fission"]; %

fig=figure('visible','off');
tileFigure=tiledlayout(height,width); % Requires R2019b or later

extract = @(fileName) extractDataFromCSVOK(fileName,1,1,'auto');
boxPlotLimit = @(values,tests,frameworks) boxPlot(values,tests,frameworks,[0 inf],n); % 12 2.2

workloadPlot(folder,frameworks,functionName,testValues,extract,boxplotFun,boxPlotLimit);
title(tileFigure,'Boxplot response time (Vector)')
xlabel(tileFigure,'Vector size (n)')
ylabel(tileFigure,'Response time (s)')
fig.Position = [0,0,1024,1024];
tileFigure.OuterPosition = [0.0 0.0 1 1];
legend('boxoff');
lgd = legend(frameworks);
lgd.NumColumns = length(frameworks);
lgd.Layout.Tile = 'south';
exportgraphics(tileFigure,'./images/workload/vector/reponseTime-fission.png')
exportgraphics(tileFigure,'./images/workload/vector/reponseTime-fission.pdf','ContentType','vector')


% cpu
fig=figure('visible','off');
tileFigure=tiledlayout(height,width); % Requires R2019b or later

functionNameCPU = strcat(functionName,"_cpu");
extract = @(fileName) extractDataFromCSV(fileName,2,1000,'%s%f%s');
barPlotLimit = @(values,tests,frameworks) barPlot(values,tests,frameworks,[0 100]);
workloadPlot(folder,frameworks,functionNameCPU,testValues,extract,@max,barPlotLimit);

title(tileFigure,'The max cpu usage for frameworks')
xlabel(tileFigure,'Vector size (n)')
ylabel(tileFigure,'Millicpu')
fig.Position = [0,0,1024,360];
tileFigure.OuterPosition = [0.0 0.0 1 1];
legend('boxoff');
lgd = legend(frameworks);
lgd.NumColumns = length(frameworks);
lgd.Layout.Tile = 'south';
exportgraphics(tileFigure,'./images/workload/vector/maxCpu.png')
exportgraphics(tileFigure,'./images/workload/vector/maxCpu.pdf','ContentType','vector')

% Memory
fig=figure('visible','off');
tileFigure=tiledlayout(height,width); % Requires R2019b or later

functionNameMemory = strcat(functionName,"_memory");
extract = @(fileName) extractDataFromCSV(fileName,2,1/(1024*1024*1024),'%s%f%s');
barPlotLimit = @(values,tests,frameworks) barPlot(values,tests,frameworks,[0 0.225]);
workloadPlot(folder,frameworks,functionNameMemory,testValues,extract,@max,barPlotLimit);

title(tileFigure,'The max memory usage for frameworks')
xlabel(tileFigure,'Vector size (n)')
ylabel(tileFigure,'GiB')
fig.Position = [0,0,1024,360];
tileFigure.OuterPosition = [0.0 0.0 1 1];
legend('boxoff');
lgd = legend(frameworks);
lgd.NumColumns = length(frameworks);
lgd.Layout.Tile = 'south';
exportgraphics(tileFigure,'./images/workload/vector/maxMemory.png')
exportgraphics(tileFigure,'./images/workload/vector/maxMemory.pdf','ContentType','vector')

fig=figure('visible','off');
tileFigure=tiledlayout(height,width); % Requires R2019b or later

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
% exportgraphics(tileFigure,'./images/workload/vector/successRate.png')

