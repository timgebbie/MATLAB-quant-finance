function [varargout] = gamgconfig(varargin)
% GAMGCONFIG GA configuration solver for the Marsili-Giada spin model
%
% [X,FVAL,[GS,CS,NS]] = GAMGCONFIG(RHO) For correlation matrix RHO. Compute 
%   the chromosome X with the i-th gene giving the cluster that the i-th 
%   object occupies that maximises the log-likelihood function for the Noh 
%   model hypothesis where from Marsili 2002:
%       1.) clusters are uncorrelated, 
%       2.) correlations within clusters are postive.
%
%  The internal correlations CS = SUM(RHO(S,S)) for cluster S where there
%  are NS objects in the S-th cluster. The coupling parameter in then:
%
%   [qn 1.] GS = SQRT(MAX(0,(CS-NS)/(NS^2-NS)))
%
%  This give the Noh model for the price fluctuations for the i-th stock
%
%   [Eqn 2.] R_i = GS * ETA_S + SQRT(1-GS) * EPSILON_i
%
%  For the noise source associated with the s-th cluster, ETA_S, and the 
%  noise sources associated with i-th stock, EPSILON_i.
%
% [X,FVAL,[GS,CS,NS]] = GAMGCONFIG(RHO,NPOP,NGEN,SGEN) for population size 
%   NPOP (default 300), number of generation NGEN (default 400), and stall
%   generation SGEN (default 500).
%
%  [X,FVAL,[GS,CS,NS]] = GAMGCONFIG(RHO,NPOP,NGEN,SGEN,NOPLOT) NOPLOT is by 
%   default FALSE, TRUE to have plots suppressed.
% 
%  [X,FVAL,[GS,CS,NS]] = GAMGCONFIG(RHO,NPOP,NGEN,SGEN,NOPLOT,OPTS)
%   >> opts = gaoptimset('UseParallel', 'never', 'Vectorized', 'off');
%
%   Need to find a linkage object specifying which object is in which cluster
%   based on the Marsili-Giada cost function. The algorithm starts with N
%   distinct objects in N clusters. The algorithm iterates this chromosome
%   until it finds the optimal chromosome with the integer valued i-th gene 
%   giving the cluster that the i-th object occupies.
%
% See Also: SLIKELIHOOD, GA

% $Revision: 1.6 $ $Date: 2009/06/19 13:23:43 $ $Author: Tim Gebbie $

% Author: Tim Gebbie (c) 2009, QT Capital Managment & University of
% Witwatersrand, Johannesburg, South Africa.

noplot = false;
nPop = 300;
nGen = 400;
sGen = 500;
options = {};
switch nargin
    case 1
        c = varargin{1};
    case 4
        c = varargin{1};
        nPop = varargin{2};
        nGen = varargin{3};
        sGen = varargin{4};
    case 5
        c = varargin{1};
        nPop = varargin{2};
        nGen = varargin{3};
        sGen = varargin{4};
        noplot = varargin{5};   
    case 6
        c = varargin{1};
        nPop = varargin{2};
        nGen = varargin{3};
        sGen = varargin{4};
        noplot = varargin{5};
        options = varargin{6};
    otherwise
        error('Incorrect Input Arguments');
end

% Fitness function and numver of variables
fitnessFcn = @(x) myfitnessFcn(x,c);
nvars = size(c,1); % N design variables

% If decision variables are bounded provide a bound e.g, LB and UB. 
LB = ones(1,nvars);
UB = nvars *ones(1,nvars); 
Bound = [LB;UB]; % If unbounded then Bound = []
x0 = 1:nvars; % initial chromosome N clusters

% plot options
if noplot
    plotopts = {[]};
    if isempty(options)
        options = gaoptimset('PlotFcns',plotopts,'Display','off');
    else
        options = gaoptimset(options,'PlotFcns',plotopts,'Display','off');
    end
else
    plotopts = {@gaplotbestf,@gaplotbestindiv};
    if isempty(options)
        options = gaoptimset('PlotFcns',plotopts);
    else
        options = gaoptimset(options,'PlotFcns',plotopts);
    end
end

% Create an options structure to be passed to GA
% Three options namely 'CreationFcn', 'MutationFcn', and
% 'PopInitRange' are required part of the problem.
options = gaoptimset(options,'CreationFcn',@int_pop,'MutationFcn',@int_mutation, ...
    'CrossoverFcn',@int_crossover,'PopInitRange',Bound, ...
    'StallGenL',sGen,'Generations',nGen,'PopulationSize',nPop,'PlotFcns', ...
    plotopts);  % {[]}

