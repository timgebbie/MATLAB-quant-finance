function h = holidays(varargin)
%HOLIDAYS Holidays and non-trading days.
%
%   H = HOLIDAYS(D1,D2) returns a vector of serial date numbers
%   corresponding to the holidays and non-trading days between 
%   the dates D1 and D2, inclusive. H = HOLIDAYS returns known 
%   non-trading day data for default country 'JSE, ZAR'.
%
%   H = HOLIDAYS(D1,D2,COUNTRY) Supports countries 'USD' and 'ZAR' as 
%   denoted by currency code.
%
%   This function contains all holiday and special non-trading day
%   data for: 
%
%   +--------------+----------------------------------------------------+
%   | CODE         | EXCHANGE                                           |
%   +--------------+----------------------------------------------------+
%   | 'NYSE','USD' | New York Stock Exchange between 1950 and 2030.     |
%   | 'JSE','ZAR'  | Johannesburg Stock Exchange between 1990 and 2030. | 
%   | 'LSE','GBP'  | London Stock Exchange between 1990 and 2030        |
%   +--------------+----------------------------------------------------+
%
%   Note: Martin Luther King Jr. Day became a non-trading day for 
%         the US markets starting January 1998.
%
%   For example, h = holidays('01-jan-1997','23-jun-1997') returns
%   h =  729391, 729438, 729477, and  729536  which are the serial  
%   dates corresponding to January 1, 1997; February 17, 1997;  
%   March 28, 1997; and May 26, 1997. 
%
%   See also BUSDATE, FBUSDATE, ISBUSDAY, LBUSDATE. 
     
%        Author(s): C.F. Garvin and J. Abbott, 10-24-95
%   Copyright 1995-2002 The MathWorks, Inc. 
%        1.1   2008/07/01 14:49:42  

% Author: Tim Gebbie 

% 1.1 2008/07/01 14:49:42 Tim Gebbie

switch nargin
    case 0 
        % the default country
        country = 'JSE';
    case 2
        d1 = varargin{1};
        d2 = varargin{2};
        country = 'JSE';
    case 3
        d1 = varargin{1};
        d2 = varargin{2};
        country = varargin{3};
    otherwise
        error('Incorrect Input Arguments');
end

