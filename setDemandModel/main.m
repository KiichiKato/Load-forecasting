clear all;
clc;
close all;
pass = pwd;
y_pred = setDemandModel([pwd, '\','LongTermPastData.csv'])
