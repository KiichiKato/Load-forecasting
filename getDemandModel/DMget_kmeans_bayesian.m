function y = DMget_kmeans_bayesian(flag,input,shortTermPastData,path)
% tic;

% disp('Matlab demand call function')

feature = 2:6;

if flag == 1

    PastDataExcelFile = input; % matrix

   %% PastData
    % PastData load
    new_format_PastData = PastDataExcelFile(1:(end-96*7),:);

    % PastData size
    [m_new_format_PastData, ~]= size(new_format_PastData);

    % if there is no 1 day past data
    if m_new_format_PastData < 96

        new_format_PastData(1:96,1) = new_format_PastData(1,1); % building ID
        new_format_PastData(1:96,2) = new_format_PastData(1,2);
        new_format_PastData(1:96,3) = new_format_PastData(1,3);
        new_format_PastData(1:96,4) = new_format_PastData(1,4);

        new_format_PastData(1:96,5) = transpose([0 0 0 1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7 8 8 8 8 9 9 9 9 10 10 10 10 ...
            11 11 11 11 12 12 12 12 13 13 13 13 14 14 14 14 15 15 15 15 16 16 16 16 17 17 17 17 18 18 18 18 ...
            19 19 19 19 20 20 20 20 21 21 21 21 22 22 22 22 23 23 23 23 0]);

        new_format_PastData(1:96,6) = transpose([1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 ...
            1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0]);

        new_format_PastData(1:96,7) = new_format_PastData(1,7);
        new_format_PastData(1:96,8) = new_format_PastData(1,8);
        new_format_PastData(1:96,9) = new_format_PastData(1,9);
        new_format_PastData(1:96,10) = new_format_PastData(1,10);

        new_format_PastData(1:96,11) = mean(new_format_PastData(1:m_new_format_PastData,11)); % demand
    else
    end

    H = transpose([0 0 0 1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7 8 8 8 8 9 9 9 9 10 10 10 10 ...
            11 11 11 11 12 12 12 12 13 13 13 13 14 14 14 14 15 15 15 15 16 16 16 16 17 17 17 17 18 18 18 18 ...
            19 19 19 19 20 20 20 20 21 21 21 21 22 22 22 22 23 23 23 23 0]);

    Q = transpose([1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 ...
            1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0]);

    %% Format change        

    % format_change_1 : new -> old
    old_format_PastData = DM_format_change_1(new_format_PastData);
    
    % old -> new format rechange
    new_format_PastData = DM_format_change_2(old_format_PastData);
    
    
    %% k-means, bayesian
    
    % check again the size of new_version_PastData

    [m_new_format_PastData, ~] = size(new_format_PastData);
    
   %% Train model

    % for train

    [PastData_holiday,PastData_weekend,PastData_week] = DM_step_group(old_format_PastData);

    % check again the size of raw_PastData because of delete
    [m_holiday_check, ~] = size(PastData_holiday);
    [m_weekend_check, ~] = size(PastData_weekend);
    [m_week_check, ~] = size(PastData_week);

    % k-means

    % PastData k-means K value

    [m_old_format_PastData, ~] = size(old_format_PastData);
    
    if (m_old_format_PastData) <= 7

        k_holiday = 1;
        k_weekend = 1;
        k_week = 2;

        % k-means past data index

        [idx_PastData_holiday,c_PastData_holiday] = kmeans(PastData_holiday(:,7:102),k_holiday);
        [idx_PastData_weekend,c_PastData_weekend] = kmeans(PastData_weekend(:,7:102),k_weekend);
        [idx_PastData_week,c_PastData_week] = kmeans(PastData_week(:,7:102),k_week);

        % bayesian

        %# lets split into training/testing

        % feature
        train_feature_holiday = PastData_holiday(1:end,feature); 
        train_feature_weekend = PastData_weekend(1:end,feature);
        train_feature_week = PastData_week(1:end,feature);

        % class index
        train_label_holiday = idx_PastData_holiday(1:end,1); 
        train_label_weekend = idx_PastData_weekend(1:end,1);
        train_label_week = idx_PastData_week(1:end,1);

        %# train model
        nb_holiday = fitcnb(train_feature_holiday,train_label_holiday,'Distribution','kernel');
        nb_weekend = fitcnb(train_feature_weekend,train_label_weekend,'Distribution','kernel');
        nb_week = fitcnb(train_feature_week,train_label_week,'Distribution','kernel');


    elseif (7 < (m_old_format_PastData)) & ((m_old_format_PastData) <= 30)

        k_holiday = 1;
        k_weekend = 2;