% Run the GA to solve for configuration
[x,fval] = ga(fitnessFcn,nvars,options);

% output arguments
varargout{1} = x;
varargout{2} = fval;
% sparse matrix 
if nargout==3,
    varargout{3} = sparse(zeros(max(x),length(x)));
    for i=1:max(x),
        varargout{3}(i,(x==i)) = 1;
    end
    varargout{3} = sparse(varargout{3});
end
% cluster parameters
if nargout==4
    % loop over each cluster to find the internal correlation matrix
    for j=1:max(x(i,:))
        sindex = (x(i,:)==j);
        % #1 : find the number of entries in each object
        ns(j) = sum(sindex);
        % #2 : find the correlation coefficient
        cs(j) = sum(sum(c(sindex,sindex)));
        % #3 : coupling factor coefficient
        gs(j) = sqrt(max(0,(cs(j)-ns(j)) ./ (ns(j) .* ns(j) - ns(j)))); % Eq.4, Marsili (2002)
    end
    varargout{4} = [gs(:),cs(:),ns(:)];
end


%---------------------------------------------------
% The Fitness Function
function score = myfitnessFcn(pop,c)
% [LC] = myfitnessFcn(X,C)
%
% X is a vector of length N for correlation matrix C of dimension N x N
% each entry in X gives the cluster occupied by the N object. 
%
% NS : number of objects in each cluster group
% CS : the cluster correlations relationships
% GS : cluster factor coefficientss
%
% NOTE: The functions sums up all internal energies in a given 
% configuration algorithm (see L. Giada & M. Marsili (2005)). 

% loop over all the populations
% find cluster index

% loop over each member of the population and evaluate
for i=1:size(pop,1),
    % loop over each cluster to find the internal correlation matrix
    for j=1:max(pop(i,:))
        sindex = (pop(i,:)==j);
        % #1 : find the number of entries in each object
        ns(j) = sum(sindex);
        % #2 : find the correlation coefficient
        cs(j) = sum(sum(c(sindex,sindex))); 
    end
    % conditions from Eq.4, Marsili (2002) 
    % -----------------------------------
    % c4 = ns > 1 & cs > ns;
    c1 = (ns == 1) & (cs >= 1); % high temperature limit => lc = 0 
    % -----------------------------------
    % optimal factor coefficient
    gs = sqrt(max(0,(cs-ns) ./ (ns .* ns - ns))); % Eq.4, Marsili (2002) 
    % first term
    t1 = log(ns ./ cs);
    % second term
    % does not satisfy condition 1
    t2(~c1) = log(((ns(~c1) .* ns(~c1) - ns(~c1)) ./ (ns(~c1) .* ns(~c1) - cs(~c1))).^(ns(~c1)-1));
    % does satisfy condition 1
    t2(c1) = 0;
    % log-likelihood (check sign)
    % ---------------------------------------------------------------------
    score(i) = - 0.5 * sum(max(0,t1 + t2)); % Eq.5, Marsili (2002) 
    % ---------------------------------------------------------------------
end
% End Fitness function
%---------------------------------------------------
% Crossover function to generate childrens satisfying the range and integer
% constraints on decision variables.
function crossoverChildren = int_crossover(parents,options,GenomeLength, ...
    FitnessFcn,unused,thisPopulation)
% INT_CROSSOVER change the cluster membership by chromosome cross-overs but 
%   only allow cross-overs between parents with the same number of clusters 
%   so that the number of clusters is only changed by mutation not cross-over
%   only accept cross-overs where the child has the same number of clusters.
%
% NOTE #1: number of crossover children
% 
% setGA.m assume that the number of crossover Children (nXoverKids) is
% 1/2 * number of parents (length(parents)) in the crossover function.
%
% * from stepGA.m line 13 : nParents = 2 * nXoverKids + nMutateKids;
% * from stepGA.m line 35 : length(parents(1:(2 * nXoverKids))) = 2 * nXoverKids
%
% Example 1:
%
% nEliteKids     = 2
% nMutateKids    = 40
% nCrossoverKids = 158
% nParents       = 356 = 2 * 158 + 40
%
% => in crossover function nCrossoverkids = 1/2*parents(1:2*158)=158
%
% See Also: STEPGA

