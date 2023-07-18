function [cs2_parameter] = read_cs2_l2i_product(filename,pathname)
% input:
%   pathname: path where save the cs2 L2i product
%   filename: name of CS2 L2i product
% output: 
%   valid cs2 parameters in Altantic Arctic
%
% Author Info
%   This function and supporting documentation were written by Weixin Zhu
%   of Tsinghua University in June 2023.
%   For any issues, please write to zwx19@mails.tsinghua.edu.cn


year_name_one=filename(1,20:23);
year_name_double=str2double(year_name_one);
month_name_one=filename(1,24:25);
month_name_double=str2double(month_name_one);
date_name_one=filename(1,26:27);
date_name_double=str2double(date_name_one);

longitude=ncread(pathname,'lon_20_ku');
latitude=ncread(pathname,'lat_20_ku');
sigma0=ncread(pathname,'sig0_1_20_ku');
surf_type=ncread(pathname,'flag_surf_type_class_20_ku');
cs2_stack_std=ncread(pathname,'stack_std_20_ku');
time=ncread(pathname,'time_20_ku');

data=[longitude,latitude,sigma0,cs2_stack_std,surf_type,time];

valid_data_index1=find(data(:,2)>64);
valid_data_index2=find(data(:,1)>-30);
valid_data_index3=find(data(:,1)<50);

valid_data_index12=intersect(valid_data_index1,valid_data_index2);
valid_data_index=intersect(valid_data_index12,valid_data_index3);

if(isempty(valid_data_index))
    cs2_parameter=[];
else
    valid_data=data(valid_data_index,:);
    cs2_parameter=valid_data;
    day_test=ones(length(cs2_parameter(:,1)),1);
    day=day_test*date_name_double;
    month_all=day_test*month_name_double;
    year=day_test*year_name_double;
    cs2_parameter=[cs2_parameter,year,month_all,day];
end

%save('~/CS2_baselind_SSD_sigma0_freeboard_type','cs2_parameter');

end
