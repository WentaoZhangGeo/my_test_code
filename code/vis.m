%% 
clc;clear;close all;
global xsize ysize AirThickness 
load('Air100km_Step2.mat');MY=MY-AirThickness;
savename=['Air',num2str(AirThickness/1000),'km_Vis'];
    %%  vis
    
    figure;
    tailecr=get(0,'ScreenSize');
    set(gcf,'Position',[1 1 tailecr(3) tailecr(4) ]);
    set(gcf,'color','w')
    
    subplot(3,3,1)
    Title='Density(kg/m^3)';
    Plot_fig(MX, MY, MRHO, Title,MVX,MVY,k)
%     caxis([1000,3600])
%     plot(TopoYLit_x,-TopoYLit_y/1000,'.')
%     plot(MX(1,:)/1000,-TopoYLit/1000,'b.')
%     TopoYLit_x=TopoYLit0(:,1);
% TopoYLit_y=TopoYLit0(:,2);
% TopoYLit = interp1(TopoYLit_x*1000,TopoYLit_y,MX(1,:));
    
    subplot(3,3,2)
    Title='Temperture(C)';
    Plot_fig(MX, MY, MTK, Title,MVX,MVY,k)
%     caxis([0,1520])
    plot(TopoYLit_x,-TopoYLit_y/1000,'-')
%     subplot(3,4,3)
%     Plot_fig(MX, MY, MPR, 'Perssure(Pa)',MVX,MVY,k)
    
    subplot(3,3,3)    
    Title='Log10(Viscosity)(Pa s)';
    Plot_fig(MX, MY, log10(META), Title,MVX,MVY,k)
%     caxis([18,21])
%     subplot(3,4,5)
%     Plot_fig(MX, MY, MEXX, Title,MVX,MVY,k)
%     title('MEXX(Pa)');
%     
%     subplot(3,4,6)
%     Plot_fig(MX, MY, MEII, Title,MVX,MVY,k)
%     title('EII(Pa)');
    
    subplot(3,3,7)
%     Plot_fig(MX, MY, MEII, 'EII(Pa)',MVX,MVY,k)
%     sufaceLow=sufaceLow+1;
    plot(Topox/1000,EYY(sufaceLow,:))
    xlim([0,xsize/1000])
%     ylim([-10e-15,10e-15])
%     ylim([-100,100])
    colormap;colorbar;
    title([ 'EYY, Depth=',num2str(CY(sufaceLow,2)/1000),' km']);
    xlabel('Distance (km)','FontWeight','bold','FontSize',8,'FontAngle','italic')
    ylabel('Vertical strain rate (s^{-1})','FontWeight','bold','FontSize',10,'FontAngle','italic')
    
%     subplot(3,4,7)
%     Plot_fig(MX, MY, DeltaMEII, Title,MVX,MVY,k)
%     title('Delta MEII(Pa)');
    
    subplot(3,3,8)
%     plot(Topox/1000,Topo(sufaceLow,:),MTopox/1000,MTopo(MsufaceLow,:))
    plot(Topox/1000,SYY(sufaceLow,:))
    xlim([0,xsize/1000])
%     ylim([-2e7,2e7])
%     ylim([-100,100])
    colormap;colorbar;
    title(['SYY，Depth=',num2str(CY(sufaceLow,2)/1000),' km']);
    xlabel('Distance (km)','FontWeight','bold','FontSize',8,'FontAngle','italic')
    ylabel('Vertical stress (Pa)','FontWeight','bold','FontSize',10,'FontAngle','italic')
    
    subplot(3,3,4)
    Plot_fig(MX, MY, MV,  'V(m/s)',MVX,MVY,k)
    plot(TopoYLit_x,-TopoYLit_y/1000,'-')
%     caxis([0e-9,12e-9])
    
    subplot(3,3,5)
%     Plot_fig(MX, MY, MVX,  'Vx(m/s)',MVX,MVY,k)
%     caxis([-8e-9,8e-9])
    Plot_fig(MX, MY, MSXX,  'SXX(Pa)',MVX,MVY,k)
%     caxis([-1e7,1e7])
    plot(TopoYLit_x,-TopoYLit_y/1000,'-')
    
    
    subplot(3,3,6)
%     Plot_fig(MX, MY, MVX,  'Vy(m/s)',MVX,MVY,k)
%     caxis([-8e-9,8e-9])
    Plot_fig(MX, MY, MEXX, 'EXX(s-1)',MVX,MVY,k)
%     caxis([-10e-14,10e-14])
    plot(TopoYLit_x,-TopoYLit_y/1000,'-')
    
    
    subplot(3,3,9)    
%     DeltaMEIIRES=log10(DeltaMEIIRES)
%     DeltaMV=MV-MVold;
%     DeltaMVRES(ntimestep)=mean(DeltaMV(:).^2).^0.5;
%     plot(DeltaMEIIRES,'r*');hold on
    semilogy(DeltaMEIIRES,'r*');hold on
%     plot(DeltaMVRES,'r*')
    xlim([0,stepmax+1])
    ylim([0,10^(int16(log10(max(DeltaMEIIRES)))+1)])
%     ylim([0,1])
    title('Root mean square error (RMSE)');
    
    suptitle({['Mesh: ',num2str(xnum),'X',num2str(ynum),...
        ', Air: ',num2str(AirThickness/1000),' km ',...
        ', BC: All free slip'];...
        ['Step = ',num2str(ntimestep)];...
        []})
    xlabel('Number of iterations') 
    %%

%     name=['Air',num2str(AirThickness/1000),'km_Step',num2str(ntimestep)];
%     saveas(gcf,name,'fig')
    saveas(gcf,savename,'jpg')
    
%close(VideoFile)

function Plot_fig(MX, MY, M, Title,MVX,MVY,k)
    global xsize ysize AirThickness 
    MX=MX/1000;
    MY=MY/1000;
    k=1*k;
    pcolor(MX,MY,M)
    colormap(jet);colorbar;
    hold on
    q=quiver(MX(1:k:end,1:k:end),MY(1:k:end,1:k:end),MVX(1:k:end,1:k:end),MVY(1:k:end,1:k:end),'color','r');
    q.LineWidth = 1;
%     q.MaxHeadSize=0.1;

    title(Title)
    xlabel('Distance (km)','FontWeight','bold','FontSize',8,'FontAngle','italic')
    ylabel('Depth (km)','FontWeight','bold','FontSize',8,'FontAngle','italic')
    shading interp;
    axis ij;
    xlim([0,xsize/1000])
    ylim([-150,(ysize-AirThickness)/1000])
end