clear all;
clc;
close all;
pass = pwd;
y_pred = getDemandModel([pwd,'\','shortTermPastData.csv'],...
                        [pwd,'\','ForecastData.csv'],...
                        [pwd,'\','ResultData.csv'])