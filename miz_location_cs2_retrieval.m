function [miz_location_by_cs2_ssd_kstest,length_miz_cs2,flag] = miz_location_cs2_retrieval(filename,pathname)
% input:
%   pathname: path where save the cs2 L2i product
%   filename: name of CS2 L2i product
% output:
%   miz_location_by_cs2_ssd_kstest:alongtrack Wave-affected MIZ location by CS2 
%   length_miz_cs2: alongtrack Wave-affected MIZ length by CS2 (km)
%   flag: regional flag (1:GS region,2:NS region,3:BS region)
%
% Author Info
%   This function and supporting documentation were written by Weixin Zhu
%   of Tsinghua University in June 2023.
%   For any issues, please write to zwx19@mails.tsinghua.edu.cn


% read the time of CS2 product
year_name_one=filename(1,20:23);
year_name_double=str2double(year_name_one);
month_name_one=filename(1,24:25);
month_name_double=str2double(month_name_one);
date_name_one=filename(1,26:27);
date_name_double=str2double(date_name_one);

% read parameters of CS2 product
[cs2_parameter]=read_cs2_l2i_product(filename,pathname);

if(isempty(cs2_parameter))
    fprintf("No valid record in Atlantic Arctic");
    miz_location_by_cs2_ssd_kstest=[];
    length_miz_cs2=nan;  
    flag=nan;
else
    % read daily sic product & calculate alongtrack sea ice concentration of each CS2 track
    [longitude_sic,latitude_sic,amsr2_sic]=read_daily_amsr2_sic(year_name_double,month_name_double,date_name_double);
    cs2_parameter_sic=griddata(longitude_sic,latitude_sic,amsr2_sic,cs2_parameter(:,1),cs2_parameter(:,2),'cubic');
    cs2_parameter_sic=[cs2_parameter,cs2_parameter_sic];

    % Convert all tracks to ascending
    [cs2_baselined_track_filter]=convert_track_ascend(cs2_parameter_sic);

    % retrieve miz with alongtrack cs2 parameter
    [cs2_ssd_kstest_miz_flag,length_miz_cs2,flag]=calculate_cs2_miz_location_length(cs2_baselined_track_filter);

    cs2_ssd_kstest_miz_index=find(cs2_ssd_kstest_miz_flag==1);
    miz_location_by_cs2_ssd_kstest=cs2_baselined_track_filter(cs2_ssd_kstest_miz_index,1:2);


end

end
