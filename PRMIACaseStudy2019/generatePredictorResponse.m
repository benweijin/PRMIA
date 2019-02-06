function T = generatePredictorResponse(T,hdays,Pfuel)
% Gnerate the timetable of predictor and respons variables
%
%   T is the imput temperature timetable with variables Dates, Dry_Bulb,
%   and TempDeviation.
%
%   hdays are a list of holidays in the range of interest
%
%   Pfuel is a timetable with variables Dates and Png
%
%   elecPrices is a timetable with Dates and ??

% Hour of day is Hr_End, Month, and Calculate Day of Week and save as catgorical
T.Hr_End = hour(T.Dates);
T.Month = month(T.Dates);
[~,T.WeekDay] = weekday(T.Dates);
T.WeekDay = categorical(string(T.WeekDay));
T.WorkingDay = categorical(isbusday(T.Dates,hdays),[1 0],{'Workday','Weekend/Holiday'});

% Spot fuel and prior spot fuel prices (syncronizing)
Pfuel.Properties.VariableNames = {'Png'};

% keep consistent time with T
startTime = min(T.Dates);
endTime = max(T.Dates);
timeIdx = timerange(startTime,endTime,'closed');
Pfuel = Pfuel(timeIdx,:);

% retime to hourly with prieious pricing
Pfuel = retime(Pfuel,'hourly','linear');
PriorDay = lag(Pfuel);
PriorWk = lag(Pfuel,days(7));
Pfuel = synchronize(Pfuel,PriorDay);
Pfuel = synchronize(Pfuel,PriorWk);

% Join T and Pfuel and retime to hourly basis using synchronize
T = synchronize(T,Pfuel);