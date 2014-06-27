SplittingFunctionGraph := function(base, gamma, fixedPoint)
    local adj;
    adj := Adjacency(gamma, fixedPoint);
    return x -> x in adj;
end;

SplittingFunctionTensor := function(base, gamma, fixedPoint)
    local row;
    row := List([1..Order(gamma)], x -> List(base.basis, y ->
                   [gamma!.entries[x][y][fixedPoint],
                    gamma!.entries[x][x][fixedPoint],
                    gamma!.entries[x][fixedPoint][x],
                    gamma!.entries[x][fixedPoint][y],
                    gamma!.entries[x][fixedPoint][fixedPoint],
                    gamma!.entries[y][x][fixedPoint],
                    gamma!.entries[y][fixedPoint][x]]
                   ));
    return x -> row[x];
end;

SplittingFunctionMatrix := function( base, gamma, fixedPoint )
    return x -> gamma[fixedPoint][x];
end;

SplittingFunctionCgr := function(base, gamma, fixedPoint )
    local row;
    row := RowOfColorGraph( gamma, fixedPoint );
    return x -> row[x];
end;


IsGraphAutomorphism := function(gamma, gen)
    Info(InfoCocoAutomorphism, 1, "IsGraphAutomorphism");
    return ForAll([1..gamma.order], x -> 
                  Adjacency(gamma, x^gen) = 
                  OnSets(Adjacency(gamma,x),gen));
end;

IsMatrixAutomorphism := function(gamma, gen)
    Info(InfoCocoAutomorphism, 1, "IsMatrixAutomorphism");
    return  ForAll([1..Length(gamma)], x ->
                   gamma[x^gen] = Permuted(gamma[x], gen));
end;

IsMatrixIsomorphism := function(gamma1, gamma2, g)
    return ForAll([1..Length(gamma1)], x ->
                  ForAll([1..Length(gamma1)], y ->
                         gamma2[x][y] = gamma1[x^g][y^g]));
end;

IsTensorAutomorphism := function( gamma, gen )
    local i, j, k, result;
    Info(InfoCocoAutomorphism, 1, "IsTensorAutomorphism");
    for i in [1..Order(gamma)] do
        for j in [1..Order(gamma)] do
            for k in [1..Order(gamma)] do
                if gamma!.entries[i][j][k] <> 
                   gamma!.entries[ i^gen][ j^gen][ k^gen] then
                    return false;
                fi;
            od;
        od;
    od;
    result := true;
    return result;
end;

IsTensorIsomorphism := function( gamma1, gamma2, gen )
    local i, j, k, result;
    Info(InfoCocoAutomorphism, 1, "IsTensorIsomorphism");
    for i in [1..Order(gamma1)] do
        for j in [1..Order(gamma1)] do
            for k in [1..Order(gamma1)] do
                if gamma2!.entries[i][j][k] <> 
                   gamma1!.entries[ i^gen][ j^gen][ k^gen] then
                    return false;
                fi;
            od;
        od;
    od;
    result := true;
    return result;
end;

IsCgrIsomorphism := function(gamma1, gamma2, gen)
    local   i,  j;
    Info(InfoCocoAutomorphism, 1, "IsCgrIsomorphism");
    return  ForAll([1..Order(gamma1)], x ->
                   RowOfColorGraph(gamma2, x^gen) =
                   Permuted(RowOfColorGraph(gamma1, x), gen));
end;

      

IsCgrAutomorphism := function( gamma, gen )
    return IsCgrIsomorphism( gamma, gamma, gen );
end;

IsWeakAutomorphism := function(gamma, gen)
    local   order,  colorImage, color1, i, j, color2, row1, row2;    
    Info(InfoCocoAutomorphism, 1, "IsWeakAutomorphism");
    order := Order(gamma);
    if OnSets([1..order], gen) <> [1..order] then
        return false;
    fi;
    colorImage := function(color)
        return (color+order)^gen - order;
    end;
    for i in [1..order] do
        row1 := RowOfColorGraph(gamma, i);
        row2 := RowOfColorGraph(gamma, i^gen);
        for j in [1..order] do
            color1 := row1[j];
            color2 := row2[j^gen];
            if colorImage(color1) <> color2 then
                Info(InfoCocoAutomorphism, 1, false);
                return false;
            fi;
        od;
    od;
    Info(InfoCocoAutomorphism, 1, true);
    return true;
