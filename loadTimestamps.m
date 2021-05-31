function ts = loadTimestamps(ts_dir)

ts = [];

fid = fopen([ts_dir '/timestamps.txt']);

if fid~=-1
    
    col = textscan(fid,'%s\n',-1,'delimiter',',');
    ts = col{1};
    fclose(fid);
    numeric=length(col{1,1});
    
    for i=1:numeric
        num(i,:) = stringToTimestampMex(ts{i});
    end
    ts = num;
end
