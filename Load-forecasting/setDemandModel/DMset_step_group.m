function [PastData_holiday,PastData_weekend,PastData_week] = DMset_step_group(old_format_PastData)

    [m_old_format_PastData, ~] = size(old_format_PastData);

    % holiday, weekend, week classify

    PastData_holiday = zeros(m_old_format_PastData,102);
    PastData_weekend = zeros(m_old_format_PastData,102);
    PastData_week = zeros(m_old_format_PastData,102);

    for i = 1:1:m_old_format_PastData
        if old_format_PastData(i,4) == 1
            PastData_holiday(i,:) = old_format_PastData(i,:); % holiday -> 2column : date, 3-6column : Feature, 7-102column : Demand
            
        elseif old_format_PastData(i,4) == 3
            PastData_weekend(i,:) = old_format_PastData(i,:); % weekend -> 2column : date, 3-6column : Feature, 7-102column : Demand
            
        elseif old_format_PastData(i,4) == 5
            PastData_weekend(i,:) = old_format_PastData(i,:);
            
        elseif old_format_PastData(i,4) == 2
            PastData_week(i,:) = old_format_PastData(i,:); % week -> 2column : date, 3-6column : Feature, 7-102column : Demand
            
        elseif old_format_PastData(i,4) == 4
            PastData_week(i,:) = old_format_PastData(i,:);
        end
    end

    PastData_holiday( ~any(PastData_holiday,2), : ) = [];  % delete holiday rows
    PastData_weekend( ~any(PastData_weekend,2), : ) = [];  % delete weekend rows
    PastData_week( ~any(PastData_week,2), : ) = [];  % delete week rows


    % check the size of holiday, weekend, week

    [m_holiday_check, ~] = size(PastData_holiday);
    [m_weekend_check, ~] = size(PastData_weekend);
    [m_week_check, ~] = size(PastData_week);


    % if there are not enough data -> just copy
    % old format

    if m_holiday_check <= 2
        PastData_holiday(2,:) = old_format_PastData(end,:);
        PastData_holiday(3,:) = old_format_PastData(end,:);
        PastData_holiday(2:3,4) = 1;
%         msgbox('copied last day data to holiday','old format for train')
    else
    end

    if m_weekend_check <= 2
        PastData_weekend(2,:) = old_format_PastData(end,:);
        PastData_weekend(3,:) = old_format_PastData(end,:);
        PastData_weekend(2,4) = 3;
        PastData_weekend(3,4) = 5;
%         msgbox('copied last day data to weekend','old format for train')
    else
    end

    if m_week_check <= 2
        PastData_week(2,:) = old_format_PastData(end,:);
        PastData_week(3,:) = old_format_PastData(end,:);
        PastData_weekend(2,4) = 2;
        PastData_weekend(3,4) = 4;
%         msgbox('copied last day data to week','old format for train')
    else
    end


    % delete 1st row

    PastData_holiday(1,:) = [];
    PastData_weekend(1,:) = [];
    PastData_week(1,:) = [];
    
end