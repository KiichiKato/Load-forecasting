clear all;
clc;
close all;
%DMset_setDemandModel(学習に用いるcsvファイル,学習する日数)
y_pred = DMset_setDemandModel([pwd, '\','LongTermPastData3.csv'],20)