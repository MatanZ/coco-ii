InstallGlobalFunction(CentralizerAlgebra,
        function(arg)
    return CallFuncList(ColorGraph, arg);
end);

InstallGlobalFunction(AlgebraicAutomorphismGroup,
        function(cgr)
    return AutomorphismGroup(StructureConstantsOfColorGraph(cgr));
end);

InstallMethod(StructureConstantsOfColorGraph,
        "for color graphs",
        ReturnTrue,
        [IsColorGraph and IsColorGraphRep],
        function(cgr)
    local i, j, k, pos,
          tensor, partition, colors, row, column, twoOrbit;
    colors := [];
    partition := [];
    for i in [1..GroupRankOfColorGraph(cgr)] do
        pos := Position(colors, cgr!.orbitColors[i]);
        if pos = fail then
            Add(colors, cgr!.orbitColors[i]);
            Add(partition, [i]);
        else
            Add(partition[pos], i);
        fi;
    od;
    #Print(partition, "\n");
    tensor := NullTensor(Group(()), Rank(cgr));
    for k in [1..Rank(cgr)] do
        twoOrbit := Position(cgr!.orbitColors, k);
        twoOrbit := cgr!.twoOrbReps[twoOrbit];
        row := RowOfColorGraph(cgr, twoOrbit[1]);
        column := ColumnOfColorGraph(cgr, twoOrbit[2]);
        for pos in [1..Order(cgr)] do
            i := row[pos];
            j := column[pos];
            IncrementEntryOfTensor(tensor, i, j, k);
        od;
    od;
    SetMates(tensor, TranspositionOnColors(cgr));
    MakeImmutable(tensor);
    return tensor;
end);

InstallMethod(StructureConstantsOfColorGraph,
        "for color graphs",
        ReturnTrue,
        [IsColorGraph and IsColorGraphMatrixRep],
        function(cgr)
    local   x,  y,  matrix,  k,  z,  i,  j,  result, matrices, order;
    order := Order(cgr);
    matrices := [];
    for x in [1..order] do
        for y in [1..order] do
            matrix := NullMat(Rank(cgr), Rank(cgr));
            k := cgr!.matrix[x][y];
            for z in [1..order] do
                i := cgr!.matrix[x][z];
                j := cgr!.matrix[z][y];
                matrix[i][j] := matrix[i][j] + 1;
            od;
            if IsBound(matrices[k]) then
                if matrices[k] <> matrix then
                    return fail;
                fi;
            else
                matrices[k] := matrix;
            fi;
        od;
    od;
    result := NullTensor(Group(()), Rank(cgr));
    for k in [1..Rank(cgr)] do
        for i in [1..Rank(cgr)] do
            for j in [1..Rank(cgr)] do
                SetEntryOfTensor(result, i, j, k, matrices[k][i][j]);
            od;
        od;
    od;
    return result;
end);

InstallMethod(IsCoherentAlgebra,
        "for color graphs",
        ReturnTrue,
        [IsColorGraph],
        0,
        function(cgr)
    if StructureConstantsOfColorGraph(cgr) = fail then
        return false;
    else
        return true;
    fi;
end);

InstallMethod(CoherentSubalgebra, 
        "for color graphs and partitions", 
        ReturnTrue,
        [IsColorGraph and IsColorGraphRep, IsList],
        0,
        function(cgr, partition)
    local partitionNumber, i, j, result, twoOrbReps, originalColor,
          newColor;
    result := ColorGraph(GroupOfCocoObject(cgr),
                      [1..Order(cgr)], OnPoints, true);
    twoOrbReps := result!.twoOrbReps;
    for i in twoOrbReps do
        originalColor := EdgeColorOfColorGraph(cgr, i[1], i[2]);
        newColor := PositionProperty(partition, x -> 
                            originalColor in x);
        SetEdgeOrbitColorOfColorGraph(result, i[1], i[2], newColor);
    od;
    #od;
    return result;
end);

