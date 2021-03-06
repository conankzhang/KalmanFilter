function [x_trace,a_trace,z_trace,Sigma2_trace] = CS4300_A6_driver_lin(...
x0,y0,vx0,vy0,max_time,del_t,theta)
% CS4300_A6_driver_lin - driver function for linear Kalman Filter
% On input:
%     x0 (float): initial x location
%     y0 (float): initial y location
%     vx0 (float): initial x velocity
%     vy0 (float): initial y velocity
%     max_time (float): max time for tracking
%     del_t (float): time step size
%     theta (float): angle of line (in radians)
% On output:
%     x_trace (nx4 array): each row has estimated pose (x,y vals)
%     a_trace (nx4 array): actual location at each time step
%     z_trace (nx2 array): sensed location at each time step
%     Sigma2_trace (struct array): covariance of estimated location
%       (i).Sigma2 (4x4 array): covariance matrix for i_th step
% Call:
%     [xt,at,zt,St] = CS4300_A6_driver_lin(0,0,1,1,1,0.1,pi/4);
% Author:
%     Rajul Ramchandani & Conan Zhang
%     UU
%     Fall 2016
u = [0;0];
xa = [x0; y0; vx0; vy0];

A = [1,0,del_t,0;0,1,0,del_t;0,0,1,0;0,0,0,1];
B = [(del_t*del_t)/2,0;0,(del_t*del_t)/2;del_t,0;0,del_t];
C = eye(2,4);
Q = eye(2,2)*0.001; % Change 0.001
R = eye(4,4)*0.001; % Change 0.001
z = CS4300_sensor(xa, C, Q);
z_trace = z';
x = [z(1); z(2); 0; 0];
Sigma2 = zeros(4,4);
x_trace = x';
Sigma2_trace(1).Sigma2 = Sigma2;

t_vals = [0:del_t:max_time];
num_steps = length(t_vals);
a_trace = xa';

for t = 1:num_steps
    xa = CS4300_process(xa, A, B, u, R);
    a_trace(t+1,:) = xa';
    z = CS4300_sensor(xa, C, Q);
    z_trace(t+1,:) = z';
    [x, Sigma2] = CS4300_KF(x, Sigma2, u, z, A, R, B, C, Q);
    x_trace(t+1,:) = x';
    Sigma2_trace(t).Sigma2 = Sigma2;
end