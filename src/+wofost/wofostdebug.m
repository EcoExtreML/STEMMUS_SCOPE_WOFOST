function [crop_output] = wofostdebug(wofostpar,V,xyt,options)
% WOFOSTDEGUG A debugging programe for crop growth simulation
% Input: WofostPar;
%        Anet;
%        Crop observations;
% output:Non-interactive crop simulations;

%% 0. global variables
global KT sfactor Dur_tot crop_output

%% 1. crop growth initilization
fluxname = '../../input/Wofost/fluxes.csv';
cropname = '../../input/Wofost/LAI_.dat';
fluxdata = csvread(fluxname,2, 0);
cropdata = readtable(cropname);

%% 2. crop growth simulation
for KT = 1:1:Dur_tot 

    % update the wofost parameters if using the extracted parameter from LAI time series
    if wofostpar.PARSCHEME == 1
       if KT == 1
           nSeasions = 1;     % initilize crop growth seasions
           [wofostpar,nSeasions] = wofost.parameter_update(wofostpar,KT,nSeasions); % initilize crop growth parameters
       elseif KT == wofostpar.CSTARTSeries(nSeasions)
           [wofostpar,nSeasions] = wofost.parameter_update(wofostpar,KT,nSeasions);
       end
    end
    
    % calculate the growth of plant
    if options.calc_vegetation_dynamic == 1  && KT >= wofostpar.CSTART && KT <= wofostpar.CEND          
        Anet = fluxdata(KT,11);
        if isnan(Anet) || Anet < -2                       % limit value of Anet
            Anet = 0;
            fluxes.Actot = Anet;
        end
        meteo.Ta = V(31).Val(KT);
        sfactor = fluxdata(KT,29);
        [crop_output] = wofost.cropgrowth(meteo,wofostpar,Anet,xyt);
     else
        crop_output(KT,1) = xyt.t(KT,1);                % Day of the year
        crop_output(KT,3) = V(22).Val(KT);              % LAI
        crop_output(KT,4) = V(23).Val(KT);              % Plant height
        crop_output(KT,5) = sfactor;                    % Water stress
    end
end

%% 2. plot figure
% x = 1:1:Dur_tot;
% titles = {'LAI','PH','LeafDM','StemDM','OrganDM'};
% for i = 1:1:5
%     subplot(3,2,i)
%     if i == 1 | i ==2
%         xobs = x;
%         yobs = V(21+i).Val;
%         ysim = crop_output(:,2+i);
%     else
%         xobs = cropdata(:,2);
%         yobs = cropdata(:,i);
%         ysim = crop_output(:,4+i)/1000;
%     end
%     
%     rmse = sqrt(mean((yobs-ysim(xobs)).^2));
%     r    = corrcoef(yobs,ysim(xobs));
%     r2   = r(1,2).^2;
%     
%     scatter(xobs,yobs,10,'red','o')
%     hold on
%     plot(x,ysim,'k','LineWidth',1.5);    
%     
%     title(titles(i));
%     text("String",'R2 = '+string(r2), 'Units','normalized','position',[0.05,0.9],'FontSize', 10, 'Color', 'k');
%     text("String",'RMSE = '+string(rmse),'Units','normalized','position',[0.05,0.8],'FontSize', 10, 'Color', 'k');
% end
% 
% subplot(3,2,6)
% ydvs = crop_output(:,2);
% plot(x,ydvs,'k','LineWidth',1.5);

x_sim  = 1:1:Dur_tot;
LAI_obs = V(22).Val(1:Dur_tot);
%PH_obs  = V(23).Val;
LAI_sim = crop_output(1:Dur_tot,3);
%PH_sim  = crop_output(:,4);

LAI_rmse = sqrt(mean((LAI_obs-LAI_sim).^2));
LAI_r    = corrcoef(LAI_obs,LAI_sim);
LAI_r2   = LAI_r(1,2).^2; 

plot(x_sim,LAI_sim,'k',x_sim,LAI_obs,'r','LineWidth',1.5);
text(100,1.9,'RMSE = '+string(LAI_rmse), 'FontSize', 12, 'Color', 'k');
text(100,2.2,'R2 = '+string(LAI_r2), 'FontSize', 12, 'Color', 'k');
%plot(x_sim,PH_sim,'k',x_sim,PH_obs,'r','LineWidth',1.5);
end

