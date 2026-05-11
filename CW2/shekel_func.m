function f = shekel_func(x, m)

    % Constants from table
    A = [4.0 4.0 4.0 4.0;
         1.0 1.0 1.0 1.0;
         8.0 8.0 8.0 8.0;
         6.0 6.0 6.0 6.0;
         3.0 7.0 3.0 7.0;
         2.0 9.0 2.0 9.0;
         5.0 5.0 3.0 3.0;
         8.0 1.0 8.0 1.0;
         6.0 2.0 6.0 2.0;
         7.0 3.6 7.0 3.6];

    c = [0.1 0.2 0.2 0.4 0.4 0.6 0.3 0.7 0.5 0.5];

    f = 0;

    for i=1:m
        sum_term = 0;
        for j=1:4
            sum_term = sum_term + (x(j) - A(i, j))^2;
        end
        f = f + 1/(sum_term + c(i));
    end
    f = -f;
end