#################################################################
#W  $Id: tensor.gi,v 1.1.1.1 2004/04/01 06:20:40 sven Exp $
##
##  $Log: tensor.gi,v $
##  Revision 1.1.1.1  2004/04/01 06:20:40  sven
##  Imported sources
##
##  Revision 1.2  2002/02/19 21:57:55  sven
##  moved BuildObject up to CocoObject
##
##  Revision 1.1.1.1  2002/02/17 22:06:37  sven
##  Imported sources
##
##  Revision 1.1  2000/02/10 17:52:13  reichard
##  Initial revision
##
##
##

Revision.tensor_gi :=
  "@(#)$Id: tensor.gi,v 1.1.1.1 2004/04/01 06:20:40 sven Exp $";
##  
## 
##################################################
##  <#GAPDoc Label="Tensors">
##  <Chapter> <Heading>Tensors</Heading>
##  <Section> <Heading>Representing tensors</Heading>
##  <#Include Label="IsTensor"/>
##  </Section>
##  </Chapter>
##  <#/GAPDoc> 
#################################################################
#R  IsTensorRep
##
DeclareRepresentation( "IsTensorRep", IsCocoObjectRep,
        ["mates",
         "entries"       # the entries of the tensor
         #"reflexive"
         ]);

############################################
#F  NullTensor( <group>, <order> )
##    returns a null tensor with the given group and order
##

InstallGlobalFunction(NullTensor,
        
function(group, order)
    local obj;
    obj := CocoObjectTemplate(group, [1..order], OnPoints);
    obj.entries := List([1..order], x -> List([1..order], y -> List([1..order], z -> 0)));
      #HashedMap(x -> x*[ 101, 211, 503 ] , x -> x*x);
    return Objectify(NewType(TensorFam, IsTensorRep and IsMutable), obj);
    
end);

InstallGlobalFunction(DenseTensorFromEntries,
        
function(group, order, entries)
    local obj;
    obj := CocoObjectTemplate(group, [1..order], OnPoints);
    obj.entries := entries;
    
    return Objectify(NewType(TensorFam, IsTensorRep and IsMutable), obj);
    
end);


#################################################################
#M  EntryOfTensor( <tensor>, <i>, <j>, <k> )
##   returns an entry of a tensor
##
InstallMethod(EntryOfTensor,
        ReturnTrue,
        [IsTensor and IsTensorRep,  
         IsPosInt, 
         IsPosInt, 
         IsPosInt],
        0,
        function(arg)
    local result;
    return arg[1]!.entries[arg[2]][arg[3]][arg[4]];
    if Length(arg) = 2 then
        result :=  arg[1]!.entries[arg[2][1]][arg[2][2]][arg[2][3]];
        #GetValue(arg[1]!.entries,arg[2]);
    else
        result := arg[1]!.entries[arg[2]][arg[3]][arg[4]];#GetValue( arg[1]!.entries, [arg[2],arg[3],arg[4]]);
    fi;
    if result = fail then
        return 0;
    fi;
    return result;
end);
############################################
#F ReflexiveColors( <tensor> )
##  
InstallGlobalFunction( ReflexiveColors,
        function( tensor )
    local result;
    result := Filtered([1..Order( tensor )],
                      x -> EntryOfTensor( tensor, x, x, x ) = 1);
    result := Filtered(result, x -> Sum(CocoComplexProduct(tensor, [x], [x]))=1);
    return result;
end);

#################################################################
#M  SetEntryOfTensor( <tensor>, <i>, <j>, <k> )
##    changes an entry of a tensor
##
InstallMethod(SetEntryOfTensor,
        ReturnTrue,
        [IsTensor and IsTensorRep and IsMutable, 
         IsPosInt, 
         IsPosInt, 
         IsPosInt,
         IsObject],
        0,
        function(arg)
    if Length(arg) = 3 then
        arg[1]!.entries[arg[2][1]][arg[2][2]][arg[2][3]] := arg[3];
        #SetValue(arg[1]!.entries,arg[2], arg[3]);
    else
        arg[1]!.entries[arg[2]][arg[3]][arg[4]] := arg[5];
        #SetValue(arg[1]!.entries, [arg[2],arg[3],arg[4]], arg[5]);
    fi;
end);
##################################################
#M IncrementEntryOfTensor( <tensor>, <i>, <j>, <k> )
##
InstallMethod(IncrementEntryOfTensor,
        ReturnTrue,
        [IsTensor and IsTensorRep and IsMutable, 
         IsPosInt, 
         IsPosInt, 
         IsPosInt],
        0,
        function(tensor, i, j, k)
    SetEntryOfTensor(tensor, i, j, k,
            EntryOfTensor(tensor, i, j, k) +1);
end);

