x = linspace(-3, 3, 15);
y = linspace(-3, 3, 15);

[X, Y] = meshgrid(x, y);

Z = peaks(X, Y);

xi = linspace(-6, 6, 100);
yi = linspace(-6, 6, 100);

[XI, YI] = meshgrid(xi, yi);

points = [XI(:) YI(:)];

methods = struct;

methods(1).interp = 'nearest';
methods(1).extrap = 'hold';

methods(2).interp = 'linear';
methods(2).extrap = 'linear';

methods(3).interp = 'akima';
methods(3).extrap = 'linear';

scrsz = get(groot,'ScreenSize');
figure('OuterPosition', [500, -200, 800 800])

h = subplot(2, 2, 1);
surf(X, Y, Z)
title('original')
xlim([-6 6])
ylim([-6 6])
zlim([-10 10])

for i = 1:numel(methods)
    
    h(end+1) = subplot(2, 2, i + 1);
    
    zi = SDF.NDTable.interpolate([XI(:) YI(:)], Z, {x, y}, 'InterpMethod', methods(i).interp, ...
        'ExtrapMethod', methods(i).extrap);
    
    ZI = reshape(zi, size(XI));
    
    surf(XI, YI, ZI);
    title(['interp=' methods(i).interp ', extrap=' methods(i).extrap])
    
    xlim([-6 6])
    ylim([-6 6])
    zlim([-10 10])
end

linkprop(h, 'CameraPosition');
