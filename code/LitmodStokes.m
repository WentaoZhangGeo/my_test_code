%% Solution of Stokes and continuity equations  from  Variable_viscosity_block.m
% with variable viscosity in 2D with direct solver
% by using external function Stokes_Continuity_solver_ghost()
% Setup corresponds to falling block test
% 
% Staggered Grid for Multigrid
% 
%     vx       vx       vx    
%
% vy  +---vy---+---vy---+   vy
%     |        |        |
%     vx   P   vx   P   vx    
%     |        |        |
% vy  +---vy---+---vy---+   vy
%     |        |        |
%     vx   P   vx   P   vx    
%     |        |        |
% vy  +---vy---+---vy---+   vy
%
%     vx       vx       vx    
% 
% Lines show basic grid
% Basic (density) nodes are shown with +
% Ghost nodes shown outside the basic grid
% are used for boundary conditions

%% Clearing all variables, arrays and closing figures
clear;clc;close all;

%% 
LitModOutputName='post_processing_output.dat';
LitMod=load(LitModOutputName);
TopoIn=load('topo.inp');

% Amount of timesteps
stepmax=2;

AirThickness = 100000.0;    % Sticky air / m
AirTypeNumber = -10;        % 
AirDensity = 1000;          % kg/m3
AirViscosity = 1e18;        % Pa s

ExtendDistance = 100000.0;  % m


% Velocity Boundary condition specified by bleft,bright,btop,bbot 
% (1=free slip -1=no slip) are implemented from ghost nodes 
% directly into Stokes and continuity equations
bleft=1;
bright=1;
btop=1;
bbottom=1;

%% Model size, m
xsize = (LitMod(end,1)-LitMod(1,1))*1000;
ysize = abs(LitMod(end,2)-0)*1000;
% xsize=1070000;
% ysize= 400000;
xsize = xsize + ExtendDistance*2;
ysize = ysize + AirThickness;

%% nodes
% Defining resolution
xres=(xsize/5000);
yres=(ysize/2000);
xnum=xres+1;
ynum=yres+1;
xnum=51;
ynum=51;

%% markers
% Defining number of markers and steps between them in the horizontal and vertical direction
xmx=5; %number of markers per cell in horizontal direction
ymy=5; %number of markers per cell in vertical direction
mxnum=(xnum-1)*xmx; %total number of markers in horizontal direction
mynum=(ynum-1)*ymy; %total number of markers in vertical direction
mxstep=xsize/mxnum; %step between markers in horizontal direction   
mystep=ysize/mynum; %step between markers in vertical direction

% Defining gridsteps
xstp=xsize./(xnum-1);
ystp=ysize./(ynum-1);

%% Creating nodes arrays
x1 = 0 * xstp:xstp:xsize;
y1 = 0 * ystp:ystp:ysize;
[NX,NY] = meshgrid(x1, y1);

%% the center of current cell
x2 = 0.5 * xstp:xstp:xsize;
y2 = 0.5 * ystp:ystp:ysize;
[CX,CY] = meshgrid(x2, y2);

%% Defining intial position of markers
x3 = 0.5 * mxstep:mxstep:xsize;
y3 = 0.5 * mystep:mystep:ysize;
[MX,MY] = meshgrid(x3, y3);
clear x1 x2 x3 y1 y2 y3

%% Creating markers arrays
MI=zeros(mynum,mxnum);   % Type
MRHO=zeros(mynum,mxnum); % Density (kg/m3)
META=zeros(mynum,mxnum);  % viscosity, Pa s
MTK=zeros(mynum,mxnum);  % Temperature, C

MXN=zeros(mynum,mxnum);  % Horizontal index
MYN=zeros(mynum,mxnum);  % Vertical index

MSXX=zeros(mynum,mxnum);  % SIGMAxx - deviatoric normal stress, Pa
MSXY=zeros(mynum,mxnum);  % SIGMAyy - shear stress, Pa
MEXX=zeros(mynum,mxnum);  % EPSILONxx - normal strain rate, 1/s
MEXY=zeros(mynum,mxnum);  % EPSILONyy - shear strain rate, 1/s
MPR=zeros(mynum,mxnum);   % Pressure, Pa
MGII=zeros(mynum,mxnum);  % Accumulated strain
MRAT=ones(mynum,mxnum);   % EiiMarker/EiiGrid Ratio

MEII=ones(mynum,mxnum);  % EPSILONyy - shear strain rate, 1/s

MVX=zeros(mynum,mxnum);
MVY=zeros(mynum,mxnum);
MV=zeros(mynum,mxnum);

%% Defining lithological structure of the model LitMod 
TopoYLit_x=TopoIn(:,1)*1000 + ExtendDistance;
TopoYLit_y=TopoIn(:,2);
TopoYLit = interp1(TopoYLit_x,TopoYLit_y,MX(1,:),'nearest','extrap');

X=LitMod(:,1)*1000 + ExtendDistance;
Y=-LitMod(:,2)*1000 + AirThickness;

sii0=1e-15;
MEII=MEII*sii0;
% Acceleration of Gravity, m/s^2
g=9.8;

