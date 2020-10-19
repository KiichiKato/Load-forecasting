% ---------------------------------------------------------------------------
% Load prediction: Model development algorithm 
% 2018/07/19 Updated Daisuke Kodaira 
% daisuke.kodaira03@gmail.com
% 
% function flag = demandModeDev(LongTermPastData)
%         flag =1 ; if operation is completed successfully
%         flag = -1; if operation fails.
% ----------------------------------------------------------------------------

function flag = DMset_setDemandModel(LongTermPastData,ValidDays)
    tic;    
    
    %% Input errors check and Load data
    if exist(LongTermPastData) == 0    % if the filename is not null
        flag = -1;  % return error
        errMessage = ['The follwing csv file is not found: ', LongTermPastData ];
        disp(errMessage)
        return
    else  % if the fine name is null
        past_load = readtable(LongTermPastData);
        colPredictors = {'BuildingIndex' 'Year' 'Month' 'Day' 'Hour' 'Quarter' 'DayOfWeek' 'Holiday' 'HighestTemp' 'Weather'};%
        PastPredictors=past_load(:, colPredictors);

    end    
    
    %% Get file path of csv data
    filepath = fileparts(LongTermPastData); 
    
    %% parameters
    %ValidDays = 30; % it must be above 1 day. 3days might provide the best performance
    n_valid_data = 96*ValidDays;
   
    
    %% 予測する曜日の指定
    %if past_load.DayOfWeek(end)==1||2||3||4||7
    %    past_load=past_load(past_load.DayOfWeek <=5,:);
    %    WeekdayData=past_load.Holiday == 4;
    %    past_load=past_load(WeekdayData,:);
    %else
    %    past_load=past_load(past_load.DayOfWeek >=6,:);
    %end

    %% Devide the data into training and validation
    past_load=past_load(end-(96*ValidDays-1):end,:);
    valid_data = table2array(past_load(end-n_valid_data+1:end, 1:end));
    train_data = past_load(1:end-n_valid_data, 1:end);
    valid_predictors = table2array(past_load(end-n_valid_data+1:end, 1:end-1));
    
    %% Train each model using past load data
    % Note: 0 means not true. If this function got the past data, model have to be trained
    DMset_Kmeans_Training(past_load, colPredictors, filepath);
    DMset_NeuralNet_Training(past_load, colPredictors, filepath);
    
    %% Validate the performance of each model
    validData_Kmeans = DMset_Kmeans_Forecast(PastPredictors, filepath);
    validData_ANN = DMset_NeuralNet_Forecast(PastPredictors, filepath);    
    
    %% 学習データを96*ValidDaysの形に変更する。
    validData_Kmeans = validData_Kmeans(end-(96*ValidDays-1):end,1);
    validData_ANN =validData_ANN(end-(96*ValidDays-1):end,1);
    for i=1:ValidDays
        y_ValidEstIndv(1).data(1:96,i)=validData_Kmeans(96*(i-1)+1:96*i,1);
        y_ValidEstIndv(2).data(1:96,i)=validData_ANN(96*(i-1)+1:96*i,1);
    end
    
    %% Optimize the coefficients for the additive model
    coeff = DMset_pso_main(y_ValidEstIndv, valid_data(:,end)); 
     % Get the number of individual forecasting algorithms (kmeans, ANN....)
    n_algorithms = size(coeff(1).data,1);

 
    %% Generate probability interval using validation result
    % Arrange an empty matrix 'y_est' in advane
    y_est = zeros(96, ValidDays);
    % Get combined estimation value 'y_est' based on optimal coefficients and deterministic forecasting
    for hour = 1:24
        for i = 1:n_algorithms
                y_est(1+(hour-1)*4:hour*4,:) = y_est(1+(hour-1)*4:hour*4,:) + coeff(hour).data(i).*y_ValidEstIndv(i).data(1+(hour-1)*4:hour*4,:);  
        end
    end    
    % Restructure the matrix format from "96*validation days" to one column 
    for day = 1:ValidDays        
        y_ValidEstComb(1+(day-1)*96:day*96, 1) = y_est(:, day);
    end    
    % Get error from validation data: absolute error, hours, Quaters
    err = [y_ValidEstComb - valid_data(:, end) valid_predictors(:,5) valid_predictors(:,6)]; 
    % Initialize the structure for error distribution
    % structure of err_distribution.data is as below:
    %   row=25hours(0~24 in "LongTermPastData"), columns=4quarters.
    %   For instance, "err_distribution(1,1).data" means 0am 0(first) quarter, which contains array like [e1,e2,e3....] 
    for hour = 1:25
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
    past_load_array=table2array(past_load);
    s1 = 'DM_pso_coeff_';
    s2 = 'DM_err_distribution_';
    s3 = num2str(past_load_array(1,1)); % Get building index
    name(1).string = strcat(s1,s3);
    name(2).string = strcat(s2,s3);
    varX(1).value = 'coeff';
    varX(2).value = 'err_distribution';
    extention='.mat';
    for i = 1:size(varX,2)
        matname = fullfile(filepath, [name(i).string extention]);
        save(matname, varX(i).value);
    end   
    % If the process properly works, give back flag as 1  
    flag = 1;    
    toc;

    % for debugging --------------------------------------------------------------------- 
    for i = 1:n_algorithms
        for day = 1:ValidDays
            predicted_load(i).data(1+(day-1)*96:day*96,:) = y_ValidEstIndv(i).data(:,day);
        end
    end
    MAPE(1) = mean(abs(y_ValidEstComb - valid_data(:,end))*100./valid_data(:,end)); % combined
    MAPE(2) = mean(abs(predicted_load(1).data - valid_data(:,end))*100./valid_data(:,end)); % k-means
    MAPE(3) = mean(abs(predicted_load(2).data - valid_data(:,end))*100./valid_data(:,end)); % fitnet
    disp(['MAPE of demand mean: ', num2str(MAPE(1)), '[%]'])
    disp(['MAPE of kmeans: ', num2str(MAPE(2)), '[%]'])
    disp(['MAPE of fitnet: ', num2str(MAPE(3)), '[%]'])
    DMset_demandGraph(1:size(y_ValidEstComb,1), y_ValidEstComb, valid_data(:,end), [], 'Combined for forecast data'); % Combined
    DMset_demandGraph(1:size(y_ValidEstComb,1), predicted_load(1).data, valid_data(:,end), [], 'k-means for forecast data'); % k-means
    DMset_demandGraph(1:size(y_ValidEstComb,1), predicted_load(2).data, valid_data(:,end), [], 'fitnet ANN for forecast data'); % NN       
    % for debugging --------------------------------------------------------------------- 

end
