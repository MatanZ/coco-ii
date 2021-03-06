ColorGraphFam := NewFamily("ColorGraphFam", IsColorGraph);

DeclareRepresentation( "IsColorGraphRep", 
        # IsAttributeStoringRep,
        IsCocoObjectRep,
        ["twoOrbReps",      # representatives of edge orbits
         "mates",           # permutation mapping each two-orb to its 
         #                  # transpose
         "orbitColors",     # for each rep its color
         "twoOrbitNumbers", # for each vertex orbit a row of the adj mat
         "colorNames",
         "names"]);         # vertex names

DeclareRepresentation( "IsColorGraphMatrixRep",
        IsAttributeStoringRep,["matrix"]);

InstallGlobalFunction(ColorGraph,
       
function(arg)
    local ii, i, j, k, l,obj,
          group, points, orbits, twoOrbReps, representatives,
          edge, color, colors, mates, repWord;
    obj := CallFuncList( CocoObjectTemplate, arg );
    obj.twoOrbReps := [];
    obj.twoOrbitNumbers := [];
    obj.orbitColors := [];
    colors := [];
    k := 0;
    for ii in [1..Length(obj.representatives)] do
        i := obj.representatives[ii];
        obj.twoOrbitNumbers[ii] := [];
        for j in Orbits(Stabilizer(obj.group, i), [1..obj.order]) do
            Add(obj.twoOrbReps, [i, j[1]]);
            k := k+1;
            for l in j do
                obj.twoOrbitNumbers[ii][l] := k;
            od;
        od;
    od;
    obj.orbitColors := [1..Length(obj.twoOrbReps)];
    
    obj.colorNames := [1..Length(obj.twoOrbReps)];
    obj :=  Objectify(NewType(ColorGraphFam, IsColorGraphRep), obj);

    # calculate symmetric mates
    obj!.mates := PermList(List([1..GroupRankOfColorGraph(obj)], x ->
                          TwoOrbitNumberOfColorGraph(obj, 
                                  Reversed(obj!.twoOrbReps[x]))));
    return obj;
end);

ColorGraphFromMatrix := function(matrix)
    local record, result, entries;
    entries := Union(matrix);
    matrix := List(matrix, x -> List(x, y -> Position(entries, y)));
    record := rec( matrix := matrix );
    result := Objectify(NewType(ColorGraphFam, IsColorGraphMatrixRep),
                      record);
    return result;
end;

InstallMethod(ViewObj, 
        "for color graphs",
        ReturnTrue,
        [IsColorGraph],
        0,
        function(x)
    Print("<");
    Print("color graph of order ", Order(x), 
          " and rank ", Rank(x), ">");
end);

InstallMethod(PrintObj,
        "for color graphs",
        ReturnTrue,
        [IsColorGraph and IsColorGraphRep],
        0,
        function(cgr)
    local   partition;
    if cgr!.orbitColors = [1..Rank(cgr)] then
        Print("ColorGraph( ", GroupOfCocoObject(cgr), " )");
    else
        partition := List(Set(cgr!.orbitColors), x ->
                          Filtered([1..Length(cgr!.orbitColors)], y ->
                                  cgr!.orbitColors[y] = x));
        Print("CoherentSubalgebra( ColorGraph( ",
              GroupOfCocoObject(cgr), "), ", partition, ")");
    fi;
end);
InstallMethod(PrintObj,
        "for color graphs",
        ReturnTrue,
        [IsColorGraph and IsColorGraphMatrixRep],
        0,
        function(cgr)
    Print("ColorGraphFromMatrix(\n");
    PrintArray(cgr!.matrix);
    Print(")");
end);


InstallMethod(Display,
        "for color graphs",
        ReturnTrue,
        [IsColorGraph],
        0,
        function(cgr)
    Print("color graph\n");
    Display(List([1..Order(cgr)], x -> RowOfColorGraph(cgr, x)));
end);



InstallOtherMethod(Order,
        "for color graphs", 
        ReturnTrue,
        [IsColorGraph and IsColorGraphMatrixRep],
        0,
        x -> Length(x!.matrix));

InstallOtherMethod(Rank, 
        "for color graphs", 
        ReturnTrue,
        [IsColorGraph and IsColorGraphRep],
        0,
        function(cgr)
    return Length(Set(cgr!.orbitColors));
end);

InstallOtherMethod(Rank, 
        "for color graphs", 
        ReturnTrue,
        [IsColorGraph and IsColorGraphMatrixRep],
        0,
        function(cgr)
    return Length(Union(cgr!.matrix));
end);
InstallMethod(GroupOfColorGraph, 
        "for color graphs",
        ReturnTrue,
        [IsColorGraph],
        0,
        function(x)
    return x!.group;
end);

InstallMethod(GroupRankOfColorGraph, 
        "for color graphs",
        ReturnTrue,
        [IsColorGraph],
        0,
        function(x)
    return Length(x!.twoOrbReps);
end);

InstallGlobalFunction(TwoOrbitRepresentative,
        function( cgr, twoOrbit )
    return cgr!.twoOrbReps[twoOrbit];
end);


InstallMethod(RowOfColorGraph,
        "for color graphs",
        ReturnTrue,
        [IsColorGraph and IsColorGraphRep, IsPosInt],
        0,
        function(cgr, i)
    
    local w, row, repWord, generators, schreier;
    schreier := cgr!.schreier;
    generators := GeneratorsOfGroup(cgr!.group);
    repWord := GRAPE_RepWord(generators, schreier, i);
    row := cgr!.twoOrbitNumbers[-schreier[repWord.representative]];
    for w in repWord.word do
        row := Permuted(row, generators[w]);
    od;
    return List(row, x -> Position(cgr!.colorNames,cgr!.orbitColors[x]));
end);

