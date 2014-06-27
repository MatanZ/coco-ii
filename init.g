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
DeclarePackage("coco", "0.6", ReturnTrue);

DeclarePackageDocumentation("coco", "doc");


for name in 
  ["cobject", 
   "tensor", 
   "colgraph", 
   "cellalg", 
   "hashmap",
   "aut",
   "utility"]
  do
    ReadPkg( "coco", Concatenation("lib/", name, ".gd"));
od;
