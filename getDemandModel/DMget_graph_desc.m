% -----------------------------------------------------------------
% This function is only for debug
% -------------------------------------------------------------------

function DMget_graph_desc(x, y_pred, y_true, boundaries, name, ci_percentage)
                
    % Graph description for prediction result
    f = figure;
    hold on;
    xticks([0:4:96])
    xticklabels({'00','01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24'})
    plot(x, y_pred,'g');
    if isempty(y_true) == 0
        plot(y_true,'r');
    else
        plot(zeros(x,1));
    end
    % If we have CI to be described
    if isempty(boundaries) == 0
        plot(boundaries(:,1),'b--');
        plot(boundaries(:,2),'b--');
        CI = 100*(1-ci_percentage);
        legend('predicted Load', 'True', [num2str(CI) '% Prediction Interval']);
    else
        legend('predicted Load', 'True');
    end
   
    % Labels of the graph
    xlabel('Time steps in a day');
    ylabel('Load [W]');
    title(name);


end