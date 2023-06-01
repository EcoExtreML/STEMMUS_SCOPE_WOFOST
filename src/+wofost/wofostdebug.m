function [crop_output] = wofostdebug(wofostpar,V,xyt,fluxname,cropname)
% WOFOSTDEGUG A debugging programe for crop growth simulation
% Input: WofostPar;
%        Anet;
%        Crop observations;
% output:Non-interactive crop simulations;

%% 0. global variables
global KT sfactor Dur_tot 

%% 1. crop growth simulation
fluxdata = csvread(fluxname,2, 0);
cropdata = xlsread(cropname);

for n = 1:1:Dur_tot
    KT = n ;
    Anet = fluxdata(n,11);
    meteo.Ta = V(31).Val(n);
    sfactor = fluxdata(n,29);
    [crop_output] = wofost.cropgrowth(meteo,wofostpar,Anet,xyt);
end

%% 2. plot figure
x = 1:1:Dur_tot;
titles = {'LAI','PH','LeafDM','StemDM','OrganDM'};
for i = 1:1:5
    subplot(3,2,i)
    if i == 1 | i ==2
        xobs = x;
        yobs = V(21+i).Val;
        ysim = crop_output(:,2+i);
    else
        xobs = cropdata(:,2);
        yobs = cropdata(:,i);
        ysim = crop_output(:,4+i)/1000;
    end
    
    rmse = sqrt(mean((yobs-ysim(xobs)).^2));
    r    = corrcoef(yobs,ysim(xobs));
    r2   = r(1,2).^2;
    
    scatter(xobs,yobs,10,'red','o')
    hold on
    plot(x,ysim,'k','LineWidth',1.5);    
    
    title(titles(i));
    text("String",'R2 = '+string(r2), 'Units','normalized','position',[0.05,0.9],'FontSize', 10, 'Color', 'k');
    text("String",'RMSE = '+string(rmse),'Units','normalized','position',[0.05,0.8],'FontSize', 10, 'Color', 'k');
end

subplot(3,2,6)
ydvs = crop_output(:,2);
plot(x,ydvs,'k','LineWidth',1.5);

% LAI_obs = V(22).Val;
% PH_obs  = V(23).Val;
% LAI_sim = crop_output(:,3);
% PH_sim  = crop_output(:,4);
% 
% LAI_rmse = sqrt(mean((LAI_obs-LAI_sim).^2));
% LAI_r    = corrcoef(LAI_obs,LAI_sim);
% LAI_r2   = LAI_r(1,2).^2; 
% 
% plot(x_sim,LAI_sim,'k',x_sim,LAI_obs,'r','LineWidth',1.5);
% text(100,4.2,'RMSE = '+string(LAI_rmse), 'FontSize', 12, 'Color', 'k');
% text(100,3.9,'R2 = '+string(LAI_r2), 'FontSize', 12, 'Color', 'k');
%         plot(x_sim,PH_sim,'k',x_sim,PH_obs,'r','LineWidth',1.5);
end

