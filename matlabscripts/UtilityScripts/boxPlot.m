function [] = boxPlot(values,tests, frameworks,limit,n)
[m1,m2]=size(values);

x = 1:m1;
y = zeros(m1, m2, n);

for i = 1:m1
    for ii = 1:m2
        value = values{i,ii};
        if(length(value) < n)
            nr = n - length(value);
            m = median(value);
            if isnan(m)
                m = 0;
            end
            value = [value;zeros(nr,1)];
            value(value==0) = m;
        end
        y(i,ii,:) = value(:);
    end
end

% Plot boxplots

h = boxplot2(y,x);

% Alter linestyle and color
cmap = get(0, 'defaultaxescolororder');
for ii = 1:m2
   structfun(@(x) set(x(ii,:), 'color', cmap(ii,:), ...
       'markeredgecolor', cmap(ii,:)), h);
end
set([h.lwhis h.uwhis], 'linestyle', '-');
set(h.out, 'marker', '.');

hAx=gca;
hAx.XTickLabel=[tests]; % label the ticks
set(hAx,'XTick',[]);
set(hAx,'XTick',[1:length(tests)]);
ylim(limit)

end