%         k_week = 2;
        
        % k-means past data index

        [idx_PastData_holiday,c_PastData_holiday] = kmeans(PastData_holiday(:,7:102),k_holiday);
        [idx_PastData_weekend,c_PastData_weekend] = kmeans(PastData_weekend(:,7:102),k_weekend);
        [idx_PastData_week,c_PastData_week] = kmeans(PastData_week(:,7:102),abs(round(mean(log10(var(PastData_week(:,7:7+23)))))));
%         [idx_PastData_week,c_PastData_week] = kmeans(PastData_week(:,7:102),k_week);

        % bayesian

        %# lets split into training/testing

        % feature
        train_feature_holiday = PastData_holiday(1:end,feature); 
        train_feature_weekend = PastData_weekend(1:end,feature);
        train_feature_week = PastData_week(1:end,feature);

        % class index
        train_label_holiday = idx_PastData_holiday(1:end,1); 
        train_label_weekend = idx_PastData_weekend(1:end,1);
        train_label_week = idx_PastData_week(1:end,1);

        %# train model
        nb_holiday = fitcnb(train_feature_holiday,train_label_holiday,'Distribution','kernel');
        nb_weekend = fitcnb(train_feature_weekend,train_label_weekend,'Distribution','kernel');
        nb_week = fitcnb(train_feature_week,train_label_week,'Distribution','kernel');
        
    else
        
    end
        
    for i_loop = 1:1:3
        if (m_old_format_PastData) >= 31

            % choose k
            if abs(var(PastData_week(:,7:102))) < 10
                if var(abs(var(PastData_week(:,7:102)))) < 0.5
                    kkk_start = abs(round(var(PastData_week(:,7:102))));
                    kkk_stop = abs(round(var(PastData_week(:,7:102)))); + 1;
                else
                    kkk_start = 5;
                    kkk_stop = 12;
                end
                

            else
                if var(abs(log10(var(PastData_week(:,7:102))))) < 0.5
                    kkk_start = abs(round(mean(log10(var(PastData_week(:,7:102)))))) - 1;
                    kkk_stop = abs(round(mean(log10(var(PastData_week(:,7:102)))))) + 1;
                else
                    kkk_start = 5;
                    kkk_stop = 12;
                end
            end
            
            result_MAPE = zeros(kkk_stop,1);
            
            for kkk = kkk_start:1:kkk_stop
                
            % old version format

            % PastData
            % 100% : total
            raw_100_PastData = old_format_PastData;
            [m_raw_100_PastData, ~] = size(raw_100_PastData);

            m_raw_70_PastData = round(m_raw_100_PastData * 0.7);
            m_raw_30_PastData = m_raw_100_PastData - m_raw_70_PastData;

            % 70% : train, 30% : validate
            raw_70_PastData = raw_100_PastData(1:m_raw_70_PastData,:);
            raw_30_PastData = raw_100_PastData(m_raw_70_PastData+1:end,:);


            % step_group
            [PastData_holiday,PastData_weekend,PastData_week] = DM_step_group(raw_70_PastData);

            % check again the size of raw_PastData because of delete
            [m_holiday_check, ~] = size(PastData_holiday);
            [m_weekend_check, ~] = size(PastData_weekend);
            [m_week_check, ~] = size(PastData_week);

            k_holiday = 1;
            k_weekend = kkk;

            % k-means past data index

            [idx_PastData_holiday,c_PastData_holiday] = kmeans(PastData_holiday(:,7:102),k_holiday);

            idx_PastData_holiday_array{k_holiday} = idx_PastData_holiday;
            c_PastData_holiday_array{k_holiday} = c_PastData_holiday;

            [idx_PastData_weekend,c_PastData_weekend] = kmeans(PastData_weekend(:,7:102),k_weekend);

            idx_PastData_weekend_array{k_weekend} = idx_PastData_weekend;
            c_PastData_weekend_array{k_weekend} = c_PastData_weekend;

            [idx_PastData_week,c_PastData_week] = kmeans(PastData_week(:,7:102),kkk);

            idx_PastData_week_array{kkk} = idx_PastData_week;
            c_PastData_week_array{kkk} = c_PastData_week;


            % bayesian

            %# lets split into training/testing

            % feature
            train_feature_holiday = PastData_holiday(1:end,feature);
            train_feature_weekend = PastData_weekend(1:end,feature);
            train_feature_week = PastData_week(1:end,feature);

            % class index
            train_label_holiday = idx_PastData_holiday(1:end,1); 
            train_label_weekend = idx_PastData_weekend(1:end,1);
            train_label_week = idx_PastData_week(1:end,1);

            %# train model
            nb_holiday_array{1} = fitcnb(train_feature_holiday,train_label_holiday,'Distribution','kernel');
            nb_weekend_array{k_weekend} = fitcnb(train_feature_weekend,train_label_weekend,'Distribution','kernel');
            nb_week_array{kkk} = fitcnb(train_feature_week,train_label_week,'Distribution','kernel');


            %% Test(to make err data)

            % new -> old version format

            % ForecastData
            raw_ForecastData = raw_30_PastData;

            [m_raw_ForecastData, ~] = size(raw_30_PastData);


            % Clustering
            % for test

            result_cluster_idx = zeros(m_raw_ForecastData,1);

            result_cluster_1D_day = zeros(m_raw_ForecastData,96);


            for i = 1:1:m_raw_ForecastData

                test_1D_day_feature(i,:) = raw_ForecastData(i,feature); % feature


                %# prediction
                if raw_ForecastData(i,4) == 1
                    result_cluster_idx(i,1) = nb_holiday_array{1}.predict(test_1D_day_feature(i,:));

                elseif raw_ForecastData(i,4) == 3
                    result_cluster_idx(i,1) = nb_weekend_array{k_weekend}.predict(test_1D_day_feature(i,:));

                elseif raw_ForecastData(i,4) == 5
                    result_cluster_idx(i,1) = nb_weekend_array{k_weekend}.predict(test_1D_day_feature(i,:));

                elseif raw_ForecastData(i,4) == 2
                    result_cluster_idx(i,1) = nb_week_array{kkk}.predict(test_1D_day_feature(i,:));

                elseif raw_ForecastData(i,4) == 4
                    result_cluster_idx(i,1) = nb_week_array{kkk}.predict(test_1D_day_feature(i,:));

                else

                end


                % idx -> kW


                if raw_ForecastData(i,4) == 1
                    result_cluster_1D_day(i,:) = c_PastData_holiday(result_cluster_idx(i,:),:);

                elseif raw_ForecastData(i,4) == 3
                    result_cluster_1D_day(i,:) = c_PastData_weekend(result_cluster_idx(i,:),:);

                elseif raw_ForecastData(i,4) == 5
                    result_cluster_1D_day(i,:) = c_PastData_weekend(result_cluster_idx(i,:),:);

                elseif raw_ForecastData(i,4) == 2
                    result_cluster_1D_day(i,:) = c_PastData_week(result_cluster_idx(i,:),:);

                elseif raw_ForecastData(i,4) == 4
                    result_cluster_1D_day(i,:) = c_PastData_week(result_cluster_idx(i,:),:);
                else
                end
            end


           %% Result err data

           result_cluster_1D_day_array{kkk} = result_cluster_1D_day;

            % err
            result_err_data_array{kkk} =  raw_30_PastData(:,7:102) - result_cluster_1D_day_array{kkk}; % real - forecast
            new_result_err_data = zeros(m_raw_30_PastData*96,1);


            err_rate_kkk = result_err_data_array{kkk} ./ raw_30_PastData(:,7:102);
            abs_err_rate_kkk = abs(err_rate_kkk);
            
