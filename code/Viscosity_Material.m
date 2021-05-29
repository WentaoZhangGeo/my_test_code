% Material properties
% MRHO = density (kg/m3): RHO*[1-ALP*(T-273)]*[1+BET*(P-1e+5)]
% MFLOW = power-law: EPSILONii=AD*SIGMAii^n*exp[-(Ea+Va*P)/RT)
% MMU = shear modulus (Pa)
% MPL = Brittle/plastic strength (Pa): SIGMAyeild=C+sin(FI)*P
%       C=C0, FI=FI0 for strain<=GAM0
%       C=C0+(C1-C0)/(GAM1-GAM0)*(strain-GAM0), FI=FI0+(FI1-FI0)/(GAM1-GAM0)*(strain-GAM0) for GAM0<strain<GAM1
%       C=C1, FI=FI1 for strain>=GAM0
% MCP = heat capacity (J/K/kg)
% MKT = thermal conductivity (W/m/K): k=k0+a/(T+77) 
% MHR = radiogenic heat production (W/m^3) 

function[eta]=Viscosity_Material(T,P,EII,Type)

% Viscosity limits for rocks, Pa
etamin=-1e+18;   % Lower limit, Pa
etamax=1e+23;   % Upper limit, Pa
% Lower stress limit for power law, Pa
% stressmin=1e+4;
%%
    d = 1e-2;  % Grain size, m
    R = 8.314;  % gas constant
    % % Dislocation creep / dry
    % A_dis = 3.5e22;  % material constant, unit, 1/(Pa^n * s * m^m)
    % n_dis = 3.5;  % stress exponent
    % m_dis = 0;  % grain size exponent
    % Ea_dis = 540000;  % activation energy, unit, J/mol
    % Va_dis = 20.0e-6;  % activation volume, unit, m3/mol    15 - 25
    % % Difusion creep / dry
    % A_dif = 8.7e15;
    % n_dif = 1.00;
    % m_dif = -2.5;
    % Ea_dif = 300000;
    % Va_dif = 6.0;

    % Dislocation creep / wet
    A_dis = 2.28e-18;  % Pa m3 s-1
    n_dis = 3.5;  % stress exponent
    m_dis = 0;  % stress exponent
    Ea_dis = 480000;  % J/mol
    Va_dis = 1.1e-5;  % activation volume, unit, m3/mol    15 - 25
    % Difusion creep / wet
    A_dif = 4.7e-16;
    n_dif = 1;
    m_dif = 3;
    Ea_dif = 335000;
    Va_dif = 4.0e-6;

%%
    % Power-law: EPSILONii=AD*SIGMAii^n*exp[-(Ea+Va*P)/RT)
	% Iterate for viscosity
	% First viscosity value
	eta_dis = 0.5 * (A_dis ^ (-1 / n_dis)) * (d ^ (m_dis / n_dis)) * (EII ^ (1 / n_dis - 1)) * exp((Ea_dis + Va_dis * P) / (n_dis * R * (T + 273.15)));
	eta_dif = 0.5 * (A_dif ^ (-1 / n_dif)) * (d ^ (m_dif / n_dif)) * (EII ^ (1 / n_dif - 1)) * exp((Ea_dif + Va_dif * P) / (n_dif * R * (T + 273.15)));

	eta = 1 / (1 / eta_dis + 1 / eta_dif);
	% Limiting viscosity for the power law
	if (eta<etamin) 
        eta=etamin;
    end
    if (eta>etamax)
        eta=etamax;
    end