InstallMethod(CoherentSubalgebra, 
        "for color graphs and partitions", 
        ReturnTrue,
        [IsColorGraph and IsColorGraphMatrixRep, IsList],
        0,
        function(cgr, partition)
    local mapping, matrix;
    mapping := List([1..Rank(cgr)], x -> PositionProperty(partition, y ->
                       x in y));
    matrix := List([1..Order(cgr)], x -> List([1..Order(cgr)], y ->
                   mapping[cgr!.matrix[x][y]]));
    return ColorGraphFromMatrix(matrix);
end);


IsReflexiveColor := function(t, i)
    return  EntryOfTensor(t, i, i, i) = 1 and
            Sum(CocoComplexProduct(t, [i],[i])) = 1;
end;

colorPartition := function(t)
    local reflexive, result, startingPart, endingPart, i;
    reflexive := ReflexiveColors(t);
    result := List(reflexive, x -> List(reflexive, y -> []));
    for i in [1..Order(t)] do
        startingPart := PositionProperty(reflexive,
                                x -> t!.entries[x][i][i] <> 0);
        endingPart := PositionProperty(reflexive,
                              x -> t!.entries[i][x][i] <> 0);
        Add(result[startingPart][endingPart], i);
    od;
    return result;
end;

MakePartition := function(tensor, set)
    local reflexive, remainder;
    reflexive := ReflexiveColors(tensor);
    remainder := Difference([1..Order(tensor)], Union(set, reflexive));
    return Set([reflexive, set, remainder]);
end;


IsCompatibleSet := function( base1, base2 )
    local set;
    if Intersection(Union(base1.base), Union(base2.base)) <> [] then
        return false;
    fi;
    if Intersection(base1.base, base2.partition) <> [] then
        return false;
    fi;
    if Intersection(base2.base, base1.partition) <> [] then
        return false;
    fi;
    if ForAny(base1.base,
              x -> not ForAny(base2.partition, y -> IsSubset(y,x)))
       then
        return false;
    fi;
    if ForAny(base2.base,
              x -> not ForAny(base1.partition, y -> IsSubset(y,x)))
       then
        return false;
    fi;
    return true;
end;

MakeBase := function(tensor, base)
    local partition, oldSize;
    
    partition := Union(base, [[1], Difference([2..Order(tensor)], Union(base))]);
    oldSize := -1;
    while Length(partition) > oldSize and IsSubset(partition, base) do
        oldSize := Length(partition);
        WLStep(tensor, partition);
    od;
    return rec( base := base, partition := partition);
end;


IsValidBase := function(base)
    return IsSubset(base.partition, base.base);
end;

OnBases :=function(x, g)
    return rec(base := OnSetsSets(x.base, g),
               partition := OnSetsSets(x.partition, g));
end;

RepActOnBases := function(G, base1, base2)
    if Collected(List(base1.base, Size)) <>
       Collected(List(base2.base, Size)) then
        return fail;
    fi;
    if
      Collected(List(base1.partition, Size))<> 
      Collected(List(base2.partition, Size)) then
        return fail;
    fi;
    return RepresentativeAction(G, base1.base, base2.base, OnSetsSets);
end;

Outdegree := function(t, color)
    local   mate,  reflexive,  start;
    
    mate := color^GetMates(t);
    reflexive := ReflexiveColors(t);
    start := First(reflexive, x -> EntryOfTensor(t, color, mate, x)
                   <> 0);
    return EntryOfTensor(t, color, mate, start);
end;

Indegree := function(t, color)
    return Outdegree(t, color^GetMates(t));
end;


PartitionFromSet := function(t, set)
    local   result;
    result := [ReflexiveColors(t), set];
    AddSet(result, Difference([1..Order(t)], Union(result)));
    return result;
end;

