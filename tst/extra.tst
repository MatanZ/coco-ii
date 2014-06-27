gap> LoadPackage("coco");
true
gap> START_TEST( "extra tests for COCO" );
gap> points := [   [[0,2]],
>   [[1,2]],
>   [[0,3]],
>   [[1,3]],
>   [[0,4]],
>   [[1,4]],
>   [[0,5]],
>   [[1,5]],
>   [[2,4]],
>   [[3,4]],
>   [[2,5]],
>   [[3,5]],
>   [[0,2,4],[1,3,5]],
>   [[0,3,5],[1,2,4]],
>   [[0,3,4],[1,2,5]],
>   [[0,2,5],[1,3,4]]
>              ] + 1;;

gap> G := Action(Group((1,2),(3,4),(5,6)), points, OnSetsSets);;
gap> cgr := ColorGraph(G);
<color graph of order 16 and rank 40>
gap> merging51 := 
>  [ [0], [ 1, 2, 3 ], [ 4, 6, 8 ], [ 5, 7, 9 ], [ 10, 20, 30 ], 
>    [ 11, 21, 31 ], [ 12, 24, 36 ], [ 13, 27, 38 ], [ 14, 26, 39 ],
>    [ 15, 25, 37 ],   [ 16, 28, 32 ], [ 17, 29, 33 ],
>    [ 18, 22, 34 ], [ 19, 23, 35 ] ] + 1;;
gap> sub51 := CoherentSubalgebra(cgr, merging51);
<color graph of order 16 and rank 14>
gap> mer2 := [[0,6],[1,7,8,9],[2,4,10,12],[3,5,11,13]]+1;;
gap> sub2 := CoherentSubalgebra(sub51, mer2);
<color graph of order 16 and rank 4>
gap> cgr := ColorGraph(Group((1,2,3,4,5)));;
gap> ColorRepresentative(cgr, 1);
[ 1, 1 ]
gap> ColorRepresentative(cgr, 2);
[ 1, 2 ]
gap> ColorRepresentative(cgr, 3);
[ 1, 3 ]
gap> ColorRepresentative(cgr, 4);
[ 1, 4 ]
gap> ColorRepresentative(cgr, 5);
[ 1, 5 ]
gap> ColorRepresentative(cgr, 6);
fail
gap> TranspositionOnColors( cgr );
(2,5)(3,4)
gap> sub := CoherentSubalgebra( cgr, [[1],[2,5],[3,4]]);;
gap> TranspositionOnColors( sub );
()
gap> t := StructureConstantsOfColorGraph( sub );
<tensor of order 3>
gap> Mates( t );
()
gap> STOP_TEST( "extra.tst", 10000);