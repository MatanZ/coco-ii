# These functions print permutation groups in COCO's original file
# format. The format is as follows: 
#
# Degree 
# Number of generators
# Generators
# 
# The generators are given as 0-based permutations in cycle notation. Each
# permutation extends to the end of the line. If the line ends in "*", the
# permutation extends to the next line.

CocoPrintPermutation := function(arg)
    local done, i, j, degree, length, stream, perm, pr, line;
    if Length(arg) = 2 then
        stream := arg[1];
        perm := arg[2];
        pr := function(arg)
            CallFuncList(PrintTo, Concatenation([stream], arg));
        end;
    else
        perm := arg[1];
        pr := Print;
    fi;
    if perm = () then
        pr(  "\n");
        return;
    fi;
    length := 0;
    degree := LargestMovedPointPerm(perm);
    done := List([1..degree], x-> false);
    line := "";
    for i in [1..degree] do
        if not done[i] and i^perm <> i then
            if Length(line) > 60 then
                #length := 0;
                pr( line, "*\n");
                line := "";
            fi;
            Append(line,  "(");
            Append(line, String(i-1));
            done[i] := true;
            j := i^perm;
            while not done[j] do
                length := length+1;
                Append(line,  ",");
                if Length(line) > 60 then
                    #length := 0;
                    pr( line, "*\n");
                    line := "";
                fi;
                Append(line, String(j-1));
                done[j] := true;
                j := j^perm;
            od;
            Append(line,  ")");
        fi;
    od;
    pr(line,  "\n");
end;


CocoPrintGroup := function( arg)
    local i, gens, stream, g, printPerm, pr, orbits;
    if Length(arg) = 2 then
        stream := arg[1];
        g := arg[2];
        pr := function(arg)
            CallFuncList(PrintTo, Concatenation([stream], arg));
        end;
        printPerm := function(perm)
            CocoPrintPermutation(stream, perm);
        end;
    else
        g := arg[1];
        pr := Print;
        printPerm := function(perm)
            CocoPrintPermutation(perm);
        end;
    fi;
    pr(  LargestMovedPoint(g), "\n");
    gens := GeneratorsOfGroup(g);
    pr(  Length(gens), "\n");
    for i in gens do
        printPerm(i);
    od;
    orbits := Orbits(g);
    Print("orbit    length     representative\n");
    for i in [1..Length(orbits)] do
        Print(i, "         ", Length(orbits[i]),
              "       ", orbits[i][1]-1, "\n");
    od;
end;