for xm = 1:1:mxnum
    for ym = 1:1:mynum 
        r=(X-MX(ym,xm)).^2+(Y-MY(ym,xm)).^2;
        num=find(r==min(r(:)));
        num=num(1);
        MI(ym,xm)=LitMod(num,8);
        MRHO(ym,xm)=LitMod(num,7);
        MTK(ym,xm)=LitMod(num,3);
        MPR(ym,xm)=LitMod(num,4)+AirDensity*g*AirThickness;
        
        if MI(ym,xm)==31
            MI(ym,xm)=75;
        end
        if MY(ym,xm)<AirThickness - 1*TopoYLit(xm)
            MI(ym,xm)=AirTypeNumber;
            MRHO(ym,xm)=AirDensity;
            
            MPR(ym,xm)=AirDensity*g*MY(ym,xm);
        end
        
%         META(ym,xm)=Viscosity_Material(MTK(ym,xm),MPR(ym,xm),MEII(ym,xm),MI(ym,xm));
        
    end
end
MPR_LitMod=MPR;
%% setting parameter

% Pressure in the upermost, leftmost (first) cell
prfirst=0;

% Maximal timestep, s
timemax=1e+8*(365.25*24*3600);
timestepSet=0; % Control No Move
% Maximal marker displacement step, number of gridsteps
markmax=0.5;

%% Density, viscosity, shear modulus, temperature, thermal conductivity, RHO*Cp arrays
typ1 = zeros(ynum,xnum);        % Type for nodes
etas1 = zeros(ynum,xnum);       % Viscosity for shear stress
etan1 = zeros(ynum-1,xnum-1);   % Viscosity for normal stress
rho1 = zeros(ynum,xnum);        % Density
tk1 = zeros(ynum,xnum);         % Temperature
tk2 = tk1;

mus1 = zeros(ynum,xnum);        % Shear modulus for shear stress
mun1 = zeros(ynum-1,xnum-1);    % Shear modulus for normal stress
sxy1 = zeros(ynum,xnum);        % Shear stress
sxx1 = zeros(ynum-1,xnum-1);    % Normal stress
rhocp1 = zeros(ynum,xnum);      % RHO*Cp (for temperature equation)
kt1 = zeros(ynum,xnum);         % Thermal conductivity
hr1 = zeros(ynum,xnum);         % Radiogenic heat production
ha1 = zeros(ynum,xnum);         % Adiabatic heat production/consuming

%% Main Time cycle