##################################################
#M SetMates( <tensor>, <permutation> )
##
InstallGlobalFunction(SetMates, function(tensor, perm)
    tensor!.mates := perm;
end);
##################################################
#M GetMates( <tensor> )
##
InstallGlobalFunction(GetMates, function(tensor)
    local reflexive, i, start, finish, mates, outvalencies;
    if IsBound(tensor!.mates) then
        return tensor!.mates;
    fi;
    mates := [];
    outvalencies := [];
    reflexive := ReflexiveColors(tensor);
    for i in [1..Order(tensor)] do
        start := First(reflexive, x -> tensor!.entries[x][i][i] = 1);
        finish := First(reflexive, x -> tensor!.entries[i][x][i] = 1);
        mates[i] := First([1..Order(tensor)], 
                          j -> tensor!.entries[i][j][start] <> 0);
        outvalencies[i] := tensor!.entries[i][mates[i]][start];
        #Print(i, ": ", [start, finish], " ", mates[i],  " valency ",
        #      tensor!.entries[i][mates[i]][start], "\n");
    od;
    tensor!.mates := PermList(mates);
    tensor!.outvalencies := outvalencies;
    return tensor!.mates;
end);

#################################################################
#F  CollapsedTensor( <tensor>, <partition> )
##    returns the collapsed tensor if it exists,
##            fail otherwise
##
InstallGlobalFunction(CollapsedTensor,
        function(tensor, partition)
    local i, j, k, l, m, n, set,
          collapsedTensor, order, product;
    if not IsTensor(tensor) or
       not IsList(partition) or
       ForAny(partition, x -> 
              not IsList(x) or
              ForAny(x, y -> not IsPosInt(y))) then
        Error("usage: CollapsedTensor( <tensor>, <partition> )\n");
        return;
    fi;
    order := Length(partition);
    collapsedTensor := NullTensor(Group(()), order);
    for i in [1..order] do
        for j in [1..order] do
            product := List([1..Order(tensor)], x -> 0);
            for k in [1..Length(product)] do
                for m in partition[i] do
                    for n in partition[j] do
                        product[k] := product[k] + 
                                      EntryOfTensor(tensor, m, n, k);
                    od;
                od;
            od;
            for l in [1..order] do
                set := Set(product{partition[l]});
                if Size(set) > 1 then
                    return fail;
                else
                    SetEntryOfTensor(collapsedTensor, i, j, l, set[1]);
                fi;
            od;
        od;
    od;
    return collapsedTensor;
end);

#################################################################
#M  ViewObject( <tensor> )
##   
InstallMethod(ViewObj, 
        "for tensors",
        ReturnTrue,
        [IsTensor],
        0,
        function(x)
    Print("<");
    if IsMutable(x) then
        Print("mutable ");
    fi;
    Print("tensor of order ", Order(x), ">");
end);

#################################################################
#M  PrintObject( <tensor> )
##   
InstallMethod(PrintObj, 
        "for tensors",
        ReturnTrue,
        [IsTensor],
        0,
        function(x)
    Print("DenseTensorFromEntries( ",
          GroupOfCocoObject(x), ", ",
          Order(x), ", ", x!.entries,
          " )");
end);
##  
PrintWidth := function(width, number)
    local i, l;
    if number = 0 then
        l := 0;
    else
        l := LogInt(number, 10);
    fi;
    for i in [l+2..width] do
        Print(" ");
    od;
    if (number = 0) then
       Print("-");
    else
        Print(number);
    fi;
end;

