
function [] = doyalmip()


runinstance('clnlbeam',5000);
runinstance('clnlbeam',50000);
runinstance('clnlbeam',500000);


end

function [] = runinstance(name,N)

modelrep = 1;

% take mimimum over repetitions to decrease variability
buildtime = Inf;
for k = 1:modelrep
    yalmip('clear')
    tic
    model = eval(sprintf('%s(%d)',name,N));
    model = yalmip2nonlinearsolver(model);
    buildtime = min(toc,buildtime);
end

% yalmip doesn't support hessians of nonlinear functions

disp(['### ',name,',',num2str(N),' ',num2str(buildtime)])


end
