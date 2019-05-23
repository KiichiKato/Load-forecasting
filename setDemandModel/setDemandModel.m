% ---------------------------------------------------------------------------
% Load prediction: Model development algorithm 
% 2018/07/19 Updated Daisuke Kodaira 
% daisuke.kodaira03@gmail.com
% 
% function flag = demandModeDev(LongTermPastData)
%         flag =1 ; if operation is completed successfully
%         flag = -1; if operation fails.
% ----------------------------------------------------------------------------

function flag = setDemandModel(LongTermPastData)
    tic;    
    
    %% Input errors check and Load data
    if exist(LongTermPastData) == 0    % if the filename is not null
        flag = -1;  % return error
        errMessage = ['The follwing file is not found: ', LongTermPastData ];
        disp(errMessage)
        return
    else  % if the fine name is null
        past_load = csvread(LongTermPastData,1,0);
    end    
    
    %% Get file path of csv data
    filepath = fileparts(LongTermPastData); 
    
    %% parameters
    ValidDays = 30; % it must be above 1 day. 3days might provide the best performance
    n_valid_data = 96*ValidDays;

    %% Devide the data into training and validation
    valid_data = past_load(end-n_valid_data+1:end, 1:end);
    train_data = past_load(1:end-n_valid_data, 1:end);
    valid_predictors = past_load(end-n_valid_data+1:end, 1:end-1);
    
    %% Train each model using past load data
    % Note: 0 means not true. If this function got the past data, model have to be trained
    op_flag = 1; % 1: training mode
    shortPast = past_load(end-7*96+1:end, :);
    kmeans_bayesian(op_flag, past_load, shortPast, filepath);
    fitnet_ANN(op_flag, past_load, shortPast, filepath);
    
    %% Validate the performance of each model
    op_flag = 2; % 2: forecasting mode      
    for day = 1:ValidDays
        FistTimeInValid = size(train_data,1)+1+96*(day-1);  % Indicator of the time instance for validation data in past_load
        short_past_load = past_load(FistTimeInValid-96*7:FistTimeInValid-1, 1:end); % size of short_past_load is always "672*11" for one week data set
        valid_predictor = valid_predictors(1+(day-1)*96:day*96, 1:end);  % predictor for 1 day (96 data instances)
        y_ValidEstIndv(1).data(:,day) = kmeans_bayesian(op_flag, valid_predictor, short_past_load, filepath);
        y_ValidEstIndv(2).data(:,day) = fitnet_ANN(op_flag, valid_predictor, short_past_load, filepath);
    end
    %% Optimize the coefficients for the additive model
    coeff = pso_main(y_ValidEstIndv, valid_data(:,end)); 

    %% Generate probability interval using validation result
    for hour = 1:24
        for i = 1:size(coeff(1).data,1)
            if i == 1
                y_est(1+(hour-1)*4:hour*4,:) = coeff(hour).data(i).*y_ValidEstIndv(i).data(1+(hour-1)*4:hour*4,:);
            else
                y_est(1+(hour-1)*4:hour*4,:) = y_est(1+(hour-1)*4:hour*4,:) + coeff(hour).data(i).*y_ValidEstIndv(i).data(1+(hour-1)*4:hour*4,:);  
            end
        end
    end    
    % Restructure
    for day = 1:ValidDays        
        y_ValidEstComb(1+(day-1)*96:day*96, 1) = y_est(:, day);
    end
    
    % error from validation data: error[%], hours, Quaters
    err = [y_ValidEstComb - valid_data(:, end) valid_predictors(:,5) valid_predictors(:,6)]; 
    % Initialize the structure for error distribution
    % structure of err_distribution.data is as below:
    % row=25hours(0~24 in "LongTermPastData"), columns=4quarters.
    % For instance, "err_distribution(1,1).data" means 0am 0(first) quarter, which contains array like [e1,e2,e3....] 
    for hour = 1:24
        for quarter = 1:4
            err_distribution(hour,quarter).err(1) = NaN;            
        end
    end
    % build the error distibution
    for k = 1:size(err,1)
        if isnan(err_distribution(err(k,2)+1, err(k,3)+1).err(1)) == 1
            err_distribution(err(k,2)+1, err(k,3)+1).err(1) = err(k,1);
        else
            err_distribution(err(k,2)+1, err(k,3)+1).err(end+1) = err(k,1);
        end
    end   
    
    %% Save .mat files
    s1 = 'pso_coeff_';
    s2 = 'err_distribution_';
    s3 = num2str(past_load(1,1)); % Get building index
    name(1).string = strcat(s1,s3);
    name(2).string = strcat(s2,s3);
    varX(1).value = 'coeff';
    varX(2).value = 'err_distribution';
    extention='.mat';
    for i = 1:size(varX,2)
        matname = fullfile(filepath, [name(i).string extention]);
        save(matname, varX(i).value);
    end        

%     % for debugging --------------------------------------------------------------------- 
%     for i = 1:2
%         for day = 1:ValidDays
%             predicted_load(i).data(1+(day-1)*96:day*96,:) = y_ValidEstIndv(i).data(:,day);
%         end
%     end
%     
%     MAPE(1) = mean(abs(y_ValidEstComb - valid_data(:,end))*100./valid_data(:,end)); % combined
%     MAPE(2) = mean(abs(predicted_load(1).data - valid_data(:,end))*100./valid_data(:,end)); % k-means
%     MAPE(3) = mean(abs(predicted_load(2).data - valid_data(:,end))*100./valid_data(:,end)); % fitnet
%     disp(['MAPE of demand mean: ', num2str(MAPE(1)), '[%]'])
%     disp(['MAPE of kmeans: ', num2str(MAPE(2)), '[%]'])
%     disp(['MAPE of fitnet: ', num2str(MAPE(3)), '[%]'])
%     demandGraph(1:size(y_ValidEstComb,1), y_ValidEstComb, valid_data(:,end), [], 'Combined for forecast data'); % Combined
%     demandGraph(1:size(y_ValidEstComb,1), predicted_load(1).data, valid_data(:,end), [], 'k-means for forecast data'); % k-means
%     demandGraph(1:size(y_ValidEstComb,1), predicted_load(2).data, valid_data(:,end), [], 'fitnet ANN for forecast data'); % NN       
% 
%     % for debugging --------------------------------------------------------------------- 
    
    
    
    flag = 1;    
    toc;
end
