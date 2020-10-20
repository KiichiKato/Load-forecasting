function DMset_Kmeans_Training(input, colPredictors, path)

    %% Read inpudata
    %     train_data = LongTermpastData(~any(isnan(LongTermpastData),2),:); % Eliminate NaN from inputdata
    %     %% Format error check (to be modified)
    %     % "-1" if there is an error in the LongpastData's data form, or "1"
    %     [~,number_of_columns1] = size(train_data);
    %     if number_of_columns1 == 12
    %         error_status = 1;
    %     else
    %         error_status = -1;
    %     end
    
    % Display for user
    disp('Training the k-menas & Baysian model....');

    %% Kmeans clustering for Charge/Discharge data
    % Extract appropriate data from inputdata for Energy transactions: pastEnegyTrans
    % Extract appropriate data from inputdata for SOC prediction: pastSOC
    
    AllOfPredictors= input(:,colPredictors); %colPredictors('BuildingIndex' 'Year' 'Month' 'Day' 'Hour' 'Quarter' 'DayOfWeek' 'Holiday' 'HighestTemp' 'Weather')のデータ

    Demand = input.Demand; % All of "Demand"    
    %Demand = normalize(Demand);
    
    % Set K using GapEvaluation
    eva_Demand = evalclusters(Demand,'kmeans','gap','B',100,'KList',[1:20]);%,'ReferenceDistribution','uniform','SearchMethod','firstMaxSE'); %Kの数を求める
    K=eva_Demand.OptimalK; %evalclustersで求めたKの値
    
    % Train k-means clustering
    [idx_PastData, c_PastData] = kmeans(Demand,K);
    
    % Train multiclass naive Bayes model
    nb_PastData = fitcnb(AllOfPredictors, idx_PastData,'Distribution','kernel');
        
    %% Save trained data in .mat files
    % idx_EnergyTrans: index for each Charge/Discharge records
    % idx_SOC: index for each SOC records
    % k_EnergyTrans: optimal K for Charge/Discharge (experimentally chosen)
    % k_SOC: optimal K for SOC (experimentally chosen)
    % nb_EnergyTrans: Trained Baysian model for Charge/Discharge [kwh]
    % nb_SOC: Trained Baysian model for SOC[%]
    % c_EnergyTrans: centroid for each cluster. The number of these values must correspond with k_EnergyTrans
    % c_SOC: centroid for each cluster
    building_num =mat2str(table2array(input(2,1))); % building number is necessary to be distinguished from other builiding mat files  
    save_name = '\DM_trainedKmeans_';
    save_name = strcat(path,save_name,building_num,'.mat');     
    save(save_name,'nb_PastData','idx_PastData','K','c_PastData');
        
    disp('Training the k-menas & Baysian model.... Done!');

end