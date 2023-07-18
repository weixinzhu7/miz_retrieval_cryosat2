function [cs2_baselined_track_new]=convert_track_ascend(cs2_baselined_track_data)
% input:alongtrack cs2 parameter 
% output: All data is arranged in ascending track direction and excludes the influence of land.
%
% Author Info
%   This function and supporting documentation were written by Weixin Zhu
%   of Tsinghua University in June 2023.
%   For any issues, please write to zwx19@mails.tsinghua.edu.cn


min_latitude=find(cs2_baselined_track_data(:,2)==min(cs2_baselined_track_data(:,2)));
if(min_latitude~=1)
    cs2_baselined_track_new=flipud(cs2_baselined_track_data);  clear cs2_baselined_track_data;
else
    cs2_baselined_track_new=cs2_baselined_track_data;  clear cs2_baselined_track_data;
end

cs2_island_flag=landmask(cs2_baselined_track_new(:,2),cs2_baselined_track_new(:,1));
cs2_island_flag_double=double(cs2_island_flag);
cs2_island_flag_index1=find(cs2_island_flag_double==1);
cs2_island_flag_index2=max(cs2_island_flag_index1):1:max(cs2_island_flag_index1)+50;
cs2_island_flag_index2=cs2_island_flag_index2';
cs2_island_flag_index=[cs2_island_flag_index1;cs2_island_flag_index2];
cs2_baselined_track_new(cs2_island_flag_index,:)=[];

end
