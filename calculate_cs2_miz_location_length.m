function [cs2_ssd_kstest_miz_flag,length_miz_cs2,flag] = calculate_cs2_miz_location_length(cs2_baselined_track_data)
%%    *******************       %%
% input:alongtrack cs2 parameter
% output:
% cs2_ssd_kstest_miz_flag:alongtrack Wave-affected MIZ location by CS2 
% length_miz_cs2: alongtrack Wave-affected MIZ length by CS2 (km)
% flag: regional flag (1:GS region,2:NS region,3:BS region)
%
% Author Info
%   This function and supporting documentation were written by Weixin Zhu
%   of Tsinghua University in June 2023.
%   For any issues, please write to zwx19@mails.tsinghua.edu.cn


% Define the parameters
flag=nan; cs2_ssd_kstest_miz_flag=[]; miz_number=0; length_miz_cs2=0;

% Determine the number of sub-tracks for this track
alongtrack_distance=ones(length(cs2_baselined_track_data(:,1)),1)*nan; alongtrack_distance(1,1)=0;
for subtrack_length_i=2:length(cs2_baselined_track_data(:,1))
    alongtrack_distance(subtrack_length_i,1)=distance(cs2_baselined_track_data((subtrack_length_i-1),2),cs2_baselined_track_data((subtrack_length_i-1),1),cs2_baselined_track_data(subtrack_length_i,2),cs2_baselined_track_data(subtrack_length_i,1),6378.137);   % requires mapping toolbox
end

subtrack_index_start=find(alongtrack_distance>10);    subtrack_index_start=[1;subtrack_index_start];   subtrack_index_end=ones(length(subtrack_index_start),1)*nan;
for i=1:(length(subtrack_index_start)-1)
    subtrack_index_end(i,1)=subtrack_index_start((i+1),1)-1;
end
subtrack_index_end(length(subtrack_index_start(:,1)),1)=length(alongtrack_distance);