% Initial time, s
timesum=0;
% Backup rock type, density and viscosity arrays
for ntimestep=1:1:stepmax
    MEIIold=MEII;
    MVold=MV;
    MPRold=MPR;
    
    %% META for each makers
    for xm = 1:1:mxnum
        for ym = 1:1:mynum
            if MI(ym,xm)==AirTypeNumber
                META(ym,xm)=AirViscosity;
            elseif MI(ym,xm)>-1 && MI(ym,xm)<11
                META(ym,xm)=1e21;
            else
                META(ym,xm)=Viscosity_Material(MTK(ym,xm),MPR(ym,xm),MEII(ym,xm),MI(ym,xm));
            end
        end
    end
    %% Backup transport properties arrays
    typ0 = typ1;
    etas0 = etas1;
    etan0 = etan1;
    mus0 = mus1;
    mun0 = mun1;
    sxy0 = sxy1;
    sxx0 = sxx1;
    rho0 = rho1;
    tk0=tk2;
    rhocp0=rhocp1;
    kt0=kt1;
    hr0=hr1;
    ha0=ha1;
    
    % Clear Clear transport properties arrays
    typ1 = zeros(ynum,xnum);
    etas1 = zeros(ynum,xnum);
    etan1 = zeros(ynum-1,xnum-1);
    rho1 = zeros(ynum,xnum);

    mus1 = zeros(ynum,xnum);
    mun1 = zeros(ynum-1,xnum-1);
    sxy1 = zeros(ynum,xnum);
    sxx1 = zeros(ynum-1,xnum-1);
    tk1 = zeros(ynum,xnum);
    rhocp1 = zeros(ynum,xnum);
    kt1 = zeros(ynum,xnum);
    hr1 = zeros(ynum,xnum);
    ha1 = zeros(ynum,xnum);
    
    % Clear wights for basic nodes
    wtnodes=zeros(ynum,xnum);
    % Clear wights for etas
    wtetas=zeros(ynum,xnum);
    % Clear wights for etan
    wtetan=zeros(ynum-1,xnum-1);

    %% Interpolating parameters from markers to nodes
    for xm = 1:1:mxnum
        for ym = 1:1:mynum  

            %  xn    rho(xn,yn)--------------------rho(xn+1,yn)
            %           ?           ^                  ?
            %           ?           ?                  ?
            %           ?          dy                  ?
            %           ?           ?                  ?
            %           ?           v                  ?
            %           ?<----dx--->o Mrho(xm,ym)       ?
            %           ?                              ?
            %           ?                              ?
            %  xn+1  rho(xn,yn+1)-------------------rho(xn+1,yn+1)
            %
            % Define indexes for upper left node in the cell where the marker is
            % !!! SUBTRACT 0.5 since int16(0.5)=1
            xn=double(int16(MX(ym,xm)./xstp-0.5))+1;
            yn=double(int16(MY(ym,xm)./ystp-0.5))+1;
            if (xn<1)
                xn=1;
            end
            if (xn>xnum-1)
                xn=xnum-1;
            end
            if (yn<1)
                yn=1;
            end
            if (yn>ynum-1)
                yn=ynum-1;
            end

            % Define normalized distances from marker to the upper left node;
            dx=MX(ym,xm)./xstp-xn+1;
            dy=MY(ym,xm)./ystp-yn+1;

            % Add density to 4 surrounding nodes
            rho1(yn,xn)=rho1(yn,xn)+(1.0-dx).*(1.0-dy).*MRHO(ym,xm);
            wtnodes(yn,xn)=wtnodes(yn,xn)+(1.0-dx).*(1.0-dy);
            rho1(yn+1,xn)=rho1(yn+1,xn)+(1.0-dx).*dy.*MRHO(ym,xm);
            wtnodes(yn+1,xn)=wtnodes(yn+1,xn)+(1.0-dx).*dy;
            rho1(yn,xn+1)=rho1(yn,xn+1)+dx.*(1.0-dy).*MRHO(ym,xm);
            wtnodes(yn,xn+1)=wtnodes(yn,xn+1)+dx.*(1.0-dy);
            rho1(yn+1,xn+1)=rho1(yn+1,xn+1)+dx.*dy.*MRHO(ym,xm);
            wtnodes(yn+1,xn+1)=wtnodes(yn+1,xn+1)+dx.*dy;

            % Add shear viscosity etas() and rock type typ() to 4 surrounding nodes
            % only using markers located at <=0.5 gridstep distances from nodes
            if(dx<=0.5 && dy<=0.5)
                etas1(yn,xn)=etas1(yn,xn)+(1.0-dx).*(1.0-dy).*META(ym,xm);
                typ1(yn,xn)=typ1(yn,xn)+(1.0-dx).*(1.0-dy).*MI(ym,xm);
                wtetas(yn,xn)=wtetas(yn,xn)+(1.0-dx).*(1.0-dy);
            end
            if(dx<=0.5 && dy>=0.5)
                etas1(yn+1,xn)=etas1(yn+1,xn)+(1.0-dx).*dy.*META(ym,xm);
                typ1(yn+1,xn)=typ1(yn+1,xn)+(1.0-dx).*dy.*MI(ym,xm);
                wtetas(yn+1,xn)=wtetas(yn+1,xn)+(1.0-dx).*dy;
            end
            if(dx>=0.5 && dy<=0.5)
                etas1(yn,xn+1)=etas1(yn,xn+1)+dx.*(1.0-dy).*META(ym,xm);
                typ1(yn,xn+1)=typ1(yn,xn+1)+dx.*(1.0-dy).*MI(ym,xm);
                wtetas(yn,xn+1)=wtetas(yn,xn+1)+dx.*(1.0-dy);
            end
            if(dx>=0.5 && dy>=0.5)
                etas1(yn+1,xn+1)=etas1(yn+1,xn+1)+dx.*dy.*META(ym,xm);
                typ1(yn+1,xn+1)=typ1(yn+1,xn+1)+dx.*dy.*MI(ym,xm);
                wtetas(yn+1,xn+1)=wtetas(yn+1,xn+1)+dx.*dy;
            end

            % Add normal viscosity etan() to the center of current cell
            etan1(yn,xn)=etan1(yn,xn)+(1.0-abs(0.5-dx)).*(1.0-abs(0.5-dy)).*META(ym,xm);
            wtetan(yn,xn)=wtetan(yn,xn)+(1.0-abs(0.5-dx)).*(1.0-abs(0.5-dy));

        end
    end

    % Computing  Viscosity, density, rock type for nodal points
    for i=1:1:ynum
        for j=1:1:xnum
            % Density
            if (wtnodes(i,j)~=0)
                % Compute new value interpolated from markers
                rho1(i,j)=rho1(i,j)./wtnodes(i,j);
            else
                % If no new value is interpolated from markers old value is used
                rho1(i,j)=rho0(i,j);
            end
            % Shear viscosity and type
            if (wtetas(i,j)~=0)
                % Compute new value interpolated from markers
                etas1(i,j)=etas1(i,j)./wtetas(i,j);
                typ1(i,j)=typ1(i,j)./wtetas(i,j);
            else
                % If no new value is interpolated from markers old value is used
                etas1(i,j)=etas0(i,j);
                typ1(i,j)=typ0(i,j);
            end
            % Normal viscosity
            if (i<ynum && j<xnum)
                if (wtetan(i,j)~=0)
                    % Compute new value interpolated from markers
                    etan1(i,j)=etan1(i,j)./wtetan(i,j);
                else
                    % If no new value is interpolated from markers old value is used
                    etan1(i,j)=etan0(i,j);
                end
            end
        end
    end

    %% cheak out Viscosity, density, rock type for nodal points
    figure(21)
    subplot(2,2,1)