%             result_MAPE = zeros(kkk,1);
            result_MAPE(kkk,1) = sum(mean(abs_err_rate_kkk))/96;

            end

            result_MAPE(~any(result_MAPE(:,1),2),1) = 100;

            min_MAPE = min(result_MAPE);

            [i_min_MAPE,~] = find(result_MAPE==min_MAPE);
            
            [m_i_min_MAPE,~] = size(i_min_MAPE);
            
            
            if m_i_min_MAPE > 1
                kkk = max(i_min_MAPE);
            
            else
                kkk = i_min_MAPE;
            end

            
        %% Train again (to update optimal kkk model)

        k_holiday = 1;
        k_weekend = kkk;

        % k-means past data index

%         idx_PastData_holiday = idx_PastData_holiday_array{kkk};
        c_PastData_holiday_save = c_PastData_holiday_array{1};

%         idx_PastData_weekend = idx_PastData_weekend_array{kkk};
        c_PastData_weekend_save = c_PastData_weekend_array{k_weekend};

%         idx_PastData_week = idx_PastData_week_array{kkk};
        c_PastData_week_save = c_PastData_week_array{1,kkk};

        % bayesian

        %# train model
        nb_holiday_save = nb_holiday_array{1};
        nb_weekend_save = nb_weekend_array{1,kkk};
        nb_week_save = nb_week_array{kkk};


        % make err using 30% past data to train ECF

        for i = 1:1:m_raw_30_PastData
            for j = 1:1:96
                new_result_err_data(j+(i-1)*96,1) = result_err_data_array{kkk}(i,j);
                raw_30_ForecastData(j+(i-1)*96,1) = result_cluster_1D_day_array{kkk}(i,j);
            end
        end

        
        err_PastData(:,1:10) = new_format_PastData(1+m_raw_70_PastData*96:end,1:10);

        err_PastData(:,11) = new_result_err_data;
        
        % save name
        
        building_num = num2str(PastDataExcelFile(2,1));
        
        Name = 'DM_err_correction_kmeans_bayesian_';
        Name = strcat(Name,building_num,'.mat');
        
        DMget_err_correction_ANN(1,err_PastData,Name,path);

        
        % PastData , Train work space data will save like .mat file

        % loop

        nb_holiday_loop{i_loop} = nb_holiday_save;
        nb_week_loop{i_loop} = nb_week_save;
        nb_weekend_loop{i_loop} = nb_weekend_save;
        c_PastData_holiday_loop{i_loop} = c_PastData_holiday_save;
        c_PastData_week_loop{i_loop} = c_PastData_week_save;
        c_PastData_weekend_loop{i_loop} = c_PastData_weekend_save;
        err_PastData_loop{i_loop} = err_PastData;
        
        clearvars nb_holiday nb_holiday_array nb_holiday_save
        clearvars nb_week nb_week_array nb_week_save
        clearvars nb_weekend nb_weekend_array nb_weekend_save
        
        clearvars c_PastData_holiday c_PastData_holiday_array c_PastData_holiday_save
        clearvars c_PastData_week c_PastData_week_array c_PastData_week_save
        clearvars c_PastData_weekend c_PastData_weekend_array c_PastData_weekend_save
        
        clearvars err_PastData
        
      
        else

        end
    end
    
    
    if (m_old_format_PastData) < 31
        
        clearvars input;
        clearvars shortTermPastData;
        
        building_num = num2str(PastDataExcelFile(2,1));

        save_name = '\demand_Model_';
        save_name = strcat(path,save_name,building_num,'.mat');
        
        
        save(save_name,'nb_holiday','nb_week','nb_weekend',...
            'c_PastData_holiday','c_PastData_week','c_PastData_weekend'...
            ,'feature','err_PastData','raw_30_ForecastData');
    else
        
        clearvars input;
        clearvars shortTermPastData;
        
        building_num = num2str(PastDataExcelFile(2,1));

        save_name = '\demand_Model_';
        save_name = strcat(path,save_name,building_num,'.mat');
        
        save(save_name,'raw_30_ForecastData'...
        ,'nb_holiday_loop','nb_week_loop','nb_weekend_loop',...
        'c_PastData_holiday_loop','c_PastData_week_loop','c_PastData_weekend_loop'...
        ,'feature','err_PastData_loop');
    end