% Calculate alongtrack MIZ for each sub-track
for subtrack_index=1:length(subtrack_index_start)

    subtrack_data=cs2_baselined_track_data(subtrack_index_start(subtrack_index):subtrack_index_end(subtrack_index),:);
    % Obtain the MIZ based on Sea Ice Concentration
    subtrack_sic=subtrack_data(:,10);
    cs2_sic_miz_index=find(subtrack_sic>15 & subtrack_sic<80);

    if(length(cs2_sic_miz_index)<2)
        cs2_miz_definition_ssd_kstest=ones(length(subtrack_data(:,1)),1)*nan;
        length_cs2_miz_ssd_kstest=0;
        fprintf("No CS-2 footprint of this subtrack with SIC=15%% & SIC=80%%");
    else
        cs2_miz_definition_ssd_kstest=ones(length(subtrack_data(:,1)),1)*nan;
        cs2_ssd_track_10km_pdf_flag_p=ones(length(subtrack_data(:,1)),1)*nan;
        cs2_ssd_track_10km_pdf_flag=ones(length(subtrack_data(:,1)),1)*nan;

        cs2_subtrack_sigma0=subtrack_data(:,3);
        cs2_subtrack_ssd=subtrack_data(:,4);

        cs2_sigma0_std_track_3km=movstd(cs2_subtrack_sigma0,[9,0]);
        cs2_sigma0_mean_track_3km=movmean(cs2_subtrack_sigma0,[9,0]);
        cs2_sigma0_std_track_20km=movstd(cs2_subtrack_sigma0,[67,0]);
        cs2_sigma0_mean_track_20km=movmean(cs2_subtrack_sigma0,[67,0]);

        %Calculate how many consecutive positions are determined by sic-miz
        cs2_track_sicmiz_data=subtrack_data(cs2_sic_miz_index,:);
        alongtrack_distance_sicmiz=ones(length(cs2_track_sicmiz_data(:,1)),1)*nan;
        for subtrack_length_i=2:length(cs2_track_sicmiz_data(:,1))
            alongtrack_distance_sicmiz(subtrack_length_i,1)=distance(cs2_track_sicmiz_data((subtrack_length_i-1),2),cs2_track_sicmiz_data((subtrack_length_i-1),1),cs2_track_sicmiz_data(subtrack_length_i,2),cs2_track_sicmiz_data(subtrack_length_i,1),6378.137);   %6378.137表示地球半径
        end

        sictrack_index_start=find(alongtrack_distance_sicmiz>20); sictrack_index_start=[1;sictrack_index_start];
        sictrack_index_end=ones(length(sictrack_index_start),1)*nan;

        if(length(sictrack_index_start)>1)
            for i=1:(length(sictrack_index_start)-1)
                sictrack_index_end(i,1)=sictrack_index_start((i+1),1)-1;
            end
            sictrack_index_end(length(sictrack_index_start(:,1)),1)=length(alongtrack_distance_sicmiz);
        else
            sictrack_index_end(length(sictrack_index_start(:,1)),1)=length(alongtrack_distance_sicmiz);
        end

        % Make sure the icepack and ocean subtrack are greater than 100km
        for ij_index=1:1:length(sictrack_index_end)           
            sic15_index_final=nan;  sic80_index_final=nan;
            index_start=sictrack_index_start(ij_index,1);
            index_end=sictrack_index_end(ij_index,1);
            start_sic_index=find(subtrack_data(:,2)==cs2_track_sicmiz_data(index_start,2));
            end_sic_index=find(subtrack_data(:,2)==cs2_track_sicmiz_data(index_end,2));
            cs2_miz_definition_ssd_kstest=ones(length(subtrack_data(:,1)),1)*nan;

            if(start_sic_index>300 && end_sic_index<(length(subtrack_data(:,1))-300))
                ocean_test_index=subtrack_data((start_sic_index-300):start_sic_index,10);
                icepack_test_index=subtrack_data(end_sic_index:end_sic_index+300,10);

                sic_ocean_test=nanmean(ocean_test_index);  % require Statistics and Machine Learning Toolbox
                sic_icepack_test=nanmean(icepack_test_index);
                if(sic_ocean_test<15 && sic_icepack_test>50)                  
                    amsr_sic15_track_lat_final=subtrack_data(start_sic_index,2);
                    amsr_sic80_track_lat_final=subtrack_data(end_sic_index,2);

                    sic15_index_final=find(subtrack_data(:,2)==amsr_sic15_track_lat_final);
                    sic80_index_final=find(subtrack_data(:,2)==amsr_sic80_track_lat_final);
                else
                    sic15_index_final=nan;
                    sic80_index_final=nan;
                end

            else
                fprintf("Not long enough CS-2 footprint of this subtrack with SIC=15%% & SIC=80%%");
            end

            valid_sic_track_index1=sic15_index_final-666;
            valid_sic_track_index2=sic80_index_final+1400;

            if(valid_sic_track_index1<-300 || isnan(valid_sic_track_index1) || isnan(valid_sic_track_index2))
                xxx=0;
            else
                if(valid_sic_track_index1<1)
                    valid_sic_track_index1=1;
                end

                if(valid_sic_track_index2>length(subtrack_data(:,1)))
                    valid_sic_track_index2=length(subtrack_data(:,1));
                end

                if((valid_sic_track_index2-sic80_index_final)<200)
                    fprintf("No valid number of track in icepack");
                else

                    test_cs2_miz_track_index=valid_sic_track_index1:1:valid_sic_track_index2; test_cs2_miz_track_index=test_cs2_miz_track_index';

                    cs2_parameter_track=subtrack_data(test_cs2_miz_track_index,:);
                    cs2_parameter_lead_track_location=cs2_parameter_track(find(cs2_parameter_track(:,5)==256),:);

                    cs2_sigma0_mean_track_3km_valid=cs2_sigma0_mean_track_3km(test_cs2_miz_track_index,:);
                    cs2_sigma0_std_track_3km_valid=cs2_sigma0_std_track_3km(test_cs2_miz_track_index,:);

                    cs2_mean_sigma0_ocean=9; cs2_std_sigma0_ocean=1/3;
                    flag_miz_start_sigma0=cs2_mean_sigma0_ocean+3*cs2_std_sigma0_ocean;

                    %Determine where the MIZ begins alongtrack
                    index_miz_start_valid_sigma0_mean=find(cs2_sigma0_mean_track_3km_valid>flag_miz_start_sigma0);
                    index_miz_start_valid_sigma0_std=find(cs2_sigma0_std_track_3km_valid>0.5);
                    index_miz_start_valid=intersect(index_miz_start_valid_sigma0_mean,index_miz_start_valid_sigma0_std);

                    cs2_miz_start_latitude=min(cs2_parameter_track(index_miz_start_valid,2));

                    if(isempty(cs2_miz_start_latitude))
                        fprintf("Invalid start point of CS2 parameters");
                    else
                        longitude_test=cs2_parameter_track(find(cs2_parameter_track(:,2)==cs2_miz_start_latitude),1);
                        latitude_test=cs2_parameter_track(find(cs2_parameter_track(:,2)==cs2_miz_start_latitude),2);

                        % confirm the flag of track location
                        if(min(longitude_test)>15 && latitude_test<80) %barents sea (longitude>15E & latitude<82N)
                            flag=3;
                        elseif(max(longitude_test)<0) % east of greenland
                            flag=1;
                        else% north of svalbard
                            flag=2;
                        end

                        % remove mis_discrimination due to random ice floes
                        if(isempty(cs2_miz_start_latitude))
                            xxx=0;
                        else
                            end_latitude=cs2_miz_start_latitude+2;

                            index_miz_test1=find(subtrack_data(:,2)>cs2_miz_start_latitude);
                            index_miz_test2=find(subtrack_data(:,2)<end_latitude);
                            index_miz_test=intersect(index_miz_test1,index_miz_test2);

                            data_miz_test1=subtrack_data(index_miz_test,:);
                            sigma0_mean_miz_test1_20km=cs2_sigma0_mean_track_20km(index_miz_test,:);
                            sigma0_std_miz_test1_20km=cs2_sigma0_std_track_20km(index_miz_test,:);
                            sigma0_std_miz_test1=cs2_sigma0_std_track_3km(index_miz_test,:);

                            ocean_index1=find(sigma0_std_miz_test1_20km<0.5); ocean_index2=find(sigma0_std_miz_test1<0.5);
                            ocean_index3=find(sigma0_mean_miz_test1_20km>7); ocean_index4=find(sigma0_mean_miz_test1_20km<13);

                            ocean_index12=intersect(ocean_index1,ocean_index2); ocean_index123=intersect(ocean_index12,ocean_index3); ocean_index=intersect(ocean_index123,ocean_index4);

                            if(isempty(ocean_index))
                                xxx=0;
                            else
                                cs2_parameter_ocean_latitude=max(data_miz_test1(ocean_index,2));
                                index_miz_start_valid_sigma0_mean=find(cs2_sigma0_mean_track_3km_valid>flag_miz_start_sigma0);
                                index_miz_start_valid_sigma0_std=find(cs2_sigma0_std_track_3km_valid>0.5);
                                index_miz_start_valid3=find(cs2_parameter_track(:,2)>cs2_parameter_ocean_latitude);

                                index_miz_start_valid1=intersect(index_miz_start_valid_sigma0_mean,index_miz_start_valid_sigma0_std);
                                index_miz_start_valid=intersect(index_miz_start_valid1,index_miz_start_valid3);
                                cs2_miz_start_latitude=min(cs2_parameter_track(index_miz_start_valid,2));
                            end
                        end

                        % determine location of alongtrack lead
                        if(isempty(cs2_miz_start_latitude))
                            miz_start_index=[];
                            cs2_parameter_lead_latitude_min=[];
                        else
                            cs2_parameter_lead_track_location_valid_index=find(cs2_parameter_lead_track_location(:,2)>cs2_miz_start_latitude);
                            cs2_parameter_lead_track_location_valid=cs2_parameter_lead_track_location(cs2_parameter_lead_track_location_valid_index,:);
                            cs2_parameter_lead_latitude_min=min(cs2_parameter_lead_track_location_valid(:,2));
                            miz_start_index=find(subtrack_data(:,2)==cs2_miz_start_latitude);
                        end

                        % Statistical characterisation of the corresponding parameters alongtrack of ICEPack and determine the end of MIZ
                        if(isempty(cs2_parameter_lead_latitude_min))
                            fprintf("Invalid Lead point of CS2 parameters");
                        else
                            miz_end_lead_index=find(subtrack_data(:,2)==cs2_parameter_lead_latitude_min);

                            if(length(subtrack_data(:,2))<miz_end_lead_index+333)
                                icepack_end_index=length(subtrack_data(:,2));
                            else
                                icepack_end_index=miz_end_lead_index+333;
                            end

                            icepack_data=subtrack_data(miz_end_lead_index:icepack_end_index,:);
                            cs2_ssd_icepack=icepack_data(:,4);

                            for i=34:length(cs2_subtrack_ssd) %10km moving mean
                                data=cs2_subtrack_ssd(i-33:i,:);
                                [flag_pdf,p_pdf_flag]=kstest2(data,cs2_ssd_icepack);
                                cs2_ssd_track_10km_pdf_flag(i,1)=flag_pdf;
                                cs2_ssd_track_10km_pdf_flag_p(i,1)=p_pdf_flag;
                            end

                            cs2_miz_end_latitude_ssd_kstest_index1=find(cs2_ssd_track_10km_pdf_flag==0);
                            cs2_miz_end_latitude_ssd_kstest_index2=find(subtrack_data(:,2)>cs2_miz_start_latitude);
                            cs2_miz_end_latitude_ssd_kstest_index=intersect(cs2_miz_end_latitude_ssd_kstest_index1,cs2_miz_end_latitude_ssd_kstest_index2);
                            cs2_miz_end_latitude_ssd_kstest_latitude=min(subtrack_data(cs2_miz_end_latitude_ssd_kstest_index,2));

                            if(isempty(cs2_miz_end_latitude_ssd_kstest_latitude))
                                cs2_miz_end_latitude_ssd_kstest_latitude=nan;
                                miz_end_ssd_kstest_index=nan;
                                cs2_miz_end_location_ssd_kstest=[];
                            else
                                if(cs2_miz_end_latitude_ssd_kstest_latitude>cs2_parameter_lead_latitude_min)
                                    cs2_miz_end_latitude_ssd_kstest_latitude=cs2_parameter_lead_latitude_min;
                                else
                                    xxx=0;
                                end
                                miz_end_ssd_kstest_index=find(subtrack_data(:,2)==cs2_miz_end_latitude_ssd_kstest_latitude);
                                cs2_miz_definition_ssd_kstest(miz_start_index:miz_end_ssd_kstest_index,:)=1;
                                cs2_miz_end_location_ssd_kstest=subtrack_data(miz_end_ssd_kstest_index,:);
                            end
                        end

                        if(length(find(cs2_miz_definition_ssd_kstest==1))>0)
                            miz_number=miz_number+1;

                            % calculate miz length & miz width
                            cs2_miz_start_location=subtrack_data(miz_start_index,:);
                            length_cs2_miz_ssd_kstest=distance(cs2_miz_end_location_ssd_kstest(1,2),cs2_miz_end_location_ssd_kstest(1,1),cs2_miz_start_location(1,2),cs2_miz_start_location(1,1),6378.137);

                        else
                            length_cs2_miz_ssd_kstest=0;
                            fprintf("Invalid MIZ retrieval with this CS2 sub-track");
                        end

                        if(isempty(length_cs2_miz_ssd_kstest))
                            length_cs2_miz_ssd_kstest=0;
                        end
                        length_miz_cs2=length_miz_cs2+length_cs2_miz_ssd_kstest;
                        cs2_ssd_kstest_miz_flag=[cs2_ssd_kstest_miz_flag;cs2_miz_definition_ssd_kstest];
                    end
                end

            end
        end
    end  
end

end