switch lower(country),
    case {'usd','nyse'},
        h = [ 712225 ;...  % 02-Jan-1950 New Year's Day
            712267 ;...  % 13-Feb-1950 Lincoln's Birthday
            712276 ;...  % 22-Feb-1950 Washington's Birthday
            712320 ;...  % 07-Apr-1950 Good Friday
            712373 ;...  % 30-May-1950 Decoration Day
            712408 ;...  % 04-Jul-1950 Independence Day
            712470 ;...  % 04-Sep-1950 Labor Day
            712508 ;...  % 12-Oct-1950 Columbus Day
            712534 ;...  % 07-Nov-1950 Election Day
            712538 ;...  % 11-Nov-1950 Armistice Day
            712550 ;...  % 23-Nov-1950 Thanksgiving
            712582 ;...  % 25-Dec-1950 Christmas
            712589 ;...  % 01-Jan-1951 New Year's Day
            712631 ;...  % 12-Feb-1951 Lincoln's Birthday
            712641 ;...  % 22-Feb-1951 Washington's Birthday
            712670 ;...  % 23-Mar-1951 Good Friday
            712738 ;...  % 30-May-1951 Decoration Day
            712773 ;...  % 04-Jul-1951 Independence Day
            712834 ;...  % 03-Sep-1951 Labor Day
            712873 ;...  % 12-Oct-1951 Columbus Day
            712898 ;...  % 06-Nov-1951 Election Day
            712904 ;...  % 12-Nov-1951 Armistice Day
            712914 ;...  % 22-Nov-1951 Thanksgiving
            712947 ;...  % 25-Dec-1951 Christmas
            712954 ;...  % 01-Jan-1952 New Year's Day
            712996 ;...  % 12-Feb-1952 Lincoln's Birthday
            713006 ;...  % 22-Feb-1952 Washington's Birthday
            713055 ;...  % 11-Apr-1952 Good Friday
            713104 ;...  % 30-May-1952 Decoration Day
            713139 ;...  % 04-Jul-1952 Independence Day
            713198 ;...  % 01-Sep-1952 Labor Day
            713240 ;...  % 13-Oct-1952 Columbus Day
            713262 ;...  % 04-Nov-1952 Election Day
            713269 ;...  % 11-Nov-1952 Armistice Day
            713285 ;...  % 27-Nov-1952 Thanksgiving
            713313 ;...  % 25-Dec-1952 Christmas
            713320 ;...  % 01-Jan-1953 New Year's Day
            713362 ;...  % 12-Feb-1953 Lincoln's Birthday
            713373 ;...  % 23-Feb-1953 Washington's Birthday
            713412 ;...  % 03-Apr-1953 Good Friday
            713569 ;...  % 07-Sep-1953 Labor Day
            713604 ;...  % 12-Oct-1953 Columbus Day
            713626 ;...  % 03-Nov-1953 Election Day
            713634 ;...  % 11-Nov-1953 Armistice Day
            713649 ;...  % 26-Nov-1953 Thanksgiving
            713678 ;...  % 25-Dec-1953 Christmas
            713685 ;...  % 01-Jan-1954 New Year's Day
            713737 ;...  % 22-Feb-1954 Washington's Birthday
            713790 ;...  % 16-Apr-1954 Good Friday
            713835 ;...  % 31-May-1954 Decoration Day
            713870 ;...  % 05-Jul-1954 Independence Day
            713933 ;...  % 06-Sep-1954 Labor Day
            713990 ;...  % 02-Nov-1954 Election Day
            714013 ;...  % 25-Nov-1954 Thanksgiving
            714042 ;...  % 24-Dec-1954 Christmas
            714102 ;...  % 22-Feb-1955 Washington's Birthday
            714147 ;...  % 08-Apr-1955 Good Friday
            714199 ;...  % 30-May-1955 Decoration Day
            714234 ;...  % 04-Jul-1955 Independence Day
            714297 ;...  % 05-Sep-1955 Labor Day
            714361 ;...  % 08-Nov-1955 Election Day
            714377 ;...  % 24-Nov-1955 Thanksgiving
            714409 ;...  % 26-Dec-1955 Christmas
            714416 ;...  % 02-Jan-1956 New Year's Day
            714467 ;...  % 22-Feb-1956 Washington's Birthday
            714504 ;...  % 30-Mar-1956 Good Friday
            714565 ;...  % 30-May-1956 Decoration Day
            714600 ;...  % 04-Jul-1956 Independence Day
            714661 ;...  % 03-Sep-1956 Labor Day
            714725 ;...  % 06-Nov-1956 Election Day
            714741 ;...  % 22-Nov-1956 Thanksgiving
            714773 ;...  % 24-Dec-1956 Christmas Eve
            714774 ;...  % 25-Dec-1956 Christmas
            714781 ;...  % 01-Jan-1957 New Year's Day
            714833 ;...  % 22-Feb-1957 Washington's Birthday
            714889 ;...  % 19-Apr-1957 Good Friday
            714930 ;...  % 30-May-1957 Decoration Day
            714965 ;...  % 04-Jul-1957 Independence Day
            715025 ;...  % 02-Sep-1957 Labor Day
            715089 ;...  % 05-Nov-1957 Election Day
            715112 ;...  % 28-Nov-1957 Thanksgiving
            715139 ;...  % 25-Dec-1957 Christmas
            715146 ;...  % 01-Jan-1958 New Year's Day
            715239 ;...  % 04-Apr-1958 Good Friday
            715295 ;...  % 30-May-1958 Decoration Day
            715330 ;...  % 04-Jul-1958 Independence Day
            715389 ;...  % 01-Sep-1958 Labor Day
            715453 ;...  % 04-Nov-1958 Election Day
            715476 ;...  % 27-Nov-1958 Thanksgiving
            715504 ;...  % 25-Dec-1958 Christmas
            715505 ;...  % 26-Dec-1958 Day after Christmas
            715511 ;...  % 01-Jan-1959 New Year's Day
            715564 ;...  % 23-Feb-1959 Washington's Birthday
            715596 ;...  % 27-Mar-1959 Good Friday
            715694 ;...  % 03-Jul-1959 Independence Day
            715760 ;...  % 07-Sep-1959 Labor Day
            715817 ;...  % 03-Nov-1959 Election Day
            715840 ;...  % 26-Nov-1959 Thanksgiving
            715869 ;...  % 25-Dec-1959 Christmas
            715876 ;...  % 01-Jan-1960 New Year's Day
            715928 ;...  % 22-Feb-1960 Washington's Birthday
            715981 ;...  % 15-Apr-1960 Good Friday
            716026 ;...  % 30-May-1960 Decoration Day
            716061 ;...  % 04-Jul-1960 Independence Day
            716124 ;...  % 05-Sep-1960 Labor Day
            716188 ;...  % 08-Nov-1960 Election Day
            716204 ;...  % 24-Nov-1960 Thanksgiving
            716236 ;...  % 26-Dec-1960 Christmas
            716243 ;...  % 02-Jan-1961 New Year's Day
            716294 ;...  % 22-Feb-1961 Washington's Birthday
            716331 ;...  % 31-Mar-1961 Good Friday
            716390 ;...  % 29-May-1961 Day before Decoration Day
            716391 ;...  % 30-May-1961 Decoration Day
            716426 ;...  % 04-Jul-1961 Independence Day
            716488 ;...  % 04-Sep-1961 Labor Day
            716552 ;...  % 07-Nov-1961 Election Day
            716568 ;...  % 23-Nov-1961 Thanksgiving
            716600 ;...  % 25-Dec-1961 Christmas
            716607 ;...  % 01-Jan-1962 New Year's Day
            716659 ;...  % 22-Feb-1962 Washington's Birthday
            716716 ;...  % 20-Apr-1962 Good Friday
            716756 ;...  % 30-May-1962 Decoration Day
            716791 ;...  % 04-Jul-1962 Independence Day
            716852 ;...  % 03-Sep-1962 Labor Day
            716916 ;...  % 06-Nov-1962 Election Day
            716932 ;...  % 22-Nov-1962 Thanksgiving
            716965 ;...  % 25-Dec-1962 Christmas
            716972 ;...  % 01-Jan-1963 New Year's Day
            717024 ;...  % 22-Feb-1963 Washington's Birthday
            717073 ;...  % 12-Apr-1963 Good Friday
            717121 ;...  % 30-May-1963 Decoration Day
            717156 ;...  % 04-Jul-1963 Independence Day
            717216 ;...  % 02-Sep-1963 Labor Day
            717280 ;...  % 05-Nov-1963 Election Day
            717300 ;...  % 25-Nov-1963 Kennedy Funeral
            717303 ;...  % 28-Nov-1963 Thanksgiving
            717330 ;...  % 25-Dec-1963 Christmas
            717337 ;...  % 01-Jan-1964 New Year's Day
            717388 ;...  % 21-Feb-1964 Washington's Birthday
            717423 ;...  % 27-Mar-1964 Good Friday
            717486 ;...  % 29-May-1964 Decoration Day
            717521 ;...  % 03-Jul-1964 Independence Day
            717587 ;...  % 07-Sep-1964 Labor Day
            717644 ;...  % 03-Nov-1964 Election Day
            717667 ;...  % 26-Nov-1964 Thanksgiving
            717696 ;...  % 25-Dec-1964 Christmas
            717703 ;...  % 01-Jan-1965 New Year's Day
            717755 ;...  % 22-Feb-1965 Washington's Birthday
            717808 ;...  % 16-Apr-1965 Good Friday
            717853 ;...  % 31-May-1965 Decoration Day
            717888 ;...  % 05-Jul-1965 Independence Day
            717951 ;...  % 06-Sep-1965 Labor Day
            718008 ;...  % 02-Nov-1965 Election Day
            718031 ;...  % 25-Nov-1965 Thanksgiving
            718060 ;...  % 24-Dec-1965 Christmas
            718120 ;...  % 22-Feb-1966 Washington's Birthday
            718165 ;...  % 08-Apr-1966 Good Friday
            718217 ;...  % 30-May-1966 Decoration Day
            718252 ;...  % 04-Jul-1966 Independence Day
            718315 ;...  % 05-Sep-1966 Labor Day
            718379 ;...  % 08-Nov-1966 Election Day
            718395 ;...  % 24-Nov-1966 Thanksgiving
            718427 ;...  % 26-Dec-1966 Christmas
            718434 ;...  % 02-Jan-1967 New Year's Day
            718485 ;...  % 22-Feb-1967 Washington's Birthday
            718515 ;...  % 24-Mar-1967 Good Friday
            718582 ;...  % 30-May-1967 Decoration Day
            718617 ;...  % 04-Jul-1967 Independence Day
            718679 ;...  % 04-Sep-1967 Labor Day
            718743 ;...  % 07-Nov-1967 Election Day
            718759 ;...  % 23-Nov-1967 Thanksgiving
            718791 ;...  % 25-Dec-1967 Christmas
            718798 ;...  % 01-Jan-1968 New Year's Day
            718840 ;...  % 12-Feb-1968 Lincoln's Birthday
            718850 ;...  % 22-Feb-1968 Washington's Birthday
            718897 ;...  % 09-Apr-1968 M L King Day of Mourning
            718900 ;...  % 12-Apr-1968 Good Friday
            718948 ;...  % 30-May-1968 Decoration Day
            718983 ;...  % 04-Jul-1968 Independence Day
            718984 ;...  % 05-Jul-1968 Day after Independence Day
            719043 ;...  % 02-Sep-1968 Labor Day
            719107 ;...  % 05-Nov-1968 Election Day
            719130 ;...  % 28-Nov-1968 Thanksgiving
            719157 ;...  % 25-Dec-1968 Christmas
            719164 ;...  % 01-Jan-1969 New Year's Day
            719204 ;...  % 10-Feb-1969 Snowstorm
            719215 ;...  % 21-Feb-1969 Washington's Birthday
            719253 ;...  % 31-Mar-1969 Eisenhower Funeral
            719257 ;...  % 04-Apr-1969 Good Friday
            719313 ;...  % 30-May-1969 Decoration Day
            719348 ;...  % 04-Jul-1969 Independence Day
            719365 ;...  % 21-Jul-1969 Lunar Exploration
            719407 ;...  % 01-Sep-1969 Labor Day
            719494 ;...  % 27-Nov-1969 Thanksgiving
            719522 ;...  % 25-Dec-1969 Christmas
            719529 ;...  % 01-Jan-1970 New Year's Day
            719582 ;...  % 23-Feb-1970 Washington's Birthday
            719614 ;...  % 27-Mar-1970 Good Friday
            719712 ;...  % 03-Jul-1970 Independence Day
            719778 ;...  % 07-Sep-1970 Labor Day
            719858 ;...  % 26-Nov-1970 Thanksgiving
            719887 ;...  % 25-Dec-1970 Christmas
            719894 ;...  % 01-Jan-1971 New Year's Day
            719939 ;...  % 15-Feb-1971 Washington's Birthday
            719992 ;...  % 09-Apr-1971 Good Friday
            720044 ;...  % 31-May-1971 Memorial Day
            720079 ;...  % 05-Jul-1971 Independence Day
            720142 ;...  % 06-Sep-1971 Labor Day
            720222 ;...  % 25-Nov-1971 Thanksgiving
            720251 ;...  % 24-Dec-1971 Christmas
            720310 ;...  % 21-Feb-1972 Washington's Birthday
            720349 ;...  % 31-Mar-1972 Good Friday
            720408 ;...  % 29-May-1972 Memorial Day
            720444 ;...  % 04-Jul-1972 Independence Day
            720506 ;...  % 04-Sep-1972 Labor Day
            720570 ;...  % 07-Nov-1972 Election Day
            720586 ;...  % 23-Nov-1972 Thanksgiving
            720618 ;...  % 25-Dec-1972 Christmas
            720621 ;...  % 28-Dec-1972 Truman Funeral
            720625 ;...  % 01-Jan-1973 New Year's Day
            720649 ;...  % 25-Jan-1973 Johnson Funeral
            720674 ;...  % 19-Feb-1973 Washington's Birthday
            720734 ;...  % 20-Apr-1973 Good Friday
            720772 ;...  % 28-May-1973 Memorial Day
            720809 ;...  % 04-Jul-1973 Independence Day
            720870 ;...  % 03-Sep-1973 Labor Day
            720950 ;...  % 22-Nov-1973 Thanksgiving
            720983 ;...  % 25-Dec-1973 Christmas
            720990 ;...  % 01-Jan-1974 New Year's Day
            721038 ;...  % 18-Feb-1974 Washington's Birthday
            721091 ;...  % 12-Apr-1974 Good Friday
            721136 ;...  % 27-May-1974 Memorial Day
            721174 ;...  % 04-Jul-1974 Independence Day
            721234 ;...  % 02-Sep-1974 Labor Day
            721321 ;...  % 28-Nov-1974 Thanksgiving
            721348 ;...  % 25-Dec-1974 Christmas
            721355 ;...  % 01-Jan-1975 New Year's Day
            721402 ;...  % 17-Feb-1975 Washington's Birthday
            721441 ;...  % 28-Mar-1975 Good Friday
            721500 ;...  % 26-May-1975 Memorial Day
            721539 ;...  % 04-Jul-1975 Independence Day
            721598 ;...  % 01-Sep-1975 Labor Day
            721685 ;...  % 27-Nov-1975 Thanksgiving
            721713 ;...  % 25-Dec-1975 Christmas
            721720 ;...  % 01-Jan-1976 New Year's Day
            721766 ;...  % 16-Feb-1976 Washington's Birthday
            721826 ;...  % 16-Apr-1976 Good Friday
            721871 ;...  % 31-May-1976 Memorial Day
            721906 ;...  % 05-Jul-1976 Independence Day
            721969 ;...  % 06-Sep-1976 Labor Day
            722026 ;...  % 02-Nov-1976 Election Day
            722049 ;...  % 25-Nov-1976 Thanksgiving
            722078 ;...  % 24-Dec-1976 Christmas
            722137 ;...  % 21-Feb-1977 Washington's Birthday
            722183 ;...  % 08-Apr-1977 Good Friday
            722235 ;...  % 30-May-1977 Memorial Day
            722270 ;...  % 04-Jul-1977 Independence Day
            722280 ;...  % 14-Jul-1977 Power Blackout
            722333 ;...  % 05-Sep-1977 Labor Day
            722413 ;...  % 24-Nov-1977 Thanksgiving
            722445 ;...  % 26-Dec-1977 Christmas
            722452 ;...  % 02-Jan-1978 New Year's Day
            722501 ;...  % 20-Feb-1978 Washington's Birthday
            722533 ;...  % 24-Mar-1978 Good Friday
            722599 ;...  % 29-May-1978 Memorial Day
            722635 ;...  % 04-Jul-1978 Independence Day
            722697 ;...  % 04-Sep-1978 Labor Day
            722777 ;...  % 23-Nov-1978 Thanksgiving
            722809 ;...  % 25-Dec-1978 Christmas
            722816 ;...  % 01-Jan-1979 New Year's Day
            722865 ;...  % 19-Feb-1979 Washington's Birthday
            722918 ;...  % 13-Apr-1979 Good Friday
            722963 ;...  % 28-May-1979 Memorial Day
            723000 ;...  % 04-Jul-1979 Independence Day
            723061 ;...  % 03-Sep-1979 Labor Day
            723141 ;...  % 22-Nov-1979 Thanksgiving
            723174 ;...  % 25-Dec-1979 Christmas
            723181 ;...  % 01-Jan-1980 New Year's Day
            723229 ;...  % 18-Feb-1980 Washington's Birthday
            723275 ;...  % 04-Apr-1980 Good Friday
            723327 ;...  % 26-May-1980 Memorial Day
            723366 ;...  % 04-Jul-1980 Independence Day
            723425 ;...  % 01-Sep-1980 Labor Day
            723489 ;...  % 04-Nov-1980 Election Day
            723512 ;...  % 27-Nov-1980 Thanksgiving
            723540 ;...  % 25-Dec-1980 Christmas
            723547 ;...  % 01-Jan-1981 New Year's Day
            723593 ;...  % 16-Feb-1981 Washington's Birthday
            723653 ;...  % 17-Apr-1981 Good Friday
            723691 ;...  % 25-May-1981 Memorial Day
            723730 ;...  % 03-Jul-1981 Independence Day
            723796 ;...  % 07-Sep-1981 Labor Day
            723876 ;...  % 26-Nov-1981 Thanksgiving
            723905 ;...  % 25-Dec-1981 Christmas
            723912 ;...  % 01-Jan-1982 New Year's Day
            723957 ;...  % 15-Feb-1982 Washington's Birthday
            724010 ;...  % 09-Apr-1982 Good Friday
            724062 ;...  % 31-May-1982 Memorial Day
            724097 ;...  % 05-Jul-1982 Independence Day
            724160 ;...  % 06-Sep-1982 Labor Day
            724240 ;...  % 25-Nov-1982 Thanksgiving
            724269 ;...  % 24-Dec-1982 Christmas
            724328 ;...  % 21-Feb-1983 Washington's Birthday
            724367 ;...  % 01-Apr-1983 Good Friday
            724426 ;...  % 30-May-1983 Memorial Day
            724461 ;...  % 04-Jul-1983 Independence Day
            724524 ;...  % 05-Sep-1983 Labor Day
            724604 ;...  % 24-Nov-1983 Thanksgiving
            724636 ;...  % 26-Dec-1983 Christmas
            724643 ;...  % 02-Jan-1984 New Year's Day
            724692 ;...  % 20-Feb-1984 Washington's Birthday
            724752 ;...  % 20-Apr-1984 Good Friday
            724790 ;...  % 28-May-1984 Memorial Day
            724827 ;...  % 04-Jul-1984 Independence Day
            724888 ;...  % 03-Sep-1984 Labor Day
            724968 ;...  % 22-Nov-1984 Thanksgiving
            725001 ;...  % 25-Dec-1984 Christmas
            725008 ;...  % 01-Jan-1985 New Year's Day
            725056 ;...  % 18-Feb-1985 Washington's Birthday
            725102 ;...  % 05-Apr-1985 Good Friday
            725154 ;...  % 27-May-1985 Memorial Day
            725192 ;...  % 04-Jul-1985 Independence Day
            725252 ;...  % 02-Sep-1985 Labor Day
            725277 ;...  % 27-Sep-1985 Hurricane Gloria
            725339 ;...  % 28-Nov-1985 Thanksgiving
            725366 ;...  % 25-Dec-1985 Christmas
            725373 ;...  % 01-Jan-1986 New Year's Day
            725420 ;...  % 17-Feb-1986 Washington's Birthday
            725459 ;...  % 28-Mar-1986 Good Friday
            725518 ;...  % 26-May-1986 Memorial Day
            725557 ;...  % 04-Jul-1986 Independence Day
            725616 ;...  % 01-Sep-1986 Labor Day
            725703 ;...  % 27-Nov-1986 Thanksgiving
            725731 ;...  % 25-Dec-1986 Christmas
            725738 ;...  % 01-Jan-1987 New Year's Day
            725784 ;...  % 16-Feb-1987 Washington's Birthday
            725844 ;...  % 17-Apr-1987 Good Friday
            725882 ;...  % 25-May-1987 Memorial Day
            725921 ;...  % 03-Jul-1987 Independence Day
            725987 ;...  % 07-Sep-1987 Labor Day
            726067 ;...  % 26-Nov-1987 Thanksgiving
            726096 ;...  % 25-Dec-1987 Christmas
            726103 ;...  % 01-Jan-1988 New Year's Day
            726148 ;...  % 15-Feb-1988 Washington's Birthday
            726194 ;...  % 01-Apr-1988 Good Friday
            726253 ;...  % 30-May-1988 Memorial Day
            726288 ;...  % 04-Jul-1988 Independence Day
            726351 ;...  % 05-Sep-1988 Labor Day
            726431 ;...  % 24-Nov-1988 Thanksgiving
            726463 ;...  % 26-Dec-1988 Christmas
            726470 ;...  % 02-Jan-1989 New Year's Day
            726519 ;...  % 20-Feb-1989 Washington's Birthday
            726551 ;...  % 24-Mar-1989 Good Friday
            726617 ;...  % 29-May-1989 Memorial Day
            726653 ;...  % 04-Jul-1989 Independence Day
            726715 ;...  % 04-Sep-1989 Labor Day
            726795 ;...  % 23-Nov-1989 Thanksgiving
            726827 ;...  % 25-Dec-1989 Christmas
            726834 ;...  % 01-Jan-1990 New Year's Day
            726883 ;...  % 19-Feb-1990 Washington's Birthday
            726936 ;...  % 13-Apr-1990 Good Friday
            726981 ;...  % 28-May-1990 Memorial Day
            727018 ;...  % 04-Jul-1990 Independence Day
            727079 ;...  % 03-Sep-1990 Labor Day
            727159 ;...  % 22-Nov-1990 Thanksgiving
            727192 ;...  % 25-Dec-1990 Christmas
            727199 ;...  % 01-Jan-1991 New Year's Day
            727247 ;...  % 18-Feb-1991 Washington's Birthday
            727286 ;...  % 29-Mar-1991 Good Friday
            727345 ;...  % 27-May-1991 Memorial Day
            727383 ;...  % 04-Jul-1991 Independence Day
            727443 ;...  % 02-Sep-1991 Labor Day
            727530 ;...  % 28-Nov-1991 Thanksgiving
            727557 ;...  % 25-Dec-1991 Christmas
            727564 ;...  % 01-Jan-1992 New Year's Day
            727611 ;...  % 17-Feb-1992 Washington's Birthday
            727671 ;...  % 17-Apr-1992 Good Friday
            727709 ;...  % 25-May-1992 Memorial Day
            727748 ;...  % 03-Jul-1992 Independence Day
            727814 ;...  % 07-Sep-1992 Labor Day
            727894 ;...  % 26-Nov-1992 Thanksgiving
            727923 ;...  % 25-Dec-1992 Christmas
            727930 ;...  % 01-Jan-1993 New Year's Day
            727975 ;...  % 15-Feb-1993 Washington's Birthday
            728028 ;...  % 09-Apr-1993 Good Friday
            728080 ;...  % 31-May-1993 Memorial Day
            728115 ;...  % 05-Jul-1993 Independence Day
            728178 ;...  % 06-Sep-1993 Labor Day
            728258 ;...  % 25-Nov-1993 Thanksgiving
            728287 ;...  % 24-Dec-1993 Christmas
            728346 ;...  % 21-Feb-1994 Washington's Birthday
            728385 ;...  % 01-Apr-1994 Good Friday
            728411 ;...  % 27-Apr-1994 Nixon Funeral
            728444 ;...  % 30-May-1994 Memorial Day
            728479 ;...  % 04-Jul-1994 Independence Day
            728542 ;...  % 05-Sep-1994 Labor Day
            728622 ;...  % 24-Nov-1994 Thanksgiving
            728654 ;...  % 26-Dec-1994 Christmas
            728661 ;...  % 02-Jan-1995 New Year's Day
            728710 ;...  % 20-Feb-1995 Washington's Birthday
            728763 ;...  % 14-Apr-1995 Good Friday
            728808 ;...  % 29-May-1995 Memorial Day
            728844 ;...  % 04-Jul-1995 Independence Day
            728906 ;...  % 04-Sep-1995 Labor Day
            728986 ;...  % 23-Nov-1995 Thanksgiving
            729018 ;...  % 25-Dec-1995 Christmas
            729025 ;...  % 01-Jan-1996 New Year's Day
            729074 ;...  % 19-Feb-1996 Washington's Birthday
            729120 ;...  % 05-Apr-1996 Good Friday
            729172 ;...  % 27-May-1996 Memorial Day
            729210 ;...  % 04-Jul-1996 Independence Day
            729270 ;...  % 02-Sep-1996 Labor Day
            729357 ;...  % 28-Nov-1996 Thanksgiving
            729384 ;...  % 25-Dec-1996 Christmas
            729391 ;...  % 01-Jan-1997 New Year's Day
            729438 ;...  % 17-Feb-1997 Washington's Birthday
            729477 ;...  % 28-Mar-1997 Good Friday
            729536 ;...  % 26-May-1997 Memorial Day
            729575 ;...  % 04-Jul-1997 Independence Day
            729634 ;...  % 01-Sep-1997 Labor Day
            729721 ;...  % 27-Nov-1997 Thanksgiving
            729749 ;...  % 25-Dec-1997 Christmas
            729756 ;...  % 01-Jan-1998 New Year's Day
            729774 ;...  % 19-Jan-1998 Martin Luther King Jr. Day
            729802 ;...  % 16-Feb-1998 Washington's Birthday
            729855 ;...  % 10-Apr-1998 Good Friday
            729900 ;...  % 25-May-1998 Memorial Day
            729939 ;...  % 03-Jul-1998 Independence Day
            730005 ;...  % 07-Sep-1998 Labor Day
            730085 ;...  % 26-Nov-1998 Thanksgiving
            730121 ;...  % 01-Jan-1999 New Year's Day
            730114 ;...  % 25-Dec-1998 Christmas
            730138 ;...  % 18-Jan-1999 Martin Luther King Jr. Day
            730166 ;...  % 15-Feb-1999 Washington's Birthday
            730212 ;...  % 02-Apr-1999 Good Friday
            730271 ;...  % 31-May-1999 Memorial Day
            730306 ;...  % 05-Jul-1999 Independence Day
            730369 ;...  % 06-Sep-1999 Labor Day
            730449 ;...  % 25-Nov-1999 Thanksgiving
            730478 ;...  % 24-Dec-1999 Christmas
            730502 ;...  % 17-Jan-2000 Martin Luther King Jr. Day
            730537 ;...  % 21-Feb-2000 Washington's Birthday
            730597 ;...  % 21-Apr-2000 Good Friday
            730635 ;...  % 29-May-2000 Memorial Day
            730671 ;...  % 04-Jul-2000 Independence Day
            730733 ;...  % 04-Sep-2000 Labor Day
            730813 ;...  % 23-Nov-2000 Thanksgiving
            730852 ;...  % 01-Jan-2001 New Year's Day
            730845 ;...  % 25-Dec-2000 Christmas
            730866 ;...  % 15-Jan-2001 Martin Luther King Jr. Day
            730901 ;...  % 19-Feb-2001 Washington's Birthday
            730954 ;...  % 13-Apr-2001 Good Friday
            730999 ;...  % 28-May-2001 Memorial Day
            731036 ;...  % 04-Jul-2001 Independence Day
            731097 ;...  % 03-Sep-2001 Labor Day
            731105 ;...  % 11-Sep-2001 September 11, 2001 Incident
            731106 ;...  % 12-Sep-2001 Market closed due to 9/11/2001
            731107 ;...  % 13-Sep-2001 Market closed due to 9/11/2001
            731108 ;...  % 14-Sep-2001 Market closed due to 9/11/2001
            731177 ;...  % 22-Nov-2001 Thanksgiving
            731217 ;...  % 01-Jan-2002 New Year's Day
            731210 ;...  % 25-Dec-2001 Christmas
            731237 ;...  % 21-Jan-2002 Martin Luther King Jr. Day
            731265 ;...  % 18-Feb-2002 Washington's Birthday
            731304 ;...  % 29-Mar-2002 Good Friday
            731363 ;...  % 27-May-2002 Memorial Day
            731401 ;...  % 04-Jul-2002 Independence Day
            731461 ;...  % 02-Sep-2002 Labor Day
            731548 ;...  % 28-Nov-2002 Thanksgiving
            731582 ;...  % 01-Jan-2003 New Year's Day
            731575 ;...  % 25-Dec-2002 Christmas
            731601 ;...  % 20-Jan-2003 Martin Luther King Jr. Day
            731629 ;...  % 17-Feb-2003 Washington's Birthday
            731689 ;...  % 18-Apr-2003 Good Friday
            731727 ;...  % 26-May-2003 Memorial Day
            731766 ;...  % 04-Jul-2003 Independence Day
            731825 ;...  % 01-Sep-2003 Labor Day
            731912 ;...  % 27-Nov-2003 Thanksgiving
            731947 ;...  % 01-Jan-2004 New Year's Day
            731940 ;...  % 25-Dec-2003 Christmas
            731965 ;...  % 19-Jan-2004 Martin Luther King Jr. Day
            731993 ;...  % 16-Feb-2004 Washington's Birthday
            732046 ;...  % 09-Apr-2004 Good Friday
            732098 ;...  % 31-May-2004 Memorial Day
            732133 ;...  % 05-Jul-2004 Independence Day
            732196 ;...  % 06-Sep-2004 Labor Day
            732276 ;...  % 25-Nov-2004 Thanksgiving
            732305 ;...  % 24-Dec-2004 Christmas
            732329 ;...  % 17-Jan-2005 Martin Luther King Jr. Day
            732364 ;...  % 21-Feb-2005 Washington's Birthday
            732396 ;...  % 25-Mar-2005 Good Friday
            732462 ;...  % 30-May-2005 Memorial Day
            732497 ;...  % 04-Jul-2005 Independence Day
            732560 ;...  % 05-Sep-2005 Labor Day
            732640 ;...  % 24-Nov-2005 Thanksgiving
            732679 ;...  % 02-Jan-2006 New Year's Day
            732672 ;...  % 26-Dec-2005 Christmas
            732693 ;...  % 16-Jan-2006 Martin Luther King Jr. Day
            732728 ;...  % 20-Feb-2006 Washington's Birthday
            732781 ;...  % 14-Apr-2006 Good Friday
            732826 ;...  % 29-May-2006 Memorial Day
            732862 ;...  % 04-Jul-2006 Independence Day
            732924 ;...  % 04-Sep-2006 Labor Day
            733004 ;...  % 23-Nov-2006 Thanksgiving
            733043 ;...  % 01-Jan-2007 New Year's Day
            733036 ;...  % 25-Dec-2006 Christmas
            733057 ;...  % 15-Jan-2007 Martin Luther King Jr. Day
            733092 ;...  % 19-Feb-2007 Washington's Birthday
            733138 ;...  % 06-Apr-2007 Good Friday
            733190 ;...  % 28-May-2007 Memorial Day
            733227 ;...  % 04-Jul-2007 Independence Day
            733288 ;...  % 03-Sep-2007 Labor Day
            733368 ;...  % 22-Nov-2007 Thanksgiving
            733408 ;...  % 01-Jan-2008 New Year's Day
            733401 ;...  % 25-Dec-2007 Christmas
            733428 ;...  % 21-Jan-2008 Martin Luther King Jr. Day
            733456 ;...  % 18-Feb-2008 Washington's Birthday
            733488 ;...  % 21-Mar-2008 Good Friday
            733554 ;...  % 26-May-2008 Memorial Day
            733593 ;...  % 04-Jul-2008 Independence Day
            733652 ;...  % 01-Sep-2008 Labor Day
            733739 ;...  % 27-Nov-2008 Thanksgiving
            733774 ;...  % 01-Jan-2009 New Year's Day
            733767 ;...  % 25-Dec-2008 Christmas
            733792 ;...  % 19-Jan-2009 Martin Luther King Jr. Day
            733820 ;...  % 16-Feb-2009 Washington's Birthday
            733873 ;...  % 10-Apr-2009 Good Friday
            733918 ;...  % 25-May-2009 Memorial Day
            733957 ;...  % 03-Jul-2009 Independence Day
            734023 ;...  % 07-Sep-2009 Labor Day
            734103 ;...  % 26-Nov-2009 Thanksgiving
            734139 ;...  % 01-Jan-2010 New Year's Day
            734132 ;...  % 25-Dec-2009 Christmas
            734156 ;...  % 18-Jan-2010 Martin Luther King Jr. Day
            734184 ;...  % 15-Feb-2010 Washington's Birthday
            734230 ;...  % 02-Apr-2010 Good Friday
            734289 ;...  % 31-May-2010 Memorial Day
            734324 ;...  % 05-Jul-2010 Independence Day
            734387 ;...  % 06-Sep-2010 Labor Day
            734467 ;...  % 25-Nov-2010 Thanksgiving
            734496 ;...  % 24-Dec-2010 Christmas
            734520 ;...  % 17-Jan-2011 Martin Luther King Jr. Day
            734555 ;...  % 21-Feb-2011 Washington's Birthday
            734615 ;...  % 22-Apr-2011 Good Friday
            734653 ;...  % 30-May-2011 Memorial Day
            734688 ;...  % 04-Jul-2011 Independence Day
            734751 ;...  % 05-Sep-2011 Labor Day
            734831 ;...  % 24-Nov-2011 Thanksgiving
            734870 ;...  % 02-Jan-2012 New Year's Day
            734863 ;...  % 26-Dec-2011 Christmas
            734884 ;...  % 16-Jan-2012 Martin Luther King Jr. Day
            734919 ;...  % 20-Feb-2012 Washington's Birthday
            734965 ;...  % 06-Apr-2012 Good Friday
            735017 ;...  % 28-May-2012 Memorial Day
            735054 ;...  % 04-Jul-2012 Independence Day
            735115 ;...  % 03-Sep-2012 Labor Day
            735195 ;...  % 22-Nov-2012 Thanksgiving
            735235 ;...  % 01-Jan-2013 New Year's Day
            735228 ;...  % 25-Dec-2012 Christmas
            735255 ;...  % 21-Jan-2013 Martin Luther King Jr. Day
            735283 ;...  % 18-Feb-2013 Washington's Birthday
            735322 ;...  % 29-Mar-2013 Good Friday
            735381 ;...  % 27-May-2013 Memorial Day
            735419 ;...  % 04-Jul-2013 Independence Day
            735479 ;...  % 02-Sep-2013 Labor Day
            735566 ;...  % 28-Nov-2013 Thanksgiving
            735600 ;...  % 01-Jan-2014 New Year's Day
            735593 ;...  % 25-Dec-2013 Christmas
            735619 ;...  % 20-Jan-2014 Martin Luther King Jr. Day
            735647 ;...  % 17-Feb-2014 Washington's Birthday
            735707 ;...  % 18-Apr-2014 Good Friday
            735745 ;...  % 26-May-2014 Memorial Day
            735784 ;...  % 04-Jul-2014 Independence Day
            735843 ;...  % 01-Sep-2014 Labor Day
            735930 ;...  % 27-Nov-2014 Thanksgiving
            735965 ;...  % 01-Jan-2015 New Year's Day
            735958 ;...  % 25-Dec-2014 Christmas
            735983 ;...  % 19-Jan-2015 Martin Luther King Jr. Day
            736011 ;...  % 16-Feb-2015 Washington's Birthday
            736057 ;...  % 03-Apr-2015 Good Friday
            736109 ;...  % 25-May-2015 Memorial Day
            736148 ;...  % 03-Jul-2015 Independence Day
            736214 ;...  % 07-Sep-2015 Labor Day
            736294 ;...  % 26-Nov-2015 Thanksgiving
            736330 ;...  % 01-Jan-2016 New Year's Day
            736323 ;...  % 25-Dec-2015 Christmas
            736347 ;...  % 18-Jan-2016 Martin Luther King Jr. Day
            736375 ;...  % 15-Feb-2016 Washington's Birthday
            736414 ;...  % 25-Mar-2016 Good Friday
            736480 ;...  % 30-May-2016 Memorial Day
            736515 ;...  % 04-Jul-2016 Independence Day
            736578 ;...  % 05-Sep-2016 Labor Day
            736658 ;...  % 24-Nov-2016 Thanksgiving
            736697 ;...  % 02-Jan-2017 New Year's Day
            736690 ;...  % 26-Dec-2016 Christmas
            736711 ;...  % 16-Jan-2017 Martin Luther King Jr. Day
            736746 ;...  % 20-Feb-2017 Washington's Birthday
            736799 ;...  % 14-Apr-2017 Good Friday
            736844 ;...  % 29-May-2017 Memorial Day
            736880 ;...  % 04-Jul-2017 Independence Day
            736942 ;...  % 04-Sep-2017 Labor Day
            737022 ;...  % 23-Nov-2017 Thanksgiving
            737061 ;...  % 01-Jan-2018 New Year's Day
            737054 ;...  % 25-Dec-2017 Christmas
            737075 ;...  % 15-Jan-2018 Martin Luther King Jr. Day
            737110 ;...  % 19-Feb-2018 Washington's Birthday
            737149 ;...  % 30-Mar-2018 Good Friday
            737208 ;...  % 28-May-2018 Memorial Day
            737245 ;...  % 04-Jul-2018 Independence Day
            737306 ;...  % 03-Sep-2018 Labor Day
            737386 ;...  % 22-Nov-2018 Thanksgiving
            737426 ;...  % 01-Jan-2019 New Year's Day
            737419 ;...  % 25-Dec-2018 Christmas
            737446 ;...  % 21-Jan-2019 Martin Luther King Jr. Day
            737474 ;...  % 18-Feb-2019 Washington's Birthday
            737534 ;...  % 19-Apr-2019 Good Friday
            737572 ;...  % 27-May-2019 Memorial Day
            737610 ;...  % 04-Jul-2019 Independence Day
            737670 ;...  % 02-Sep-2019 Labor Day
            737757 ;...  % 28-Nov-2019 Thanksgiving
            737791 ;...  % 01-Jan-2020 New Year's Day
            737784 ;...  % 25-Dec-2019 Christmas
            737810 ;...  % 20-Jan-2020 Martin Luther King Jr. Day
            737838 ;...  % 17-Feb-2020 Washington's Birthday
            737891 ;...  % 10-Apr-2020 Good Friday
            737936 ;...  % 25-May-2020 Memorial Day
            737975 ;...  % 03-Jul-2020 Independence Day
            738041 ;...  % 07-Sep-2020 Labor Day
            738121 ;...  % 26-Nov-2020 Thanksgiving
            738157 ;...  % 01-Jan-2021 New Year's Day
            738150 ;...  % 25-Dec-2020 Christmas
            738174 ;...  % 18-Jan-2021 Martin Luther King Jr. Day
            738202 ;...  % 15-Feb-2021 Washington's Birthday
            738248 ;...  % 02-Apr-2021 Good Friday
            738307 ;...  % 31-May-2021 Memorial Day
            738342 ;...  % 05-Jul-2021 Independence Day
            738405 ;...  % 06-Sep-2021 Labor Day
            738485 ;...  % 25-Nov-2021 Thanksgiving
            738514 ;...  % 24-Dec-2021 Christmas
            738538 ;...  % 17-Jan-2022 Martin Luther King Jr. Day
            738573 ;...  % 21-Feb-2022 Washington's Birthday
            738626 ;...  % 15-Apr-2022 Good Friday
            738671 ;...  % 30-May-2022 Memorial Day
            738706 ;...  % 04-Jul-2022 Independence Day
            738769 ;...  % 05-Sep-2022 Labor Day
            738849 ;...  % 24-Nov-2022 Thanksgiving
            738888 ;...  % 02-Jan-2023 New Year's Day
            738881 ;...  % 26-Dec-2022 Christmas
            738902 ;...  % 16-Jan-2023 Martin Luther King Jr. Day
            738937 ;...  % 20-Feb-2023 Washington's Birthday
            738983 ;...  % 07-Apr-2023 Good Friday
            739035 ;...  % 29-May-2023 Memorial Day
            739071 ;...  % 04-Jul-2023 Independence Day
            739133 ;...  % 04-Sep-2023 Labor Day
            739213 ;...  % 23-Nov-2023 Thanksgiving
            739252 ;...  % 01-Jan-2024 New Year's Day
            739245 ;...  % 25-Dec-2023 Christmas
            739266 ;...  % 15-Jan-2024 Martin Luther King Jr. Day
            739301 ;...  % 19-Feb-2024 Washington's Birthday
            739340 ;...  % 29-Mar-2024 Good Friday
            739399 ;...  % 27-May-2024 Memorial Day
            739437 ;...  % 04-Jul-2024 Independence Day
            739497 ;...  % 02-Sep-2024 Labor Day
            739584 ;...  % 28-Nov-2024 Thanksgiving
            739618 ;...  % 01-Jan-2025 New Year's Day
            739611 ;...  % 25-Dec-2024 Christmas
            739637 ;...  % 20-Jan-2025 Martin Luther King Jr. Day
            739665 ;...  % 17-Feb-2025 Washington's Birthday
            739725 ;...  % 18-Apr-2025 Good Friday
            739763 ;...  % 26-May-2025 Memorial Day
            739802 ;...  % 04-Jul-2025 Independence Day
            739861 ;...  % 01-Sep-2025 Labor Day
            739948 ;...  % 27-Nov-2025 Thanksgiving
            739983 ;...  % 01-Jan-2026 New Year's Day
            739976 ;...  % 25-Dec-2025 Christmas
            740001 ;...  % 19-Jan-2026 Martin Luther King Jr. Day
            740029 ;...  % 16-Feb-2026 Washington's Birthday
            740075 ;...  % 03-Apr-2026 Good Friday
            740127 ;...  % 25-May-2026 Memorial Day
            740166 ;...  % 03-Jul-2026 Independence Day
            740232 ;...  % 07-Sep-2026 Labor Day
            740312 ;...  % 26-Nov-2026 Thanksgiving
            740348 ;...  % 01-Jan-2027 New Year's Day
            740341 ;...  % 25-Dec-2026 Christmas
            740365 ;...  % 18-Jan-2027 Martin Luther King Jr. Day
            740393 ;...  % 15-Feb-2027 Washington's Birthday
            740432 ;...  % 26-Mar-2027 Good Friday
            740498 ;...  % 31-May-2027 Memorial Day
            740533 ;...  % 05-Jul-2027 Independence Day
            740596 ;...  % 06-Sep-2027 Labor Day
            740676 ;...  % 25-Nov-2027 Thanksgiving
            740705 ;...  % 24-Dec-2027 Christmas
            740729 ;...  % 17-Jan-2028 Martin Luther King Jr. Day
            740764 ;...  % 21-Feb-2028 Washington's Birthday
            740817 ;...  % 14-Apr-2028 Good Friday
            740862 ;...  % 29-May-2028 Memorial Day
            740898 ;...  % 04-Jul-2028 Independence Day
            740960 ;...  % 04-Sep-2028 Labor Day
            741040 ;...  % 23-Nov-2028 Thanksgiving
            741079 ;...  % 01-Jan-2029 New Year's Day
            741072 ;...  % 25-Dec-2028 Christmas
            741093 ;...  % 15-Jan-2029 Martin Luther King Jr. Day
            741128 ;...  % 19-Feb-2029 Washington's Birthday
            741167 ;...  % 30-Mar-2029 Good Friday
            741226 ;...  % 28-May-2029 Memorial Day
            741263 ;...  % 04-Jul-2029 Independence Day
            741324 ;...  % 03-Sep-2029 Labor Day
            741404 ;...  % 22-Nov-2029 Thanksgiving
            741444 ;...  % 01-Jan-2030 New Year's Day
            741437 ;...  % 25-Dec-2029 Christmas
            741464 ;...  % 21-Jan-2030 Martin Luther King Jr. Day
            741492 ;...  % 18-Feb-2030 Washington's Birthday
            741552 ;...  % 19-Apr-2030 Good Friday
            741590 ;...  % 27-May-2030 Memorial Day
            741628 ;...  % 04-Jul-2030 Independence Day
            741688 ;...  % 02-Sep-2030 Labor Day
            741775 ;...  % 28-Nov-2030 Thanksgiving
            741802 ;...  % 25-Dec-2030 Christmas
            ];
    case {'zar','jse'},
        h = [ ...
            727191  % 24-Dec-1990, Mon
            727192  % 25-Dec-1990, Tue
            727193  % 26-Dec-1990, Wed
            727198  % 31-Dec-1990, Mon
            727199  % 01-Jan-1991, Tue
            727286  % 29-Mar-1991, Fri
            727289  % 01-Apr-1991, Mon
            727319  % 01-May-1991, Wed
            727327  % 09-May-1991, Thu
            727349  % 31-May-1991, Fri
            727481  % 10-Oct-1991, Thu
            727548  % 16-Dec-1991, Mon
            727557  % 25-Dec-1991, Wed
            727558  % 26-Dec-1991, Thu
            727559  % 27-Dec-1991, Fri
            727564  % 01-Jan-1992, Wed
            727660  % 06-Apr-1992, Mon
            727671  % 17-Apr-1992, Fri
            727674  % 20-Apr-1992, Mon
            727685  % 01-May-1992, Fri
            727712  % 28-May-1992, Thu
            727914  % 16-Dec-1992, Wed
            727923  % 25-Dec-1992, Fri
            727930  % 01-Jan-1993, Fri
            728025  % 06-Apr-1993, Tue
            728028  % 09-Apr-1993, Fri
            728031  % 12-Apr-1993, Mon
            728069  % 20-May-1993, Thu
            728080  % 31-May-1993, Mon
            728279  % 16-Dec-1993, Thu
            728385  % 01-Apr-1994, Fri
            728388  % 04-Apr-1994, Mon
            728390  % 06-Apr-1994, Wed
            728411  % 27-Apr-1994, Wed
            728412  % 28-Apr-1994, Thu
            728424  % 10-May-1994, Tue
            728426  % 12-May-1994, Thu
            728445  % 31-May-1994, Tue
            728577  % 10-Oct-1994, Mon
            728644  % 16-Dec-1994, Fri
            728654  % 26-Dec-1994, Mon
            728661  % 02-Jan-1995, Mon  *New Year's Day
            728739  % 21-Mar-1995, Tue   Human Rights' Day
            728763  % 14-Apr-1995, Fri   Good Friday
            728766  % 17-Apr-1995, Mon   Family Day
            728776  % 27-Apr-1995, Thu   Freedom Day
            728780  % 01-May-1995, Mon   Workers' Day
            728826  % 16-Jun-1995, Fri   Youth Day
            728880  % 09-Aug-1995, Wed   National Woman's Day
            728927  % 25-Sep-1995, Mon  *Heritage Day
            728964  % 01-Nov-1995, Wed  ?Extra Public Holiday
            729018  % 25-Dec-1995, Mon   Christmas Day
            729019  % 26-Dec-1995, Tue   Day of Goodwill
            729025  % 01-Jan-1996, Mon   New Year's Day
            729105  % 21-Mar-1996, Thu   Human Rights' Day
            729120  % 05-Apr-1996, Fri   Good Friday
            729123  % 08-Apr-1996, Mon   Family Day
            729146  % 01-May-1996, Wed   Workers' Day
            729193  % 17-Jun-1996, Mon  *Youth Day
            729246  % 09-Aug-1996, Fri   National Woman's Day
            729292  % 24-Sep-1996, Tue   Heritage Day
            729375  % 16-Dec-1996, Mon   Day of Reconciliation
            729384  % 25-Dec-1996, Wed   Christmas Day
            729385  % 26-Dec-1996, Thu   Day of Goodwill
            729391  % 01-Jan-1997, Wed   New Year's Day
            729470  % 21-Mar-1997, Fri   Human Rights' Day
            729477  % 28-Mar-1997, Fri   Good Friday
            729480  % 31-Mar-1997, Mon   Family Day
            729508  % 28-Apr-1997, Mon  *Freedom Day
            729511  % 01-May-1997, Thu   Workers' Day
            729557  % 16-Jun-1997, Mon   Youth Day
            729657  % 24-Sep-1997, Wed   Heritage Day
            729740  % 16-Dec-1997, Tue   Day of Reconciliation
            729749  % 25-Dec-1997, Thu   Christmas Day
            729750  % 26-Dec-1997, Fri   Day of Goodwill
            729756  % 01-Jan-1998, Thu   New Year's Day
            729757  % 02-Jan-1998, Fri  ?Extra Public Holiday
            729855  % 10-Apr-1998, Fri   Good Friday
            729858  % 13-Apr-1998, Mon   Family Day
            729872  % 27-Apr-1998, Mon   Freedom Day
            729876  % 01-May-1998, Fri   Workers' Day
            729922  % 16-Jun-1998, Tue   Youth Day
            729977  % 10-Aug-1998, Mon  *National Woman's Day
            730022  % 24-Sep-1998, Thu   Heritage Day
            730105  % 16-Dec-1998, Wed   Day of Reconciliation
            730114  % 25-Dec-1998, Fri   Christmas Day
            730121  % 01-Jan-1999, Fri   New Year's Day
            730201  % 22-Mar-1999, Mon  *Human Rights' Day
            730212  % 02-Apr-1999, Fri   Good Friday
            730215  % 05-Apr-1999, Mon   Family Day
            730237  % 27-Apr-1999, Tue   Freedom Day
            730273  % 02-Jun-1999, Wed  ?Extra Public Holiday
            730287  % 16-Jun-1999, Wed   Youth Day
            730341  % 09-Aug-1999, Mon   National Woman's Day
            730387  % 24-Sep-1999, Fri   Heritage Day
            730470  % 16-Dec-1999, Thu   Day of Reconciliation
            730481  % 27-Dec-1999, Mon  *Day of Goodwill
            730484  % 30-Dec-1999, Thu  ?Extra Public Holiday
            730485  % 31-Dec-1999, Fri  ?Extra Public Holiday
            730488  % 03-Jan-2000, Mon  ?Extra Public Holiday
            730566  % 21-Mar-2000, Tue   Human Rights' Day
            730597  % 21-Apr-2000, Fri   Good Friday
            730600  % 24-Apr-2000, Mon   Family Day
            730603  % 27-Apr-2000, Thu   Freedom Day
            730607  % 01-May-2000, Mon   Workers' Day
            730653  % 16-Jun-2000, Fri   Youth Day
            730707  % 09-Aug-2000, Wed   National Woman's Day
            730754  % 25-Sep-2000, Mon  *Heritage Day
            730825  % 05-Dec-2000, Tue  ?Election Day
            730845  % 25-Dec-2000, Mon   Christmas Day
            730846  % 26-Dec-2000, Tue   Day of Goodwill
            730852  % 01-Jan-2001, Mon   New Year's Day
            730931  % 21-Mar-2001, Wed   Human Rights' Day
            730954  % 13-Apr-2001, Fri   Good Friday
            730957  % 16-Apr-2001, Mon   Family Day
            730968  % 27-Apr-2001, Fri   Freedom Day
            730972  % 01-May-2001, Tue   Workers' Day
            731072  % 09-Aug-2001, Thu   National Woman's Day
            731118  % 24-Sep-2001, Mon   Heritage Day
            731202  % 17-Dec-2001, Mon  *Day of Reconciliation
            731210  % 25-Dec-2001, Tue   Christmas Day
            731211  % 26-Dec-2001, Wed   Day of Goodwill
            731217  % 01-Jan-2002, Tue   New Year's Day
            731296  % 21-Mar-2002, Thu   Human Rights' Day
            731304  % 29-Mar-2002, Fri   Good Friday
            731307  % 01-Apr-2002, Mon   Family Day
            731337  % 01-May-2002, Wed   Workers' Day
            731384  % 17-Jun-2002, Mon  *Youth Day
            731437  % 09-Aug-2002, Fri   National Woman's Day
            731483  % 24-Sep-2002, Tue   Heritage Day
            731566  % 16-Dec-2002, Mon   Day of Reconciliation
            731575  % 25-Dec-2002, Wed   Christmas Day
            731576  % 26-Dec-2002, Thu   Day of Goodwill
            731582  % 01-Jan-2003, Wed   New Year's Day
            731661  % 21-Mar-2003, Fri   Human Rights' Day
            731689  % 18-Apr-2003, Fri   Good Friday
            731692  % 21-Apr-2003, Mon   Family Day
            731699  % 28-Apr-2003, Mon  *Freedom Day
            731702  % 01-May-2003, Thu   Workers' Day
            731748  % 16-Jun-2003, Mon   Youth Day
            731848  % 24-Sep-2003, Wed   Heritage Day
            731931  % 16-Dec-2003, Tue   Day of Reconciliation
            731940  % 25-Dec-2003, Thu   Christmas Day
            731941  % 26-Dec-2003, Fri   Day of Goodwill
            731947  % 01-Jan-2004, Thu   New Year's Day
            732028  % 22-Mar-2004, Mon  *Human Rights' Day
            732046  % 09-Apr-2004, Fri   Good Friday
            732049  % 12-Apr-2004, Mon   Family Day
            732064  % 27-Apr-2004, Tue   Freedom Day
            732114  % 16-Jun-2004, Wed   Youth Day
            732168  % 09-Aug-2004, Mon   National Woman's Day
            732214  % 24-Sep-2004, Fri   Heritage Day
            732297  % 16-Dec-2004, Thu   Day of Reconciliation
            732308  % 27-Dec-2004, Mon  *Day of Goodwill
            732392  % 21-Mar-2005, Mon   Human Rights' Day
            732396  % 25-Mar-2005, Fri   Good Friday
            732399  % 28-Mar-2005, Mon   Family Day
            732429  % 27-Apr-2005, Wed   Freedom Day
            732434  % 02-May-2005, Mon  *Workers' Day
            732479  % 16-Jun-2005, Thu   Youth Day
            732533  % 09-Aug-2005, Tue   National Woman's Day
            732662  % 16-Dec-2005, Fri   Day of Reconciliation
            732672  % 26-Dec-2005, Mon  *Christmas Day
            732672  % 26-Dec-2005, Mon   Day of Goodwill
            732679  % 02-Jan-2006, Mon  *New Year's Day
            732757  % 21-Mar-2006, Tue   Human Rights' Day
            732781  % 14-Apr-2006, Fri   Good Friday
            732784  % 17-Apr-2006, Mon   Family Day
            732794  % 27-Apr-2006, Thu   Freedom Day
            732798  % 01-May-2006, Mon   Workers' Day
            732844  % 16-Jun-2006, Fri   Youth Day
            732898  % 09-Aug-2006, Wed   National Woman's Day
            732945  % 25-Sep-2006, Mon  *Heritage Day
            733036  % 25-Dec-2006, Mon   Christmas Day
            733037  % 26-Dec-2006, Tue   Day of Goodwill
            733043  % 01-Jan-2007, Mon   New Year's Day
            733122  % 21-Mar-2007, Wed   Human Rights' Day
            733138  % 06-Apr-2007, Fri   Good Friday
            733141  % 09-Apr-2007, Mon   Family Day
            733159  % 27-Apr-2007, Fri   Freedom Day
            733163  % 01-May-2007, Tue   Workers' Day
            733263  % 09-Aug-2007, Thu   National Woman's Day
            733309  % 24-Sep-2007, Mon   Heritage Day
            733393  % 17-Dec-2007, Mon  *Day of Reconciliation
            733401  % 25-Dec-2007, Tue   Christmas Day
            733402  % 26-Dec-2007, Wed   Day of Goodwill
            733408  % 01-Jan-2008, Tue   New Year's Day
            733488  % 21-Mar-2008, Fri   Human Rights' Day
            733488  % 21-Mar-2008, Fri   Good Friday
            733491  % 24-Mar-2008, Mon   Family Day
            733526  % 28-Apr-2008, Mon  *Freedom Day
            733529  % 01-May-2008, Thu   Workers' Day
            733575  % 16-Jun-2008, Mon   Youth Day
            733675  % 24-Sep-2008, Wed   Heritage Day
            733758  % 16-Dec-2008, Tue   Day of Reconciliation
            733767  % 25-Dec-2008, Thu   Christmas Day
            733768  % 26-Dec-2008, Fri   Day of Goodwill
            733774  % 01-Jan-2009, Thu   New Year's Day
            733873  % 10-Apr-2009, Fri   Good Friday
            733876  % 13-Apr-2009, Mon   Family Day
            733885  % 22-Apr-2009, Wed   General Election
            733890  % 27-Apr-2009, Mon   Freedom Day
            733894  % 01-May-2009, Fri   Workers' Day
            733940  % 16-Jun-2009, Tue   Youth Day
            733995  % 10-Aug-2009, Mon  *National Woman's Day
            734040  % 24-Sep-2009, Thu   Heritage Day
            734123  % 16-Dec-2009, Wed   Day of Reconciliation
            734132  % 25-Dec-2009, Fri   Christmas Day
            734139  % 01-Jan-2010, Fri   New Year's Day
            734219  % 22-Mar-2010, Mon  *Human Rights' Day
            734230  % 02-Apr-2010, Fri   Good Friday
            734233  % 05-Apr-2010, Mon   Family Day
            734255  % 27-Apr-2010, Tue   Freedom Day
            734305  % 16-Jun-2010, Wed   Youth Day
            734359  % 09-Aug-2010, Mon   National Woman's Day
            734405  % 24-Sep-2010, Fri   Heritage Day
            734488  % 16-Dec-2010, Thu   Day of Reconciliation
            734499  % 27-Dec-2010, Mon  *Day of Goodwill
            734583  % 21-Mar-2011, Mon   Human Rights' Day
            734615  % 22-Apr-2011, Fri   Good Friday
            734618  % 25-Apr-2011, Mon   Family Day
            734620  % 27-Apr-2011, Wed   Freedom Day
            734625  % 02-May-2011, Mon  *Workers' Day
            734670  % 16-Jun-2011, Thu   Youth Day
            734724  % 09-Aug-2011, Tue   National Woman's Day
            734853  % 16-Dec-2011, Fri   Day of Reconciliation
            734863  % 26-Dec-2011, Mon  *Christmas Day
            734863  % 26-Dec-2011, Mon   Day of Goodwill
            734870  % 02-Jan-2012, Mon  *New Year's Day
            734949  % 21-Mar-2012, Wed   Human Rights' Day
            734965  % 06-Apr-2012, Fri   Good Friday
            734968  % 09-Apr-2012, Mon   Family Day
            734986  % 27-Apr-2012, Fri   Freedom Day
            734990  % 01-May-2012, Tue   Workers' Day
            735090  % 09-Aug-2012, Thu   National Woman's Day
            735136  % 24-Sep-2012, Mon   Heritage Day
            735220  % 17-Dec-2012, Mon  *Day of Reconciliation
            735228  % 25-Dec-2012, Tue   Christmas Day
            735229  % 26-Dec-2012, Wed   Day of Goodwill
            735235  % 01-Jan-2013, Tue   New Year's Day
            735314  % 21-Mar-2013, Thu   Human Rights' Day
            735322  % 29-Mar-2013, Fri   Good Friday
            735325  % 01-Apr-2013, Mon   Family Day
            735355  % 01-May-2013, Wed   Workers' Day
            735402  % 17-Jun-2013, Mon  *Youth Day
            735455  % 09-Aug-2013, Fri   National Woman's Day
            735501  % 24-Sep-2013, Tue   Heritage Day
            735584  % 16-Dec-2013, Mon   Day of Reconciliation
            735593  % 25-Dec-2013, Wed   Christmas Day
            735594  % 26-Dec-2013, Thu   Day of Goodwill
            735600  % 01-Jan-2014, Wed   New Year's Day
            735679  % 21-Mar-2014, Fri   Human Rights' Day
            735707  % 18-Apr-2014, Fri   Good Friday
            735710  % 21-Apr-2014, Mon   Family Day
            735717  % 28-Apr-2014, Mon  *Freedom Day
            735720  % 01-May-2014, Thu   Workers' Day
            735766  % 16-Jun-2014, Mon   Youth Day
            735866  % 24-Sep-2014, Wed   Heritage Day
            735949  % 16-Dec-2014, Tue   Day of Reconciliation
            735958  % 25-Dec-2014, Thu   Christmas Day
            735959  % 26-Dec-2014, Fri   Day of Goodwill
            735965  % 01-Jan-2015, Thu   New Year's Day
            736057  % 03-Apr-2015, Fri   Good Friday
            736060  % 06-Apr-2015, Mon   Family Day
            736081  % 27-Apr-2015, Mon   Freedom Day
            736085  % 01-May-2015, Fri   Workers' Day
            736131  % 16-Jun-2015, Tue   Youth Day
            736186  % 10-Aug-2015, Mon  *National Woman's Day
            736231  % 24-Sep-2015, Thu   Heritage Day
            736314  % 16-Dec-2015, Wed   Day of Reconciliation
            736323  % 25-Dec-2015, Fri   Christmas Day
            736330  % 01-Jan-2016, Fri   New Year's Day
            736410  % 21-Mar-2016, Mon   Human Rights' Day
            736414  % 25-Mar-2016, Fri   Good Friday
            736417  % 28-Mar-2016, Mon   Family Day
            736447  % 27-Apr-2016, Wed   Freedom Day
            736452  % 02-May-2016, Mon  *Workers' Day
            736497  % 16-Jun-2016, Thu   Youth Day
            736551  % 09-Aug-2016, Tue   National Woman's Day
            736680  % 16-Dec-2016, Fri   Day of Reconciliation
            736690  % 26-Dec-2016, Mon  *Christmas Day
            736690  % 26-Dec-2016, Mon   Day of Goodwill
            736697  % 02-Jan-2017, Mon  *New Year's Day
            736775  % 21-Mar-2017, Tue   Human Rights' Day
            736799  % 14-Apr-2017, Fri   Good Friday
            736802  % 17-Apr-2017, Mon   Family Day
            736812  % 27-Apr-2017, Thu   Freedom Day
            736816  % 01-May-2017, Mon   Workers' Day
            736862  % 16-Jun-2017, Fri   Youth Day
            736916  % 09-Aug-2017, Wed   National Woman's Day
            736963  % 25-Sep-2017, Mon  *Heritage Day
            737054  % 25-Dec-2017, Mon   Christmas Day
            737055  % 26-Dec-2017, Tue   Day of Goodwill
            737061  % 01-Jan-2018, Mon   New Year's Day
            737140  % 21-Mar-2018, Wed   Human Rights' Day
            737149  % 30-Mar-2018, Fri   Good Friday
            737152  % 02-Apr-2018, Mon   Family Day
            737177  % 27-Apr-2018, Fri   Freedom Day
            737181  % 01-May-2018, Tue   Workers' Day
            737281  % 09-Aug-2018, Thu   National Woman's Day
            737327  % 24-Sep-2018, Mon   Heritage Day
            737411  % 17-Dec-2018, Mon  *Day of Reconciliation
            737419  % 25-Dec-2018, Tue   Christmas Day
            737420  % 26-Dec-2018, Wed   Day of Goodwill
            737426  % 01-Jan-2019, Tue   New Year's Day
            737505  % 21-Mar-2019, Thu   Human Rights' Day
            737534  % 19-Apr-2019, Fri   Good Friday
            737537  % 22-Apr-2019, Mon   Family Day
            737546  % 01-May-2019, Wed   Workers' Day
            737593  % 17-Jun-2019, Mon  *Youth Day
            737646  % 09-Aug-2019, Fri   National Woman's Day
            737692  % 24-Sep-2019, Tue   Heritage Day
            737775  % 16-Dec-2019, Mon   Day of Reconciliation
            737784  % 25-Dec-2019, Wed   Christmas Day
            737785  % 26-Dec-2019, Thu   Day of Goodwill
            737791  % 01-Jan-2020, Wed   New Year's Day
            737891  % 10-Apr-2020, Fri   Good Friday
            737894  % 13-Apr-2020, Mon   Family Day
            737908  % 27-Apr-2020, Mon   Freedom Day
            737912  % 01-May-2020, Fri   Workers' Day
            737958  % 16-Jun-2020, Tue   Youth Day
            738013  % 10-Aug-2020, Mon  *National Woman's Day
            738058  % 24-Sep-2020, Thu   Heritage Day
            738141  % 16-Dec-2020, Wed   Day of Reconciliation
            738150  % 25-Dec-2020, Fri   Christmas Day
            738157  % 01-Jan-2021, Fri   New Year's Day
            738237  % 22-Mar-2021, Mon  *Human Rights' Day
            738248  % 02-Apr-2021, Fri   Good Friday
            738251  % 05-Apr-2021, Mon   Family Day
            738273  % 27-Apr-2021, Tue   Freedom Day
            738323  % 16-Jun-2021, Wed   Youth Day
            738377  % 09-Aug-2021, Mon   National Woman's Day
            738423  % 24-Sep-2021, Fri   Heritage Day
            738506  % 16-Dec-2021, Thu   Day of Reconciliation
            738517  % 27-Dec-2021, Mon  *Day of Goodwill
            738601  % 21-Mar-2022, Mon   Human Rights' Day
            738626  % 15-Apr-2022, Fri   Good Friday
            738629  % 18-Apr-2022, Mon   Family Day
            738638  % 27-Apr-2022, Wed   Freedom Day
            738643  % 02-May-2022, Mon  *Workers' Day
            738688  % 16-Jun-2022, Thu   Youth Day
            738742  % 09-Aug-2022, Tue   National Woman's Day
            738871  % 16-Dec-2022, Fri   Day of Reconciliation
            738881  % 26-Dec-2022, Mon  *Christmas Day
            738881  % 26-Dec-2022, Mon   Day of Goodwill
            738888  % 02-Jan-2023, Mon  *New Year's Day
            738966  % 21-Mar-2023, Tue   Human Rights' Day
            738983  % 07-Apr-2023, Fri   Good Friday
            738986  % 10-Apr-2023, Mon   Family Day
            739003  % 27-Apr-2023, Thu   Freedom Day
            739007  % 01-May-2023, Mon   Workers' Day
            739053  % 16-Jun-2023, Fri   Youth Day
            739107  % 09-Aug-2023, Wed   National Woman's Day
            739154  % 25-Sep-2023, Mon  *Heritage Day
            739245  % 25-Dec-2023, Mon   Christmas Day
            739246  % 26-Dec-2023, Tue   Day of Goodwill
            739252  % 01-Jan-2024, Mon   New Year's Day
            739332  % 21-Mar-2024, Thu   Human Rights' Day
            739340  % 29-Mar-2024, Fri   Good Friday
            739343  % 01-Apr-2024, Mon   Family Day
            739373  % 01-May-2024, Wed   Workers' Day
            739420  % 17-Jun-2024, Mon  *Youth Day
            739473  % 09-Aug-2024, Fri   National Woman's Day
            739519  % 24-Sep-2024, Tue   Heritage Day
            739602  % 16-Dec-2024, Mon   Day of Reconciliation
            739611  % 25-Dec-2024, Wed   Christmas Day
            739612  % 26-Dec-2024, Thu   Day of Goodwill
            739618  % 01-Jan-2025, Wed   New Year's Day
            739697  % 21-Mar-2025, Fri   Human Rights' Day
            739725  % 18-Apr-2025, Fri   Good Friday
            739728  % 21-Apr-2025, Mon   Family Day
            739735  % 28-Apr-2025, Mon  *Freedom Day
            739738  % 01-May-2025, Thu   Workers' Day
            739784  % 16-Jun-2025, Mon   Youth Day
            739884  % 24-Sep-2025, Wed   Heritage Day
            739967  % 16-Dec-2025, Tue   Day of Reconciliation
            739976  % 25-Dec-2025, Thu   Christmas Day
            739977  % 26-Dec-2025, Fri   Day of Goodwill
            739983  % 01-Jan-2026, Thu   New Year's Day
            740075  % 03-Apr-2026, Fri   Good Friday
            740078  % 06-Apr-2026, Mon   Family Day
            740099  % 27-Apr-2026, Mon   Freedom Day
            740103  % 01-May-2026, Fri   Workers' Day
            740149  % 16-Jun-2026, Tue   Youth Day
            740204  % 10-Aug-2026, Mon  *National Woman's Day
            740249  % 24-Sep-2026, Thu   Heritage Day
            740332  % 16-Dec-2026, Wed   Day of Reconciliation
            740341  % 25-Dec-2026, Fri   Christmas Day
            740348  % 01-Jan-2027, Fri   New Year's Day
            740428  % 22-Mar-2027, Mon  *Human Rights' Day
            740432  % 26-Mar-2027, Fri   Good Friday
            740435  % 29-Mar-2027, Mon   Family Day
            740464  % 27-Apr-2027, Tue   Freedom Day
            740514  % 16-Jun-2027, Wed   Youth Day
            740568  % 09-Aug-2027, Mon   National Woman's Day
            740614  % 24-Sep-2027, Fri   Heritage Day
            740697  % 16-Dec-2027, Thu   Day of Reconciliation
            740708  % 27-Dec-2027, Mon  *Day of Goodwill
            740793  % 21-Mar-2028, Tue   Human Rights' Day
            740817  % 14-Apr-2028, Fri   Good Friday
            740820  % 17-Apr-2028, Mon   Family Day
            740830  % 27-Apr-2028, Thu   Freedom Day
            740834  % 01-May-2028, Mon   Workers' Day
            740880  % 16-Jun-2028, Fri   Youth Day
            740934  % 09-Aug-2028, Wed   National Woman's Day
            740981  % 25-Sep-2028, Mon  *Heritage Day
            741072  % 25-Dec-2028, Mon   Christmas Day
            741073  % 26-Dec-2028, Tue   Day of Goodwill
            741079  % 01-Jan-2029, Mon   New Year's Day
            741158  % 21-Mar-2029, Wed   Human Rights' Day
            741167  % 30-Mar-2029, Fri   Good Friday
            741170  % 02-Apr-2029, Mon   Family Day
            741195  % 27-Apr-2029, Fri   Freedom Day
            741199  % 01-May-2029, Tue   Workers' Day
            741299  % 09-Aug-2029, Thu   National Woman's Day
            741345  % 24-Sep-2029, Mon   Heritage Day
            741429  % 17-Dec-2029, Mon  *Day of Reconciliation
            741437  % 25-Dec-2029, Tue   Christmas Day
            741438  % 26-Dec-2029, Wed   Day of Goodwill
            741444  % 01-Jan-2030, Tue   New Year's Day
            741523  % 21-Mar-2030, Thu   Human Rights' Day
            741552  % 19-Apr-2030, Fri   Good Friday
            741555  % 22-Apr-2030, Mon   Family Day
            741564  % 01-May-2030, Wed   Workers' Day
            741611  % 17-Jun-2030, Mon  *Youth Day
            741664  % 09-Aug-2030, Fri   National Woman's Day
            741710  % 24-Sep-2030, Tue   Heritage Day
            741793  % 16-Dec-2030, Mon   Day of Reconciliation
            741802  % 25-Dec-2030, Wed   Christmas Day
            741803  % 26-Dec-2030, Thu   Day of Goodwill
            ];
        case {'gbp','lse'},
            error('LSE not yet supported');
            h = [...
                733408 % 01-Jan-2008, Tue, New Year 
                733488 % 21-Mar-2008, Fri, Good Friday
                733491 % 24-Mar-2008, Mon, Easter Monday
                733533 % 05-May-2008, Mon, May (First Monday in May)
                733554 % 26-May-2008, Mon, Spring (Last Monday in May)
                733645 % 25-Aug-2008, Mon, Summer (Last Monday in August)
                733767 % 25-Dec-2008, Thr, Christmas Day
                733768 % 26-Dec-2008, Fri, Boxing Day
                733774 % 01-Jan-2009, Thr, New Year
                733873 % 10-Apr-2009, Fri, Good Friday
                733876 % 13-Apr-2009, Mon, Easter Monday
                733897 % 04-May-2009, Mon, May (First Monday in May)
                733918 % 25-May-2009, Mon, Spring (Last Monday in May)
                734016 % 31-Aug-2009, Mon, Summer (Last Monday in August)
                734132 % 25-Dec-2009, Thr, Christmas Day
                734135 % 28-Dec-2009, Fri, Boxing Day
                734139 % 01-Jan-2010, Tue, New Year 
                734230 % 02-Apr-2010, Fri, Good Friday
                734233 % 05-Apr-2010, Mon, Easter Monday
                734261 % 03-May-2010, Mon, May (First Monday in May)
                734289 % 31-May-2010, Mon, Spring (Last Monday in May)
                734380 % 30-Aug-2010, Mon, Summer (Last Monday in August)
                734499 % 27-Dec-2010, Thr, Christmas Day
                734500 % 28-Dec-2010, Fri, Boxing Day
                734504 % 01-Jan-2011, Thr, New Year   
                ];
    otherwise
        error('Unrecognized Country');
end

h = sort(h, 1);   % Make sure that the dates are in chronological order

if nargin == 1
  error('Please enter D2.')
elseif nargin >= 2
  if isstr(d1) | isstr(d2)
    start = datenum(d1);
    fin = datenum(d2);
  else
    start = d1;
    fin = d2;
  end  
  hindex = find(h < start | h > fin);
  h(hindex) = [];
end

