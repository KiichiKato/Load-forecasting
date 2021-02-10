clear all;
clc;
close all;
%DMset_setDemandModel(CSV used for Traning ,Number of days for training)
y_pred = DMset_setDemandModel([pwd, '\','DLT_20180801KEPRI.csv'],30)