end;

IsWeakIsomorphism := function(gamma1, gamma2, gen)
    local   order,  colorImage, color1, i, j, color2;    
    Info(InfoCocoAutomorphism, 1, "IsWeakIsomorphism");
    order := Order(gamma1);
    if OnSets([1..order], gen) <> [1..order] then
        return false;
    fi;
    colorImage := function(color)
        return (color+order)^gen - order;
    end;
    for i in [1..order] do
        for j in [1..order] do
            color1 := EdgeColorOfColorGraph(gamma2, i, j);
            color2 := EdgeColorOfColorGraph(gamma1, i^gen, j^gen);
            if colorImage(color1) <> color2 then
                return false;
            fi;
        od;
    od;
    return true;
end;



IsInvariant := function(obj)
    if not IsRecord(obj) then
       return false;
    fi;
    if not IsBound(obj.isInvariant) then
       return false;
    fi;
    return obj.isInvariant;
end;

InstallGlobalFunction(MakeInvariant,
        function(gamma)
    local splittingFunction, isAutomorphism, order,
          initialSplit, isIsomorphism;
        Info(InfoCocoAutomorphism, 1, "MakeInvariant");
    initialSplit := x -> 0;
    isIsomorphism := fail;
    if IsGraph(gamma) then
        splittingFunction := SplittingFunctionGraph;
        isAutomorphism := IsGraphAutomorphism;
        order := gamma.order;
    elif IsTensor(gamma) then
        splittingFunction := SplittingFunctionTensor;
        isAutomorphism := IsTensorAutomorphism;
        isIsomorphism := IsTensorIsomorphism;	
        order := Order(gamma);
    elif IsList(gamma) then
        splittingFunction := SplittingFunctionMatrix;
        isAutomorphism := IsMatrixAutomorphism;
        isIsomorphism := IsMatrixIsomorphism;
        order := Length(gamma);
    else
        splittingFunction := SplittingFunctionCgr;
        isAutomorphism := IsCgrAutomorphism;
        isIsomorphism := IsCgrIsomorphism;
        order := Order(gamma);
    fi;
    return rec(isInvariant := true,
               order := order,
               gamma := gamma,
               SplittingFunction := splittingFunction,
               IsAutomorphism := isAutomorphism,
               IsIsomorphism := isIsomorphism,
               initialSplit:= initialSplit);
end);


NumberOfCells := function( base )
    return Length( base.lengths );
end;


GetCell := function( base, i)
  return base.points{[base.firsts[i]..
                 base.firsts[i] + base.lengths[i] - 1]};
end;


GetCells := function( base )
    local result, i, cell;
    result := [];
    for i in [1..NumberOfCells( base ) ] do
        Add( result, base.points{[base.firsts[i]..
                base.firsts[i] + base.lengths[i] - 1]} );
    od;
    return result;
end;