##  
InstallMethod( Display,
        "for tensors",
        ReturnTrue,
        [IsTensor],
        0,
        function(x)
    local i, j, k, max, width, totalWidth;
    max := 0;
    for i in [1..Order(x)] do
        for k in [1..Order(x)] do
            for j in [1..Order(x)] do
                max := Maximum(max, EntryOfTensor(x, i, j, k));
            od;
        od;
    od;
    width := LogInt(max, 10) + 3;
    totalWidth := Order(x) * width + 1;
    Print("+", List([1..totalWidth], x -> '-'), "+\n");
    for i in [1..Order(x)] do
        for k in [1..Order(x)] do
            Print("|");
            for j in [1..Order(x)] do
                PrintWidth(width, EntryOfTensor(x, i, j, k));
            od;
            Print(" |\n");
        od;
        Print("+", List([1..totalWidth], x -> '-'), "+\n");
    od;
end);

  
##################################################
#M  AutomorphismGroup( <tensor> )
##################################################
InstallOtherMethod(AutomorphismGroup, 
        "for tensors of structure constants",
        ReturnTrue,
        [IsTensor],
        0,
        function(t)
    local inv, aut;
    inv := MakeInvariant(t);
    aut := FindAutomorphismGroup(inv);
    return aut;
end);
##################################################
#M  AutGroupOfCocoObject( <tensor> )
##################################################
InstallMethod(AutGroupOfCocoObject, 
        "for tensors of structure constants",
        ReturnTrue,
        [IsTensor],
        0,
        function(t)
    local inv, aut;
    Print("#I Warning: AutGroupOfCocoObject is obsolete; use AutomorphismGroup instead\n");
    return AutomorphismGroup(t);
end);
##################################################
#M  MergingsOfTensor( <p> )
##################################################
InstallMethod(MergingsOfTensor, 
        "for tensors of structure constants",
        ReturnTrue,
        [IsTensor],
        0,
        function(t)
    local goodSets, set, partition, stablePartitions;
    stablePartitions := [];
    goodSets := GoodSets(t);
    for set in Union(goodSets.symmetrical, goodSets.asymmetrical) do
        partition := Set([[1],set, Difference([2..Order(t)],set)]);
        AddSet(stablePartitions, WLStabilize(t, partition));
    od;
    return List(stablePartitions, x -> [x,CollapsedTensor(t, x)]);
end);
##################################################
#F  IsGoodSet
##################################################
InstallGlobalFunction(IsGoodSet, function(tensor, set)
    local i, j, k, result, pastResults;
    pastResults := [];
    for k in set do
        result := 0;
        for i in set do
            for j in set do
                result := result + EntryOfTensor(tensor, i, j, k);
            od;
        od;
        AddSet(pastResults, result);
        if Size(pastResults) > 1 then
            return false;
        fi;
    od;
    return true;
end);
##################################################
#F  CocoComplexProduct
##################################################
InstallGlobalFunction(CocoComplexProduct, function(tensor, set1, set2)
    local i, j, k, product;
    product := 0*[1..Order(tensor)];
    for i in set1 do
        for j in set2 do
            #for k in [1..Order(tensor)] do
            #    product[k] := product[k] + EntryOfTensor(tensor, i, j, k);
            #od;
            product := product + tensor!.entries[i][j];
        od;
    od;
    return product;
end);
##################################################
#F  WLStep
##################################################
InstallGlobalFunction(WLStep, function(tensor, partition)
    local i, j, k, product, values, done,
          difference, intersection, image;
    done := false;
    for i in partition do
        image := OnSets(i, Mates(tensor));
        intersection := Intersection(i, image);
        difference := Difference(i, image);
        if intersection <> [] and difference <> [] then
            RemoveSet(partition, i);
            UniteSet(partition, [intersection, difference]);
        fi;
    od;
    for i in partition do
        for j in partition do
            product := CocoComplexProduct(tensor, i, j);
            for k in partition do
                values := Set(product{k});
                if Size(values) > 1 then
                    RemoveSet(partition, k);
                    UniteSet(partition, 
                            List(values, 
                                 x -> Filtered(k, y ->
                                         product[y] = x)));
                    return;
                fi;
            od;
            if done then
                return;
            fi;
        od;
    od;
    return partition;
end);
##################################################
#F  WLStabilize( <tensor>, <partition> )
##################################################
InstallGlobalFunction(WLStabilize, function(tensor, partition)
    local oldSize;
    oldSize := -1;
    while oldSize < Size(partition) do
        oldSize := Size(partition);
        WLStep(tensor, partition);
        Info(InfoTensor, 2, Length(partition));
    od;
    return partition;
end);

