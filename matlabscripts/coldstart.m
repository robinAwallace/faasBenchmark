dataFiles = dir('2021-04-26/coldstart/*.csv'); 
if ~exist('./images/coldstart', 'dir')
   mkdir('./images/coldstart')
end

n=length(dataFiles);
all_times=[];
for i=1:n
  filename=strcat('2021-04-26/coldstart/',dataFiles(i).name);
  T=readtable(filename);
  times = T{:,1};
  all_times(:,i)=times;
end
fig=figure('visible','on');
boxplot(all_times,'Labels',{'Fission','OpenFaaS'}) %,'Kubeless','OpenWhisk'
title('Response time, Cold start')
xlabel('Frameworks')
ylabel('Response time (s)')
%fig.Position = [0,0,1920,1024];
%fig.OuterPosition = [0.0 0.0 1 1];
exportgraphics(fig,'./images/coldstart/coldstart.png')
exportgraphics(fig,'./images/coldstart/coldstart.pdf','ContentType','vector')


dataFiles = dir('2021-04-26/coldstart/reference/*.csv'); 
n=length(dataFiles);
all_times=[];
for i=1:n
  filename=strcat('2021-04-26/coldstart/reference/',dataFiles(i).name);
  T=readtable(filename);
  times = T{:,1};
  all_times(:,i)=times;%*1000;
end

fig=figure('visible','on');
boxplot(all_times,'Labels',{'Fission','OpenFaaS'}) %,'Kubeless','OpenWhisk'
title('Response time, Reference')
xlabel('Frameworks')
ylabel('Response time (s)')
%fig.Position = [0,0,1920,1024];
%fig.OuterPosition = [0.0 0.0 1 1];
exportgraphics(fig,'./images/coldstart/coldstart-reference.png')
exportgraphics(fig,'./images/coldstart/coldstart-reference.pdf','ContentType','vector')