WeakSplittingFunction := function(base, gamma, fixedPoint)
    local   basis,  order,  fixedVertices,  fixedColors, 
            row, cells, vertexInvariant, colorInvariant, 
            invariant, color, tensor;
    Info(InfoCocoAutomorphism, 1, "WeakSplittingFunction");
    order := Order(gamma);
    cells := GetCells(base);
    if fixedPoint <= order then # fixing a vertex
        row := RowOfColorGraph(gamma, fixedPoint)+order;
        vertexInvariant := List(row, x -> PositionProperty(cells, y -> x in y));
        colorInvariant := 
          List([1..Rank(gamma)], 
               color -> Filtered([1..Length(cells)], cell ->
                       ForAny(cells[cell], z -> z <= order and row[z] = color+order)));
        invariant := Concatenation(vertexInvariant, colorInvariant);
        return x -> invariant[x];
    else # fixing a color
        basis := base.basis;
        color := fixedPoint-order;
        fixedVertices := Filtered(basis, x -> x < order);
        vertexInvariant := List([1..order], x -> 0);
        tensor := StructureConstantsOfColorGraph(gamma);
        fixedColors := Filtered(base.basis, x -> x > order)-order;
        fixedPoint := fixedPoint - order;
        colorInvariant := List([1..Order(tensor)], x -> List(fixedColors, y ->
                       [tensor!.entries[x][y][fixedPoint],
                        tensor!.entries[x][x][fixedPoint],
                        tensor!.entries[x][fixedPoint][x],
                        tensor!.entries[x][fixedPoint][y],
                        tensor!.entries[x][fixedPoint][fixedPoint],
                        tensor!.entries[y][x][fixedPoint],
                        tensor!.entries[y][fixedPoint][x]]
                       ));
        invariant := Concatenation(vertexInvariant, colorInvariant);
        return x -> invariant[x];
    fi;
    return x -> x = fixedPoint ;
end;
InstallGlobalFunction(MakeWeakInvariant,
        function(gamma)
    local   splittingFunction,  order;
    order := Order(gamma);
    return rec(isInvariant := true,
               order := Order(gamma) + Rank(gamma),
               gamma := gamma,
               SplittingFunction := WeakSplittingFunction,
               IsAutomorphism := IsWeakAutomorphism,
               IsIsomorphism := IsWeakIsomorphism,
               initialSplit := x -> x <= order);
end);



SplittingFunction := function(base, gamma, fixedPoint)
    local   adj,  func,  row;
    #Info(InfoCocoAutomorphism, 1, "SplittingFunction");
    if IsInvariant(gamma) then
        return gamma.SplittingFunction(base, gamma.gamma, fixedPoint);
    elif IsRecord(gamma) then
        return SplittingFunctionGraph(base, gamma, fixedPoint);
    elif IsTensor(gamma) then
        return SplittingFunctionTensor( base, gamma, fixedPoint );
    elif IsList(gamma) then
        return SplittingFunctionMatrix( base, gamma, fixedPoint );
    else
        Error();
        return SplittingFunctionCgr(base, gamma, fixedPoint );
    fi;
    
end;

IsAutomorphism := function(gamma, gen)
    local     result,  i,  j,  k;
    #Print("checking automorphism..\n");
    Info(InfoCocoAutomorphism, 1, "IsAutomorphism");
    if IsInvariant(gamma) then
        return gamma.IsAutomorphism(gamma.gamma, gen);
    elif true then
        Error();
    elif IsRecord(gamma) then
        return IsGraphAutomorphism( gamma, gen );
    elif IsList(gamma) then
        return IsMatrixAutomorphism( gamma, gen );
    elif IsTensor(gamma) then
        return IsTensorAutomorphism( gamma, gen );
    else
        Error();
        return IsCgrAutomorphism( gamma, gen );
    fi;
end;

GetOrder := function(gamma)
    local   order;
    if IsInvariant(gamma) then
        return gamma.order;
    elif IsRecord(gamma) then
        order := gamma.order;
    elif IsList(gamma) then
        order := Length(gamma);
    else
        order := Order(gamma);
    fi;
    return order;
end;



CheckCellNumbers := function(base)
    local cells, i, j;
    cells := GetCells( base );
    for i in [1..Length(cells) ] do
        for j in cells[i] do
            if i <> base.cellNumbers[ base.points[j] ] then
                return false;
            fi;
        od;
    od;
    return true;
end;



