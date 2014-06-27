RequirePackage("gapdoc");
path := "doc/";
main := "manual.xml";
    manual := "manual";
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
              "../lib/tensor.gi",
              "../tst/unittest.xml"];
str := ComposedXMLString( path, main, files );
r := ParseTreeXMLString( str );
CheckAndCleanGapDocTree( r );
exampleText := "";
extractExamples := function(record)
    local i;
    if not IsRecord(record) then
        return;
    fi;
    if record.name = "Example" then
        Append(exampleText, record.content[1].content);
        return;
    fi;
    if not IsBound(record.content) then
        return;
    fi;
    if not IsList(record.content) then
        return;
    fi;
    for i in record.content do
        extractExamples( i );
    od;
end;
extractExamples(r);
PrintTo("unittest.tst", 
        "gap> RequirePackage( \"coco\" );\n",
        "true\n");
AppendTo("unittest.tst", exampleText, "\n");
ReadTest("unittest.tst");
