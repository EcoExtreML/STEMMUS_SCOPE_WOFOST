global SaturatedK SaturatedMC ResidualMC Coefficient_n Coefficient_Alpha porosity FOC FOS FOSL MSOC Coef_Lamda fieldMC latitude longitude fmax theta_s0 Ks0
% the path SoilPropertyPath is set in filereads.m
% dirOutput=dir([SoilPropertyPath, 'Hydraul_Param_SoilGrids_Schaap_sl7.nc']);
%ncdisp([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl1.nc'],'/','full');
%ncdisp([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl2.nc'],'/','full');
%ncdisp([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl3.nc'],'/','full');
%ncdisp([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl4.nc'],'/','full');
%ncdisp([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl5.nc'],'/','full');
%ncdisp([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl6.nc'],'/','full');
%ncdisp([SoilPropertyPath,'Hydraul_Param_SoilGrids_Schaap_sl7.nc'],'/','full');
%ncdisp([SoilPropertyPath,'CLAY1.nc','/','full');
%% load soil property
% lat=ncread([SoilPropertyPath,'CLAY1.nc'],'lat');
% lon=ncread([SoilPropertyPath,'CLAY1.nc'],'lon');
% for i=1:16800
%     if abs(lat(i)-latitude)<0.0085
%     break
%     end
% end
%  for j=1:43200
%         if abs(lon(j)-longitude)<0.0085
%         break
%         end
%  end
% depth1=ncread([SoilPropertyPath,'CLAY1.nc'],'depth');
% depth2=ncread([SoilPropertyPath,'CLAY2.nc'],'depth');
% depth3=ncread([SoilPropertyPath,'POR.nc'],'depth');
% CLAY1=ncread([SoilPropertyPath,'CLAY1.nc'],'CLAY',[j,i,1],[1,1,4]);
% CLAY2=ncread([SoilPropertyPath,'CLAY2.nc'],'CLAY',[j,i,1],[1,1,4]);
% SAND1=ncread([SoilPropertyPath,'SAND1.nc'],'SAND',[j,i,1],[1,1,4]);
% SAND2=ncread([SoilPropertyPath,'SAND2.nc'],'SAND',[j,i,1],[1,1,4]);
% SILT1=ncread([SoilPropertyPath,'SILT1.nc'],'SILT',[j,i,1],[1,1,4]);
% SILT2=ncread([SoilPropertyPath,'SILT2.nc'],'SILT',[j,i,1],[1,1,4]);
% OC1=ncread([SoilPropertyPath,'OC1.nc'],'OC',[j,i,1],[1,1,4]);
% OC2=ncread([SoilPropertyPath,'OC2.nc'],'OC',[j,i,1],[1,1,4]);

FOC=[0.14 0.13 0.12 0.15 0.22 0.22]; %fraction of clay
FOS=[0.44 0.47 0.44 0.43 0.35 0.35 ]; %fraction of sand
%FOSL=1-FOC-FOS; %fraction of silt
MSOC=[0.0162 0.0110 0.0044 0.0033 0 0];  %mass fraction of soil organic matter
%% load lamda
% lati=ncread([SoilPropertyPath,'lambda/lambda_l1.nc'],'lat');
% long=ncread([SoilPropertyPath,'lambda/lambda_l1.nc'],'lon');
% for i=1:21600
%     if abs(lati(i)-latitude)<=0.0042
%     break
%     end
% end
%  for j=1:43200
%         if abs(long(j)-longitude)<=0.0042
%         break
%         end
%  end
% lambda1=ncread([SoilPropertyPath,'lambda/lambda_l1.nc'],'lambda',[j,i],[1,1]);
% lambda2=ncread([SoilPropertyPath,'lambda/lambda_l2.nc'],'lambda',[j,i],[1,1]); 
% lambda3=ncread([SoilPropertyPath,'lambda/lambda_l3.nc'],'lambda',[j,i],[1,1]); 
% lambda4=ncread([SoilPropertyPath,'lambda/lambda_l4.nc'],'lambda',[j,i],[1,1]); 
% lambda5=ncread([SoilPropertyPath,'lambda/lambda_l5.nc'],'lambda',[j,i],[1,1]); 
% lambda6=ncread([SoilPropertyPath,'lambda/lambda_l6.nc'],'lambda',[j,i],[1,1]);
% lambda7=ncread([SoilPropertyPath,'lambda/lambda_l7.nc'],'lambda',[j,i],[1,1]);
% lambda8=ncread([SoilPropertyPath,'lambda/lambda_l8.nc'],'lambda',[j,i],[1,1]);
Coef_Lamda=[0.1930 0.200 0.2060 0.1870 0.1550 0.1550];
%% load soil hydrulic parameters
% lat=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl1_alpha.nc'],'latitude');
% lon=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl1_alpha.nc'],'longitude');
% % read data
% for i=1:17924
%     if abs(lat(i)-latitude)<=0.0042
%     break
%     end
% end
%  for j=1:43200
%         if abs(lon(j)-longitude)<=0.0042
%         break
%         end
% end
% % 0cm
% alpha0=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl1_alpha.nc'],'alpha_0cm',[j,i],[1,1]);
% n0=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl1_n.nc'],'n_0cm',[j,i],[1,1]);

theta_s0=0.4493;

% theta_r0=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl1_thetar.nc'],'thetar_0cm',[j,i],[1,1]);

Ks0=43.6748;

% % 5cm
% alpha5=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl2_alpha.nc'],'alpha_5cm',[j,i],[1,1]);
% n5=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl2_n.nc'],'n_5cm',[j,i],[1,1]);
% theta_s5=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl2_thetas.nc'],'thetas_5cm',[j,i],[1,1]);
% theta_r5=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl2_thetar.nc'],'thetar_5cm',[j,i],[1,1]);
% Ks5=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl2_Ks.nc'],'Ks_5cm',[j,i],[1,1]);
% % 15cm
% alpha15=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl3_alpha.nc'],'alpha_15cm',[j,i],[1,1]);
% n15=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl3_n.nc'],'n_15cm',[j,i],[1,1]);
% theta_s15=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl3_thetas.nc'],'thetas_15cm',[j,i],[1,1]);
% theta_r15=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl3_thetar.nc'],'thetar_15cm',[j,i],[1,1]);
% Ks15=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl3_Ks.nc'],'Ks_15cm',[j,i],[1,1]);
% % 30cm
% alpha30=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl4_alpha.nc'],'alpha_30cm',[j,i],[1,1]);
% n30=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl4_n.nc'],'n_30cm',[j,i],[1,1]);
% theta_s30=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl4_thetas.nc'],'thetas_30cm',[j,i],[1,1]);
% theta_r30=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl4_thetar.nc'],'thetar_30cm',[j,i],[1,1]);
% Ks30=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl4_Ks.nc'],'Ks_30cm',[j,i],[1,1]);
% % 60cm
% alpha60=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl5_alpha.nc'],'alpha_60cm',[j,i],[1,1]);
% n60=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl5_n.nc'],'n_60cm',[j,i],[1,1]);
% theta_s60=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl5_thetas.nc'],'thetas_60cm',[j,i],[1,1]);
% theta_r60=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl5_thetar.nc'],'thetar_60cm',[j,i],[1,1]);
% Ks60=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl5_Ks.nc'],'Ks_60cm',[j,i],[1,1]);
% % 100cm
% alpha100=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl6_alpha.nc'],'alpha_100cm',[j,i],[1,1]);
% n100=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl6_n.nc'],'n_100cm',[j,i],[1,1]);
% theta_s100=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl6_thetas.nc'],'thetas_100cm',[j,i],[1,1]);
% theta_r100=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl6_thetar.nc'],'thetar_100cm',[j,i],[1,1]);
% Ks100=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl6_Ks.nc'],'Ks_100cm',[j,i],[1,1]);
% % 200cm
% alpha200=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl7_alpha.nc'],'alpha_200cm',[j,i],[1,1]);
% n200=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl7_n.nc'],'n_200cm',[j,i],[1,1]);
% theta_s200=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl7_thetas.nc'],'thetas_200cm',[j,i],[1,1]);
% theta_r200=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl7_thetar.nc'],'thetar_200cm',[j,i],[1,1]);
% Ks200=ncread([SoilPropertyPath,'Schaap/PTF_SoilGrids_Schaap_sl7_Ks.nc'],'Ks_200cm',[j,i],[1,1]);

 %% load maximum fractional saturated area
%  FMAX=ncread([SoilPropertyPath,'surfdata.nc'],'FMAX');
%  if longitude>=0
%      j = fix(longitude/0.5);
%      l = mod(longitude,0.5);
%        if l<0.25
%           j=j+1;
%        else
%           j=j;
%        end
%  else
%      j = fix((longitude+360)/0.5);
%      l = mod((longitude+360),0.5);
%        if l<0.25
%           j=j+1;
%        else
%           j=j;
%        end
%  end
% 
%      i = fix((latitude+90)/0.5);
%      k = mod((latitude+90),0.5);
%        if k<0.25
%           i=i+1;
%        else
%           i=i;
%        end

fmax=0.4564;
% soil property
SaturatedK=[4.7382  6.0719  3.2960  2.3233  2.4605  2.8647]/(3600*24);%[2.67*1e-3  1.79*1e-3 1.14*1e-3 4.57*1e-4 2.72*1e-4];      %[2.3*1e-4  2.3*1e-4 0.94*1e-4 0.94*1e-4 0.68*1e-4] 0.18*1e-4Saturation hydraulic conductivity (cm.s^-1);
SaturatedMC=[0.3552    0.3597    0.3587    0.3511    0.3467     0.3457];                              % 0.42 0.55 Saturated water content;
ResidualMC=[0.0571    0.0565    0.0629    0.0641    0.0614   0.0597];                               %0.037 0.017 0.078 The residual water content of soil;
Coefficient_n=[1.3912    1.4411    1.3607    1.2593    1.2451    1.2575];                            %1.2839 1.3519 1.2139 Coefficient in VG model;
Coefficient_Alpha=[0.0133    0.0122    0.0138    0.0181    0.0198    0.0197];                   % 0.02958 0.007383 Coefficient in VG model;
porosity =[0.3552    0.3597    0.3587    0.3511    0.3467     0.3457];                                      % Soil porosity;
fieldMC = [0.2166    0.2122    0.2270   0.2396    0.2371   0.2318]; 
%fieldMC=(1./(((341.09.*Coefficient_Alpha).^(Coefficient_n)+1).^(1-1./Coefficient_n))).*(SaturatedMC-ResidualMC)+ResidualMC;   