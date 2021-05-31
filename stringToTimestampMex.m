function array=stringToTimestampMex(ts)
    array=[];
    array(1)=str2double(ts(1:4));
    array(2)=str2double(ts(6:7));
    array(3)=str2double(ts(9:10));
    array(4)=str2double(ts(12:13));
    array(5)=str2double(ts(15:16));
    array(6)=str2double(ts(18:29));
    
end