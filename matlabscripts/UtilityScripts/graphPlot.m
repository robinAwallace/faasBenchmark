function [] = graphPlot(values,tests, frameworks,limit)
    %BARPLOT Summary of this function goes here
    %   Detailed explanation goes here
    plot(tests,values);
    ylim(limit)
    legend(frameworks);
end

