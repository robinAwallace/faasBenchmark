fileName = "/home/robin/Documents/university/exjobb/data/github_stars.csv";
if ~exist('./images/', 'dir')
   mkdir('./images/')
end

T=readtable(fileName,'Format','auto');

X = T{:,1};
OpenFaas = T{:,3}; 
Kubeless = T{:,5}; 
Fission = T{:,7};

fig=figure('visible','on');
hold on
plot(X,OpenFaas)
plot(X,Kubeless)
plot(X,Fission)

title('Github stars')
xlabel('Date')
ylabel('Stars')
fig.Position = [0,0,1024,1024];
legend('boxoff');
lgd = legend("OpenFaas", "Kubeless", "Fission", 'Location','southoutside');
lgd.NumColumns = 3;
exportgraphics(fig,'./images/githubStars.pdf','ContentType','vector')

%value = T{:,column}; 