SplitOffAtPoint := function( base, index )
    local cell, p, positionInCell, first, i;
    p := base.points[ index ];
    cell := base.cellNumbers[p];
    first := base.firsts[cell];
    if first = index then
        return;
    fi;
    positionInCell := index - first;
    Add(base.firsts, index );
    Add( base.lengths, base.lengths[cell] - positionInCell );
    base.lengths[ cell ] := positionInCell;
    for i in [index .. index+base.lengths[NumberOfCells( base ) ] - 1] do
        base.cellNumbers[base.points[i]] := NumberOfCells(base );
    od;    
end;


MySortParallel := function(toSort, other)
    local perm, length;
    length := Length(toSort);
    perm := SortingPerm(toSort);
    toSort{[1..length]} := Permuted(toSort, perm); # kludge to get the effect
    other{[1..length]} := Permuted(other, perm);   # of pass-by-reference
end;




SplitCellByFunction := function( base, cellNr, fnc )
    local points, values, cell, perm, first, length, i, allValues, 
          pointSets;
    if not IsBound( base.invariant ) then
        base.invariant := [];
    fi;
    first := base.firsts[cellNr];
    length := base.lengths[cellNr];
    if length = 1 then
        base.invariant[cellNr] := fnc(first);
        return;
    fi;
    cell := [first .. first + length - 1 ];
    points  := base.points{cell};
    values := List(points, fnc);
    MySortParallel( values, points );
    base.points{cell} := points;
    base.invariant[cellNr] := values[1];
    for i in [2..length] do
        if values[i] <> values[i-1] then
            SplitOffAtPoint( base, first + i-1 );
            base.invariant[NumberOfCells(base)] := values[i];
        fi;
    od;
end;

MakeTrivialPartition := function( order )
    local result;
    result := rec();
    result.points := [1..order];
    result.cellNumbers := List(result.points, x -> 1);
    result.lengths := [ order ];
    result.firsts := [1];
    result.basis := [];
    return result;
end;


MakeTrivialBase := function( gamma )
    local result, order;
    result := MakeTrivialPartition(GetOrder( gamma ));
    SplitCellByFunction( result, 1, gamma.initialSplit );
    return result;
end;


JoinCells := function( base )
    local first, previousCell, lastPoint, i;
    first := base.firsts[NumberOfCells(base)];
    lastPoint := first + base.lengths[NumberOfCells(base)] - 1;
    previousCell := base.cellNumbers[base.points[first-1]];
    base.lengths[previousCell] := base.lengths[previousCell] + 
                                  base.lengths[NumberOfCells(base)];
    Unbind( base.firsts[NumberOfCells(base)]);
    Unbind( base.lengths[NumberOfCells(base)]);
    for i in [first .. lastPoint] do
        base.cellNumbers[base.points[i]] := previousCell;
    od;
end;




SelectCell := function(basis, lastBase)
    local cell, i, j, k, max, l;
    Info(InfoCocoAutomorphism, 1, "select cell");
    cell := First([1..NumberOfCells(lastBase)], 
                      x -> lastBase.lengths[x] = 1 and not
                      lastBase.points[lastBase.firsts[x]] in basis);
    if cell <> fail then
        Info(InfoCocoAutomorphism, 2, "found cell of size 1");
        return cell;
    fi;
    max :=  1;
    for j in [1..NumberOfCells(lastBase)] do
        l := lastBase.lengths[j];
        if l <> 1 and l > max then
            max := l;
            cell := j;
        fi;
    od;
    Info(InfoCocoAutomorphism, 2, "found cell of size ", max);
    return cell;
end;


InitializeFullBase := function(gamma)
    local result, order;
    order := GetOrder(gamma);
    result := rec();
    result.basis := [];
    result.levels := [];
    result.cellFixed := [];
    Add(result.levels, MakeTrivialBase(gamma));
    return result;
end;

