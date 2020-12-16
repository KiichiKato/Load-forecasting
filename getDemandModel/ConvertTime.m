function y=ConvertTime(input,flag)
%flag = 2 : demand is not exist

years = input.Year(end)-input.Year(1)+1;

%% 年ごとにデータを分ける

for i=1:years
    Year=input.Year==input.Year(1)+(i-1);
    YearlyData=input(Year,2:6);
    
    %% 月ごとにデータを分ける
    
    for j=YearlyData.Month(1):YearlyData.Month(end)
        Month= YearlyData.Month == j;
        MonthryData=YearlyData(Month,:);
        clear Month
        H = height(MonthryData);
        Month=MonthryData.Month(1);
      %% Judge days of the month (31or30or29or28days)
        if Month==2
            if MonthryData.Year(1)/400==0
                Dayfloat=((MonthryData.Day-1)*96+MonthryData.Hour*4+MonthryData.Quarter)/(29*96);
                Day=29;
            elseif MonthryData.Year(1)/100==0
                Dayfloat=((MonthryData.Day-1)*96+MonthryData.Hour*4+MonthryData.Quarter)/(28*96);
                Day=28;                
            elseif MonthryData.Year(1)/40==0
                Dayfloat=((MonthryData.Day-1)*96+MonthryData.Hour*4+MonthryData.Quarter)/(29*96);
                Day=29;
            else
                Dayfloat=((MonthryData.Day-1)*96+MonthryData.Hour*4+MonthryData.Quarter)/(28*96);
                Day=28;
            end
        elseif Month==4||Month==6||Month==9||Month==11
            Dayfloat=((MonthryData.Day-1)*96+MonthryData.Hour*4+MonthryData.Quarter)/(30*96);
            Day=30;
        else
            Dayfloat=((MonthryData.Day-1)*96+MonthryData.Hour*4+MonthryData.Quarter)/(31*96);
            Day=31;
        end
        
        for k=1:H
         MonthryTimeCos(j).data(k,1)= cos(2*pi*Dayfloat(k,1));
         MonthryTimeSin(j).data(k,1) = sin(2*pi*Dayfloat(k,1));
        end
    end
    
    X=size(MonthryTimeCos,2);
    
    %% 月ごとのデータを1年分にまとめる
    
    for j=2:X
         MonthryTimeCos(1).data= cat(1,MonthryTimeCos(1).data,MonthryTimeCos(j).data);
         MonthryTimeSin(1).data= cat(1,MonthryTimeSin(1).data,MonthryTimeSin(j).data);
    end
    H2 = size(MonthryTimeCos(1).data,1);
    for k=1:H2
         YearlyTimeCos(i).data(k,1)= MonthryTimeCos(1).data(k,1);
         YearlyTimeSin(i).data(k,1) = MonthryTimeSin(1).data(k,1);
    end
    clear MonthryTimeCos MonthryTimeSin Month MonthryData Dayfloat
end

%% 年ごとのデータをすべてまとめる

X2=size(YearlyTimeCos,2);
    for i=2:X2
         YearlyTimeCos(1).data= cat(1,YearlyTimeCos(1).data,YearlyTimeCos(i).data);
         YearlyTimeSin(1).data= cat(1,YearlyTimeSin(1).data,YearlyTimeSin(i).data);
    end
CyclicalMonthCos=YearlyTimeCos(1).data;
CyclicalMonthSin=YearlyTimeSin(1).data;

input.CyclicalMonthCos = CyclicalMonthCos;
input.CyclicalMonthSin = CyclicalMonthSin;

Weekfloat=((input.DayOfWeek-1)*96+input.Hour*4+input.Quarter)/672;
input.CyclicalWeekCos=cos(2*pi*Weekfloat);
input.CyclicalWeekSin=sin(2*pi*Weekfloat);

hourfloat=(input.Hour*4+input.Quarter)/96;
input.CyclicalDayCos=cos(2*pi*hourfloat);
input.CyclicalDaySin=sin(2*pi*hourfloat);

convertdata=input(:,1:10);
convertdata.CyclicalMonthCos = CyclicalMonthCos;
convertdata.CyclicalMonthSin = CyclicalMonthSin;
convertdata.CyclicalWeekCos=cos(2*pi*Weekfloat);
convertdata.CyclicalWeekSin=sin(2*pi*Weekfloat);
convertdata.CyclicalDayCos=cos(2*pi*hourfloat);
convertdata.CyclicalDaySin=sin(2*pi*hourfloat);
if flag==1
 convertdata.Demand=input.Demand;
end

y=convertdata;


