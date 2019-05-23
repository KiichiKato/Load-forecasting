function y = DMset_err_correction_t_2(shortTermPastData,path)
% tic;

% feature
% P1(day), P2(holiday), P3(highest Temp), P4(weather)

feature = 2:10;

    %% fitent
    %% load .mat file
    [m_Short,n_Short] = size(shortTermPastData);
    
    if m_Short < 96*3
        ShortExcelFile = shortTermPastData(:,:);
    else
%         ShortExcelFile = shortTermPastData((end-96*3+1):end,:);
%         ShortExcelFile = shortTermPastData((end-96*1+1):end,:);
        ShortExcelFile = shortTermPastData(:,:);
    end
    
    building_num = num2str(ShortExcelFile(2,1));

    load_name = '\DM_fitnet_ANN_';
    load_name = strcat(path,load_name,building_num,'.mat');
       
    load(load_name,'-mat');

    %% ForecastData
    % ForecastData load
    ShortData_ANN = ShortExcelFile;

    % ForecastData size
    [m_raw_ShortData_ANN, n_raw_ShortData_ANN]= size(ShortData_ANN);

    % Feature data

    %% Test
        % classify
        % make initial format

        ShortData_holiday_ANN = zeros(m_raw_ShortData_ANN,n_raw_ShortData_ANN);
        ShortData_weekend_ANN = zeros(m_raw_ShortData_ANN,n_raw_ShortData_ANN);
        ShortData_week_ANN = zeros(m_raw_ShortData_ANN,n_raw_ShortData_ANN);

        for i = 1:1:m_raw_ShortData_ANN
            % holiday
            if ShortData_ANN(i,8) == 1
                ShortData_holiday_ANN(i,:) = ShortData_ANN(i,:); % holiday -> 1column : date, 2-5column : Feature, 6-101column : Demand

            % weekend
            elseif ShortData_ANN(i,8) == 3
                ShortData_weekend_ANN(i,:) = ShortData_ANN(i,:); % weekend -> 1column : date, 2-5column : Feature, 6-101column : Demand

            elseif ShortData_ANN(i,8) == 5
                ShortData_weekend_ANN(i,:) = ShortData_ANN(i,:);

            %week
            elseif ShortData_ANN(i,8) == 2
                ShortData_week_ANN(i,:) = ShortData_ANN(i,:); % week -> 1column : date, 2-5column : Feature, 6-101column : Demand

            elseif ShortData_ANN(i,8) == 4
                ShortData_week_ANN(i,:) = ShortData_ANN(i,:);
            end
        end

    ShortData_holiday_ANN( ~any(ShortData_holiday_ANN,2), : ) = [];  % delete holiday rows
    ShortData_weekend_ANN( ~any(ShortData_weekend_ANN,2), : ) = [];  % delete weekend rows
    ShortData_week_ANN( ~any(ShortData_week_ANN,2), : ) = [];  % delete week rows

    % ANN
    for i_loop = 1:1:3
        net_holiday_ANN = net_holiday_ANN_loop{i_loop};
        net_weekend_ANN = net_weekend_ANN_loop{i_loop};
        net_week_ANN = net_week_ANN_loop{i_loop};

        % for test
        % kW

        % Predict the responses using the trained network

        result_ForecastData_ANN_loop = zeros(m_raw_ShortData_ANN,1);

        for i = 1:1:m_raw_ShortData_ANN

            % holiday
            if ShortData_ANN(i,8) == 1
                x2_holiday_ANN = transpose(ShortData_ANN(i,feature));
                result_ForecastData_ANN_loop(i,:) = net_holiday_ANN(x2_holiday_ANN);

            % weekend
            elseif ShortData_ANN(i,8) == 3
                x2_weekend_ANN = transpose(ShortData_ANN(i,feature));
                result_ForecastData_ANN_loop(i,:) = net_weekend_ANN(x2_weekend_ANN);

            elseif ShortData_ANN(i,8) == 5
                x2_weekend_ANN = transpose(ShortData_ANN(i,feature));
                result_ForecastData_ANN_loop(i,:) = net_weekend_ANN(x2_weekend_ANN);

            % week
            elseif ShortData_ANN(i,8) == 2
                x2_week_ANN = transpose(ShortData_ANN(i,feature));
                result_ForecastData_ANN_loop(i,:) = net_week_ANN(x2_week_ANN);

            elseif ShortData_ANN(i,8) == 4
                x2_week_ANN = transpose(ShortData_ANN(i,feature));
                result_ForecastData_ANN_loop(i,:) = net_week_ANN(x2_week_ANN);
             end
        end

        result_ForecastData_ANN{i_loop} = result_ForecastData_ANN_loop;

    end
    
    result_ForecastData_ANN_sum = result_ForecastData_ANN{1}+result_ForecastData_ANN{2}+result_ForecastData_ANN{3};
    
    result_ForecastData_ANN_mean = result_ForecastData_ANN_sum/3;
    
    real_demand = ShortData_ANN(:,11);
    
    err_ShortData = real_demand - result_ForecastData_ANN_mean; % real - forecast
    err_ShortData_rate = err_ShortData./real_demand; % (real - forecast) / real
    
 %% raw : time, column : day
     % set err_ShorData_rate_final time step from 1 to 96
    j = 1;
    
    for i = 1:1:m_raw_ShortData_ANN
        if ShortData_ANN(i,5)*4 == 0 & ShortData_ANN(i,6) == 0
            err_ShorData_rate_final(96,j) = err_ShortData_rate(i,1);
        else
            err_ShorData_rate_final((ShortData_ANN(i,5)*4 + ShortData_ANN(i,6)),j) = err_ShortData_rate(i,1);
        end
        
            if i == m_raw_ShortData_ANN
            else
                if (ShortData_ANN(i,4) - ShortData_ANN((i+1),4)) == 0
                else
                    j = j + 1;
                end
            end
    end
    
    % sum of matrix rows
    
    err_ShorData_rate_final_sum = sum(err_ShorData_rate_final,2);
    
    num_err_0(:,:) = sum(err_ShorData_rate_final(:,:) == 0,2);
    [~,num_err] = size(err_ShorData_rate_final);
    num_err = num_err - num_err_0;
    
    err_ShorData_rate_final_mean = err_ShorData_rate_final_sum ./ num_err;
    
    % bias detection
    bias_detection_ANN = zeros(24,1);
    
    bias_detection_ANN = err_ShortData_rate((end-23):end,1); % 6 hour
    
    bias_detection_ANN = bias_detection_ANN + 0.000001;

    bias_detection_sign = 1;
    
    for i = 1:1:24
        bias_detection_sign = bias_detection_sign * bias_detection_ANN(i,1);
    end
    
    % detect
    
    if bias_detection_sign > 0
        bias_err_rate_mean_value = sum(bias_detection_ANN) / (24 - sum(bias_detection_ANN == 0));
        bias_err_rate_mean(1:96,1) = bias_err_rate_mean_value;
        
    else
    end
    
    % err compare
    
    if bias_detection_sign > 0
        err_trend_mean = mean(bias_err_rate_mean) - mean(err_ShorData_rate_final_mean);
    
        if sign(bias_err_rate_mean) == sign(err_trend_mean)
            y = bias_err_rate_mean;
        else
            y = err_ShorData_rate_final_mean;
        end
        
    else
        y = err_ShorData_rate_final_mean;
    end
    
end

