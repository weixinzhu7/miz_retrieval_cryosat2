%% ******************************************************************************************************************************** %%
% input: CryoSat-2 L2i product
% output: 
% miz_location_by_cs2:alongtrack Wave-affected MIZ location by CS2 
% length_miz_cs2: alongtrack Wave-affected MIZ length by CS2 (km)
% flag: regional flag (1:GS region,2:NS region,3:BS region)
%
% Author Info
%   This function and supporting documentation were written by Weixin Zhu
%   of Tsinghua University in June 2023.
%   For any issues, please write to zwx19@mails.tsinghua.edu.cn


%% ******************************************************************************************************************************** %%
clc;  clear;
close all;

pathname='~/CS_LTA__SIR_SARI2__20150214T000431_20150214T000746_D001.nc';
filename='CS_LTA__SIR_SARI2__20150214T000431_20150214T000746_D001.nc';

[miz_location_by_cs2,length_miz_cs2,flag]=miz_location_cs2_retrieval(filename,pathname);



           