%     plot(NX,NY,'black',NX',NY','black')
%     hold on
%     plot(CX,CY,'r*')
%     plot(MX,MY,'b.')
    
    pcolor(MX,MY,MTK);
    shading interp;
    colormap(jet);colorbar;
    axis ij;
    title(['Temperture/C']);
    subplot(2,2,2)
    pcolor(MX,MY,MRHO);
    shading interp;
    colormap(jet);colorbar;
    axis ij;
    title(['Rock density']);
    subplot(2,2,3)
    pcolor(MX,MY,log10(META));
    shading interp;
    colormap(jet);colorbar;
    axis ij;
    title(['Rock Viscosity']);
    subplot(2,2,4)
    pcolor(MX,MY,MI);
    shading interp;
    colormap(jet);colorbar;
    axis ij;
    title(['Rock Type']);
    
    %
	figure(22)
    subplot(2,2,1)
    pcolor(NX,NY,tk1);
    shading interp;
    colormap(jet);colorbar;
    axis ij;
    title(['Temperture/C']);
    subplot(2,2,2)
    pcolor(NX,NY,rho1);
    shading interp;
    colormap(jet);colorbar;
    axis ij;
    title(['Rock density']);
    subplot(2,2,3)
    surf(NX,NY,log10(etas1));
    
    shading interp;
    colormap(jet);colorbar;
    axis ij;
    title(['Rock Viscosity']);
    subplot(2,2,4)
    pcolor(NX,NY,typ1);
    shading interp;
    colormap(jet);colorbar;
    axis ij;
    title(['Rock Type']);
    
    %% Computing right part of Stokes (RX, RY) and Continuity (RC) equation
    % vx, vy, P
    vx1=zeros(ynum+1,xnum);
    vy1=zeros(ynum,xnum+1);
    pr1=zeros(ynum-1,xnum-1);
    % Right parts of equations
    RX1=zeros(ynum+1,xnum);
    RY1=zeros(ynum,xnum+1);
    RC1=zeros(ynum-1,xnum-1);
    % Grid points cycle
    for i=1:1:ynum;
        for j=1:1:xnum
            % Right part of x-Stokes Equation
            if(j>1 && i>1 && j<xnum)
                RX1(i,j)=0;
            end
            % Right part of y-Stokes Equation
            if(j>1 && i>1 && i<ynum)
                RY1(i,j)=-g*(rho1(i,j)+rho1(i,j-1))/2;
            end
        end
    end


    % Solving of Stokes and Continuity equations on nodes
    % and computing residuals
    % by calling function Stokes_Continuity_solver_ghost()

    [vx1,resx1,vy1,resy1,pr1,resc1]=Stokes_Continuity_solver_ghost(prfirst,etas1,etan1,xnum,ynum,xstp,ystp,RX1,RY1,RC1,bleft,bright,btop,bbottom);
    
    
    %% Compute Stress and strain rate components
    EXX=zeros(ynum-1,xnum-1); % Strain rate EPSILONxx, 1/s
    SXX=zeros(ynum-1,xnum-1); % deviatoric stress SIGMAxx, Pa
    EYY=zeros(ynum-1,xnum-1); % Strain rate EPSILONyy, 1/s
    SYY=zeros(ynum-1,xnum-1); % deviatoric stress SIGMAyy, Pa
    EXY=zeros(ynum,xnum); % Strain rate EPSILONxy, 1/s
    SXY=zeros(ynum,xnum); % deviatoric stress SIGMAxy, Pa
    % second invariant of the Strain rate, 1/s, deviatoric stress, Pa
    EII=zeros(ynum-1,xnum-1); % EII=((EXX'2 + EYY'2 + EYX'2 + EXY'2)/2)^0.5
    SII=zeros(ynum-1,xnum-1); % SII=((SXX'2 + SYY'2 + SYX'2 + SXY'2)/2)^0.5
    
    % Compute EPSILONxy, SIGMAxy in basic nodes
    for xn = 1:1:xnum
        for yn = 1:1:ynum 
            % EXY=0.5(dvx/dy+dvy/dx)
            EXY(yn,xn)=0.5*((vx1(yn+1,xn)-vx1(yn,xn))/ystp+...
                (vy1(yn,xn+1)-vy1(yn,xn))/xstp);
            % SXY
            SXY(yn,xn)=2*etas1(yn,xn)*EXY(yn,xn);
        end
    end
    
    % Compute EPSILONxx, SIGMA'xx in pressure nodes
    % deviatoric stress ij = 2*eta*strain rate ij
    for xn = 1:1:xnum-1
        for yn = 1:1:ynum-1  
            % EXX=dvx/dx
            EXX(yn,xn)=(vx1(yn+1,xn+1)-vx1(yn+1,xn))/xstp;
            % SXX
            SXX(yn,xn)=2*etan1(yn,xn)*EXX(yn,xn);
            % EYY=dvy/dy
            EYY(yn,xn)=(vy1(yn+1,xn+1)-vy1(yn,xn+1))/ystp;
            % SYY
            SYY(yn,xn)=2*etan1(yn,xn)*EYY(yn,xn);
            % SII
            SII(yn,xn)=1/2*(SXX(yn,xn)^2 + SYY(yn,xn)^2 + SXY(yn,xn)^2 + SXY(yn,xn)^2);
            SII(yn,xn)=SII(yn,xn)^0.5;
            % EII
            EII(yn,xn)=1/2*(EXX(yn,xn)^2 + EYY(yn,xn)^2 + EXY(yn,xn)^2 + EXY(yn,xn)^2);
            EII(yn,xn)=EII(yn,xn)^0.5;
            % SII
            SII(yn,xn)=1/2*(SXX(yn,xn)^2 + SYY(yn,xn)^2 + SXY(yn,xn)^2 + SXY(yn,xn)^2);
            SII(yn,xn)=SII(yn,xn)^0.5;
        end
    end
    
    
    %% Defining scale for Stokes residuals from y-Stokes equation
    % dSIGMAij/dj-dP/di=-RHO*gi=0  => Stokes scale=abs(RHO*gi)
    stokesscale= MRHO(1)*g;
    % Defining scale for Continuity residuals from y-Stokes equation
    % dvx/dx+dvy/dy=0 can be transformed to 2ETA(dvx/dx+dvy/dy)/dx=0 
    % which is similar to dSIGMAij/dj and has scale given above
    % therefore continuity scale = scale=abs(RHO*gi/ETA*dx)
    continscale= MRHO(1)*g/META(1)*xstp;



    % Defining timestep
    timestep=timemax;
    % Check maximal velocity
    vxmax=max(abs(max(max(vx1))),abs(min(min(vx1))))
    vymax=max(abs(max(max(vy1))),abs(min(min(vy1))))
    % Check marker displacement step
    if (vxmax>0)
        if (timestep>markmax*xstp/vxmax)
            timestep=markmax*xstp/vxmax
        end
    end
    if (vymax>0)
        if (timestep>markmax*ystp/vymax)
            timestep=markmax*ystp/vymax
        end
    end
    timestep=timestep
    
    timestep=timestepSet; % setting

    %% Moving Markers by velocity field %% Computing strain rate and pressure for markers
    
    for xm = 1:1:mxnum
        for ym = 1:1:mynum  

            %  xn    V(xn,yn)--------------------V(xn+1,yn)
            %           ?           ^                  ?
            %           ?           ?                  ?
            %           ?          dy                  ?
            %           ?           ?                  ?
            %           ?           v                  ?
            %           ?<----dx--->o Mrho(xm,ym)       ?
            %           ?                              ?
            %           ?                              ?
            %  xn+1  V(xn,yn+1)-------------------V(xn+1,yn+1)
            
            %% Computing strain rate and pressure for markers
            xn=double(int16(MX(ym,xm)./xstp))+1;
            yn=double(int16(MY(ym,xm)./ystp))+1;
            % Check vertical index for upper left VX-node 
            % It must be between 1 and ynum (see picture for staggered grid)
            if (xn<1)
                xn=1;
            end
            if (xn>xnum-2)
                xn=xnum-2;
            end
            if (yn<1)
                yn=1;
            end
            if (yn>ynum-2)
                yn=ynum-2;
            end
            % Define and check normalized distances from marker to the pressure-node;
            dx=MX(ym,xm)./xstp-xn+0.5;
            dy=MY(ym,xm)./ystp-yn+0.5;

            % Calculate Marker velocity from four surrounding nodes
            MSXX(ym,xm)=0;
            MSXX(ym,xm)=MSXX(ym,xm)+(1.0-dx).*(1.0-dy).*SXX(yn,xn);
            MSXX(ym,xm)=MSXX(ym,xm)+(1.0-dx).*dy.*SXX(yn+1,xn);
            MSXX(ym,xm)=MSXX(ym,xm)+dx.*(1.0-dy).*SXX(yn,xn+1);
            MSXX(ym,xm)=MSXX(ym,xm)+dx.*dy.*SXX(yn+1,xn+1); 
            
            MEXX(ym,xm)=0;
            MEXX(ym,xm)=MEXX(ym,xm)+(1.0-dx).*(1.0-dy).*EXX(yn,xn);
            MEXX(ym,xm)=MEXX(ym,xm)+(1.0-dx).*dy.*EXX(yn+1,xn);
            MEXX(ym,xm)=MEXX(ym,xm)+dx.*(1.0-dy).*EXX(yn,xn+1);
            MEXX(ym,xm)=MEXX(ym,xm)+dx.*dy.*EXX(yn+1,xn+1); 
            
            MEYY(ym,xm)=0;
            MEYY(ym,xm)=MEYY(ym,xm)+(1.0-dx).*(1.0-dy).*EYY(yn,xn);
            MEYY(ym,xm)=MEYY(ym,xm)+(1.0-dx).*dy.*EYY(yn+1,xn);
            MEYY(ym,xm)=MEYY(ym,xm)+dx.*(1.0-dy).*EYY(yn,xn+1);
            MEYY(ym,xm)=MEYY(ym,xm)+dx.*dy.*EYY(yn+1,xn+1); 
            
            MPR(ym,xm)=0;
            MPR(ym,xm)=MPR(ym,xm)+(1.0-dx).*(1.0-dy).*pr1(yn,xn);
            MPR(ym,xm)=MPR(ym,xm)+(1.0-dx).*dy.*pr1(yn+1,xn);
            MPR(ym,xm)=MPR(ym,xm)+dx.*(1.0-dy).*pr1(yn,xn+1);
            MPR(ym,xm)=MPR(ym,xm)+dx.*dy.*pr1(yn+1,xn+1); 
            