InstallMethod(RowOfColorGraph,
        "for color graphs",
        ReturnTrue,
        [IsColorGraph and IsColorGraphMatrixRep, IsPosInt],
        0,
        function(cgr, i)
    return cgr!.matrix[i];
end);

InstallMethod(ColumnOfColorGraph,
        "for color graphs",
        ReturnTrue,
        [IsColorGraph, IsPosInt],
        0,
        function(cgr, i)
    local w, row, repWord, generators, schreier;
    schreier := cgr!.schreier;
    generators := GeneratorsOfGroup(cgr!.group);
    repWord := GRAPE_RepWord(generators, schreier, i);
    row := cgr!.twoOrbitNumbers[-schreier[repWord.representative]];
    for w in repWord.word do
        row := Permuted(row, generators[w]);
    od;
    row :=  List(row, x -> cgr!.orbitColors[x^cgr!.mates]);
    return List(row, x -> Position(cgr!.colorNames, x));
    
end);
InstallMethod(EdgeColorOfColorGraph,
        "for color graphs",
        ReturnTrue,
        [IsColorGraph, IsPosInt, IsPosInt],
        0,
        function(cgr, i, j)
    return RowOfColorGraph(cgr, i)[j];
end);

InstallMethod(SetEdgeOrbitColorOfColorGraph,
        "for color graphs",
        ReturnTrue,
        [IsColorGraph, IsPosInt, IsPosInt, IsPosInt],
        0,
        function(cgr, i, j, color)
    
    local w, row, repWord, generators, schreier, subOrbit, rank;
    subOrbit := TwoOrbitNumberOfColorGraph(cgr, [i, j]);
    
    cgr!.orbitColors[subOrbit] := color;
    cgr!.colorNames := Set(cgr!.orbitColors);
    
end);

InstallMethod(BaseGraphOfColorGraph,
        "for color graphs",
        ReturnTrue,
        [IsColorGraph, IsPosInt],
        0,
        function(cgr, color)
    return Graph(GroupOfCocoObject(cgr), [1..Order(cgr)],
                   OnPoints, function(x,y)
        return EdgeColorOfColorGraph(cgr, x, y) = color; end, true);
end);
InstallMethod(IsIsomorphismOfObjects, 
        "for color graphs",
        ReturnTrue,
        [IsColorGraph, IsColorGraph, IsPerm],
        0,
        function(cgr1, cgr2, g)
    local row1, row2, i, j;
    if (Order(cgr1) <> Order(cgr2)) then
        return false;
    fi;
    if Rank(cgr1) <> Rank(cgr2) then
        return false;
    fi;
    for i in [1..Order(cgr1)] do
        row1 := Permuted(RowOfColorGraph(cgr1, i), g);
        row2 := RowOfColorGraph(cgr2, i^g);
        if row1 <> row2 then
           return false;
        fi;
    od;
    return true;
end);


InstallMethod(AutGroupOfCocoObject, 
        "for color graphs",
        ReturnTrue,
        [IsColorGraph],
        0,
        function(cgr)
    local inv;
    inv := MakeInvariant(cgr);
    return FindAutomorphismGroup(inv);
end);

InstallOtherMethod(AutomorphismGroup,
        "for color graphs",
        [IsColorGraph],
        function(cgr)
    local inv;
    inv := MakeInvariant(cgr);
    return FindAutomorphismGroup(inv);
end);

InstallMethod(ColorAutomorphismGroup,
        "for color graphs",
        ReturnTrue,
        [IsColorGraph],
        0,
        function(cgr)
    local inv;
    inv := MakeWeakInvariant(cgr);
    return FindAutomorphismGroup(inv);
end);

InstallGlobalFunction(
        TwoOrbitNumberOfColorGraph, function(cgr, edge)
    local i, j,repWord;
    repWord := RepresentativeWordOfCocoObject(cgr, edge[1]);
    j := edge[2];
    for i in Reversed(repWord.word) do
        j := j/GeneratorsOfGroup(GroupOfCocoObject(cgr))[i];
    od;
    return cgr!.twoOrbitNumbers[-cgr!.schreier[repWord.representative]][j];
    
end);
    
InstallMethod( ColorRepresentative,
        "for color graphs and integers",
        [IsColorGraph, IsInt],
        function(cgr, color)
    local pos;
    pos := Position(cgr!.orbitColors, color);
    if pos = fail then
        return fail;
    fi;
    return cgr!.twoOrbReps[pos];
end);

InstallMethod( Fibres,
        "for color graphs",
        [IsColorGraph],
        function(cgr)
    local   colors,  colorSet,  fibres;

    colors := List([1..Order(cgr)], x -> EdgeColorOfColorGraph(cgr, x, x));
    colorSet := Set(colors);
    fibres := List(colorSet, x -> Filtered([1..Length(colors)],  y ->
                      colors[y] = x));
    return fibres;
end);

InstallMethod( Neighbors,
        "for a color graph, a vertex, and a color",
        [IsColorGraph, IsInt, IsInt],
        function(cgr, x, color)
    local row, result;
    row := RowOfColorGraph(cgr, x);
    result := Filtered([1..Length(row)], y -> row[y] = color);
    return result;
end);

InstallMethod( IsHomogeneous,
        "for a color graph",
        [IsColorGraph],
        function(cgr)
    return Length(Fibres(cgr)) = 1;
end);

IsSchurian := function(cgr)
    local   aut;
    
    aut := AutomorphismGroup(cgr);

    return Rank(cgr) = Rank(ColorGraph(AutomorphismGroup(cgr)));
end;
