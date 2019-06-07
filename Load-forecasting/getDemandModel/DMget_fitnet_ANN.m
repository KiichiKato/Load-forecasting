function y = DMget_fitnet_ANN(flag,input,shortTermPastData,path)
% tic;

% feature 
% P1(day), P2(holiday), P3(highest Temp), P4(weather)
feature = 2:10;

if flag == 1
    PastDataExcelFile_ANN = input;

    %% PastData
    % PastData load
    PastData_ANN = PastDataExcelFile_ANN(1:(end-96*7),:);
    
    % if there is 0 value in demand column -> delete
    PastData_ANN(~any(PastData_ANN(:,11),2),:) = [];
    
    % PastData size
    [m_PastData_ANN, ~]= size(PastData_ANN);

    % if there is no 1 day past data

    if m_PastData_ANN < 96
        PastData_ANN(1:96,1) = PastData_ANN(1,1); % building index
        PastData_ANN(1:96,2) = PastData_ANN(1,2);
        PastData_ANN(1:96,3) = PastData_ANN(1,3);
        PastData_ANN(1:96,4) = PastData_ANN(1,4);

        PastData_ANN(1:96,5) = transpose([0 0 0 1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7 8 8 8 8 9 9 9 9 10 10 10 10 ...
            11 11 11 11 12 12 12 12 13 13 13 13 14 14 14 14 15 15 15 15 16 16 16 16 17 17 17 17 18 18 18 18 ...
            19 19 19 19 20 20 20 20 21 21 21 21 22 22 22 22 23 23 23 23 24]);

        PastData_ANN(1:96,6) = transpose([1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 ...
            1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0]);

        PastData_ANN(1:96,7) = PastData_ANN(1,7);
        PastData_ANN(1:96,8) = PastData_ANN(1,8);
        PastData_ANN(1:96,9) = PastData_ANN(1,9);
        PastData_ANN(1:96,10) = PastData_ANN(1,10);

        PastData_ANN(1:96,11) = mean(PastData_ANN(1:m_PastData_ANN,11));
    end

    [m_PastData_ANN, n_PastData_ANN] = size(PastData_ANN);

   %% Train model
    % ANN
    % for train
    % make a format
    % holiday, weekend, week classify

    % if there are not enough data -> just copy
    % new format

    if m_PastData_ANN <= 192
        PastData_holiday_ANN(:,:) = PastData_ANN(:,:);
        PastData_weekend_ANN(:,:) = PastData_ANN(:,:);
        PastData_week_ANN(:,:) = PastData_ANN(:,:);
    else

    % classify
        % make initial format

        PastData_holiday_ANN = zeros(m_PastData_ANN,n_PastData_ANN);
        PastData_weekend_ANN = zeros(m_PastData_ANN,n_PastData_ANN);
        PastData_week_ANN = zeros(m_PastData_ANN,n_PastData_ANN);

        for i = 1:1:m_PastData_ANN
            % holiday
            if PastData_ANN(i,8) == 1
                PastData_holiday_ANN(i,:) = PastData_ANN(i,:); % holiday

            % weekend
            elseif PastData_ANN(i,8) == 3
                PastData_weekend_ANN(i,:) = PastData_ANN(i,:); % weekend

            elseif PastData_ANN(i,8) == 5
                PastData_weekend_ANN(i,:) = PastData_ANN(i,:);

            %week
            elseif PastData_ANN(i,8) == 2
                PastData_week_ANN(i,:) = PastData_ANN(i,:); % week

            elseif PastData_ANN(i,8) == 4
                PastData_week_ANN(i,:) = PastData_ANN(i,:);
            end
        end

    PastData_holiday_ANN( ~any(PastData_holiday_ANN,2), : ) = [];  % delete holiday rows
    PastData_weekend_ANN( ~any(PastData_weekend_ANN,2), : ) = [];  % delete weekend rows
    PastData_week_ANN( ~any(PastData_week_ANN,2), : ) = [];  % delete week rows
    end

    % make model
    for i_loop = 1:1:3

        [m_holiday_ANN,~] = size(PastData_holiday_ANN);
        [m_weekend_ANN,~] = size(PastData_weekend_ANN);
        [m_week_ANN,~] = size(PastData_week_ANN);

        % holiday

        trainDay_holiday_ANN = m_holiday_ANN;

        x_holiday_ANN = transpose(PastData_holiday_ANN(1:trainDay_holiday_ANN,feature)); % input(feature)
        t_holiday_ANN = transpose(PastData_holiday_ANN(1:trainDay_holiday_ANN,11)); % target

        % Create and display the network
        net_holiday_ANN = fitnet([20, 20, 20, 20, 5],'trainscg');
        net_holiday_ANN.trainParam.showWindow = false;
    %     disp('Training fitnet')
        % Train the network using the data in x and t
        net_holiday_ANN = train(net_holiday_ANN,x_holiday_ANN,t_holiday_ANN);

        % weekend

        trainDay_weekend_ANN = m_weekend_ANN;

        x_weekend_ANN = transpose(PastData_weekend_ANN(1:trainDay_weekend_ANN,feature)); % input(feature)
        t_weekend_ANN = transpose(PastData_weekend_ANN(1:trainDay_weekend_ANN,11)); % target

        % Create and display the network
        net_weekend_ANN = fitnet([20, 20, 20, 20, 5],'trainscg');
        net_weekend_ANN.trainParam.showWindow = false;
    %     disp('Training fitnet')
        % Train the network using the data in x and t
        net_weekend_ANN = train(net_weekend_ANN,x_weekend_ANN,t_weekend_ANN);

        trainDay_week_ANN = m_week_ANN;

        x_week_ANN = transpose(PastData_week_ANN(1:trainDay_week_ANN,feature)); % input(feature)
        t_week_ANN = transpose(PastData_week_ANN(1:trainDay_week_ANN,11)); % target

        % Create and display the network
        net_week_ANN = fitnet([20, 20, 20, 20, 5],'trainscg');
        net_week_ANN.trainParam.showWindow = false;
    %     disp('Training fitnet')
        % Train the network using the data in x and t
        net_week_ANN = train(net_week_ANN,x_week_ANN,t_week_ANN);

        % PastData , Train work space data will save like .mat file
    
        net_holiday_ANN_loop{i_loop} = net_holiday_ANN;
        net_weekend_ANN_loop{i_loop} = net_weekend_ANN;
        net_week_ANN_loop{i_loop} = net_week_ANN;
 
    end
        
    clearvars input;
    clearvars shortTermPastData;
    
    building_num = num2str(PastDataExcelFile_ANN(2,1));

    save_name = '\fitnet_ANN_';
    save_name = strcat(path,save_name,building_num,'.mat');
    
    clearvars path;
    save(save_name);


