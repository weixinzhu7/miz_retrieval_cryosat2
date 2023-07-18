function [longitude_sic,latitude_sic,sic_double] = read_daily_amsr2_sic(year_index,month_index,day_index)
%input: index of date
%output: daily SIC product from University of Bremen
%
% Author Info
%   This function and supporting documentation were written by Weixin Zhu
%   of Tsinghua University in June 2023.
%   For any issues, please write to zwx19@mails.tsinghua.edu.cn


month={'01','02','03','04','05','06','07','08','09','10','11','12'};
date={'01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31'};
% read longitude & latitude of SIC product
longitude_latitude_path='~/LongitudeLatitudeGrid-n6250-Arctic.hdf';
longitude_info_sic=hdfinfo(longitude_latitude_path);
longitude_sds_info_sic=longitude_info_sic.SDS(1); latitude_sds_info=longitude_info_sic.SDS(2);
longitude_sic=hdfread(longitude_sds_info_sic); latitude_sic=hdfread(latitude_sds_info);
longitude_sic=double(longitude_sic); latitude_sic=double(latitude_sic);
longitude_sic_new=zeros(1792,1216)*nan;

for ii=1:1792
    for jj=1:1216
        if(longitude_sic(ii,jj)>180)
            longitude_sic_new(ii,jj)=longitude_sic(ii,jj)-360;
        else
            longitude_sic_new(ii,jj)=longitude_sic(ii,jj);
        end
    end
end
longitude_sic=longitude_sic_new;

% read daily SIC product
for year_i=year_index
    for month_i=month_index
        for day_i=day_index
            sic_product=sprintf('~/asi-AMSR2-n6250-%d%s%s-v5.hdf',year_i,month{1,month_index},date{1,day_index});
            fileinfo_sic=hdfinfo(sic_product);
            sds_info_sic = fileinfo_sic.SDS(1);
            sic = hdfread(sds_info_sic);
            sic_double=double(sic);
        end
    end
end
