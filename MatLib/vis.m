%% 
clc;clear;close all;
global xsize ysize AirThickness 
load('Air100km_Step2.mat');MY=MY-AirThickness;
savename=['Air',num2str(AirThickness/1000),'km_Vis'];

    %%  vis
    
    MX=MX-ExtendDistance;
    TopoYLit_x=TopoYLit_x-ExtendDistance;
    tailecr=get(0,'ScreenSize');
    set(gcf,'Position',[1000 1 tailecr(3) tailecr(4) ]);
    set(gcf,'color','w')
    
    subplot(3,4,1)
    Plot_fig(MX, MY, MRHO, 'Density(kg/m^3)',MVX,MVY,k)
%     caxis([1000,3600])
    plot(MX(1,:)/1000,-TopoYLit/1000,'-') % or % plot(MX(1,:)/1000,-TopoYLit/1000,'-')
    
    subplot(3,4,2)
    Plot_fig(MX, MY, MTK, 'Temperture(C)',MVX,MVY,k)
%     caxis([0,1520])
    plot(MX(1,:)/1000,-TopoYLit/1000,'-')
    
    subplot(3,4,3)
    Plot_fig(MX, MY, MPR, 'Perssure(Pa)',MVX,MVY,k)
    plot(MX(1,:)/1000,-TopoYLit/1000,'-')

    subplot(3,4,4)
    dMPR=MPR-MPR_LitMod;
    Plot_fig(MX, MY, MPR-MPR_LitMod, 'Δ Perssure(Pa)',MVX,MVY,k)
    plot(MX(1,:)/1000,-TopoYLit/1000,'-')
    
%     subplot(3,4,8)
%     plot(MX(1,:),MPR(:,20),'b-',MX(1,:),MPR_LitMod(:,20),'r-')
    
    subplot(3,4,5)    
    Plot_fig(MX, MY, log10(META), 'Log10(Viscosity)(Pa s)',MVX,MVY,k)
%     caxis([18,21])

%     subplot(3,4,5)
%     Plot_fig(MX, MY, MEXX, Title,MVX,MVY,k)
%     title('MEXX(Pa)');
  
%     subplot(3,4,7)
%     Plot_fig(MX, MY, DeltaMEII, Title,MVX,MVY,k)
%     title('Delta MEII(Pa)');
    
    subplot(3,4,6)
%     Plot_fig(MX, MY, MVX,  'Vx(m/s)',MVX,MVY,k)
%     caxis([-8e-9,8e-9])
    Plot_fig(MX, MY, MSXX,  'SXX(Pa)',MVX,MVY,k)
%     caxis([-1e7,1e7])
    plot(MX(1,:)/1000,-TopoYLit/1000,'-')
    
    subplot(3,4,7)
%     Plot_fig(MX, MY, MVX,  'Vy(m/s)',MVX,MVY,k)
%     caxis([-8e-9,8e-9])
    Plot_fig(MX, MY, MEXX, 'EXX(s-1)',MVX,MVY,k)
%     caxis([-10e-14,10e-14])
    plot(MX(1,:)/1000,-TopoYLit/1000,'-')
    
    subplot(3,4,8)
    Plot_fig(MX, MY, MEII, 'EII(Pa)',MVX,MVY,k)
    plot(MX(1,:)/1000,-TopoYLit/1000,'-')
    
    subplot(3,4,9)
    Plot_fig(MX, MY, MV, 'V(m/s)',MVX,MVY,k)
    plot(MX(1,:)/1000,-TopoYLit/1000,'-')
    caxis([0e-9,10e-9])
    
    subplot(3,4,10)
%     Plot_fig(MX, MY, MEII, 'EII(Pa)',MVX,MVY,k)
%     sufaceLow=sufaceLow+1;
    plot(Topox/1000,EYY(sufaceLow,:))
%     xlim([0,xsize/1000])
%     ylim([-10e-15,10e-15])
%     ylim([-100,100])
    colorbar;
    title(['EYY, Depth=',num2str((CY(sufaceLow,2)-AirThickness)/1000),' km']);
    xlabel('Distance (km)','FontWeight','bold','FontSize',8,'FontAngle','italic')
    ylabel('Vertical strain rate (s^{-1})','FontWeight','bold','FontSize',8,'FontAngle','italic')
  
    subplot(3,4,11)
%     plot(Topox/1000,Topo(sufaceLow,:),MTopox/1000,MTopo(MsufaceLow,:))
    plot(Topox/1000,SYY(sufaceLow,:))
%     xlim([0,xsize/1000])
%     ylim([-2e7,2e7])
%     ylim([-100,100])
    colormap;colorbar;
    title(['SYY，Depth=',num2str((CY(sufaceLow,2)-AirThickness)/1000),' km']);
    xlabel('Distance (km)','FontWeight','bold','FontSize',8,'FontAngle','italic')
    ylabel('Vertical stress (Pa)','FontWeight','bold','FontSize',8,'FontAngle','italic')
    
    subplot(3,4,12)    
%     DeltaMEIIRES=log10(DeltaMEIIRES)
%     DeltaMV=MV-MVold;
%     DeltaMVRES(ntimestep)=mean(DeltaMV(:).^2).^0.5;
%     plot(DeltaMEIIRES,'r*');hold on
    semilogy(DeltaMEIIRES,'r*');hold on
%     plot(DeltaMVRES,'r*')
%     xlim([0,stepmax+1])
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
%     xlim([-150,xsize/1000+50])
    ylim([-150,(ysize-AirThickness)/1000])
end