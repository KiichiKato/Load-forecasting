% -----------------------------------------------------------------
% This function is only for debug
% -------------------------------------------------------------------

function graph_desc(x, y_pred, y_true, boundaries, name, ci_percentage)
                
    % Graph description for prediction result
    f = figure;
    hold on;
    plot(x, y_pred,'g');
    if isempty(y_true) == 0
        plot(y_true,'r');
    else
        plot(zeros(x,1));
    end
    if isempty(boundaries) == 0
        plot(boundaries(:,1),'b--');
        plot(boundaries(:,2),'b--');
    end
    
    CI = 100*(1-ci_percentage);
    
    xlabel('Time steps');
    ylabel('Load [MW]');
    title(name);
    legend('predicted Load', 'True', [num2str(CI) '% Prediction Interval']);


end