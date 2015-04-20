m = 500;
n = 500;
dx = 1/n;
T = 1.58;
dt = T/m;
h2 = dx^2;
a = 0.001;

cvx_solver gurobi

disp('cvx_begin')
cvx_begin

% y should be (0..m,0..n), so we'll have to do a +1 correction everywhere
variable y(m+1,n+1)
y >= 0
y <= 1
variable u(m)
u <=  1
u >= -1

% Objective - has sums of quadratics
disp('obj')
% First sum is (in orig idx)  sum_{j in 1..n-1} (y(m,j) - 1)^2
%obj_sum_A = 0;
%for j = 1:(n-1)
%  obj_sum_A = obj_sum_A + (y(m+1,j+1) - 1)^2;
%end
obj_sum_A = sum((y(m+1,2:n) - 1).^2);
% Second sum is (in orig idx)  sum_{i in 1..m-1} u(i)^2
%obj_sum_B = 0;
%for i = 1:(m-1)
%  obj_sum_B = obj_sum_B + u(i)^2;
%end
obj_sum_B = sum(u(1:(m-1)).^2);

minimize( 0.25*dx*( (y(m+1,1) - 1)^2 + 2*obj_sum_A + (y(m+1,n+1) - 1)^2 ) + 0.25*a*dt*(2*obj_sum_B + u(m)^2) );

% PDE constraint
disp('pde')
% Using for loops is too slow for CVX to handle even for (100,100)
% Given what we loop over, and the +1 index correction, here is the mapping
% that allows us to write it in vectorized form. Replace the following single
% indices with the following ranges:
% i   ->  og:  0:m-1  ->  cvx:  1:m
% i+1 ->  og:  1:m    ->  cvx:  2:m+1
% j-1 ->  og:  0:n-2  ->  cvx:  1:n-1
% j   ->  og:  1:n-1  ->  cvx:  2:n
% j+1 ->  og:  2:n    ->  cvx:  3:n+1

lhs = y(2:(m+1),2:n) - y(1:m,2:n);
rhs = y(1:m,1:(n-1)) - 2*y(1:m,2:n) + y(1:m,3:(n+1)) + y(2:(m+1),1:(n-1)) - 2*y(2:(m+1),2:n) + y(2:(m+1),3:(n+1));
lhs == dt*0.5/h2*rhs

disp('remaining constraints')

% IC, BC1, BC2 constraints
y(1,:) == 0
y(2:(m+1),3) - 4*y(2:(m+1),2) + 3*y(2:(m+1),1) == 0
y(2:(m+1),n-2+1) - 4*y(2:(m+1),n-1+1) + 3*y(2:(m+1),n+1) == u - y(2:(m+1),n+1)

disp('cvx_end')
cvx_end
