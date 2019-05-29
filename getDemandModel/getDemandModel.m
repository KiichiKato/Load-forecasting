% ---------------------------------------------------------------------------
% Load prediction: Foecasting algorithm 
% 2018/11/25 Updated Daisuke Kodaira 
% daisuke.kodaira03@gmail.com
%
% function flag = demandForecast(shortTermPastData, ForecastData, ResultData)
%     flag =1 ; if operation is completed successfully
%     flag = -1; if operation fails.
%     This function depends on demandModel.mat. If these files are not found return -1.
%     The output of the function is "ResultData.csv"
% ----------------------------------------------------------------------------

function flag = getDemandModel(shortTermPastData, ForecastData, ResultData)
    tic;
 
    %% Input errors check and Load data
    if exist(shortTermPastData) == 0 || exist(ForecastData) == 0
        flag = -1;
        errMessage =  'ERROR: one of the input csv files is missing';
        disp(errMessage)
        return
    else
        short_past_load = csvread(shortTermPastData,1,0);
        predictors = csvread(ForecastData,1,0);
        Resultfile = ResultData;    
    end       
    
    %% Get file path of csv data
    filepath = fileparts(shortTermPastData);
    buildingIndex = short_past_load(1,1);
    
    %% Error recognition: Check mat files exist
    name1 = [filepath, '\', 'demand_Model_', num2str(buildingIndex), '.mat'];
    name2 = [filepath, '\', 'DM_err_correction_kmeans_bayesian_', num2str(buildingIndex), '.mat'];
    name3 = [filepath, '\', 'DM_err_distribution_', num2str(buildingIndex), '.mat'];
    name4 = [filepath, '\', 'DM_fitnet_ANN_', num2str(buildingIndex), '.mat'];
    name5 = [filepath, '\', 'DM_pso_coeff_', num2str(buildingIndex), '.mat'];
    if exist(name1) == 0 || exist(name2) == 0 || exist(name3) == 0 || exist(name4) == 0 || exist(name5) == 0
        flag = -1;
        errMessage = 'ERROR: .mat files is not found (or the building index is not consistent in "demandModelDev" and "demandForecst" phase)';
        disp(errMessage)
        return
    end    
    
    %% Load .mat files from give path of "shortTermPastData"
    s1 = 'DM_pso_coeff_';
    s2 = 'DM_err_distribution_';
    s3 = num2str(buildingIndex);    
    name(1).string = strcat(s1,s3);
    name(2).string = strcat(s2,s3);
    varX(1).value = 'coeff';
    varX(2).value = 'err_distribution';
    extention='.mat';
    for i = 1:size(varX,2)
        matname = fullfile(filepath, [name(i).string extention]);
        load(matname);
    end  
       
    %% parameters
    op_flag = 2; % 2: forecast mode(validation)
    ci_percentage = 0.05; % 0.05 = 95% it must be between 0 to 1      
    
    %% Prediction for test data
    predicted_load(1).data = DMget_kmeans_bayesian(op_flag, predictors, short_past_load, filepath);
    predicted_load(2).data = DMget_fitnet_ANN(op_flag, predictors, short_past_load, filepath);   

    %% Prediction result
    for hour = 1:24
        for i = 1:size(coeff(1).data,1) % the number of prediction methods(k-means and fitnet)
            if i == 1
                yDetermPred(1+(hour-1)*4:hour*4,:) = coeff(hour).data(i).*predicted_load(i).data(1+(hour-1)*4:hour*4);
            else
                yDetermPred(1+(hour-1)*4:hour*4,:) = yDetermPred(1+(hour-1)*4:hour*4,:) + coeff(hour).data(i).*predicted_load(i).data(1+(hour-1)*4:hour*4);  
            end
        end
    end    
    %% Generate Result file    
    % Headers for output file
    hedder = {'BuildingIndex', 'Year', 'Month', 'Day', 'Hour', 'Quarter', 'DemandMean', 'CIMin', 'CIMax', 'CILevel', 'pmfStartIndx', 'pmfStep', ...
                      'DemandpmfData1', 'DemandpmfData2', 'DemandpmfData3', 'DemandpmfData4', 'DemandpmfData5', 'DemandpmfData6' ...
                      'DemandpmfData7', 'DemandpmfData8', 'DemandpmfData9', 'DemandpmfData10'};
    fid = fopen(Resultfile,'wt');
    fprintf(fid,'%s,',hedder{:});
    fprintf(fid,'\n');
        
    % Make distribution of prediction
    % Note: "err_distribution.err" ->  error value
    %           "err_distribution.pred" -> prediction value (err + deterministic prediction)
    % err_distribution
    for i = 1:size(yDetermPred,1)
        hour = predictors(i,5)+1;   % hour 1~24
        quater = predictors(i,6)+1; % quater 1~4
        prob_prediction(hour, quater).pred = yDetermPred(i)+err_distribution(hour, quater).err;
        prob_prediction(hour, quater).pred = max(prob_prediction(hour, quater).pred, 0);    % all elements must be bigger than zero
        % When the validation date is for only one day, generate duplicated records for mean function
        if size(prob_prediction(hour, quater).pred, 2) == 1
            prob_prediction(hour, quater).pred = [prob_prediction(hour, quater).pred prob_prediction(hour, quater).pred];
        end
        % Get mean value of Probabilistic load prediction
        prob_prediction(hour, quater).mean = mean(prob_prediction(hour, quater).pred)';
        % Get Confidence Interval
        [PImean(i,1), PImin(i,1), PImax(i,1)] = DMget_GetConfInter(prob_prediction(hour, quater).pred);   % 2sigma(95%) boundaries return    
        % Generate probabilistic mass function(PMF) for result csv file
        [demandpmfData(i,:), edges(i,:)] = histcounts(prob_prediction(hour, quater).mean, 10, 'Normalization', 'probability');
        pmfStart(i,:) = edges(i,1);
        pmfStart(i,:) = max(pmfStart(i,:), 0); % all elements must be bigger than zero
        pmfStep(i,:) =  abs(edges(i,1) - edges(i,2));
     end
    
    % Make matrix to be written in "ResultData.csv"
    result = [predictors(:,1:6) PImean PImin PImax 100*(1-ci_percentage)*ones(size(yDetermPred,1),1) pmfStart pmfStep demandpmfData];
    fprintf(fid,['%d,', '%4d,', '%02d,', '%02d,', '%02d,', '%d,', '%f,', '%f,', '%f,', '%02d,', repmat('%f,',1,12) '\n'], result');
    fclose(fid);
    
    % for debugging --------------------------------------------------------
    observed = csvread('TargetData.csv');
    % observed = nan(size(y_mean,1), 1);
    boundaries =  [PImin, PImax];
    DMget_graph_desc(1:size(predictors,1), yDetermPred, observed, boundaries, 'Combined for forecast data', ci_percentage); % Combined
    DMget_graph_desc(1:size(predictors,1), predicted_load(1).data, observed, [], 'k-means for forecast data', ci_percentage); % k-means
    DMget_graph_desc(1:size(predictors,1), predicted_load(2).data, observed, [], 'fitnet ANN for forecast data', ci_percentage); % NN
    % Cover Rate of PI
    count = 0;
    for i = 1:size(observed,1)
        if (PImin(i)<=observed(i)) && (observed(i)<=PImax(i))
            count = count+1;
        end
    end
    PICoverRate = 100*count/size(observed,1);
    MAPE(1) = mean(abs(yDetermPred - observed)*100./observed); % combined
    MAPE(2) = mean(abs(predicted_load(1).data - observed)*100./observed); % k-means
    MAPE(3) = mean(abs(predicted_load(2).data - observed)*100./observed); % fitnet
    disp(['PI cover rate is ',num2str(PICoverRate), '[%]/', num2str(100*(1-ci_percentage)), '[%]'])
    disp(['MAPE of demand mean: ', num2str(MAPE(1)), '[%]'])
    disp(['MAPE of kmeans: ', num2str(MAPE(2)), '[%]'])
    disp(['MAPE of fitnet: ', num2str(MAPE(3)), '[%]'])    
    % for debugging --------------------------------------------------------------------- 

    flag = 1;
    toc;
end
