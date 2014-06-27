################################################################
##
##  $Id: read.g,v 1.2 2004/04/01 06:59:43 sven Exp $
##
################################################################


ReadPkg( "coco", "files.g");

for name in  COCO_FILENAMES
  do
    ReadPkg( "coco", Concatenation("lib/", name, ".gi"));
od;


ReadPkg("coco", "lib/doc.g");
ReadPkg("coco", "lib/cocoio.g");