m = 10;              % choose 5, 7, or 10
nvars = 4;           % x1, x2, x3, x4

lb = -15 * ones(1,4);
ub = 20 * ones(1,4);

fitness = @(x) shekel_func(x, m);

options = optimoptions('ga', ...
    'PopulationSize', 100, ...
    'MaxGenerations', 100, ...
    'PlotFcn', {@gaplotbestf, @gaplotmean}, ...
    'Display', 'iter');

[x_opt, fval] = ga(fitness, nvars, [], [], [], [], lb, ub, [], options);