%             MEII(ym,xm)=(MSXX(ym,xm)^2+MSXY(ym,xm)^2)^0.5;
            MEII(ym,xm)=1/2*(MEXX(ym,xm)^2 + MEYY(ym,xm)^2 + MEXY(ym,xm)^2 + MEXY(ym,xm)^2);
            MEII(ym,xm)=MEII(ym,xm)^0.5;
            
            %%
            % Define indexes for upper left node in the VX-cell where the marker is
            % VX-cells are displaced upward for 1/2 of vertical gridstep
            % !!! SUBTRACT 0.5 since int16(0.5)=1
            xn=double(int16(MX(ym,xm)./xstp-0.5))+1;
            yn=double(int16((MY(ym,xm)+ystp/2.0)./ystp-0.5))+1;
            % Check vertical index for upper left VX-node 
            % It must be between 1 and ynum (see picture for staggered grid)
            if (xn<1)
                xn=1;
            end
            if (xn>xnum-1)
                xn=xnum-1;
            end
            if (yn<1)
                yn=1;
            end
            if (yn>ynum)
                yn=ynum;
            end
            % Define and check normalized distances from marker to the upper left VX-node;
            dx=MX(ym,xm)./xstp-xn+1;
            dy=(MY(ym,xm)+ystp/2.0)./ystp-yn+1;

            % Calculate Marker velocity from four surrounding nodes
            vxm=0;
            vxm=vxm+(1.0-dx).*(1.0-dy).*vx1(yn,xn);
            vxm=vxm+(1.0-dx).*dy.*vx1(yn+1,xn);
            vxm=vxm+dx.*(1.0-dy).*vx1(yn,xn+1);
            vxm=vxm+dx.*dy.*vx1(yn+1,xn+1);

            % Define indexes for upper left node in the VY-cell where the marker is
            % VY-cells are displaced leftward for 1/2 of horizontal gridstep
            % !!! SUBTRACT 0.5 since int16(0.5)=1
            xn=double(int16((MX(ym,xm)+xstp/2.0)./xstp-0.5))+1;
            yn=double(int16(MY(ym,xm)./ystp-0.5))+1;
            % Check horizontal index for upper left VY-node 
            % It must be between 1 and xnum (see picture for staggered grid)
            if (xn<1)
                xn=1;
            end
            if (xn>xnum)
                xn=xnum;
            end
            if (yn<1)
                yn=1;
            end
            if (yn>ynum-1)
                yn=ynum-1;
            end
            % Define and check normalized distances from marker to the upper left VX-node;
            dx=(MX(ym,xm)+xstp/2.0)./xstp-xn+1;
            dy=MY(ym,xm)./ystp-yn+1;
            % Calculate Marker velocity from four surrounding nodes
            vym=0;
            vym=vym+(1.0-dx).*(1.0-dy).*vy1(yn,xn);
            vym=vym+(1.0-dx).*dy.*vy1(yn+1,xn);
            vym=vym+dx.*(1.0-dy).*vy1(yn,xn+1);
            vym=vym+dx.*dy.*vy1(yn+1,xn+1);

            % Displacing Marker according to its velocity
            MX(ym,xm)=MX(ym,xm)+timestep*vxm;
            MY(ym,xm)=MY(ym,xm)+timestep*vym;
            
            MVX(ym,xm)=vxm;
            MVY(ym,xm)=vym;
            MV(ym,xm)=(vxm*vxm+vym*vym)^0.5;
        end
    end
    
        %% Computing strain rate and pressure for markers
    MEII = interp2(CX,CY,EII,MX,MY);
    MEII(isnan(MEII)==1)=sii0;
    
    figure(41)
    subplot(2,2,1)
    surf(MX,MY,MEIIold);title('MEIIold')
    shading interp;
    light;
    lighting phong;
    axis tight;
    subplot(2,2,2)
    surf(MX,MY,MEII);title('MEII')
    shading interp;
    light;
    lighting phong;
    axis tight;
    subplot(2,2,3)
    surf(MX,MY,MEII-MEIIold);title('MEII-MEIIold')
    shading interp;
    light;
    lighting phong;
    axis tight;
    subplot(2,2,4)
    surf(CX,CY,EII);title('EII')
    shading interp;
    light;
    lighting phong;
    axis tight;
    
    
    
    
    
    %% Plotting velocity
    k=int16(ynum*ymy/30);
    figure(9);
    subplot(2,2,1)
    pcolor(NX,NY,log10(etas1));
    colormap(jet);colorbar;
    hold on
    quiver(MX(1:k:end,1:k:end),MY(1:k:end,1:k:end),MVX(1:k:end,1:k:end),MVY(1:k:end,1:k:end),'color','r');
    shading interp;
    axis ij;
    title('Viscosity');
    subplot(2,2,2)
    pcolor(MX,MY,MV);
    hold on
    quiver(MX(1:k:end,1:k:end),MY(1:k:end,1:k:end),MVX(1:k:end,1:k:end),MVY(1:k:end,1:k:end),'color','r');
    shading interp;
    colormap(jet);colorbar;
    axis ij;
    title(' V');
    subplot(2,2,3)
    pcolor(MX,MY,MVX);
    hold on
    quiver(MX(1:k:end,1:k:end),MY(1:k:end,1:k:end),MVX(1:k:end,1:k:end),MVY(1:k:end,1:k:end),'color','r');
    shading interp;
    colormap(jet);colorbar;
    axis ij;
    subplot(2,2,4)
    title(' Vx');
    pcolor(MX,MY,MVY);
    hold on
    quiver(MX(1:k:end,1:k:end),MY(1:k:end,1:k:end),MVX(1:k:end,1:k:end),MVY(1:k:end,1:k:end),'color','r');
    shading interp;
    colormap(jet);colorbar;
    axis ij;
    title(' Vy');