% initialise crossoverChildren
crossoverChildren = [];
nKids = length(parents)/2;
% Find all parents with the same number of clusters
for i=1:length(parents)
    ns(i) = max(thisPopulation(parents(i),:));
end
% Find unique set of NS
unique_ns = unique(ns);
% initialise child count
nChild = 0;
for i=1:length(unique_ns)
    % index all parents with value NS
    index = find((ns==unique_ns(i)));
    % find the permutations of all parents with value NS no more than 15
    % parents and hence 105 combinations per iteration.
    toxover = nchoosek(index(1:min(20,length(index))),min(2,length(index)));
    % cross all those parent with same cluster size NS and find children
    if size(toxover,1)>1
        for j=1:size(toxover,1)
            % index of genome to cross-over
            xind = logical(randi([0 1],1,GenomeLength));
            % create the cross-over child
            % -------------------------------------------------------------
            Child(1,xind)  = thisPopulation(parents(toxover(j,1)),xind);
            Child(1,~xind) = thisPopulation(parents(toxover(j,2)),~xind);
            % -------------------------------------------------------------
            % if not all clusters are represented rescale drop this case
            if length(unique(Child))==unique_ns(i),
                % aggregate the cross-over children
                crossoverChildren = [crossoverChildren; Child];
                nChild = nChild + 1;
            end
        end
    end
end
% randomise to ensure that there are enough nKids children
xoverindex = randi(nChild,1,nKids);
% keep the right number of cross-over children
crossoverChildren = crossoverChildren(xoverindex,:);
% End of crossover function

%---------------------------------------------------
% Mutation function to generate childrens satisfying the range and integer
% constraints on decision variables.
function mutationChildren = int_mutation(parents,options,GenomeLength, ...
    FitnessFcn,state,thisScore,thisPopulation)
% INT_MUTATION change the number of clusters and randomly populate clusters
%   with objects. This is the only place in the algorithm where the number of
%   clusters is changed.
%
% NOTE #1: number of mutation children
% 
% setGA.m assume that the number of crossover Children (nXoverKids) is
% 1/2 * number of parents (length(parents)) in the crossover function.
%
% * from stepGA.m line 13 : nParents = 2 * nXoverKids + nMutateKids;
% * from stepGA.m line 36 : nMutateKids = parents((1 + 2 * nXoverKids):end)
%
% Example 1:
%
% nEliteKids     = 2
% nMutateKids    = 40
% nCrossoverKids = 158
% nParents       = 356 = 2 * 158 + 40
%
% => in mutation function nMutateKids = parents(1+2*158:356) <=> 40 children
%
% See Also: STEPGA

% initialise
shrink = .01;
scale = 1;
scale = scale - shrink * scale * state.Generation/options.Generations;
range = options.PopInitRange;
lower = range(1,:);
upper = range(2,:);
scale = scale * max(upper - lower);
mutationPop = length(parents);
% mutate the size of the clusters
ns = 1 + round(scale * rand(1,mutationPop));
% generate mutations in the cluster membership
for i=1:mutationPop
    % Mutate the children with genome of length GenomeLength
    mutationChildren(i,:) = randi(ns(i),1,GenomeLength);
end
% ensure that the cluster size lines up with the values
mutationChildren = uniquemax(mutationChildren);
% End of mutation function

%---------------------------------------------------
function Population = int_pop(GenomeLength,FitnessFcn,options)

% initial population must include the singleton case 1:N
totalpopulation = sum(options.PopulationSize);
range = options.PopInitRange;
lower= range(1,:);
span = range(2,:) - lower;
% The use of ROUND function will make sure that individuals are integers.
Population = repmat(lower,totalpopulation,1) +  ...
    round(repmat(span,totalpopulation,1) .* rand(totalpopulation,GenomeLength));
% addon the initial cluster case 
Population = [1:GenomeLength; Population];
% remove the last case
Population = Population(1:end-1,:);
% ensure that the cluster numbers are index correctly by re-indexing
Population = uniquemax(Population);
% End of creation function

%---------------------------------------------------
% Helper functions
function pop = uniquemax(pop)
% X = UNIQUEMAX(X) Ensure that the population has the same number of
% clusters and it has maximum cluster index.
for i=1:size(pop,1),
    [b1,m1,n1] = unique(pop(i,:));
    b10 = 1:length(b1);
    pop(i,:) = b10(n1);
end
% EOF