MakeSearchObject := function(t)
    local   result, i, j, k;
    result :=  rec(
                   t := t,
                   set := [],
                   products := List([1..Order(t)], 
                           x -> List([1..x], y -> 0)),
                   valid := List([1..Order(t)], x -> 0),
                   goodSets := [],
                   length := 0,
                   outdegrees := List([1..Order(t)], x ->
                           Outdegree(t, x)),
                   indegrees := List([1..Order(t)], x ->
                           Indegree(t, x)),
                   colorPartition := colorPartition(t),
                   startingFiber := [],
                   endingFiber := [],
                   );
    for i in [1..Length(result.colorPartition)] do
        for j in [1..Length(result.colorPartition[i])] do
            for k in result.colorPartition[i][j] do
                result.startingFiber[k] := i;
                result.endingFiber[k] := j;
            od;
        od;
    od;
    result.currentOutdegrees := List(result.colorPartition, x -> 0);
    result.currentIndegrees := List(result.colorPartition, x -> 0);
    return result;
end;

CheckGood := function(obj, length)
    local   S,  t1,  k,  x,  T,  t3,  j,  t2,  i,   out,
            indeg;
    
    # This function checks whether set{[1..length]} is
    # a good subset. It uses previously computed products
    # to speed up the computation of the product.
    if length = 0 then
        return true;
    fi;
    S := Set(obj.set{[1..length]});
    if length = 1 then
        
        obj.products[length] :=
          [obj.t!.entries[ obj.set[1]][ obj.set[1]][ obj.set[1]]];
        obj.valid[length] := 1;
    else
        for t1 in [1..length] do
            k := obj.set[t1];
            #x := First([length-1, length-2..t1], 
            #           x -> obj.valid[x] >= t1);
            x := length-1;
            if obj.valid[length-1] < t1 then
                obj.products[length][t1] := 0;
                T := [1..length];
            else
                obj.products[length][t1] := obj.products[x][t1];
                T := [x+1..length];
            fi;
            
            for t3 in T do
                j := obj.set[t3];
                for t2 in [1..t3-1] do
                    i := obj.set[t2]; 
                    obj.products[length][t1] :=
                      obj.products[length][t1] +
                      obj.t!.entries[ i][ j][ k]
                      + obj.t!.entries [j][ i][ k];
                od;
                obj.products[length][t1] :=
                  obj.products[length][t1] + 
                  obj.t!.entries[ j][ j][ k];
            od;
            obj.valid[length] := t1;
            if obj.products[length][t1] <> obj.products[length][1] then
                return true;
            fi;
            
        od;
    fi;
    if not Intersection(S,OnSets(S, GetMates(obj.t)))  in [[], S] then
        return;
    fi;
    out := Set(obj.currentOutdegrees);
    RemoveSet(out, 0);
    if Size(out) <> 1 then
        return;
    fi;
    
    indeg := Set(obj.currentIndegrees);
    RemoveSet(indeg, 0);
    if Size(indeg) <> 1 then
        return;
    fi;
    if not S in WLStabilize(obj.t, PartitionFromSet(obj.t, S)) then
        return;
    fi;
    if not IsCanonicalSetOrbitRepresentative(AutomorphismGroup(obj.t), S) then
        return;
    fi;
    Add(obj.goodSets, S);
#    Print(S, " ", obj.currentOutdegrees, " ",
#          obj.currentIndegrees, "\n");
    
    return true;
end;

AddPoint := function(obj, p)
    local   complex;
    obj.length := obj.length+1;
    obj.set[obj.length] := p;
    obj.currentOutdegrees[obj.startingFiber[p]] := 
      obj.currentOutdegrees[obj.startingFiber[p]] +
      obj.outdegrees[p];
    obj.currentIndegrees[obj.endingFiber[p]] := 
      obj.currentIndegrees[obj.endingFiber[p]] +
      obj.indegrees[p];
    #Print("adding ", p, "\n");
    CheckGood(obj, obj.length);
    return;
    
    complex := CocoComplexProduct(obj.t, obj.set{[1..obj.length]},
                       obj.set{[1..obj.length]});
    if ForAny([1..obj.valid[obj.length]], x ->
              obj.products[obj.length][x] <> complex[obj.set[x]]) then
        Error();
    fi;
