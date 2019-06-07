%% Format change
% 1 colunm demand -> 96 colunm demand

function y = DMget_format_change_1(input_data)

    new_format_PastData = input_data;

    % check again the size of new_version_PastData because of copy
    [m_new_format_PastData, ~] = size(new_format_PastData);

    % Demand data

    j = 1;

    old_format_PastData = zeros(round(m_new_format_PastData/96),102);

    for i = 1:1:m_new_format_PastData
        if new_format_PastData(i,5) == 0 & new_format_PastData(i,6) == 0
            old_format_PastData(j,6 + 96) = new_format_PastData(i,11);
        else
            old_format_PastData(j,6 + (new_format_PastData(i,5)*4 + new_format_PastData(i,6))) = new_format_PastData(i,11);
        end
        
        if i == m_new_format_PastData
        else
            if (new_format_PastData(i,4) - new_format_PastData((i+1),4)) == 0
            else
                j = j + 1;
            end
        end
    end

    % Feature data

    j = 1;

    old_format_PastData(1:end,1) = new_format_PastData(1,1);

    for i = 1:1:m_new_format_PastData

        if i == m_new_format_PastData
            old_format_PastData(j,3:6) = new_format_PastData(i,7:10);
            old_format_PastData(j,2) = new_format_PastData(i,2)*10000 + new_format_PastData(i,3)*100 + new_format_PastData(i,4);
        else
            old_format_PastData(j,3:6) = new_format_PastData(i,7:10);
            old_format_PastData(j,2) = new_format_PastData(i,2)*10000 + new_format_PastData(i,3)*100 + new_format_PastData(i,4);
                if (new_format_PastData(i,4) - new_format_PastData((i+1),4)) == 0
                else
                    j = j + 1;
                end
        end
    end

    % if there is 0 value in demand column -> delete (or change column avg)

    for delete_i = 7:1:102
%             old_format_condition_PastData(~any(old_format_condition_PastData(:,delete_i),2),delete_i) = mean(old_format_condition_PastData(:,delete_i));
        old_format_PastData(~any(old_format_PastData(:,delete_i),2),:) = [];
    end

    for delete_i = 2:1:4
        old_format_PastData(~any(old_format_PastData(:,delete_i),2),:) = [];
    end

    y = old_format_PastData;
    
end
