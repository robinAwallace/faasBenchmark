folder = "/home/robin/Documents/university/exjobb/data/increasingClient/HighConcurrentUsers";
if ~exist('./images/highconcurrentusers', 'dir')
   mkdir('./images/highconcurrentusers')
end

frameworks=["openfaas","kubeless"]; %
clients=[100,1000,2000,3000];
replications=[10,50,100];
functionName = "vector";
n = 10000;
pass = @(x) x;
boxplotFun = @(x) {x};

height=1;%ceil(length(replications))
width=3;

% responsetime
fig=figure('visible','on');
tileFigure=tiledlayout(height,width); % Requires R2019b or later

extract = @(fileName) extractDataFromCSVOK(fileName,1,1,'auto');
graphPlotLimit = @(values,tests,frameworks) graphPlot(values,tests,frameworks,[0 12]);
barPlotLimit = @(values,tests,frameworks) barPlot(values,tests,frameworks,[0 0.7]); % 12 2.2
boxPlotLimit = @(values,tests,frameworks) boxPlot(values,tests,frameworks,[0 20],n); % 12 2.2
replicationPlot(folder,replications,frameworks,functionName,clients,extract,boxplotFun,boxPlotLimit);
title(tileFigure,'Boxplot response time')
xlabel(tileFigure,'Concurrent users')
ylabel(tileFigure,'Response time (s)')
fig.Position = [0,0,256*width,400*height];
tileFigure.OuterPosition = [0.0 0.0 1 1];
legend('boxoff');
lgd = legend(frameworks);
lgd.NumColumns = length(frameworks);
lgd.Layout.Tile = 'south';
exportgraphics(tileFigure,'./images/highconcurrentusers/reponseTime.png')

% cpu
fig=figure('visible','on');
tileFigure=tiledlayout(height,width); % Requires R2019b or later

functionNameCPU = strcat(functionName,"_cpu");
extract = @(fileName) extractDataFromCSV(fileName,2,1000,'%s%f%s');
graphPlotLimit = @(values,tests,frameworks) graphPlot(values,tests,frameworks,[0 0.15]);
barPlotLimit = @(values,tests,frameworks) barPlot(values,tests,frameworks,[0 750]);
replicationPlot(folder,replications,frameworks,functionNameCPU,clients,extract,@max,barPlotLimit);

title(tileFigure,'The max cpu usage for frameworks')
xlabel(tileFigure,'Concurrent users')
ylabel(tileFigure,'Millicpu')
fig.Position = [0,0,256*width,400*height];
tileFigure.OuterPosition = [0.0 0.0 1 1];
legend('boxoff');
lgd = legend(frameworks);
lgd.NumColumns = length(frameworks);
lgd.Layout.Tile = 'south';
exportgraphics(tileFigure,'./images/highconcurrentusers/maxCpu.png')

% Memory
fig=figure('visible','on');
tileFigure=tiledlayout(height,width); % Requires R2019b or later

functionNameMemory = strcat(functionName,"_memory");
extract = @(fileName) extractDataFromCSV(fileName,2,1/(1024*1024*1024),'%s%f%s');
graphPlotLimit = @(values,tests,frameworks) graphPlot(values,tests,frameworks,[0 6.5]);
barPlotLimit = @(values,tests,frameworks) barPlot(values,tests,frameworks,[0 6.2]);
replicationPlot(folder,replications,frameworks,functionNameMemory,clients,extract,@max,barPlotLimit);

title(tileFigure,'The max memory usage for frameworks')
xlabel(tileFigure,'Concurrent users')
ylabel(tileFigure,'GiB')
fig.Position = [0,0,256*width,400*height];
tileFigure.OuterPosition = [0.0 0.0 1 1];
legend('boxoff');
lgd = legend(frameworks);
lgd.NumColumns = length(frameworks);
lgd.Layout.Tile = 'south';
exportgraphics(tileFigure,'./images/highconcurrentusers/maxMemory.png')

fig=figure('visible','on');
tileFigure=tiledlayout(height,width); % Requires R2019b or later

barPlotLimit = @(values,tests,frameworks) barPlot(values,tests,frameworks,[0 110]); % 12 2.2
succesRatePlot(folder,replications,frameworks,functionName,clients,n,barPlotLimit);
title(tileFigure,'The success rate of 10 000 requests')
xlabel(tileFigure,'Concurrent users')
ylabel(tileFigure,'Success in rate (%)')
fig.Position = [0,0,256*width,400*height];
tileFigure.OuterPosition = [0.0 0.0 1 1];
legend('boxoff');
lgd = legend(frameworks);
lgd.NumColumns = length(frameworks);
lgd.Layout.Tile = 'south';
exportgraphics(tileFigure,'./images/highconcurrentusers/successRate.png')


% % res = succesRate(folder,replications,frameworks,functionName,clients,n);
% % 
% % cHeader = frameworks; %dummy header
% % commaHeader = [cHeader;repmat({','},1,numel(cHeader))]; %insert commaas
% % commaHeader = commaHeader(:)';
% % textHeader = cell2mat(commaHeader); %cHeader in text with commas
% % %write header to file
% % fid = fopen('successRateIncreasingClients.csv','w'); 
% % fprintf(fid,'%s\n',textHeader);
% % fclose(fid);
% % %write data to end of file
% % dlmwrite('successRateIncreasingClients.csv',res,'-append');
