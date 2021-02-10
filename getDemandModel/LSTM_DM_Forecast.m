function y=LSTM_DM_Forecast(input, path)
    % Display for user
    disp('Validating the LSTM model....');
    
    %% Read Input data
    % get building number
    building_num = num2str(input.BuildingIndex(1));
    % load a '.mat' file
    load_name = '\DM_trainedLSTM_';
    load_name = strcat(path,load_name,building_num,'.mat');
    load(load_name,'-mat');
    
    %% Forecast
    input=input(:, colPredictors);
    XTest = table2array(input).';
    net = predictAndUpdateState(net,XTrain);

    numTimeStepsTest = size(XTest,2);
    for i = 1:numTimeStepsTest
         [net,YPred(:,i)] = predictAndUpdateState(net,XTest(:,i),'ExecutionEnvironment','auto');
    end
    YPred = sig*YPred + mu;
    
    y = YPred;

end    