clearvars
load Data\ngPrices.mat
tail(ngPrices)

ngPrices = fillmissing(ngPrices,'previous'); % enough data to fill
ngPrices = rmmissing(ngPrices); % remove remaining missing data
Dates = ngPrices.Time;
S = ngPrices.RNGWHHDd;
plot(Dates,S)
ylabel('Spot Prices of Natural Gas')
recessionplot

x = log(S);
dx = diff(x);
dt = 1/261; % Time in years (261 observations per year)
dxdt = dx/dt;
x(1) = []; % To ensure the number of elements in x and dxdt match
scatter(x,dxdt)
xlabel('x')
ylabel('dx/dt')

mdl = fitlm(x, dxdt,'linear','VarNames',{'dxdt','x'})
 
revRate   = -mdl.Coefficients.Estimate(1)
 
meanLevel = mdl.Coefficients.Estimate(2)/revRate
 
res = dxdt - predict(mdl,x);
vol = std(res) * sqrt(dt) 

OUmodel = hwv(revRate, meanLevel, vol,  'StartState', x(end))
OUmodelSDE = sdemrd(revRate, meanLevel, 0, vol, 'StartState', x(end))

NTrials = 1000;
NSteps  = 2000;
Xsim = simulate(OUmodel, NSteps, 'NTrials', NTrials, 'DeltaTime', dt);
Xsim = squeeze(Xsim); % Remove redundant dimension
Ssim = exp(Xsim);
% This does the same as the lines above, but puts it all in a function we
% can reuse for different NTrials, and NSteps.  We will use this later.
simFcn = @(NSteps, NTrials) exp( squeeze( simulate(OUmodel, NSteps, 'NTrials', NTrials, 'DeltaTime', dt) ) );
% Visualize first 80 prices of 100 paths
plot(Dates(end-20:end), S(end-20:end), Dates(end)+days(0:79), Ssim(1:80,1:100));
xlabel('Date')
ylabel('NG Spot Price')
axis tight
 
mkdir SavedModels
ngModel = struct('oumodel',OUmodel,'dt',dt,'simFcn',simFcn,'lastDate',Dates(end),'Freq','daily','Data',timetable(Dates,S))
 
save SavedModels\NGPriceModel.mat -struct ngModel