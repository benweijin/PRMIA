function [Dry_Bulb, TempDeviation] = simulateTemperatures(tempModel,Dates,NTrials)

NSteps = length(Dates);
AveTemp = tempModel.sinmodel(datenum(Dates)) + tempModel.m;
Dry_Bulb = zeros(NSteps,NTrials);
for n=1:NTrials
    Dry_Bulb(:,n) = simulate(tempModel.arimax,length(AveTemp),'X',AveTemp);
end
TempDeviation = Dry_Bulb - AveTemp;

Dry_Bulb = array2table(Dry_Bulb);
Dry_Bulb.Dates = Dates';
Dry_Bulb = table2timetable(Dry_Bulb);

TempDeviation = array2table(TempDeviation);
TempDeviation.Dates = Dates';
TempDeviation = table2timetable(TempDeviation);