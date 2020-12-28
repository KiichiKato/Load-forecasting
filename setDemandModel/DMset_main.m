clear all;
clc;
close all;
%DMset_setDemandModel(学習�?�用�?�るcsvファイル,学習�?�る日数)
y_pred = DMset_setDemandModel([pwd, '\','DLT_20180801KEPRI.csv'],1)