%     saveas(gcf,[num2str(ntimestep),'V'],'jpg')
    
    %% Plotting Residuals for x-Stokes as surface
    figure(1);
    subplot(2,3,1)
    resx0=resx1/stokesscale;
    surf(resx0);
    shading interp;
    light;
    lighting phong;
    axis tight;
    zlabel('residual x-Stokes')
%     colormap(jet);colorbar;
    
    % Plotting Residuals for y-Stokes as surface
    subplot(2,3,2)
    resy0=resy1/stokesscale;
    surf(resy0);
    shading interp;
    light;
    lighting phong;
    axis tight;
    zlabel('residual Y-stokes')
%     colormap(jet);colorbar;
    
    % Plotting Residuals for Continuity as surface
    subplot(2,3,3)
    resc0=resc1/continscale;
    surf(resc0);
    shading interp;
    light;
    lighting phong;
    axis tight;
    zlabel('residual continuity')
%     colormap(jet);colorbar;
    
    % Plotting vx
    subplot(2,3,4)
    surf(vx1);
    shading interp;
    light;
    lighting phong;
    axis tight;
%     colormap(jet);colorbar;

    % Plotting vy
    subplot(2,3,5)
    surf(vy1);
    shading interp;
    light;
    lighting phong;
    axis tight;
