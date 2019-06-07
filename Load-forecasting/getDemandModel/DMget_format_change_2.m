%% Format change
% 96 colunm demand -> 1 colunm demand


function y = DMget_format_change_2(input_data)

    H = transpose([0 0 0 1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5 6 6 6 6 7 7 7 7 8 8 8 8 9 9 9 9 10 10 10 10 ...
            11 11 11 11 12 12 12 12 13 13 13 13 14 14 14 14 15 15 15 15 16 16 16 16 17 17 17 17 18 18 18 18 ...
            19 19 19 19 20 20 20 20 21 21 21 21 22 22 22 22 23 23 23 23 0]);

    Q = transpose([1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 ...
            1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0 1 2 3 0]);

    old_format_PastData = input_data;
    
    [re_m,~] = size(old_format_PastData);

    % demand
    % column : 7 - 102

    for i = 1:1:re_m
        for j = 1:1:96
            data_Period(j+96*(i-1),11) = old_format_PastData(i,6+j);
        end
    end

    % feature
    % column : 2 - 5

    for i = 1:1:re_m
        for j = 1:1:96
            data_Period(j+96*(i-1),7:10) = old_format_PastData(i,3:6);
            data_Date(j+96*(i-1),1:2) = old_format_PastData(i,1:2);
        end
    end

    % date
    % column : 1

    for i = 1:1:(re_m*96)

        new_Date(i,1) = data_Date(i,1); % Year

        new_Date(i,2) = round(data_Date(i,2),-4)/10000; % Year

        new_Date(i,3) = (round(data_Date(i,2),-2)-round(data_Date(i,2),-4))/100; % Month

        new_Date(i,4) = mod(mod(data_Date(i,2),round(data_Date(i,2),-4)),100); % Day

    end


    new_format_PastData = zeros(re_m*96,11);

    % column 1 - 4 : buildingIndex, Year, Month, Day

    new_format_PastData(1:re_m*96,1:4) = new_Date(1:re_m*96,1:4);

    % column 5 - 6 : Hour, Quarter

    for i = 1:1:re_m*96
        if mod(i,96) == 0
            new_format_PastData(i,5) = H(96,1);
            new_format_PastData(i,6) = Q(96,1);
        else
            new_format_PastData(i,5) = H(mod(i,96),1);
            new_format_PastData(i,6) = Q(mod(i,96),1);
        end
    end

    % column 7 - 11 : feature, demand

    new_format_PastData(1:re_m*96,7:11) = data_Period(1:re_m*96,7:11);
    
    
    y = new_format_PastData;
    
end