end;

RemovePoint := function(obj)
    local p;
    p := obj.set[obj.length];
    #Print("removing ", p, "\n");
    obj.currentOutdegrees[obj.startingFiber[p]] := 
      obj.currentOutdegrees[obj.startingFiber[p]] -
      obj.outdegrees[p];
    obj.currentIndegrees[obj.endingFiber[p]] := 
      obj.currentIndegrees[obj.endingFiber[p]] -
      obj.indegrees[p];
    
    obj.valid[obj.length] := 0;
    obj.length := obj.length - 1;
end;

SymmetricalGoodSets := function(obj, start)
    local     t1,  k,  j,  t2,  i,  maxLength, mate;
    
    maxLength := Int((Order(obj.t)-1)/2);
    #CheckGood(obj, length);

    if obj.length >= maxLength then
        return;
    fi;
    if #obj.length <= 6 and 
      not IsCanonicalSetOrbitRepresentative(AutomorphismGroup(obj.t), 
               Set(obj.set{[1..obj.length]})) then
        #Print("reducible\n");
        return;
    fi;
#    Print(obj.set{[1..obj.length]}, "\n");
    for i in [start..Order(obj.t)] do
        mate := i^obj.t!.mates;
        if IsReflexiveColor(obj.t, i) then
            continue;
        fi;
        if mate < i then
            continue;
        fi;
        if i = mate then
            AddPoint(obj, i);
            SymmetricalGoodSets(obj,  i+1);
            RemovePoint(obj);
        else
            AddPoint(obj, i);
            AddPoint(obj, mate);
            SymmetricalGoodSets(obj,  i+1);
            RemovePoint(obj);
            RemovePoint(obj);
        fi;
    od;
end;


AntisymmetricalGoodSets := function(obj, length)
    local     t1,  k,  j,  t2,  i,   start,  maxLength, mate;
    maxLength := Int((Order(obj.t)-1)/2);
    #CheckGood(obj, length);

    if length >= maxLength then
        return;
    fi;
    # currently the canonicity test is too slow to perform it at all
    # stages
    #if length <= 6 then
        
        if not  IsCanonicalSetOrbitRepresentative(AutomorphismGroup(obj.t), 
                   Set(obj.set{[1..length]})) then
            #Print("reducible\n");
            return;
        fi;
        
#        Print(obj.set{[1..length]}, "\n");
    #fi;
    if length = 0 then
        start := 2;
    else
        start := obj.set[length]+1;
    fi;
    for i in [start..Order(obj.t)] do
        if IsReflexiveColor(obj.t, i) then
#            Print("reflexive\n");
            continue;
        fi;
        mate := i^obj.t!.mates;
        if mate = i then
            continue;
        fi;
        if mate in obj.set{[1..length]} then
            continue;
        fi;
        if length = 0 and mate < i then
            continue;
        fi;
        AddPoint(obj, i);
        #if length = 0 and i^obj.t!.mates < i then
        #    continue;
        #fi;
        #obj.set[length+1] := i;
        AntisymmetricalGoodSets(obj, length+1);
        RemovePoint(obj);
    od;
end;


AllGoodSets := function(t)
    local   obj,  starttime,  endtime,  sym;

    
    obj := MakeSearchObject(t);
    
    starttime := Runtime();
    Info( InfoTensor, 1, "automorphism group of size ", 
          Size(AutomorphismGroup( t )) );
    SymmetricalGoodSets(obj,  1);
    endtime := Runtime();
    sym := Length(obj.goodSets);
    Info(InfoTensor, 1, "found ", Length(obj.goodSets), " symmetrical good sets in ", StringTime(endtime-starttime));
    starttime := Runtime();
    AntisymmetricalGoodSets(obj, 0);
    endtime := Runtime();
    obj.goodSets := Set(obj.goodSets);
    Info(InfoTensor, 1, "found ", Length(obj.goodSets) - sym, 
          " antisymmetrical good sets in ", StringTime(endtime-starttime));
    obj.goodSets := Filtered(obj.goodSets, 
                            x -> Length(x) *2 < Order(t));
    return obj.goodSets;
