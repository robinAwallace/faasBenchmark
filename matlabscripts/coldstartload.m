T=readtable('data/coldstartload/openfaas_sleep.csv');
%T=readtable('test1.csv');
times1 = T{:,1};
figure
hold on
yyaxis left
ylim([0 inf])
plot(times1)

T=readtable('data/coldstartload/openfaas_sleep_count.csv','Format','%s%f%s');
%T=readtable('test.csv');
count = T{:,2};
%length(times1)
x = linspace(0,length(times1),numel(count));
yyaxis right
ylim([0 21])
plot(x,count)


% data = rand(1, 32);                                     % Create Data Vector
% x = linspace(0, 50, numel(data));                       % Create Independent Variable Vector
% figure
% hold on
% plot(x, data)
% 
% data = rand(1, 50);                                     % Create Data Vector
% x = linspace(0, 50, numel(data));                       % Create Independent Variable Vector
% plot(x, data)