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

% An alternative formulation was suggested by the creator
% of YALMIP. We did not consider it as, while the most it
% is the most efficient, it bears little resemblance to
% the original mathematical formulation and so somewhat
% defeats the purpose of an AML.
% a = repmat([i/G;j/G],1,G) - y';
% b = -2*sqrt(2)*(1 - z(i+1,j+1,:));
% C = [C,cone([b(:)'+d;a])];

options = sdpsettings('solver','gurobi');
optimize(C,d,options);

exit