else

    % disp('Matlab demand call function')
    % file does not exist so use already created .mat
    
   %% load .mat file
      %#function ClassificationNaiveBayes
      
    ForecastExcelFile = input;
          
    building_num = num2str(ForecastExcelFile(2,1));

    load_name = '\demand_Model_';
    load_name = strcat(path,load_name,building_num,'.mat');

    load(load_name,'-mat');


    %% ForecastData

    % ForecastData load
    new_version_ForecastData = ForecastExcelFile;

    % ForecastData size
    [m_new_veresion_ForecastData, ~]= size(new_version_ForecastData);

    % Feature data

    j = 1;

    % using day type we can find period of forecast
    Forecast_day = 1;

    for day = 1:1:m_new_veresion_ForecastData

        if m_new_veresion_ForecastData == (m_new_veresion_ForecastData - 1)
            if abs(new_version_ForecastData((day+1),7) - new_version_ForecastData(day,7)) > 0
                Forecast_day = Forecast_day + 1;
            else
            end  
        break
        end
    end

    old_format_condition_forecast = zeros(Forecast_day,6);


    for i = 1:1:m_new_veresion_ForecastData


        if i == m_new_veresion_ForecastData

            old_format_condition_forecast(j,3:6) = new_version_ForecastData(i,7:10);
            old_format_condition_forecast(j,2) = new_version_ForecastData(i,2)*10000 + new_version_ForecastData(i,3)*100 + new_version_ForecastData(i,4);

        else

            old_format_condition_forecast(j,3:6) = new_version_ForecastData(i,7:10);
            old_format_condition_forecast(j,2) = new_version_ForecastData(i,2)*10000 + new_version_ForecastData(i,3)*100 + new_version_ForecastData(i,4);

            if (new_version_ForecastData(i,4) - new_version_ForecastData((i+1),4)) == 0
            else
                j = j + 1;
            end
        end
    end

    %% format change
    
    % new -> old version format

    % ForecastData
    raw_ForecastData = old_format_condition_forecast;

    [m_raw_ForecastData, ~] = size(old_format_condition_forecast);

    %% k-means, bayesian Test

    % Clustering
    % for test

    result_cluster_idx = zeros(m_raw_ForecastData,1);

    result_cluster_1D_day_loop = zeros(m_raw_ForecastData,96);

    
    for i_loop = 1:1:3
        
        nb_holiday = nb_holiday_loop{i_loop};
        nb_week = nb_week_loop{i_loop};
        nb_weekend = nb_weekend_loop{i_loop};
        c_PastData_holiday = c_PastData_holiday_loop{i_loop};
        c_PastData_week = c_PastData_week_loop{i_loop};
        c_PastData_weekend = c_PastData_weekend_loop{i_loop};
        err_PastData = err_PastData_loop{i_loop};
    
    
        for i_forecast = 1:1:m_raw_ForecastData

            test_1D_day_feature(i_forecast,:) = raw_ForecastData(i_forecast,feature); % feature


            %# prediction
            if raw_ForecastData(i_forecast,4) == 1
                result_cluster_idx(i_forecast,1) = nb_holiday.predict(test_1D_day_feature(i_forecast,:));

            elseif raw_ForecastData(i_forecast,4) == 3
                result_cluster_idx(i_forecast,1) = nb_weekend.predict(test_1D_day_feature(i_forecast,:));

            elseif raw_ForecastData(i_forecast,4) == 5
                result_cluster_idx(i_forecast,1) = nb_weekend.predict(test_1D_day_feature(i_forecast,:));

            elseif raw_ForecastData(i_forecast,4) == 2
                result_cluster_idx(i_forecast,1) = nb_week.predict(test_1D_day_feature(i_forecast,:));

            elseif raw_ForecastData(i_forecast,4) == 4
                result_cluster_idx(i_forecast,1) = nb_week.predict(test_1D_day_feature(i_forecast,:));

            end


            % idx -> kW

            if raw_ForecastData(i_forecast,4) == 1
                result_cluster_1D_day_loop(i_forecast,:) = c_PastData_holiday(result_cluster_idx(i_forecast,:),:);

            elseif raw_ForecastData(i_forecast,4) == 3
                result_cluster_1D_day_loop(i_forecast,:) = c_PastData_weekend(result_cluster_idx(i_forecast,:),:);

            elseif raw_ForecastData(i_forecast,4) == 5
                result_cluster_1D_day_loop(i_forecast,:) = c_PastData_weekend(result_cluster_idx(i_forecast,:),:);             

            elseif raw_ForecastData(i_forecast,4) == 2
                result_cluster_1D_day_loop(i_forecast,:) = c_PastData_week(result_cluster_idx(i_forecast,:),:);                   

            elseif raw_ForecastData(i_forecast,4) == 4
                result_cluster_1D_day_loop(i_forecast,:) = c_PastData_week(result_cluster_idx(i_forecast,:),:);                
            end
            

        end

    
    result_cluster_1D_day{i_loop} = result_cluster_1D_day_loop;
        
    end
    
    result_cluster_1D_day_mean = result_cluster_1D_day{1}+result_cluster_1D_day{2}+result_cluster_1D_day{3};
    
    result_cluster_1D_day_final = result_cluster_1D_day_mean/3;
    
    
    %% ResultingData File
    % 3. Create demand result excel file with the given file name
    
    % same period at ForecastData
    new_version_ResultingData(:,1:10) = new_version_ForecastData(:,1:10);

    % forecast Demand

    [m_new_veresion_ForecastData, ~]= size(new_version_ForecastData);

    j = 1;

    for i = 1:1:m_new_veresion_ForecastData
        if new_version_ForecastData(i,5) == 0 & new_version_ForecastData(i,6) == 0
            new_version_ResultingData(i,11) = result_cluster_1D_day_final(j,96);
        else
            new_version_ResultingData(i,11) = result_cluster_1D_day_final(j,(new_version_ForecastData(i,5)*4 + new_version_ForecastData(i,6)));
        end
        
        if i == m_new_veresion_ForecastData
        else
            if (new_version_ForecastData(i,4) - new_version_ForecastData((i+1),4)) == 0
            else
                j = j + 1;
            end
        end
    end


    %% err correction
    % variance error correction
    
    building_num = num2str(ForecastExcelFile(2,1));
        
    Name = 'DM_err_correction_kmeans_bayesian_';
    Name = strcat(Name,building_num,'.mat');
    
    y_err = DMget_err_correction_ANN(2,ForecastExcelFile,Name,path);

    [m_y_err,~] = size(y_err);
    
    y_err_2 = zeros(m_y_err,1);
    
    for i = 1:2:(m_y_err-1)
        y_err_2(i,1) = mean(y_err(i:i+1,1));
        y_err_2(i+1,1) = mean(y_err(i:i+1,1));
    end


    y_demand = new_version_ResultingData(1:m_new_veresion_ForecastData,11);


