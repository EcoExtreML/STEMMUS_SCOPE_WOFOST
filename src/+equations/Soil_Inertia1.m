function [GAM] = Soil_Inertia1(SMC)
global theta_s0
%soil inertia method by Murray and Verhoef (
% Moving towards a more mechanistic approach in the determination of soil heat
% flux from remote measurements I. A universal approach to calculate
% thermal inertia)

% % parameters

theta_s = theta_s0; %(saturated water content, m3/m3)
Sr = SMC/theta_s;

%fss = 0.58; %(sand fraction for sandy loam, check the paper)
gamma_s = 0.27; %%0.27 (soil texture dependent parameter);% 0.27 if fs<0.4; 0.96 if fs>0.4
dels = 1.33; %(shape parameter)

ke = exp(gamma_s*(1- power(Sr,(gamma_s - dels))));

phis  = theta_s0; %(phis == theta_s)
lambda_d = -0.56*phis + 0.51;

QC = 0.20; %(quartz content)
lambda_qc = 7.7;  %(thermal conductivity of quartz, constant)
lambda_o  = 2.0;  %(thermal conductivity of other minerals, constant, 2.0 w m-1 k-1 for QC > 0.2 else 3.0)

lambda_s = (lambda_qc^(QC))*lambda_o^(1-QC);
lambda_wtr = 0.57;   %(thermal conductivity of water, W/m.K, constant)

lambda_w = (lambda_s^(1-phis))*lambda_wtr^(phis);

lambdas = ke*(lambda_w - lambda_d) + lambda_d;

Hcs = 1.25*10^6; % heat capacity of soil   2.0*10^6 J m-3 K-1 = Bulk density (1.4 g/cm3) * specific heat of soil (1.0 J g-1 K-1) eq 13
Hcw = 4.2*10^6; % heat capacity of water  J m-3 K-1

Hc = (Hcw * SMC)+ (1-theta_s)*Hcs;

GAM = sqrt(lambdas.*Hc);
