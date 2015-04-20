disp('CVX')
G = 25;
F = 25;

cvx_solver gurobi

cvx_begin

variable d nonnegative
variable y(F,2) nonnegative
variable z(G+1,G+1,F) binary

minimize( d )

y <= 1

sum(z,3) == 1

for i = 0:G
  for j = 0:G
    for f = 1:F
      d >= norm([i/G,j/G] - y(f,:)) - 2*sqrt(2)*(1- z(i+1,j+1,f))
    end
  end
end

cvx_end
