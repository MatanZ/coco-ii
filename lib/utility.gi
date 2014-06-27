InstallGlobalFunction(ReadTensor,
        # reads a tensor in COCO-1.2 format and returns it
        function(filename)
    local   stream,  fibers, line, order, tensor, entries, i;
    stream := InputTextFile(filename);
    # fibers
    line := ReadLine(stream);
    Unbind(line[Length(line)]);
    fibers := Int(line);
    Print("fibres: ", fibers, "\n");
    # order
    line := ReadLine(stream);
    line := SplitString(line, "", ",\n");
    order := Sum(List(line, Int));
    Print("order: ", order, "\n");
    # mates (ignored)
    line := ReadLine(stream);
    while line[Length(line)-1] = '*' do
      line := ReadLine(stream);
    od;
    tensor := NullTensor(Group(()), order);
    while true do
        line := ReadLine(stream);
        if line = fail then
            break;
        fi;
        if (Length(line) = 0) or (line[1] <> '(') then
            continue;
        fi;
        entries  := SplitString(line, "", "(),-*\n");
        entries := List(entries, Int);
        if not IsInt(Length(entries)/4) then
            Error("tensor: wrong format");
        fi;
        for i in [1,5..Length(entries)-3] do
            SetEntryOfTensor(tensor, entries[i]+1,
                    entries[i+1]+1, entries[i+2]+1, entries[i+3]);
        od;
    od;
    CloseStream(stream);
    return tensor;
end);

