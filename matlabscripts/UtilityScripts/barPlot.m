function [] = barPlot(values,tests, frameworks,limit)
    %BARPLOT Summary of this function goes here
    %   Detailed explanation goes here
    hB=bar(values,0.4);     % use a meaningful variable for a handle array...
    hAx=gca;            % get a variable for the current axes handle
    
    %hT=[];              % placeholder for text object handles
    %for i=1:length(hB)  % iterate over number of bar objects
    %  hT=[hT,text(hB(i).XData+hB(i).XOffset,hB(i).YEndPoints,frameworks(:,i), ...
    %          'VerticalAlignment','bottom','horizontalalign','center')];
    %end
    %hAx.XTickLabel=tests; % label the ticks
    set(hAx,'XTick',[]);
    set(hAx,'XTick',[1:length(tests)]);
    %set(gca,'Xtick',log10(1024):1:log10(1.024*10^8))
    set(hAx,'XTickLabel',tests);
    ylim(limit)
    
    % Legend will show names for each color
    
end