%% Materials
% 1 = Weak Layer ("sticky water")
MRHO(1,1)=1000;             % standard density, kg/m^3
MRHO(1,2)=3e-5;             % thermal expansion, 1/K
MRHO(1,3)=1e-11;            % compressibility, 1/Pa
MFLOW(1,1)=0;               % 0=constant viscosity
MFLOW(1,2)=1e+18;           % viscosity, Pa s
MMU(1)=1e+20;               % shear modulus, Pa
MPL(1,1)=0;                 % C0, Pa
MPL(1,2)=0;                 % C1, Pa
MPL(1,3)=0;                 % sin(FI0)
MPL(1,4)=0;                 % sin(FI1)
MPL(1,5)=0;                 % GAM0
MPL(1,6)=1;                 % GAM1
MCP(1)=3000;                % Cp, J/kg
MKT(1,1)=300;               % k0, W/m/K
MKT(1,2)=0;                 % a, W/m
MHR(1)=0;                   % radiogenic heat production, W/m^3
% 2 = Sediments
MRHO(2,1)=3000;             % standard density, kg/m^3
MRHO(2,2)=3e-5;             % thermal expansion, 1/K
MRHO(2,3)=1e-11;            % compressibility, 1/Pa
MFLOW(2,1)=1;               % 1=power law (wet quartzite: Ranalli, 1995)
MFLOW(2,2)=3.2e-4;          % AD, 1/s/MPa^n
MFLOW(2,3)=2.3;             % n
MFLOW(2,4)=154;             % Ea, kJ/mol
MFLOW(2,5)=0;               % Va, cm^3
MMU(2)=1e+10;               % shear modulus, Pa
MPL(2,1)=3e+5;              % C0, Pa
MPL(2,2)=3e+5;              % C1, Pa
MPL(2,3)=0;                 % sin(FI0)
MPL(2,4)=0;                 % sin(FI1)
MPL(2,5)=0;                 % GAM0
MPL(2,6)=1;                 % GAM1
MCP(2)=1000;                % Cp, J/kg
MKT(2,1)=0.64;              % k0, W/m/K
MKT(2,2)=807;               % a, W/m
MHR(2)=2.0e-6;              % radiogenic heat production, W/m^3
% 3 = Upper oceanic crust (basalts)
MRHO(3,1)=3200;             % standard density, kg/m^3
MRHO(3,2)=3e-5;             % thermal expansion, 1/K
MRHO(3,3)=1e-11;            % compressibility, 1/Pa
MFLOW(3,1)=1;               % 1=power law (wet quartzite: Ranalli, 1995)
MFLOW(3,2)=3.2e-4;          % AD, 1/s/MPa^n
MFLOW(3,3)=2.3;             % n
MFLOW(3,4)=154;             % Ea, kJ/mol
MFLOW(3,5)=0;               % Va, cm^3
MMU(3)=2.5e+10;             % shear modulus, Pa
MPL(3,1)=3e+5;              % C0, Pa
MPL(3,2)=3e+5;              % C1, Pa
MPL(3,3)=0;                 % sin(FI0)
MPL(3,4)=0;                 % sin(FI1)
MPL(3,5)=0;                 % GAM0
MPL(3,6)=1;                 % GAM1
MCP(3)=1000;                % Cp, J/kg
MKT(3,1)=1.18;              % k0, W/m/K
MKT(3,2)=474;               % a, W/m
MHR(3)=2.5e-7;              % radiogenic heat production, W/m^3
% 4 = Lower oceanic crust (gabbro)
MRHO(4,1)=3200;             % standard density, kg/m^3
MRHO(4,2)=3e-5;             % thermal expansion, 1/K
MRHO(4,3)=1e-11;            % compressibility, 1/Pa
MFLOW(4,1)=1;               % 1=power law (plagioclase An75: Ranalli, 1995)
MFLOW(4,2)=3.3e-4;          % AD, 1/s/MPa^n
MFLOW(4,3)=3.2;             % n
MFLOW(4,4)=238;             % Ea, kJ/mol
MFLOW(4,5)=0;               % Va, cm^3
MMU(4)=2.5e+10;             % shear modulus, Pa
MPL(4,1)=3e+5;              % C0, Pa
MPL(4,2)=3e+5;              % C1, Pa
MPL(4,3)=0.2;               % sin(FI0)
MPL(4,4)=0.2;               % sin(FI1)
MPL(4,5)=0;                 % GAM0
MPL(4,6)=1;                 % GAM1
MCP(4)=1000;                % Cp, J/kg
MKT(4,1)=1.18;              % k0, W/m/K
MKT(4,2)=474;               % a, W/m
MHR(4)=2.5e-7;              % radiogenic heat production, W/m^3
% 5 = Lithospheric mantle
MRHO(5,1)=3300;             % standard density, kg/m^3
MRHO(5,2)=3e-5;             % thermal expansion, 1/K
MRHO(5,3)=1e-11;            % compressibility, 1/Pa
MFLOW(5,1)=1;               % 1=power law (dry olivine: Ranalli, 1995)
MFLOW(5,2)=2.5e+4;          % AD, 1/s/MPa^n
MFLOW(5,3)=3.5;             % n
MFLOW(5,4)=532;             % Ea, kJ/mol
MFLOW(5,5)=12;              % Va, cm^3
MMU(5)=6.7e+10;             % shear modulus, Pa
MPL(5,1)=3e+5;              % C0, Pa
MPL(5,2)=3e+5;              % C1, Pa
MPL(5,3)=0.6;               % sin(FI0)
MPL(5,4)=0.6;               % sin(FI1)
MPL(5,5)=0;                 % GAM0
MPL(5,6)=1;                 % GAM1
MCP(5)=1000;                % Cp, J/kg
MKT(5,1)=0.73;              % k0, W/m/K
MKT(5,2)=1293;              % a, W/m
MHR(5)=2.2e-8;              % radiogenic heat production, W/m^3
% 6 = Asthenospheric mantle
MRHO(6,1)=3300;             % standard density, kg/m^3
MRHO(6,2)=3e-5;             % thermal expansion, 1/K
MRHO(6,3)=1e-11;            % compressibility, 1/Pa
MFLOW(6,1)=1;               % 1=power law (dry olivine: Ranalli, 1995)
MFLOW(6,2)=2.5e+4;          % AD, 1/s/MPa^n
MFLOW(6,3)=3.5;             % n
MFLOW(6,4)=532;             % Ea, kJ/mol
MFLOW(6,5)=12;              % Va, cm^3
MMU(6)=6.7e+10;             % shear modulus, Pa
MPL(6,1)=3e+5;              % C0, Pa
MPL(6,2)=3e+5;              % C1, Pa
MPL(6,3)=0.6;               % sin(FI0)
MPL(6,4)=0.6;               % sin(FI1)
MPL(6,5)=0;                 % GAM0
MPL(6,6)=1;                 % GAM1
MCP(6)=1000;                % Cp, J/kg
MKT(6,1)=0.73;              % k0, W/m/K
MKT(6,2)=1293;              % a, W/m
MHR(6)=2.2e-8;              % radiogenic heat production, W/m^3
% 7 = Hydrated mantle in the intra-plate fracture zone
MRHO(7,1)=3300;             % standard density, kg/m^3
MRHO(7,2)=3e-5;             % thermal expansion, 1/K
MRHO(7,3)=1e-11;            % compressibility, 1/Pa
MFLOW(7,1)=1;               % 1=power law (wet olivine: Ranalli, 1995)
MFLOW(7,2)=2.0e+3;          % AD, 1/s/MPa^n
MFLOW(7,3)=4.0;             % n
MFLOW(7,4)=471;             % Ea, kJ/mol
MFLOW(7,5)=0;               % Va, cm^3
MMU(7)=6.7e+10;             % shear modulus, Pa
MPL(7,1)=3e+5;              % C0, Pa
MPL(7,2)=3e+5;              % C1, Pa
MPL(7,3)=0;                 % sin(FI0)
MPL(7,4)=0;                 % sin(FI1)
MPL(7,5)=0;                 % GAM0
MPL(7,6)=1;                 % GAM1
MCP(7)=1000;                % Cp, J/kg
MKT(7,1)=0.73;              % k0, W/m/K
MKT(7,2)=1293;              % a, W/m
MHR(7)=2.2e-8;              % radiogenic heat production, W/m^3




end


