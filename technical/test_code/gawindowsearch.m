function [x,fval] = gawindowsearch

%% Fitness function and numver of variables
fitnessFcn = @(x) norm(x);
numberOfVariables = 15;

% If decision variables are bounded provide a bound e.g, LB and UB. 
LB = -5*ones(1,numberOfVariables);
UB = 5*ones(1,numberOfVariables); 
Bound = [LB;UB]; % If unbounded then Bound = []

% Create an options structure to be passed to GA
% Three options namely 'CreationFcn', 'MutationFcn', and
% 'PopInitRange' are required part of the problem.
options = gaoptimset('CreationFcn',@int_pop,'MutationFcn',@int_mutation, ...
    'PopInitRange',Bound,'Display','iter','StallGenL',40,'Generations',150, ...
    'PopulationSize',60,'PlotFcns',{@gaplotbestf,@gaplotbestindiv});

[x,fval] = ga(fitnessFcn,numberOfVariables,options);
%---------------------------------------------------

%% Mutation function 
% Mutation function to generate childrens satisfying the range and integer
% constraints on decision variables.
function mutationChildren = int_mutation(parents,options,GenomeLength, ...
    FitnessFcn,state,thisScore,thisPopulation)
shrink = .01; 
scale = 1;
scale = scale - shrink * scale * state.Generation/options.Generations;
range = options.PopInitRange;
lower = range(1,:);
upper = range(2,:);
scale = scale * (upper - lower);
mutationPop =  length(parents);
% The use of ROUND function will make sure that childrens are integers.
mutationChildren =  repmat(lower,mutationPop,1) +  ...
    round(repmat(scale,mutationPop,1) .* rand(mutationPop,GenomeLength));
% End of mutation function

function Population = int_pop(GenomeLength,FitnessFcn,options)

totalpopulation = sum(options.PopulationSize);
range = options.PopInitRange;
lower= range(1,:);
span = range(2,:) - lower;
% The use of ROUND function will make sure that individuals are integers.
Population = repmat(lower,totalpopulation,1) +  ...
    round(repmat(span,totalpopulation,1) .* rand(totalpopulation,GenomeLength));
% End of creation function

% Fitness Function
