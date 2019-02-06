function Pfuel = simultateNG(startDate,endDate,NGModel,NTrials)

DateRange = timerange(startDate,endDate,'closed');
% historical data
HistNG = NGModel.Data(DateRange,:);

% extend to full simulation timeframe
DailyDates = HistNG.Dates(end):days:endDate;
NSteps_daily = length(DailyDates)-1;

simNG = NGModel.simFcn(NSteps_daily,NTrials);

SimData = table2timetable([table(DailyDates','VariableName',{'Dates'}), array2table(simNG)]);

% Merge historical and simulated into one set of data.  Note that the first
% row of simNG is the last row of Historical, so delete it then retime to
% hourly
simNG = repmat(HistNG.S,1,NTrials); % resize to match NTrials
tmpData = table2timetable([table(HistNG.Dates,...
    'VariableNames',{'Dates'}), array2table(simNG)]); 
SimData(1,:) = []; % remove the same timing
Pfuel = [tmpData; SimData];

% Make sure it goes to endDate
if Pfuel.Dates(end) < endDate
    tmp = array2table(NaN(1,width(Pfuel)),'VariableNames',Pfuel.Properties.VariableNames);
    Pfuel(end+1,:) = tmp;
    Pfuel.Dates(end) = endDate;
end
    
    