FixPoint := function(base, gamma, i)
    local result, cell, fixedIndex, fixedPoint, adj, tmp, func, row;
    result := base;
    result.invariant := [];
    cell := result.cellNumbers[i];
    fixedIndex := result.firsts[cell];
    while base.points[fixedIndex] <> i do
        fixedIndex := fixedIndex+1;
    od;
    base.points[fixedIndex] := base.points[base.firsts[cell]];
    base.points[base.firsts[cell]] := i;
    fixedPoint := i;
    Add(result.basis, fixedPoint);
    if result.lengths[cell] > 1 then
        SplitOffAtPoint(result, result.firsts[cell] + 1);
    fi;
    func := SplittingFunction( base, gamma, fixedPoint );
    for i in [1..NumberOfCells(result)] do
        if result.lengths[i] > 1 then
            SplitCellByFunction( result, i, func);
        fi;
    od;
    return result;
end;


AddLevelToFullBase := function(result, gamma)
    local lastBase, cell, point;
    Info(InfoCocoAutomorphism, 1, "adding level");
    lastBase := result.levels[Length(result.levels)];
    cell := SelectCell(result.basis, lastBase);
    point := lastBase.points[lastBase.firsts[cell]];
    Add(result.cellFixed, cell);
    Add(result.basis, point);
    Add(result.levels, FixPoint(StructuralCopy(lastBase), gamma, point));
    
end;

BuildFullBase := function(gamma)
    local result, cell, lastBase, point, max, i, j, l, min, order;
    Info(InfoCocoAutomorphism, 1, "building full base");
    order := GetOrder(gamma);
    result := InitializeFullBase(gamma);
    while NumberOfCells(result.levels[Length(result.levels)]) < order do
        AddLevelToFullBase( result, gamma );
    od;
    return result;
end;



nodesSearched := 0;

IsCompatibleBase := function(base, knownBase)
    local result;
    result :=  base.lengths = knownBase.lengths and
               base.invariant = knownBase.invariant;
    return result;
end;



ResultingIsomorphism := function(gamma1, gamma2, base, fullBase)
    local level, i, gen;
    level := Length(fullBase.cellFixed) + 1;
    
    gen := [];
    for i in [1..Length(base.points)] do
        gen[base.points[i]] := fullBase.levels[level].points[i];
    od;
    gen := PermList(gen);
    if not gamma1.IsIsomorphism(gamma1.gamma,gamma2.gamma, gen) then
        return fail;
    fi;
    return gen;
end;



FindIsomorphism := function(fullBase, base, gamma1, gamma2, level, knownGroup)
    local gen, i, cell, bookMark, result, bookmark, orbit, baseLength, stab,
          orbits;
    nodesSearched := nodesSearched + 1;
    if level > Length(fullBase.cellFixed) then
        return ResultingIsomorphism(gamma1, gamma2, base, fullBase);
    fi;
    cell := GetCells(base)[fullBase.cellFixed[level]];
    stab := Stabilizer(knownGroup, base.basis, OnTuples);
    orbits := Orbits(stab, cell);
    for orbit in orbits do
        i := orbit[1];
        bookmark := NumberOfCells(base);
        FixPoint(base, gamma2, i);
        if IsCompatibleBase( base, fullBase.levels[level+1])  then
            result := FindIsomorphism(fullBase, base, gamma1, gamma2, level+1,
                              stab);
            if result <> fail then
                return result;
            fi;
        fi;
        while NumberOfCells(base) > bookmark do
            JoinCells(base);
        od;
        Unbind( base.basis[Length(base.basis)] );
    od;
    return fail;
end;

IsomorphismObjects := function(inv1, inv2)
    local   fullBase,  base;
    fullBase := BuildFullBase(inv1);
    base := MakeTrivialBase(inv2);
    return FindIsomorphism(fullBase, base, inv1, inv2, 1, Group(()));
end;

ResultingAutomorphism := function(gamma, base, fullBase)
    local level, i, gen;
    level := Length(fullBase.cellFixed) + 1;
    gen := [];
    for i in [1..Length(base.points)] do
        gen[base.points[i]] := fullBase.levels[level].points[i];
    od;
    gen := PermList(gen);
    if not IsAutomorphism(gamma, gen) then
        return fail;
    fi;
    return gen;
end;