%     y_demand_with_1 = y_demand + y_err;
    y_demand_with_2 = y_demand + y_err_2;

    
    % bias error correction
    % err correction t_1 (short)
    
    % forecast err rate

     if exist('shortTermPastData','var')
         
        y_err_rate = DMget_err_correction_t_1(shortTermPastData,path);

        [m_new_veresion_ForecastData, ~]= size(new_version_ForecastData);

        j = 1;

        y_err_rate_result = zeros(m_new_veresion_ForecastData,1);
    
        count_1 = 1; % to count abs err rate bigger than 1
        
    for i = 1:1:m_new_veresion_ForecastData
        if new_version_ForecastData(i,5)*4 == 0 & new_version_ForecastData(i,6) == 0
            y_err_rate_result(i,1) = y_err_rate(1,96);
        else
            y_err_rate_result(i,1) = y_err_rate(1,(new_version_ForecastData(i,5)*4 + new_version_ForecastData(i,6)));
        end

        if abs(y_err_rate_result(i,1)) > 1
            count_1 = count_1 + 1;
        else
        end
        
        if i == m_new_veresion_ForecastData
        else
            if (new_version_ForecastData(i,4) - new_version_ForecastData((i+1),4)) == 0
            else
                j = j + 1;
            end
        end
    end
    
     y_demand_with_3 = y_demand ./ (1 - y_err_rate_result);
    
     if count_1 > 4
         y = y_demand_with_2;
     else
        y = y_demand_with_3;
     end

     else
         y = y_demand_with_2;
     end
     
end

% toc
end