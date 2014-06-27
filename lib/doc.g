CocoUpdateManual := function()
    local path, manual, files;
    path := "/home/sven/Programming/Mathematics/Gap/pkg/coco/doc/";
    manual := "manual";
    files :=["../lib/tensor.gi",
             "../lib/tensor.gd",
             "../lib/colgraph.gi",
             "../lib/colgraph.gd"];
    MakeGAPDocDoc(path, manual, files, "coco");
end;


PrintPCDATA := function (stream,  r )
    if not IsRecord( r )  then
        return;
    fi;
    if not IsBound( r.name ) or r.name <> "PCDATA"  then
        return;
    fi;
    PrintTo( stream,  r.content );
    return;
end;


PrintExamples := function ( stream, r )
    local  i;
    if not IsRecord( r )  then
        return;
    fi;
    if IsBound( r.name ) and r.name = "Example"  then
        if IsBound( r.content ) and IsList( r.content )  then
            for i  in r.content  do
                PrintPCDATA(stream,  i );
            od;
        fi;
    fi;
    if IsBound( r.content ) and IsList( r.content )  then
        for i  in r.content  do
            PrintExamples( stream, i );
        od;
    fi;
    return;
end;

MakeTestSuite := function()
    local   files,  path,  manual,  str,  r,  stream;

    files :=[ "../lib/aut.g",
              "../lib/banner.g",
              "../lib/cellalg.gd",
              "../lib/cellalg.gi",
              "../lib/cobject.gd",
              "../lib/cobject.gi",
              "../lib/colgraph.gd",
              "../lib/colgraph.gi",
              "../lib/hashmap.gd",
              "../lib/hashmap.gi",
              "../lib/hashset.gd",
              "../lib/hashset.gi",
              "../lib/pbag.g",
              "../lib/pbag.gd",
              "../lib/sorbiter.gd",
              "../lib/sorbiter.gi",
              "../lib/stbcbckt.gd",
              "../lib/stbcbckt.gi",
              "../lib/tensor.gd",
              "../lib/tensor.gi"];
    path := "/home/sven/Programming/Mathematics/Gap/pkg/coco/doc";
    manual := "manual.xml";
    str := ComposedXMLString(path, manual, files);
    r := ParseTreeXMLString(str);
    CheckAndCleanGapDocTree(r);
    stream := OutputTextFile("coco.tst", false);
    PrintExamples(stream, r);
end;

  