FindAutomorphism := function(fullBase, base, gamma, level, knownGroup)
    local gen, i, cell, bookMark, result, bookmark, orbit, baseLength, stab,
          orbits;
    Info(InfoCocoAutomorphism, 1, "FindAutomorphism ", level);
    nodesSearched := nodesSearched + 1;
    if level > Length(fullBase.cellFixed) then
        return ResultingAutomorphism(gamma, base, fullBase);
    fi;
    cell := GetCells(base)[fullBase.cellFixed[level]];
    stab := Stabilizer(knownGroup, base.basis, OnTuples);
    orbits := Orbits(stab, cell);
    for orbit in orbits do
        i := orbit[1];
        bookmark := NumberOfCells(base);
        FixPoint(base, gamma, i);
        if IsCompatibleBase( base, fullBase.levels[level+1])  then
            result := FindAutomorphism(fullBase, base, gamma, level+1,
                              stab);
            if result <> fail then
                return result;
            fi;
        fi;
        while NumberOfCells(base) > bookmark do
            JoinCells(base);
        od;
        Unbind( base.basis[Length(base.basis)] );
    od;
    return fail;
end;


InstallGlobalFunction(FindAutomorphismGroup,
        function(gamma)
    local fullBase, base, i,j,k, generators, group, length, gen, bookmark,
          options, l, goodOrbit, badOrbit, baseLength, size,
          startTime, endTime, stab, order, oldSize, 
          strongGeneratingSet, g, preimage;
    generators := [()];
    group := Group(generators);
    fullBase := BuildFullBase(gamma);
    if IsCocoObject(gamma) then
        strongGeneratingSet := 
          StrongGeneratorsStabChain(StabChain(GroupOfCocoObject(gamma),
                  fullBase.basis));
    else
        strongGeneratingSet := [];
    fi;
    l :=Length(fullBase.basis);
    size := 1;
    order := GetOrder(gamma);
    nodesSearched := 0;
    for length in [l, l-1..1] do
        if fullBase.levels[length].lengths[fullBase.cellFixed[length]] = 1
           then
            continue;
        fi;
        for g in strongGeneratingSet do
            if fullBase.basis[length] ^ g <> fullBase.basis[length] and
               ForAll([1..length-1], x ->
                      fullBase.basis[x]^g = fullBase.basis[x]) then
                Add(generators, g);
            fi;
        od;
        group := Group(generators);
        base := MakeTrivialBase( gamma );
        for i in [1..length-1] do
            FixPoint(base, gamma, fullBase.basis[i]);
        od;
        options := GetCells(base)[fullBase.cellFixed[length]];
        preimage := fullBase.basis[length];
        goodOrbit := Set(Orbit(group, fullBase.basis[length]));
        badOrbit := [];
        oldSize := Size(group);
        for i in options do
            if i in Union(goodOrbit, badOrbit) then
                continue;
            fi;
            bookmark := NumberOfCells(base);
            baseLength := Length(base.basis);
            FixPoint(base, gamma, i);
            stab := Stabilizer(group, base.basis, OnTuples);
            startTime := Runtime();
            if IsCompatibleBase( base,   fullBase.levels[length+1]) then
                gen := FindAutomorphism(fullBase, base, gamma, length+1,
                               group);
                if gen = fail then
                    badOrbit := Union(badOrbit, Orbit(group, i));
                else
                    if not gen in Group(generators) then
                        Add(generators, gen);
                        group := Group(generators);
                    fi;
                    Add(goodOrbit, i);
                    goodOrbit := Union(Orbits(group, goodOrbit));
                    badOrbit := Union(Orbits(group, badOrbit));
                fi;
            else
                badOrbit := Union(badOrbit, Orbit(group, i));
            fi;
            if not i in Union(goodOrbit, badOrbit) then
                Error();
            fi;
            while NumberOfCells(base) > bookmark do
                JoinCells(base);
            od;
            base.basis := base.basis{[1..baseLength]};
            endTime := Runtime();
        od;
        size := size * Length(goodOrbit);
    od;
    Info(InfoCocoAutomorphism, 1, "nodes searched: ", nodesSearched, "\n");
    generators := Difference(generators, [ () ] );
    return Group(generators, ());
end);