%     colormap(jet);colorbar;

    % Plotting P
    subplot(2,3,6)
    pcolor(typ1);
    shading interp;
    colormap(jet);colorbar;
    axis ij;
    title(['Rock types, Time = ',num2str(timesum*1e-6/(365.25*24*3600)),' Myr']);

    % Advance in time
    timesum=timesum+timestep;

    % Define vertical velocity for the initial center of the block
    % Initial position of block center in vy grid
    xblock=(xsize+xstp)/2;
    yblock=0.2*ysize;
    % Define indexes for upper left node in the Vy cell where the top of the wave is
    % !!! SUBTRACT 0.5 since int16(0.5)=1
    xn=double(int16(xblock./xstp-0.5))+1;
    yn=double(int16(yblock./ystp-0.5))+1;
    % Define normalized distances from the top of the growing wave to the upper left Vy node;
    dx=xblock./xstp-xn+1;
    dy=yblock./ystp-yn+1;
    % Interpolate Vy velocity from 4 nodes
    vyblock=(1.0-dx)*(1.0-dy)*vy1(yn,xn)+dx*(1.0-dy)*vy1(yn,xn+1)+(1.0-dx)*dy*vy1(yn+1,xn)+dx*dy*vy1(yn+1,xn+1)

    
    %% Topo
    MTopox=MX(1,:);
    dis=MY(:,1)-AirThickness;
    MsufaceLow=find(dis>0);
    MsufaceLow=MsufaceLow(1);
    
%     P=(MPR(sufaceLow,1)+MPR(sufaceTop,1))/2;
%     P=MPR(MsufaceLow,:);
    dy=MY(MsufaceLow+1,1)-MY(MsufaceLow,1);
    
    dvy=MVY(2:end,:)-MVY(1:end-1,:);
    dvy(mynum,:)=0;

    drho=2400-AirDensity;
    
%     MTopoSYY = (2*META.*dvy)/dy-MPR;
    MTopoSYY=-MSXX-MPR;
%     MTopoSYY=-MSXX-0;
    MTopo=-MTopoSYY/drho/g;
    figure(51)
    subplot(4,1,1)
    plot(MTopox,MVY(MsufaceLow,:))
    ylabel('MVY')
    subplot(4,1,2)
    plot(MTopox,MTopo(MsufaceLow,:))
    
    
    %
    Topox=CX(1,:);
    dis=CY(:,1)-AirThickness;
    sufaceLow=find(dis>0);
    sufaceLow=sufaceLow(1);

    subplot(4,1,3)