end;


Mergings := function(arg)
    local tensor, goodSets, partitions, blist, allGoodSets, allMergings, bases,
          base, orbit, candidates, cand, newBase,  G,
          i, reps, gOnGoodSets, mergings, startTime, filter;
    startTime := Runtime();
    tensor := arg[1];
    if Length(arg) > 1 then
        filter := arg[2];
    else
        filter := function(t, partition)
            return true;
        end;
    fi;
    
    G := AutomorphismGroup(tensor);
    goodSets := AllGoodSets(tensor);

    Info(InfoTensor, 1, "found ", Length(goodSets), " goodSets in ",
         StringTime(Runtime()-startTime));
    partitions := List(goodSets, x -> MakePartition(tensor, x));

    partitions := List(partitions, x -> WLStabilize(tensor, x));
    blist := List([1..Length(goodSets)], x -> goodSets[x] in partitions[x]);
    goodSets := ListBlist(goodSets, blist);
    partitions := ListBlist(partitions, blist);
    Info(InfoTensor, 1, "found ", Length(goodSets), " real good sets");
    bases := [];
    bases[1] := List(goodSets, x -> MakeBase(tensor, [x]));
    bases[1] := Filtered(bases[1], x -> filter(tensor, x.partition));
    bases[1] := Orbits(G, bases[1], OnBases);
    allGoodSets := Union(bases[1]);
    gOnGoodSets := Action(G, allGoodSets, OnBases);
    bases[1] := List(bases[1], x -> x[1]);
    Info(InfoTensor, 1, "found ", Length(bases[1]), " bases of length 1 after ",
         StringTime(Runtime()-startTime));
    bases[2] := [];
    for base in bases[1]  do
        candidates := Filtered(allGoodSets, x -> IsCompatibleSet(base, x));
        candidates := Orbits(Stabilizer(G, base, OnBases), candidates, OnBases);
        for cand in candidates do
            newBase := MakeBase(tensor, Union(base.base, cand[1].base));
            if IsValidBase(newBase) and filter(tensor, newBase.partition) then
                Add(bases[2], newBase);
            fi;
        od;
    od;
    Info(InfoTensor, 1,Length(bases[2]), " bases of length 2, ", StringTime(Runtime()-startTime));
    reps := [];
    for i in bases[2] do
        if not ForAny(reps, x -> 
                   RepActOnBases(G, x, i)  <> fail)
           then
            Add(reps, i);
        fi;
    od;
    
    bases[2] := reps;
    Info(InfoTensor, 1,Length(bases[2]), " inequivalent bases of length 2, ", StringTime(Runtime()-startTime));
    i := 2;
    while bases[i] <> [] do
        bases[i+1] := [];
        for base in bases[i] do
            candidates := Filtered(allGoodSets, x -> IsCompatibleSet(base, x));
            candidates := Filtered(candidates, x -> x.base[1] > base.base[i]);
            for cand in candidates do
                newBase := MakeBase(tensor, Union(base.base, cand.base));
                if IsValidBase(newBase) and filter(tensor, newBase.partition) then
                    if not ForAny(Combinations(base.base, Length(base.base)-1),
                               x -> MakeBase(tensor, Union(x, cand.base)).partition = newBase.partition)
                       then
                        Add( bases[i+1], newBase);
                    fi;
                fi;
            od;
            
        od;
        Info(InfoTensor, 1, Length(bases[i+1]), " bases of length ", 
             i+1, ", ", StringTime(Runtime()-startTime));
        reps := [];
        for base in bases[i+1] do
            if not ForAny(reps,x -> RepActOnBases(G, base, x) <> fail) then
                Add(reps, base);
            fi;
        od;
        bases[i+1] := reps;
        Info(InfoTensor, 1, Length(bases[i+1]), " inequivalent bases of length ",
             i+1, ", ", StringTime(Runtime()-startTime));
        i := i+1;
    od;
    mergings := Union(List(bases, x -> List(x, y -> y.partition)));
    reps := [];
    for i in mergings do
        if ForAny(reps, x -> 
                  Collected(List(x, Size)) = Collected(List(i,Size))
                  and
                  RepresentativeAction(G, x, i, OnSetsSets) <> fail)
           
           then
            continue;
        fi;
        Add(reps, i);
    od;
    Info(InfoTensor, 1, StringTime(Runtime()-startTime),
         " found ", Length(reps), " mergings");
    return reps;
