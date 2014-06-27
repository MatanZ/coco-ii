############################################
##  $Id: cobject.gi,v 1.1.1.1 2004/04/01 06:20:40 sven Exp $
##
##  $Log: cobject.gi,v $
##  Revision 1.1.1.1  2004/04/01 06:20:40  sven
##  Imported sources
##
##  Revision 1.1.1.1  2002/02/17 22:06:37  sven
##  Imported sources
##
##  Revision 1.2  2000/02/10 17:37:53  reichard
##  *** empty log message ***
##
##
############################################

Revision.cobject_gd :=
  "@(#)$Id: cobject.gi,v 1.1.1.1 2004/04/01 06:20:40 sven Exp $";

############################################
#F  CocoObjectFam
############################################
CocoObjectFam := NewFamily("CocoObjectFam", IsCocoObject);

############################################
#R  IsCocoObjectRep
############################################
DeclareRepresentation( "IsCocoObjectRep", IsAttributeStoringRep,
        ["order",           # number of vertices
         "group",           # subgroup of autGroup
         "schreier",        # complete Schreier vector of <group>
         "representatives"  # orbit representatives of [1..<order>]
        ]);


############################################
#M  GroupOfCocoObject( <cobj>)
############################################

#
#  No test! It has to be ensured that the relevant entries are initialized.
#  This is done using the CocoObjectTemplate.
#
InstallMethod(GroupOfCocoObject,
        "for coco objects",
        ReturnTrue,
        [IsCocoObject and IsCocoObjectRep],
        0,
        function(cobj)
    return cobj!.group;
    end);

############################################
#M  SchreierVectorOfCocoObject( <cobj>)
############################################
InstallMethod(SchreierVectorOfCocoObject,
        "for coco objects",
        ReturnTrue,
        [IsCocoObject and IsCocoObjectRep],
        0,
        function(cobj)
    return cobj!.schreier;
end);

############################################
#M  Order( <cobj>)
############################################
#InstallMethod(OrderOfCocoObject,
#        "for coco objects",
#        ReturnTrue,
#        [IsCocoObject and IsCocoObjectRep],
#        0,
#        function(cobj)
#    return cobj!.order;
#end);
InstallOtherMethod( Order,
        "for coco objects",
        ReturnTrue,
        [IsCocoObject and IsCocoObjectRep],
        0,
        function( cobj )
    return cobj!.order;
end);
############################################
#M  RepresentativesOfCocoObject( <cobj>)
############################################

InstallMethod(RepresentativesOfCocoObject,
        "for coco objects",
        ReturnTrue,
        [IsCocoObject and IsCocoObjectRep],
        0,
        function( cobj )
    return cobj!.representatives;
end);
############################################
#X  RepresentativeWordOfCocoObject( <cobj>, <point> )
############################################
InstallGlobalFunction(RepresentativeWordOfCocoObject,
        function(cobj, point)
    local schreier, generators, repWord, permIdx, preImg;
    
    schreier := SchreierVectorOfCocoObject(cobj);
    generators := GeneratorsOfGroup(GroupOfCocoObject(cobj));
    
    repWord := [];
    permIdx := schreier[point];
    preImg := point;
    while permIdx > 0 do
        Add(repWord, permIdx);
        preImg := preImg / generators[permIdx];
        permIdx := schreier[preImg];
    od;
    
    return rec(word := Reversed(repWord),
               representative := preImg);
end);   

############################################
#F  CocoObjectTemplate(arg )
############################################
InstallGlobalFunction(CocoObjectTemplate,
        function(arg)
    local i,j,k,
          group, domain, action, inducedGroup, inducedDomain, schreier, rep,
          orbit, generator, numberOfOrbits, image, order, isomorphism, isFullDomain;
    ##
    
    group := arg[1];
    domain := [1..LargestMovedPoint(group)];
    action := OnPoints;
    isFullDomain := true;
    if Length(arg) >= 2 then
        domain := arg[2];
    fi;
    if Length(arg) >= 3 then
        action := arg[3];
    fi;
    if Length(arg) >= 4 then
        isFullDomain := arg[4];
    fi;
    
    if not isFullDomain then
        domain := Concatenation(Orbits(group, domain, action));
    fi;
    
    isomorphism := ActionHomomorphism(group, domain, action);
    inducedGroup := Images(isomorphism);
    inducedDomain := [1..Length(domain)];
    order := Length(inducedDomain);
    numberOfOrbits := 0;
    schreier := 0*inducedDomain;
    rep := [];
    for i in inducedDomain do
        if schreier[i] = 0 then
            Add(rep, i);
            schreier[i] := -Length(rep);
            orbit := [i];
            for j in orbit do
                for k in [1..Length(GeneratorsOfGroup(inducedGroup))] do
                    image := j^GeneratorsOfGroup(inducedGroup)[k];
                    if schreier[image] = 0 then
                        Add(orbit, image);
                        schreier[image] := k;
                    fi;
                od;
            od;
        fi;
    od;
        
    
    return rec(order := order,
               group := inducedGroup,
               originalGroup := group,
               isomorphism := isomorphism,
               schreier := schreier,
               representatives := rep,
               names := domain);
end);
############################################  
#F  OrbitNumber( <cobj>, <point> )
############################################
InstallGlobalFunction(OrbitNumber,
        function( cobj, point )
    local representatives, repWord, rep, orbitNumber;
    representatives := RepresentativesOfCocoObject( cobj );
    repWord := RepresentativeWordOfCocoObject( cobj, point );
    rep := repWord.representative;
    orbitNumber := Position(representatives, rep);
    return orbitNumber;
end);


############################################
#F  BuildPbagObject
############################################
InstallGlobalFunction(BuildPbagObject, function(cocoObject)
    local obj;
    
    obj:=rec();
    obj.T:=cocoObject;
    obj.v:=Order(cocoObject);
    obj.ncp:=1;
    obj.fvc:=List([1..obj.v], x->1);
    obj.fcv:=[[1..obj.v]];
    obj.S:=[];
    obj.ST:=[];
    return obj;
end);
###########################################################
#E  Emacs
##
##  Local Variables:
##  mode:               gap
##  mode:               outline-minor
##  outline-regexp:     "#A\\|#P\\|#O\\|#F\\|#E\\|#N\\|#M"
##  fill-column:        76
##  fill-prefix:        "##  "
##  eval:               (hide-body)
##  End:
##