TestAutomorphism := function(invariant, gen)
    local   fullBase,  base,  i,  preimage,  image;
    fullBase := BuildFullBase( invariant );
    base := MakeTrivialBase( invariant );
    for i in [1..Length(fullBase.basis)] do
        preimage := fullBase.basis[i];
        image := preimage ^ gen;
        Print("mapping ", preimage, "->", image, "\n");
        FixPoint(base, invariant, image);
        Print("original cells: ", GetCells(fullBase.levels[i+1]), "\n");
        Print("cells now:      ", GetCells(base), "\n");
        if not IsCompatibleBase( base, fullBase.levels[i+1] ) then
            Print("not compatible\n");
            return;
        fi;
    od;
    Print("ok");
end;

IsomorphismCgr := function(gamma2, gamma1)
 local   inv1,  inv2,  isomorphism, starttime,
            base, fullBase;
    if Order(gamma1) <> Order(gamma2) then
        return fail;
    fi;
    if Rank(gamma1) <> Rank(gamma2) then
        return fail;
    fi;
    Info(InfoCocoAutomorphism, 1, "IsIsmorphicCgr, order ",
         Order(gamma1), ", rank ", Rank(gamma1));
    starttime := Runtime();
    inv1 := MakeWeakInvariant(gamma1);
    inv2 := MakeWeakInvariant(gamma2);
    fullBase := BuildFullBase(inv1);
    base := MakeTrivialBase(inv2);
    isomorphism := FindIsomorphism(fullBase, base, inv1, inv2, 1, 
                           ColorAutomorphismGroup(gamma2));
    
    Info(InfoCocoAutomorphism, 1, StringTime(Runtime()-starttime),
         " ", isomorphism <> fail);
    return isomorphism;
end;

IsomorphismTensor := function(gamma2, gamma1)
 local   inv1,  inv2,  isomorphism, starttime,
            base, fullBase;
    if Order(gamma1) <> Order(gamma2) then
        return fail;
    fi;
    Info(InfoCocoAutomorphism, 1, "IsomorphismTensor, order ",
         Order(gamma1), ", rank ", Rank(gamma1));
    starttime := Runtime();
    inv1 := MakeInvariant(gamma1);
    inv2 := MakeInvariant(gamma2);
    fullBase := BuildFullBase(inv1);
    base := MakeTrivialBase(inv2);
    isomorphism := FindIsomorphism(fullBase, base, inv1, inv2, 1, 
                           AutomorphismGroup(gamma2));
    Info(InfoCocoAutomorphism, 1, StringTime(Runtime()-starttime),
         " ", isomorphism <> fail);
    return isomorphism;
end;

IsomorphismMatrices := function(gamma1, gamma2)
    local   inv1,  inv2;
    if Length(gamma1) <> Length(gamma2) then
        return fail;
    fi;
    inv1 := MakeInvariant(gamma1);
    inv2 := MakeInvariant(gamma2);
    return FindIsomorphism(BuildFullBase(inv1),
                   MakeTrivialBase(inv2), inv1, inv2, 1, Group(()));
end;

IsIsomorphicCgr := function(gamma1, gamma2)
    local   isomorphism;
    if Order(gamma1) <> Order(gamma2) or
       Rank(gamma1) <> Rank(gamma2) then
        return false;
    fi;
    isomorphism := IsomorphismCgr(gamma1, gamma2);
    return IsPerm(isomorphism);
end;

IsomorphismClasses := function(graphs)
    local   reps,  i,  pos;
    reps := [];
    for i in [1..Length(graphs)] do
        pos := PositionProperty(reps, x -> IsIsomorphicCgr(graphs[i], x));
        if pos <> fail then
            Print();
        else
            Add(reps, graphs[i]);
        fi;
    od;
    return reps;
end;
