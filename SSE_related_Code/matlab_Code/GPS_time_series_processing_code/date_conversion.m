function [date_conversion]=date_conversion( date )

% converting a date from yyyy-mm-dd to the year plus the comma value of the 
% respective date of the year (also considering leap years)
% specified time of each date is 0 a.m.


% reads month and day
month=date(6:7);
day=date(9:10);

% reads the respective year
year=date(1:4);
year=str2num(year);

% figures out, how many days went by since January 1, 0 a.m. of the
% respective year
switch str2num(month)
    case 1
        day_of_year=str2num(day);
    case 2
        day_of_year=31+str2num(day);
    case 3
        day_of_year=31+28+str2num(day);
    case 4
        day_of_year=31+28+31+str2num(day);
    case 5
        day_of_year=31+28+31+30+str2num(day);
    case 6
        day_of_year=31+28+31+30+31+str2num(day);
    case 7
        day_of_year=31+28+31+30+31+30+str2num(day);
    case 8
        day_of_year=31+28+31+30+31+30+31+str2num(day);
    case 9
        day_of_year=31+28+31+30+31+30+31+31+str2num(day);
    case 10
        day_of_year=31+28+31+30+31+30+31+31+30+str2num(day);
    case 11
        day_of_year=31+28+31+30+31+30+31+31+30+31+str2num(day);
    case 12
        day_of_year=31+28+31+30+31+30+31+31+30+31+30+str2num(day);
end
       
% if there's a leap year, add "1"
if num_days(year)== 366 && str2num(month) > 2
    day_of_year=day_of_year+1;
end

% calculating the value behind the comma
date_comma=(day_of_year-1)/num_days(year);       %(-1, in order to yield 00:00 on each given day)

% calculating the final value
date_conversion=year+date_comma;
end




 
    