folder = "/home/robin/Documents/university/exjobb/2021-03-22/increasingClient/HighConcurrentUsers";
frameworks=["openfaas","kubeless"]; %
clients=[3000];
replications=[100];
functionName = "vector";
n = 1000;

height=2;%ceil(length(replications))
width=1;

% responsetime
fig=figure('visible','on');
tileFigure=tiledlayout(height,width); % Requires R2019b or later

extract = @(fileName) extractDataFromCSVXYOKError(fileName,8,1,1,'auto');
scatterPlotLimit = @(values,tests) scatterPlot(values,tests,[0 20.5],[0 30]);
replicationPlotOverTime(folder,replications,frameworks,functionName,clients,extract,scatterPlotLimit);
title(tileFigure,'The reponse time per request over time (3000 concurrent users, replication 100)')
xlabel(tileFigure,'Time (s)')
ylabel(tileFigure,'Response time (s)')

fig.Position = [0,0,1024,720];
tileFigure.OuterPosition = [0.0 0.0 1 1];
legend('boxoff');
lgd = legend(["OK","Error"]);
lgd.NumColumns = length(frameworks);
lgd.Layout.Tile = 'south';
exportgraphics(tileFigure,'responseTimeOverTime.png')