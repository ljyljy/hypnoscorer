% Warning: Crappy code ---v

function listresults
    files = matfiles();

    a_lin_accuracies = [];
    a_rbf_accuracies = [];
    b_lin_accuracies = [];
    b_rbf_accuracies = [];
    allstages = {'1','2','3','R','W'};
    a_lin_featurefreq = struct('Mean',0,'Variance',0,'Skewness',0,'Kurtosis',0,'HjorthMobility',0,'HjorthComplexity',0,'Amplitude',0,'F1',0,'F2',0,'F3',0);  % TODO Soft-code
    a_rbf_featurefreq = a_lin_featurefreq;
    b_lin_featurefreq = a_lin_featurefreq;
    b_rbf_featurefreq = b_lin_featurefreq;
    a_lin_confusion = zeros(numel(allstages));
    a_rbf_confusion = a_lin_confusion;
    b_lin_confusion = a_lin_confusion;
    b_rbf_confusion = a_lin_confusion;
    for i = 1:numel(files)
        load(files{i})
        e1 = evaluations1(1);
        e2 = evaluations2(1);

        c1 = e1.confusionmatrix;
        c1 = c1./repmat(sum(c1,2),1,size(c1,1));
        o1 = strjoin(num2cell(e1.confusionorder));
        c2 = e2.confusionmatrix;
        c2 = c2./repmat(sum(c2,2),1,size(c2,1));
        o2 = strjoin(num2cell(e2.confusionorder));
        if strfind(files{i},'lin')
            a_lin_accuracies = [a_lin_accuracies e1.accuracy];
            b_lin_accuracies = [b_lin_accuracies e2.accuracy];
            for f = e1.testingset.features'
                a_lin_featurefreq.(f{:}) = a_lin_featurefreq.(f{:}) + 1;
            end
            for f = e2.testingset.features'
                b_lin_featurefreq.(f{:}) = b_lin_featurefreq.(f{:}) + 1;
            end
            a_lin_confusion = a_lin_confusion + reencode_confusion(c1,strsplit(o1),allstages);
            b_lin_confusion = b_lin_confusion + reencode_confusion(c2,strsplit(o2),allstages);
        elseif strfind(files{i},'rbf')
            a_rbf_accuracies = [a_rbf_accuracies e1.accuracy];
            b_rbf_accuracies = [b_rbf_accuracies e2.accuracy];
            for f = e1.testingset.features'
                a_rbf_featurefreq.(f{:}) = a_rbf_featurefreq.(f{:}) + 1;
            end
            for f = e2.testingset.features'
                b_rbf_featurefreq.(f{:}) = b_rbf_featurefreq.(f{:}) + 1;
            end
            a_rbf_confusion = a_rbf_confusion + reencode_confusion(c1,strsplit(o1),allstages);
            b_rbf_confusion = b_rbf_confusion + reencode_confusion(c2,strsplit(o2),allstages);
        else
            error('MAT file is not marked lin nor rbf.')
        end

        disp(['Feature selection  | ' strjoin(e1.testingset.features)])
        disp(['Enhanced selection | ' strjoin(e2.testingset.features)])
        disp(['Accuracy           | ' num2str(e1.accuracy)])
        disp(['Enhanced accuracy  | ' num2str(e2.accuracy) ' (' num2str(100*e2.accuracy/e1.accuracy-100) ' %)'])
        disp( 'Confusion matrix   | ')
        printmat(c1,'',o1,o1)
        fprintf('\n')
    end
    a_lin_mean_estimate = mean(a_lin_accuracies);
    a_rbf_mean_estimate = mean(a_rbf_accuracies);
    b_lin_mean_estimate = mean(b_lin_accuracies);
    b_rbf_mean_estimate = mean(b_rbf_accuracies);
    a_lin_std_estimate = std(a_lin_accuracies);
    a_rbf_std_estimate = std(a_rbf_accuracies);
    b_lin_std_estimate = std(b_lin_accuracies);
    b_rbf_std_estimate = std(b_rbf_accuracies);
    a_lin_confusion = a_lin_confusion./numel(a_lin_accuracies);
    a_rbf_confusion = a_rbf_confusion./numel(a_rbf_accuracies);
    b_lin_confusion = b_lin_confusion./numel(b_lin_accuracies);
    b_rbf_confusion = b_rbf_confusion./numel(b_rbf_accuracies);
    disp(['Average accuracy of A, linear | ',num2str(a_lin_mean_estimate),' +-~ ',num2str(a_lin_std_estimate)])
    disp(['Average accuracy of B, linear | ',num2str(b_lin_mean_estimate),' +-~ ',num2str(b_lin_std_estimate)])
    disp(['Average accuracy of A, RBF    | ',num2str(a_rbf_mean_estimate),' +-~ ',num2str(a_rbf_std_estimate)])
    disp(['Average accuracy of B, RBF    | ',num2str(b_rbf_mean_estimate),' +-~ ',num2str(b_rbf_std_estimate)])
    d_lin = sqrt(a_lin_std_estimate^2/numel(a_lin_accuracies)+b_lin_std_estimate^2/numel(b_lin_accuracies));
    d_rbf = sqrt(a_rbf_std_estimate^2/numel(a_rbf_accuracies)+b_rbf_std_estimate^2/numel(b_rbf_accuracies));
    u_lin = (b_lin_mean_estimate-a_lin_mean_estimate)/d_lin;
    u_rbf = (b_rbf_mean_estimate-a_rbf_mean_estimate)/d_rbf;
    significance95 = norminv(1-0.05/2);
    if abs(u_lin) < significance95
        disp([num2str(-significance95),' < ',num2str(u_lin),' < ',num2str(significance95)])
        disp('Insignificant result --> no conclusion can be made.')
    else
        disp(['u_lin = ',num2str(u_lin),' --> SIGNIFICANCE!!!!!!!!!!!1111111111111'])
    end
    if abs(u_rbf) < significance95
        disp([num2str(-significance95),' < ',num2str(u_rbf),' < ',num2str(significance95)])
        disp('Insignificant result --> no conclusion can be made.')
    else
        disp(['u_rbf = ',num2str(u_rbf),' --> SIGNIFICANCE!!!!!!!!!!!1111111111111'])
    end
    disp('Confusion matrix, scorer A, linear kernel |')
    printmat(a_lin_confusion,'',strjoin(allstages),strjoin(allstages));
    disp('Confusion matrix, scorer A, RBF kernel |')
    printmat(a_rbf_confusion,'',strjoin(allstages),strjoin(allstages));
    disp('Confusion matrix, scorer B, linear kernel |')
    printmat(b_lin_confusion,'',strjoin(allstages),strjoin(allstages));
    disp('Confusion matrix, scorer B, RBF kernel |')
    printmat(b_rbf_confusion,'',strjoin(allstages),strjoin(allstages));

    freqplot({a_lin_featurefreq,a_rbf_featurefreq,b_lin_featurefreq,b_rbf_featurefreq},{'Scorer A, linear kernel','Scorer A, RBF kernel','Scorer B, linear kernel','Scorer B, RBF kernel'})
    freqplot({addStructs(a_lin_featurefreq,a_rbf_featurefreq),addStructs(b_lin_featurefreq,b_rbf_featurefreq)},{'Scorer A','Scorer B'})
