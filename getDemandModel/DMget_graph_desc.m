% -----------------------------------------------------------------
% This function is only for debug
% -------------------------------------------------------------------

function DMget_graph_desc(x, y_pred, y_true, boundaries, name, ci_percentage)
                
    % Graph description for prediction result
    timestep=linspace(0.25,24,96);
    f = figure;
    hold on;
    plot(timestep, y_pred,'g');
    xticks(0:1:24)
    if isempty(y_true) == 0
        plot(timestep,y_true,'r');
    else
        plot(timestep,zeros(x,1));
    end
    % If we have CI to be described
    if isempty(boundaries) == 0
        plot(timestep,boundaries(:,1),'b--');
        plot(timestep,boundaries(:,2),'b--');
        CI = 100*(1-ci_percentage);
        legend('predicted Load', 'True', [num2str(CI) '% Prediction Interval']);
    else
        legend('predicted Load', 'True');
    end
   
    % Labels of the graph
    xlabel('Time steps in a day');
    ylabel('Load [kW]');
    title(name);


end