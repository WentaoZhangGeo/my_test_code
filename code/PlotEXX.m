%% 
clc;clear;close all
ScreenSize = get(0,'ScreenSize');
ScreenSize(3)=800;
figure('Position',[0 500 ScreenSize(3) ScreenSize(3)*0.7])
subplot(2,1,2)
LW=1;
load('~/Music/stokes/120km2/Air120km_Step10.mat','EYY','Topox','sufaceLow')
plot(Topox/1000,EYY(sufaceLow,:),'-','DisplayName','Air120km','LineWidth',LW)
hold on

load('~/Music/stokes/100km2/Air100km_Step15.mat','EYY','Topox','sufaceLow')
plot(Topox/1000,EYY(sufaceLow,:),'-','DisplayName','Air100km','LineWidth',LW)
% hold on

load('~/Music/stokes/80km2/Air80km_Step18.mat','EYY','Topox','sufaceLow')
plot(Topox/1000,EYY(sufaceLow,:),'--','DisplayName','Air80km','LineWidth',LW)

load('~/Music/stokes/50km2/Air50km_Step17.mat','EYY','Topox','sufaceLow')
plot(Topox/1000,EYY(sufaceLow,:),'-.','DisplayName','Air50km','LineWidth',LW)

load('~/Music/stokes/30km2/Air30km_Step20.mat','EYY','Topox','sufaceLow')
plot(Topox/1000,EYY(sufaceLow,:),':','DisplayName','Air30km','LineWidth',LW)

% load('~/Music/stokes/Air20km_Step5.mat','EYY','Topox','sufaceLow')
% plot(Topox/1000,EYY(sufaceLow,:),':','DisplayName','Air20km','LineWidth',LW)

load('~/Music/stokes/0km/Air0km_Step20.mat','EYY','Topox','sufaceLow')
plot(Topox/1000,EYY(sufaceLow,:),'black-','DisplayName','Air0km','LineWidth',LW)

set(gcf,'color','w')
set(gca,'fontsize',10,'fontweight','normal','fontweight','bold','fontangle','italic')
set(gca,'LineWidth',1.5)

% grid on
set(gca,'XGrid','on','YGrid','on','YMinorGrid','off')
% set(gca,'XTick',0:50:1070)
% set(gca,'XMinorTick','on')
xlim([0,1100])
ylim([-1.2,1.2]*1e-14)
leg=legend('boxon');
leg.LineWidth=0.5;
leg.FontSize=7;
leg.NumColumns=1;
xlabel('Distance/km');
ylabel('Vertical strain rate / s^{-1}');


%%
subplot(2,1,1)
load('~/Music/stokes/120km2/Air120km_Step10.mat','TopoYLit_x','TopoYLit_y')
plot(TopoYLit_x,TopoYLit_y,'-','LineWidth',LW)
hold on
plot(TopoYLit_x*2,TopoYLit_y*0,'black-','LineWidth',LW/2)

set(gcf,'color','w')
set(gca,'fontsize',10,'fontweight','normal','fontweight','bold','fontangle','italic')
set(gca,'LineWidth',1.5)

% grid on
set(gca,'XGrid','on','YGrid','on','YMinorGrid','off')
% set(gca,'XTick',0:50:1070)
% set(gca,'XMinorTick','on')
xlim([0,1100])
% ylim([-1.2,1.2]*1e-14)
% xlabel('Distance/km');
ylabel('Topography/m');

saveas(gcf,'EXX','pdf')
saveas(gcf,'EXX','tif')