else

    % file does not exist so use already created .mat
   %% load .mat file
   
    ForecastExcelFile = input;
    
    building_num = num2str(ForecastExcelFile(2,1));

    load_name = '\DM_fitnet_ANN_';
    load_name = strcat(path,load_name,building_num,'.mat');
    
    load(load_name,'-mat');

    %% ForecastData

    % ForecastData load
    ForecastData_ANN = ForecastExcelFile;

    % ForecastData size
    [m_ForecastData_ANN, n_ForecastData_ANN]= size(ForecastData_ANN);

    % Feature data

    %% Test
        % classify
        % make initial format

        ForecastData_holiday_ANN = zeros(m_ForecastData_ANN,n_ForecastData_ANN);
        ForecastData_weekend_ANN = zeros(m_ForecastData_ANN,n_ForecastData_ANN);
        ForecastData_week_ANN = zeros(m_ForecastData_ANN,n_ForecastData_ANN);

        for i = 1:1:m_ForecastData_ANN
            % holiday
            if ForecastData_ANN(i,8) == 1
                ForecastData_holiday_ANN(i,:) = ForecastData_ANN(i,:); % holiday -> 1column : date, 2-5column : Feature, 6-101column : Demand

            % weekend
            elseif ForecastData_ANN(i,8) == 3
                ForecastData_weekend_ANN(i,:) = ForecastData_ANN(i,:); % weekend -> 1column : date, 2-5column : Feature, 6-101column : Demand

            elseif ForecastData_ANN(i,8) == 5
                ForecastData_weekend_ANN(i,:) = ForecastData_ANN(i,:);

            %week
            elseif ForecastData_ANN(i,8) == 2
                ForecastData_week_ANN(i,:) = ForecastData_ANN(i,:); % week -> 1column : date, 2-5column : Feature, 6-101column : Demand

            elseif ForecastData_ANN(i,8) == 4
                ForecastData_week_ANN(i,:) = ForecastData_ANN(i,:);
            end
        end

    ForecastData_holiday_ANN( ~any(ForecastData_holiday_ANN,2), : ) = [];  % delete holiday rows
    ForecastData_weekend_ANN( ~any(ForecastData_weekend_ANN,2), : ) = [];  % delete weekend rows
    ForecastData_week_ANN( ~any(ForecastData_week_ANN,2), : ) = [];  % delete week rows

    % ANN

    for i_loop = 1:1:3
        net_holiday_ANN = net_holiday_ANN_loop{i_loop};
        net_weekend_ANN = net_weekend_ANN_loop{i_loop};
        net_week_ANN = net_week_ANN_loop{i_loop};
    
        % for test
        % kW

        % Predict the responses using the trained network

        result_ForecastData_ANN_loop = zeros(m_ForecastData_ANN,1);

        for i = 1:1:m_ForecastData_ANN

            % holiday
            if ForecastData_ANN(i,8) == 1
                x2_holiday_ANN = transpose(ForecastData_ANN(i,feature));
                result_ForecastData_ANN_loop(i,:) = net_holiday_ANN(x2_holiday_ANN);

            % weekend
            elseif ForecastData_ANN(i,8) == 3
                x2_weekend_ANN = transpose(ForecastData_ANN(i,feature));
                result_ForecastData_ANN_loop(i,:) = net_weekend_ANN(x2_weekend_ANN);

            elseif ForecastData_ANN(i,8) == 5
                x2_weekend_ANN = transpose(ForecastData_ANN(i,feature));
                result_ForecastData_ANN_loop(i,:) = net_weekend_ANN(x2_weekend_ANN);

            % week
            elseif ForecastData_ANN(i,8) == 2
                x2_week_ANN = transpose(ForecastData_ANN(i,feature));
                result_ForecastData_ANN_loop(i,:) = net_week_ANN(x2_week_ANN);

            elseif ForecastData_ANN(i,8) == 4
                x2_week_ANN = transpose(ForecastData_ANN(i,feature));
                result_ForecastData_ANN_loop(i,:) = net_week_ANN(x2_week_ANN);
            end
        end

        result_ForecastData_ANN{i_loop} = result_ForecastData_ANN_loop;
    end
    
    result_ForecastData_ANN_mean = result_ForecastData_ANN{1}+result_ForecastData_ANN{2}+result_ForecastData_ANN{3};
    
    result_ForecastData_ANN_final = result_ForecastData_ANN_mean/3;
    
    %  3. Create demand result excel file with the given file name

    %% ResultingData File

    % same period at ForecastData
    ResultingData_ANN(:,1:10) = ForecastData_ANN(:,1:10);

    % forecast Demand

    [m_ForecastData_ANN, ~]= size(ForecastData_ANN);

     ResultingData_ANN(:,11) = result_ForecastData_ANN_final;

    % 4. return mean forecast values arrary

    y_demand = ResultingData_ANN(1:m_ForecastData_ANN,11);
    
    
    %% err correction t_1 (short)
    
    % forecast err rate

    if exist('shortTermPastData','var')

        y_err_rate = DMget_err_correction_t_2(shortTermPastData,path);
        
        [m_ResultingData_ANN,~] = size(ResultingData_ANN);
        
        y_err_rate_result = zeros(m_ResultingData_ANN,1);
        
        j = 1;
        
        for i = 1:1:m_ResultingData_ANN
            if ForecastData_ANN(i,5)*4 == 0 & ForecastData_ANN(i,6) == 0
                y_err_rate_result(i,1) = y_err_rate(96,1);
            else
                y_err_rate_result(i,1) = y_err_rate((ForecastData_ANN(i,5)*4 + ForecastData_ANN(i,6)),1);
            end

            if i == m_ResultingData_ANN
            else
                if (ForecastData_ANN(i,4) - ForecastData_ANN((i+1),4)) == 0
                else
                    j = j + 1;
                end
            end
        end        

        y_demand_with_3 = y_demand ./ (1 - y_err_rate_result);

        y = y_demand_with_3;

    else
        y = y_demand;
    end


end

% toc
end
