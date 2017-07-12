x = linspace(0, 2 * pi, 6);
y = sin(x);
xi = linspace(-1.5,  2 * pi + 1.5, 1000);

methods(1).interp = 'hold';
methods(1).extrap = 'hold';

methods(2).interp = 'nearest';
methods(2).extrap = 'hold';

methods(3).interp = 'linear';
methods(3).extrap = 'linear';

methods(4).interp = 'akima';
methods(4).extrap = 'linear';

scrsz = get(groot,'ScreenSize');
figure('OuterPosition', [500, -200, 800 800])

for i = 1:numel(methods)
    
    subplot(numel(methods), 1, i)
    title(['interp=' methods(i).interp ', extrap=' methods(i).extrap])
    
    yi = SDF.NDTable.interpolate(xi', y, {x}, 'InterpMethod', methods(i).interp, ...
        'ExtrapMethod', methods(i).extrap);

    hold on
    grid on
    plot(xi, yi, 'Color', 'blue')
    plot(x, y, 'Marker', 'o', 'MarkerFaceColor', 'red', 'LineStyle', 'none', 'Color', 'black')
    xlim([xi(1), xi(end)])
    ylim([-2 2])
end
