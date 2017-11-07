function ind = findName(name, array)
ind = [];
for i=1:numel(array)
    if strfind(char(array(i)), name)
        ind  = i;
        break;
    end
end
end
