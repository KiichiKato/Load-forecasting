% y_ture: True load [MW]
% y_predict: predicted load [MW]
function coeff=DMset_pso_main2(y_predict, y_true)  
    % Initialization
    NumOfmethods = size(y_predict, 2); % the number of prediction methods (k-means and fitnet)
    days = size(y_predict(1).data,2);
    hours=size(y_true, 1)/days/4;
    %% three method
    % Restructure the predicted data
    for j = 1:NumOfmethods
        for hour = 1:hours
            yPredict(hour).data(:,j) = reshape(y_predict(j).data(1+(hour-1)*2:hour*2,:), [],1); % this global variable is utilized in 'objective_func'
        end
    end
   clear hour;
   % Restructure the target data
   for day = 1:days
       initial = 1+(day-1)*48;
       for hour = 1:hours 
           a=1+(day-1)*2;
           b=2*day;
           c=initial+(hour-1)*2;
           d=initial-1+hour*2;           
           yTarget(hour).data(a:b,1) = reshape(y_true(c:d,1), [],1); 
       end
   end
    % Essential paramerters for PSO performance
    for hour = 1:hours
        g_y_predict = yPredict(hour).data;
        g_y_true = yTarget(hour).data;
        rng default  % For reproducibility
        % PSO parameters definition
        nvars = NumOfmethods;
        lb = zeros(1, NumOfmethods); % lower boundary for PSO
        ub = ones(1, NumOfmethods); % upper boundary for PSO
        % Define Objective function
        objFunc = @(weight) objectiveFunc(weight, g_y_predict, g_y_true);
        % Input praemters for PSO
        options = optimoptions('particleswarm', 'MaxIterations',2000,'FunctionTolerance', 1e-25, 'MaxStallIterations', 1500,'Display', 'none');
        % Call PSO and get optimal weights for each hour
        [coeff(hour, :),~,~,~] = particleswarm(objFunc,nvars,lb,ub, options);   
        sumofcoeff=sum(coeff(hour, :));
        for j=1:3
            coeff(hour, j)=coeff(hour, j)/sumofcoeff;
        end
        clear j;        
    end

end

function err1 = objectiveFunc(weight, forecast, target) % objective function
    ensembleForecasted = sum(forecast.*weight, 2);  % add multiple methods
    err1 = sum(abs(target - ensembleForecasted));
    err2 = abs(1-sum(weight));
    total_err = err1+100*err2;
end