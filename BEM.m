clc
clear all
close all

%% Physical Constraints

d = 0.998; % [m] Diameter
R = d/2;
dhub = 0.1; % [m] Diameter of Hub
rhub = dhub/2;
tmin = 0.005; % [m] Minimum thickness
tcmax = 0.14; % [-] Maximum thickness relativ to chord length
chordmin = 0.04; % [m] Minimum thickness absolutt
SM = 0.002; % [m] Safety margin in construction
Hmax = 0.05 - SM; % [m] Maximum blade width
Bmax = 0.1 - SM; % [m] Maximum height
u0 = 12; % [m/s] Incomming wind speed
TSR = 7.5; % [-] Tip speed relative to incomming windspeed
z = 2; % [-] Number of blades

% Numerical setup
n = 1e3;
dr = R/n;
r = linspace(rhub+dr, R, n);

% Initial data
a_int = 1/3;
Re_int = ReEst(u0, TSR, a_int, R, chordmin)
w = u0*TSR/R;

%% Setting up lists
a = zeros(1, length(r));
AoA_blade = a;
lambda = a;
amark = a;
sigma = a;
LcR_ratio = a;
Lc = a;
u_rel = a;
Re = a;
Cr = a;
dM = a;
dMmark = a;
dT = a;

M = 0;
T = 0;
P = 0;
lambda(end) = w*R/u0;
%% Air properties
rho = 1.225;
vu = 15.6e-6;

%% NACA 6409
ClCd = 87.4; % [63.7 87.4 118.6]; % Re = 1e5, 2e5, 5e5, Ncrit = 5, opt AoA = 6, 6, 5
Cl = 1.2603; % [1.2456 1.2603 1.1728]; % Re = 1e5, 2e5, 5e5, Ncrit = 5, opt AoA = 6, 6, 5
Cd = Cl/ClCd;
angle_opt = 6; % [6 6 5];

% Choosing data based


% %% NREL's S802 - DISCARDED
% Cl = 1.1093; % @ Re = 5e5 & alpha = 5 deg
% Cd = 0.00894;% @ Re = 5e5 & alpha = 5 deg
% ClCd = Cl/Cd;




for i = 1:n;
    lambda(i) = w*r(i)/u0;
    fun_temp = @(a, lr)(16*a^3 - 24*a^2 + a*(9 - 3*lr^2) - 1 + lr^2);
    fun = @(a) fun_temp(a, lambda(i));
    a(i) = fzero(fun, a_int); 
    amark(i) = (1- 3*a(i))/(4*a(i) - 1);
    sigma(i) = atand((1-a(i))/((1 + amark(i))*lambda(i)));
    AoA_blade(i) = sigma(i) - angle_opt;
    Ca(i) = Cl*cosd(sigma(i)) + Cd*sind(sigma(i));
    Cr(i) = Cl*sind(sigma(i)) - Cd*cosd(sigma(i));
    LcR_ratio(i) = (8*pi*a(i)*lambda(i)*sind(sigma(i))^2)/((1 - a(i))*z*Ca(i)*lambda(end));
    Lc(i) = R*LcR_ratio(i);
    
    % Deciding if blade is larger than allowed
        % Checking if height is limiting factor
        if Lc(i)*sind(AoA_blade(i)) >= Hmax
            Lc(i) = Hmax/sind(AoA_blade(i));
        else
        end
        if Lc(i)*cosd(AoA_blade(i)) >= Bmax
            Lc(i) = Bmax/cosd(AoA_blade(i));
        else
        end
        if Lc(i) <= chordmin
            Lc(i) = chordmin;
        else
        end
%         if Lc(i)*0.09 <= tmin
%             Lc(i) = tmin/0.09;
%         else
%         end
            
    u_rel(i) = sqrt(((1-a(i))*u0)^2 + ((1+amark(i))*w*r(i))^2);
    Re(i) = u_rel(i)*Lc(i)/vu;
    dMmark(i) = 0.5*rho*u_rel(i)^2 *Cr(i)*Lc(i)*dr;
    dM(i) = dMmark(i)*r(i);
    dT(i) = 0.5*rho*u_rel(i)^2 *Ca(i)*Lc(i)*dr;
    
    P = P + (dMmark(i)*r(i)*w*z);
    
    
    M = M + dM(i);
    T = T + dT(i);
end
figure()
plot(r, Lc)

function re = ReEst(U, TSR, a, r, Lc)
vu = 15.6e-6;
a_mark = (1 - 3*a)/(4*a - 1);
w = U*TSR/r;
W = sqrt((U*(1 - a))^2 + (r*w*(1 + a_mark))^2);
re = W*Lc/vu;
end