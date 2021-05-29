function Plot_fig(MX, MY, M, Title,MVX,MVY,k)
%     MY=MY-20000;
    pcolor(MX/1000,MY/1000,M)
    colormap(jet);colorbar;
    hold on
    quiver(MX(1:k:end,1:k:end)/1000,MY(1:k:end,1:k:end)/1000,MVX(1:k:end,1:k:end),MVY(1:k:end,1:k:end),'color','r');

    title(Title)
    xlabel('Distance (km)','FontWeight','bold','FontSize',8,'FontAngle','italic')
    ylabel('Depth (km)','FontWeight','bold','FontSize',8,'FontAngle','italic')
    shading interp;
    axis ij;
%     xlim([0,1070])
%     ylim([-30,20])
end