%     dy=CY(MsufaceLow+1,1)-CY(MsufaceLow,1);
%     dvy=vy1(2:end,1:end-2)-vy1(1:end-1,1:end-2);
%     dvy(ynum-1,:)=0;
%     TopoSYY = (2*etan1.*dvy)/dy-pr1;

    TopoSYY=SYY-pr1;
%     TopoSYY=SYY-0;
    Topo=-TopoSYY/drho/g;
    
    plot(vy1(sufaceLow,:))
    
    subplot(4,1,4)
    plot(Topox,Topo(sufaceLow,:))
%     plot(Topox,Topo(sufaceLow,:),Topox,-TopoSYY1(sufaceLow,:)/drho/g)
    
%     saveas(gcf,[num2str(ntimestep),'Topo'],'jpg')
%     SXX(yn,xn)
    


    %%  VideoFile
    figure(101);
    tailecr=[1 1 1600 1200];
    set(gcf,'Position',[1 1 tailecr(3) tailecr(4) ]);
    set(gcf,'color','w')
    
    subplot(3,3,1)
    Title='Density(kg/m^3)';
    Plot_fig(MX, MY, MRHO, Title,MVX,MVY,k)
    
    subplot(3,3,2)
    Title='Temperture(C)';
    Plot_fig(MX, MY, MTK, Title,MVX,MVY,k)
    
%     subplot(3,4,3)
%     Title='Perssure(Pa)';
%     Plot_fig(MX, MY, MPR, Title,MVX,MVY,k)
    
    subplot(3,3,3)    
    Title='Log10(Viscosity)(Pa s)';
    Plot_fig(MX, MY, log10(META), Title,MVX,MVY,k)
    
%     subplot(3,4,5)
%     Plot_fig(MX, MY, MEXX, Title,MVX,MVY,k)
%     title('MEXX(Pa)');
%     
%     subplot(3,4,6)
%     Plot_fig(MX, MY, MEII, Title,MVX,MVY,k)
%     title('EII(Pa)');
    
    subplot(3,3,7)
%     Plot_fig(MX, MY, MEII, 'EII(Pa)',MVX,MVY,k)
    plot(Topox/1000,EYY(sufaceLow,:))
    xlim([0,xsize/1000])
%     ylim([-100,100])
    colormap;colorbar;
    title([ 'Depth=',num2str(CY(sufaceLow,2)/1000),' km']);
    ylabel('EYY(s-1)')
    
%     subplot(3,4,7)
    DeltaMEII=(MEII-MEIIold)./MEIIold;
%     Plot_fig(MX, MY, DeltaMEII, Title,MVX,MVY,k)
%     title('Delta MEII(Pa)');
    
    subplot(3,3,8)
%     plot(Topox/1000,Topo(sufaceLow,:),MTopox/1000,MTopo(MsufaceLow,:))
    plot(Topox/1000,SYY(sufaceLow,:))
    xlim([0,xsize/1000])
%     ylim([-100,100])
    colormap;colorbar;
    title(['Depth=',num2str(CY(sufaceLow,2)/1000),' km']);
    ylabel('SYY(Pa)')
    
    subplot(3,3,4)
    Plot_fig(MX, MY, MV,  'V(m/s)',MVX,MVY,k)

    subplot(3,3,5)
    pcolor(MX,MY,MVX);
    Plot_fig(MX, MY, MVX,  'Vx(m/s)',MVX,MVY,k)
    
    subplot(3,3,6)
    Plot_fig(MX, MY, MVX,  'Vx(m/s)',MVX,MVY,k)
    title('Vy(m/s)');
    
    subplot(3,3,9)
    DeltaMEIIRES(ntimestep)=mean(DeltaMEII(:).^2).^0.5;
    
%     DeltaMEIIRES=log10(DeltaMEIIRES)
%     DeltaMV=MV-MVold;
%     DeltaMVRES(ntimestep)=mean(DeltaMV(:).^2).^0.5;
    semilogy(DeltaMEIIRES,'r*');hold on
%     plot(DeltaMVRES,'r*')
    xlim([0,stepmax+1])
    ylim([0,10^(int16(log10(max(DeltaMEIIRES)))+1)])
    title('Root mean square error (RMSE)');
    
%     suptitle([num2str(xnum),'X',num2str(ynum),', step=',num2str(ntimestep)])
    suptitle({['Mesh: ',num2str(xnum),'X',num2str(ynum),...
        ', Air: ',num2str(AirThickness/1000),' km ',...
        ', BC: All free slip'];...
        ['Step = ',num2str(ntimestep)];...
        []})
    xlabel('Number of iterations') 
    
    %% Save result
    name=['Air',num2str(AirThickness/1000),'km_Step',num2str(ntimestep)];
    %saveas(gcf,name,'fig')
    saveas(gcf,name,'jpg')
    save(name)
    if ntimestep<stepmax
        clf
    end
    
end

