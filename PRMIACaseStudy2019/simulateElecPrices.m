function  [SimElec, X] = simulateElecPrices(SimTemp, SimTempDeviation, SimNG, hdays, elecModel, NSteps, NTrials)

SimElec = zeros(NSteps,NTrials);
for n = 1:NTrials
    T = SimTemp(:,n);
    T.Properties.VariableNames = {'Dry_Bulb'};
    T.TempDeviation = SimTempDeviation{:,n};
    Pfuel = SimNG(:,n);
    Pfuel.Properties.VariableNames = {'Png'};
    
    X = generatePredictorResponse(T,hdays,Pfuel);
    
    X = timetable2table(X);
    
    SimElec(:,n) = elecModel.treemodel.predictFcn(X);
end
Dates = SimTemp.Dates;
SimElec = array2timetable(SimElec,'RowTimes',Dates);
SimElec.Properties.DimensionNames = {'Dates','Variables'};