##################################################
#F  GoodSets( <tensor> )
##################################################
InstallGlobalFunction(GoodSets, function(tensor)
    local g, mates, symsets, asymsets, set, sor, i;
    g := AutomorphismGroup(tensor);
    mates := GetMates(tensor);
    symsets := [];
    asymsets := [];
    i := 0;
    
    sor := SetOrbitRepresentatives(g, [2..Order(tensor)]);
    Info(InfoTensor, 1, "need to filter ", Size(sor), " sets");
    for set in sor do
        i := i+1;
        #Info(InfoTensor, 2,i, "/", size, ", ", set);
        if set = OnSets(set, mates) and
           IsGoodSet(tensor, set) then
            Add(symsets, set);
        elif Intersection(set, OnSets(set, mates)) = [] and
          IsGoodSet(tensor, set) then
            Add(asymsets, set);
        fi;
    od;
    Info(InfoTensor, 1, Length(symsets), " symmetrical and ",
          Length(asymsets), " asymmetrical good sets.\n");
    return rec(symmetrical := symsets,
               asymmetrical := asymsets);
end);

##################################################
#F  SymmetricGoodSets( <tensor> )
##################################################

InstallGlobalFunction(SymmetricGoodSets, function(tensor)
    local g, points, mates, sor, i, size;
    g := AutomorphismGroup(tensor);
    mates := GetMates(tensor);
    points := Filtered([2..Order(tensor)],
                      x -> x^mates = x);
    sor := SetOrbitRepresentatives(g, points);
    size := Size(sor);
    Info(InfoTensor, 1, "need to filter ", size, " sets");
    i := 0;
    return Filtered(sor, function(x)
        i := i+1;
        Info(InfoTensor, 2,i, "/", size, ", ", x);
        return IsGoodSet(tensor, x);
    end);
    
end);
############################################
#F  AllMergings( <tensor> )
############################################
InstallGlobalFunction(AllMergings, function(tensor)
    local i, j, k, goodSets, solutions, backtrack, newSets;
    backtrack := function(sets, merging, candidates)
        local i, j, k, rest, toSplit, newCandidates;
        #if ForAny(merging, x -> not x in goodSets) then
        #    Error();
        #fi;
        Add(solutions, merging);
        Info(InfoTensor,1, "found solution ", sets);
        Info(InfoTensor, 1, "merging: ", merging);
        toSplit := First(merging, x -> (not x in sets) and (not x in candidates));
        if toSplit <> fail then
            candidates := Filtered(candidates, x ->
                                  IsSubset(toSplit, x) and (x <> toSplit));
        else
            
            candidates := Filtered(candidates, 
                                  x -> Intersection(x, Union(sets)) = []);
            candidates := Filtered(candidates, x ->
                                  (not x in merging) and
                                  ForAny(merging, y -> IsSubset(y,x)));
        fi;
        Info(InfoTensor,2, "candidates: ", candidates); 
        newCandidates := ShallowCopy(candidates);
        Info(InfoTensor, 2, Collected(Concatenation(candidates)));
        #candidates := Filtered(candidates, x -> candidates[1][1] in x);
        Info(InfoTensor,2, "candidates: ", candidates);
        Info(InfoTensor,1, Length(candidates), " candidates left");
        for i in candidates do
            RemoveSet(newCandidates, i);
            newSets := ShallowCopy(sets);
            Add(newSets, i);
            rest := Difference([2..Order(tensor)], Union(newSets));
            merging := WLStabilize(tensor, Union(newSets, [rest]));
            if ForAll(newSets, set -> ForAny(merging, class ->
                       IsSubset(class, set))) then
               backtrack(newSets, merging, newCandidates);
            fi;
        od;
    end;
    
    goodSets := GoodSets(tensor);
    goodSets := Union(Orbits(AutomorphismGroup(tensor),
                       Union(goodSets.symmetrical, goodSets.asymmetrical),
                       OnSets));
    Info(InfoTensor, 1, "found ", Length(goodSets),
         " good sets altogether");
    solutions := [];
    backtrack([], [[2..Order(tensor)]], goodSets);
    Info(InfoTensor, 1, "found ", Length(solutions), " solutions");
    Info(InfoTensor, 1, Size(Set(solutions)), " distinct solutions");
    return Set(solutions);
    
end);
##  
#M IsCommutative( <tensor> )
##
##  
InstallMethod( IsCommutative, 
        "for tensors",
        [IsTensor],
        
        function(t)
    local   entries,  i,  j;
    entries := t!.entries;
    for i in [1..Order(t)] do
        for j in [i+1..Order(t)] do
            if entries[i][j] <> entries[j][i] then
                return false;
            fi;
        od;
    od;
    return true;
end);
##  
InstallMethod( Mates,
        "for tensors",
        ReturnTrue,
        [IsTensor],
        0,
        function(t)
    return t!.mates;
end);

                
###########################################################
#E  Emacs
##
##  Local Variables:
##  mode:               gap
##  End:
##
