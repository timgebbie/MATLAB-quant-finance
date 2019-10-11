function trstoploss(t,p,pos,th,ph,thresh)
% Trailing stop loss function
% t,p = time and price sampled half hourly
% pos = position from marisa with N=220, M=25
% th,ph,time and price sampled minutely 
% thres is the stoploss threshold in ticks
%
% Easy to get out, difficult to get back in.

N=length(ph);
% make a long vector of positions at the minute time intervals
pos1m=zeros(N,1); 
pos1ms1=zeros(N,1);
step = 30;

% now loop down the long vector and copy th elast
for i=1:length(pos)-1
    index=(i-1)*step+1:i*stop;
    if pos(i)>0 % taking a long position
        hiprice=p(i);
        for j=index
            % follow the price up, resetting the s
            if ph(j)>hiprice, 
                hiprice=ph(j); 
                pos1ms1 = 1;
                % check to see if we have breached the threshold
            elseif hiprice-ph(j) < thresh,
                pos1ms1 = 0; 
            end
        end
    elseif posi(i) <0 % take a short position
        loprice=p(i);
        for j=index
            % follow the price down, resetting the 
            if ph(j)<loprice, 
                loprice = ph(j);
                pos1ms1 = -1;
            elseif ph(j)-loprice < thresh,
                pos1ms1 = 0;
            end
        end
    end
end
                