end;




InstallMethod(CoherentSubalgebras,
        "for color graphs",
        ReturnTrue,
        [IsColorGraph],
        0,
        function( cgr )
    return CoherentSubalgebras(cgr, ReturnTrue);
end);
InstallOtherMethod(CoherentSubalgebras,
        "for color graphs",
        ReturnTrue,
        [IsColorGraph, IsFunction],
        0,
        function( cgr, filter )
    local   tensor,  mergings,  colorGroup,  aaut;


    tensor := StructureConstantsOfColorGraph(cgr);
    mergings := Mergings(tensor, filter);
    # apply color group
    colorGroup := ColorAutomorphismGroup(cgr);
    colorGroup := Action(colorGroup, [1..Rank(cgr)] + Order(cgr));
    aaut := AutomorphismGroup(tensor);
    if colorGroup <> aaut then
#        Print("blowing up orbits; old number: ", Length(mergings), "\n");
        mergings := Concatenation(Orbits(aaut, mergings, OnSetsSets));
        mergings := Orbits(colorGroup, mergings, OnSetsSets);
        mergings := List(mergings, Minimum);
#        Print("new number: ", Length(mergings), "\n");
    fi;
    Sort(mergings, function(x,y)
        return Length(x) > Length(y);
    end);
    
    return List(mergings, x -> CoherentSubalgebra(cgr, x));
end);

InstallOtherMethod(IsPrimitive, 
        "for color graphs", 
        ReturnTrue,
        [IsColorGraph],
        0,
        function(cgr)
    local graphs, tensor, i, j, k, order;
    
    tensor := StructureConstantsOfColorGraph(cgr);
    order := Order(tensor);
    graphs := List([1..order], x -> BaseGraphOfColorGraph(cgr, x));

    return ForAll(graphs{[2..Length(graphs)]}, IsConnectedGraph);
end);

InstallMethod(TranspositionOnColors,
        "for color graphs",
        [IsColorGraph],
        function(cgr)
    local   result,  i,  rep,  img,  col;

    result := [];
    for i in [1..Length(cgr!.twoOrbReps)] do
        col := cgr!.orbitColors[i];
        rep := cgr!.twoOrbReps[i];
        img := EdgeColorOfColorGraph(cgr, rep[2], rep[1]);
        if IsBound(result[col]) and img <> result[col] then
            return fail;
        fi;
        result[col] := img;
    od;
    return PermList(result);
end);

PrintMergingInfo := function(sub)
    local   merging,  row,  subdegrees,  i;
    merging := List(sub!.colorNames, x -> 
                    Filtered([1..Length(sub!.orbitColors)], 
                            y -> sub!.orbitColors[y] = x));
    row := RowOfColorGraph(sub,1);
    subdegrees := List(Collected(row), x -> x[2]);
    subdegrees := Collected(subdegrees);
    if IsPrimitive(sub) then
        Print("primitive ");
    fi;
    Print("merging of rank ", Rank(sub), "\n");
    Print("subdegrees: ");
    for i in subdegrees do
        Print(i[1], "^", i[2], " ");
    od;
    Print("\n");
    Print("merging: ", merging-1, "\n");
    if Rank(sub) < 6 then
        Display(StructureConstantsOfColorGraph(sub));
    fi;
    Print("\n");
end;

