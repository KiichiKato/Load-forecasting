function DMset_LSTM_Training(input, colPredictors, path)
    % Display for user
    disp('Training the LSTM model....');
    AllOfPredictors= input(:,colPredictors);
    inputdata = table2array(input).';
    Predicterdata = table2array(AllOfPredictors).';
    data=(input.Demand).';
    
    %%

    dataTest = data;
    mu = mean(data);
    sig = std(data);
    mu2 = mean(Predicterdata,2);
    sig2 = std(Predicterdata,0,2);

    dataTrainStandardized = (data - mu) / sig;
    for i= 1:size(Predicterdata,1) 
     if sig2(i,1)==0
        PredicterdataStandardized(i,:) = (Predicterdata(i,:));
     else
        PredicterdataStandardized(i,:) = (Predicterdata(i,:) - mu2(i,1)) / sig2(i,1);
     end
    end
    XTrain = Predicterdata;
    YTrain = dataTrainStandardized;
    
    numFeatures = size(XTrain,1);
    numResponses = size(YTrain,1);
    
    numHiddenUnits = 100;
    layers = [ ...
        sequenceInputLayer(numFeatures) 
        lstmLayer(numHiddenUnits)   
        lstmLayer(numHiddenUnits)
        fullyConnectedLayer(numResponses)
        regressionLayer];
    options = trainingOptions('adam', ...
        'MaxEpochs',100, ...
        'GradientThreshold',1, ...
        'InitialLearnRate',0.005, ...
        'LearnRateSchedule','piecewise', ...
        'LearnRateDropPeriod',125, ...
        'LearnRateDropFactor',0.2, ...
        'Verbose',0);
    

    net = trainNetwork(XTrain,YTrain,layers,options);
    
    
    

    %% save result mat file
    building_num = num2str(input.BuildingIndex(1));
    save_name1 = '\DM_trainedLSTM_';
    save_fullPath = strcat(path,save_name1,building_num,'.mat');
    clearvars path;
    save(save_fullPath, 'colPredictors' , 'net','sig','mu','data','XTrain'); 
    % Display for user
    disp('Training the LSTM model.... Done!');
end    