%    freqplot({addStructs(a_lin_featurefreq,b_lin_featurefreq),addStructs(a_rbf_featurefreq,b_rbf_featurefreq)},{'Linear','RBF'})
end

function c2 = reencode_confusion(c1,o1,o2)
    % INV o1 \subseteq o2
    c2 = zeros(numel(o2));
    for i = 1:numel(o1)
        for j = 1:numel(o1)
            k = strmatch(o1{i},o2);  % TODO strmatch alternative
            l = strmatch(o1{j},o2);
            c2(k,l) = c1(i,j);
        end
    end
end

function freqplot(freqs,descriptions)
    figure
    matfreqs = cell2mat(arrayfun(@(x){cell2mat(struct2cell(x{1}))},freqs));
    plt = bar(matfreqs);
    ax = gca;
    set(ax,'XTickLabel',fieldnames(freqs{1}))
    ax.XTickLabelRotation = 45;
    legend(plt,descriptions)
    title('Frequency of selected features')
    xlabel('Features')
    ylabel('Frequency (Number of times selected)')
end

function filenames = matfiles
    f = dir('.');
    r = regexpi({f.name},'.*\.mat','match');
    filenames = [r{:}];
end

% http://stackoverflow.com/a/17267634
function S = addStructs(S1, S2)
    fNames1 = fieldnames(S1);
    fNames2 = fieldnames(S2);
    diff = setdiff(fNames1, fNames2);
    if ~isempty(diff)
       error('addStructs: structures do not contain same field names')
    end
    numFields = length(fNames1);
    for i=1:numFields
        % get values for each struct for this field
        fNameCell = fNames1(i);
        fName = fNameCell{:};
        val1 = S1.(fName);
        val2 = S2.(fName);
        % if field non-numeric, use value from first struct
        if (~isnumeric(val1) || ~isnumeric(val2) )
            S.(fName) = val1;
        % if fields numeric but not the same length, use value
        % from first struct
        elseif (length(val1) ~= length(val2) )
            S.(fName) = val1;
        % if fields numeric and same length, add them together
        else
            S.(fName) = val1 + val2;
        end
    end
end