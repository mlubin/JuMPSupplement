disp('YALMIP')
G = 25;
F = 25;

d = sdpvar(1,1);
y = sdpvar(F,2);
z = binvar(G+1,G+1,F,'full');

C = [y <= 1, sum(z,3) == 1];

tic
for i = 0:G
  for j = 0:G
    for f = 1:F
      C = [C, d >= norm([i/G,j/G] - y(f,:)) - 2*sqrt(2)*(1 - z(i+1,j+1,f))];
    end
  end
end
toc

options = sdpsettings('solver','gurobi');
optimize(C,d,options);

exit
