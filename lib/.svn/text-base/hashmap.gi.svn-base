############################################################
## hashmap.gi
##
## COCO share package
##
## (C) MII Sven Reichard
############################################################

############################################################
##  <#GAPDoc Label="HashedMaps">
##  <Chapter> <Heading>Hashed Maps</Heading>
##  This chapter describes an efficient implementation of 
##  general maps based on hashing.
##  <#Include Label="HashedMapConstruction">
##  </Chapter>
##  <#/GAPDoc>

HashedMapFam := NewFamily("HashedMapFam", IsHashedMap);

DeclareRepresentation( "IsHashedMapRep",
        IsComponentObjectRep,
        ["primaryHash",
         "secondaryHash",
         "slots",
         "size"]);


############################################################
##  <#GAPDoc Label="HashedMapConstruction">
##  <Section> <Heading>Constructing hashed maps</Heading>
##  <ManSection>
##  <Func Name="HashedMap" Arg="prim, sec [, initial]"></Func>
##  <Description>
##  constructs an empty map with hash functions <Arg>prim</Arg> and
##  <Arg>sec</Arg>. If <Arg>initial</Arg> is given it determines the 
##  initial number of slots; otherwise, a default value is used.
##  <Example>
##  gap&gt; primary := x -> x*x;;
##  gap&gt; secondary := x -> x*[1..Length(x)];;
##  gap&gt; map := HashedMap(primary, secondary);
##  &lt;object&gt;
##  </Example>
##  </Description>
##  </ManSection>
##  </Section>
##  <#/GAPDoc>
InstallGlobalFunction(HashedMap,
        
        function(arg)
    local primary, secondary, nrSlots, slots, obj;
    primary := arg[1];
    secondary := arg[2];
    nrSlots := 97;
    if Length(arg) >= 3 then
        nrSlots := arg[3];
    fi;
    slots := List([1..nrSlots], x -> fail);
    obj := rec(primaryHash := primary,
               secondaryHash := secondary,
               slots := slots,
               size := 0);
    return Objectify(NewType(HashedMapFam, IsHashedMapRep), obj);
end);

InstallOtherMethod(Size,
        "for hashed maps",
        ReturnTrue,
        [IsHashedMap],
        0,
        function(x)
    return x!.size;
end);

InstallGlobalFunction(NumberOfSlots,
        function(hashmap)
    return Size(hashmap!.slots);
end);

InstallGlobalFunction(GetValue,
        function(hashmap, key)
    local prim, sec, pos;
    prim := hashmap!.primaryHash(key);
    pos := prim mod Size(hashmap!.slots);
    sec := (hashmap!.secondaryHash(key) mod (Size(hashmap!.slots)-1)) +1;
    while hashmap!.slots[pos+1] <> fail and
      hashmap!.slots[pos+1].key <> key do
        pos := (pos + sec) mod NumberOfSlots(hashmap);
    od;
    if hashmap!.slots[pos+1] = fail then
        return fail;
    else
        return hashmap!.slots[pos+1].value;
    fi;
end);

InstallGlobalFunction(SetValue,
        function(hashmap, key, value)
    
    local prim, sec, pos;
    prim := hashmap!.primaryHash(key);
    pos := prim mod Size(hashmap!.slots);
    sec := (hashmap!.secondaryHash(key) mod (Size(hashmap!.slots)-1)) +1;
    while hashmap!.slots[pos+1] <> fail and
      hashmap!.slots[pos+1].key <> key do
        pos := (pos + sec) mod NumberOfSlots(hashmap);
    od;
    if hashmap!.slots[pos+1] = fail then
        hashmap!.size := hashmap!.size + 1;
        hashmap!.slots[pos+1] := rec(key := key, value := value);
        if 2*Size(hashmap) > NumberOfSlots(hashmap) then
            ResizeHashMap(hashmap, NextPrimeInt(2*NumberOfSlots(hashmap)));
        fi;
    else
        hashmap!.slots[pos+1] := rec(key := key, value := value);
    fi;
end);

InstallGlobalFunction(ResizeHashMap,
        function(hashmap, newSize)
    local oldSlots, i;
    oldSlots := hashmap!.slots;
    hashmap!.slots := List([1..newSize], x -> fail);
    hashmap!.size := 0;
    for i in oldSlots do
        if i <> fail then
            SetValue(hashmap, i.key, i.value);
        fi;
    od;
end);
