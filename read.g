################################################################
##
##  $Id: read.g,v 1.2 2004/04/01 06:59:43 sven Exp $
##
################################################################


ReadPkg( "coco-ii", "files.g");

for name in  COCO_FILENAMES
  do
    ReadPkg( "coco-ii", Concatenation("lib/", name, ".gi"));
od;


ReadPkg("coco-ii", "lib/doc.g");
ReadPkg("coco-ii", "util/cocoio.g");
