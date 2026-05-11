% Reading the datatable

T = readtable('M33176_1_CW_MAIN_AppendixA Osteoporosis Dataset.xlsx');

varfun(@class, T, 'OutputFormat', 'table');

string_cols = [10 15 16 17 18];

vars = T.Properties.VariableNames(string_cols);

% Handling different data types in the table

for i = 1:length(vars)
    
    raw = T.(vars{i});
    
    newcol = NaN(size(raw));
    
    for k = 1:numel(raw)
        val = raw{k};
        
        if isempty(val)
            newcol(k) = NaN;
        elseif isnumeric(val)
            newcol(k) = val;
        else
            newcol(k) = str2double(val);
        end
    end
    
    T.(vars{i}) = newcol;   % works cleanly with names
end

% splitting categorical and numerical columns for data visualisations

cols = 1:26;
categorical_cols_indices = [1 2 4 10 11 12 13 14 16];
numerical_cols_indices = [];
j = 1;
for i=1:length(cols)
    if ismember(cols(i), categorical_cols_indices) == 0
        numerical_cols_indices(j) = i;
        j = j+1;
    end
end

% Barplots - general data

vars = T.Properties.VariableNames(cols);

figure(1);
cur = 1;
for i=1:3
    for j=1:3
        raw = T.(vars{categorical_cols_indices(cur)});
        raw = raw(~isnan(raw));
        nunique = max(raw) + 1;
        counts = zeros(1, nunique);
        for k=1:numel(raw)
            val = raw(k);
            val = val+1;
            counts(val) = counts(val) + 1;
        end
        subplot(3, 3, cur);
        xlabels = 0:nunique-1;
        b = bar(xlabels, counts);
        text(0:length(counts)-1,counts,num2str(counts'),'vert','bottom','horiz','center');
        title(vars{categorical_cols_indices(cur)}, 'Interpreter', 'none', 'FontSize', 8);
        cur = cur+1;
    end
end

% Barplots - count of categorical features among fracture and non-fracture
% cases

figure(2);
cur = 1;
for i=1:2
    for j=1:4
        raw = T.(vars{categorical_cols_indices(cur+1)});
        raw = raw(~isnan(raw));
        nunique = max(raw) + 1;
        xlabels = 0:nunique-1;
        vbx_0 = T(T.VBX == 0, :);
        raw = vbx_0.(vars{categorical_cols_indices(cur+1)});
        raw = raw(~isnan(raw));
        counts = zeros(2, nunique);
        for k=1:numel(raw)
            val = raw(k);
            val = val+1;
            counts(1, val) = counts(1, val) + 1;
        end

        vbx_1 = T(T.VBX == 1, :);
        raw = vbx_1.(vars{categorical_cols_indices(cur+1)});
        raw = raw(~isnan(raw));
        for k=1:numel(raw)
            val = raw(k);
            val = val+1;
            counts(2, val) = counts(2, val) + 1;
        end

        subplot(2, 4, cur);

        b = bar(xlabels, counts');

        for idx = 1:size(counts,1)
            
            xtips = b(idx).XEndPoints;
            ytips = b(idx).YEndPoints;
            
            labels = string(b(idx).YData);
            
            text(xtips, ytips, labels, ...
                'VerticalAlignment', 'bottom', ...
                'HorizontalAlignment', 'center', ...
                'FontSize', 7);
        end
        legend("No Facture", "Fracture");
        title(vars{categorical_cols_indices(cur+1)}, 'Interpreter', 'none', 'FontSize', 8);
        cur = cur+1;
    end
end

% Histograms showing numerical data distributions

figure(3);
cur = 1;
for i=1:3
    for j=1:5
        subplot(3, 6, cur);
        raw = T.(vars{numerical_cols_indices(cur)});
        histogram(raw, 15);
        title(vars{numerical_cols_indices(cur)}, 'Interpreter', 'none', 'FontSize', 8);
        cur = cur + 1;
    end
end

subplot(3, 6, 16);
raw = T.(vars{numerical_cols_indices(cur)});
histogram(raw, 15);
title(vars{numerical_cols_indices(cur)}, 'Interpreter', 'none', 'FontSize', 8);

cur = cur + 1;

subplot(3, 6, 17);
raw = T.(vars{numerical_cols_indices(cur)});
histogram(raw, 15);
title(vars{numerical_cols_indices(cur)}, 'Interpreter', 'none', 'FontSize', 8);

% Density distribution of numerical values among different VBX statuses

figure(4);
cur = 1;
for i=1:3
    for j=1:5
        subplot(3, 6, cur);
        vbx_0 = T(T.VBX == 0, :);
        raw = vbx_0.(vars{numerical_cols_indices(cur)});
        [fp_0,xfp_0] = kde(raw);

        vbx_1 = T(T.VBX == 1, :);
        raw = vbx_1.(vars{numerical_cols_indices(cur)});
        [fp_1,xfp_1] = kde(raw);


        plot(xfp_0,fp_0, xfp_1,fp_1);
        legend("No Facture", "Fracture");
        title(vars{numerical_cols_indices(cur)}, 'Interpreter', 'none', 'FontSize', 8);
        cur = cur + 1;
    end
end

% Handling missing values

totalMissing = sum(ismissing(T), 'all')

summary(T)

% Deleting Menopause and HRT columns, because they have more than 40% of
% data absent

deleting_cols_id = [10 11];

T(:,deleting_cols_id) = [];

cols = 1:24;

vars = T.Properties.VariableNames(cols);

categorical_cols_indices = [1 2 4 12 13 14 16];

% Shifting column indices after HRT by 2

for i=1:length(numerical_cols_indices)
    if numerical_cols_indices(i) > 11
        numerical_cols_indices(i) = numerical_cols_indices(i) - 2;
    end
end

for i=1:length(categorical_cols_indices)
    if categorical_cols_indices(i) > 11
        categorical_cols_indices(i) = categorical_cols_indices(i) - 2;
    end
end

% Replacing absent values in numerical columns with medians

for i = 1:length(numerical_cols_indices)
    
    col_idx = numerical_cols_indices(i);
    raw = T.(vars{col_idx});
    
    % Only proceed if there are missing values
    if any(isnan(raw))
        
        med = median(raw(~isnan(raw)));   % ignore NaNs
        raw(isnan(raw)) = med;            % replace NaNs
        
        T.(vars{col_idx}) = raw;          % ✅ correct assignment
        
    end
end

% Replacing missing values in categorical columns with the most frequent
% categories (mode)

for i = 1:length(categorical_cols_indices)
    
    col_idx = categorical_cols_indices(i);
    raw = T.(vars{col_idx});
    
    % Only proceed if there are missing values
    if any(isnan(raw))
        
        popular = mode(raw(~isnan(raw)));   % ignore NaNs
        raw(isnan(raw)) = popular;            % replace NaNs
        
        T.(vars{col_idx}) = raw;          % ✅ correct assignment
        
    end
end

% Checking for new columns features summary

summary(T)

% Selecting features


data_process = T{:, 2:size(T, 2)};

% Normalizing features using z-scores

data_process = normalize(data_process, 'range');

%Selecting target column

target_process = T{:, 1};

% Training classification model

IN = data_process';
TARGET = full(ind2vec(target_process' + 1));

rng(42);

% training classification model using Scaled Conjugate Gradient algorithm

% To Train of the algorithms uncomment one and comment the other

% net = patternnet([10 5], 'trainscg'); % this is SCG
net = patternnet([10 5], 'trainlm'); % to use Levenberg-Marquardt algorithm
net.performFcn = 'crossentropy';

net.divideParam.trainRatio = 0.7;
net.divideParam.valRatio = 0.15;
net.divideParam.testRatio = 0.15;

net.trainParam.epochs = 100;

net = train(net, IN, TARGET);
