clearvars
% files downloaded manually and saved to Data folder
files = dir('/Users/jinbenwei/msmf/2019spring/PRMIA/PRMIACaseStudy2019/Data/*_smd_hourly*');
assert(~isempty(files),'No electicity data found, please download and add to the Data directory')
xlsfiles = fullfile(files(1).folder, {files.name});
% the spreadsheets change the number and name of the variables, so defind
% common names
varNames = {'Date','Hr_End','DA_Demand','RT_Demand','DA_LMP','DA_EC'...
    'DA_CC', 'DA_MLC','RT_LMP','RT_EC','RT_CC','RT_MLC','Dry_Bulb',...
    'Dew_Point','System_Load','Reg_Service_Price','Reg_Capacity_Price'};
% create empty data arrays and keep variable names the same
elecPrices = timetable();
for f= 1:length(xlsfiles)
    try
        T = readtable(xlsfiles{f},'Sheet','ISONE CA');
        T.Properties.VariableNames = varNames([1:end-2,end]);
        T.(varNames{end-1}) = NaN(height(T),1);
    catch
        T = readtable(xlsfiles{f},'Sheet','ISO NE CA');
        T = T(:,varNames);
        % ensure hours are numbers
        if iscellstr(T.Hr_End)
            T.Hr_End = double(string(T.Hr_End));
        end
    end
    disp(['Processing: ',xlsfiles{f}])
    
    % convert the Date and Hour into a datetime
    T.Date = T.Date + hours(T.Hr_End-1);
    
    % synchronize the price data
    elecPrices = [elecPrices; T];
end

elecPrices = table2timetable(elecPrices);

save Data\elecPrices.mat elecPrices

clearvars
% Source urls and spreadsheet files to download
baseurl = 'https://www.eia.gov/dnav/ng/hist_xls/';
ngsrc = {'RNGWHHDd.xls', 'RNGC1d.xls', 'RNGC2d.xls', 'RNGC3d.xls', 'RNGC4d.xls'};
% create empty data arrays
ngPrices = timetable();
xlsfiles = cell(size(ngsrc));
% download the files
for f= 1:length(ngsrc)
    xlsfiles{f} = websave( fullfile('Data', ngsrc{f}), [baseurl,ngsrc{f}] );
    disp(['Data saved: ', xlsfiles{f}]);
    
    % extract the variable name from the downloaded file and create a table
    [~, varName ] = fileparts(xlsfiles{f});
    opts = detectImportOptions(xlsfiles{f},'Sheet','Data 1');
    T = readtable(xlsfiles{f},opts);
    T.Properties.VariableNames = {'Date', varName};
    
    % syncronize the price data
    ngPrices = synchronize(ngPrices, table2timetable(T));
end

tail(ngPrices)

plot(ngPrices.Time,ngPrices.Variables)
legend(ngPrices.Properties.VariableNames)

save Data\ngPrices.mat ngPrices