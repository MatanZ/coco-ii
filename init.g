#############################################################################
##
##  init.g                    COCO package                      
##                                                              Mikhail Klin
##                                                            Christian Pech
##                                                             Sven Reichard
##
##  Copyright 2006 University of Western Australia
##
##  Reading the declaration part of the COCO package.
##
#############################################################################

LoadPackage("grape");
LoadPackage("setorbit");
DeclarePackage("coco-ii", "0.0.1", ReturnTrue);

DeclarePackageDocumentation("coco-ii", "doc");


for name in 
  ["cobject", 
   "tensor", 
   "colgraph", 
   "cellalg", 
   "hashmap",
   "aut",
   "utility"]
  do
    ReadPkg( "coco-ii", Concatenation("lib/", name, ".gd"));
od;
