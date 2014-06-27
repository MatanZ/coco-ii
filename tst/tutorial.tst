gap> START_TEST( "coco functionality" );
gap> LoadPackage("coco");
true
gap> e8 := ElementaryAbelianGroup(8);;
gap> g := Action(e8, e8, OnRight);;
gap> cgr := ColorGraph(g);
<color graph of order 8 and rank 8>
gap> Display(cgr);
color graph
[ [  1,  2,  3,  4,  5,  6,  7,  8 ],
  [  2,  1,  4,  3,  6,  5,  8,  7 ],
  [  3,  4,  1,  2,  7,  8,  5,  6 ],
  [  4,  3,  2,  1,  8,  7,  6,  5 ],
  [  5,  6,  7,  8,  1,  2,  3,  4 ],
  [  6,  5,  8,  7,  2,  1,  4,  3 ],
  [  7,  8,  5,  6,  3,  4,  1,  2 ],
  [  8,  7,  6,  5,  4,  3,  2,  1 ] ]
gap> Size(AutomorphismGroup(cgr));
8
gap> Size(ColorAutomorphismGroup(cgr));
1344
gap> Size(AlgebraicAutomorphismGroup(cgr));
168
gap> sub := CoherentSubalgebras(cgr);;
gap> Collected(List(sub, Rank));
[ [ 3, 2 ], [ 4, 2 ], [ 5, 2 ], [ 6, 1 ], [ 8, 1 ] ]
gap> psl := PSL(2,8);;
gap> s2 := SylowSubgroup(psl, 2);;
gap> cosets := RightCosets(psl, s2);;
gap> G := Action(psl, cosets, OnRight);;
gap> cgr := ColorGraph(G);
<color graph of order 63 and rank 14>
gap> sub := CoherentSubalgebras(cgr);;
blowing up orbits; old number: 10
new number: 12
gap> Collected(List(sub, Rank));
[ [ 3, 3 ], [ 4, 4 ], [ 5, 1 ], [ 6, 1 ], [ 8, 2 ], [ 14, 1 ] ]
gap> srg := Filtered(sub, IsPrimitive);
[ <color graph of order 63 and rank 3>, <color graph of order 63 and rank 3> ]
gap> IsIsomorphicCgr(srg[1], srg[2]);
false
gap> graphs := List(srg, x -> BaseGraphOfColorGraph(x, 2));;

gap> CocoPrintGroup(Group((1,2,3,4,5), (2,5)(3,4)));
5
2
(0,1,2,3,4)
(1,4)(2,3)
orbit    length     representative
1         5       0


gap> List(graphs, GlobalParameters);
[ [ [ 0, 0, 30 ], [ 1, 13, 16 ], [ 15, 15, 0 ] ], 
  [ [ 0, 0, 30 ], [ 1, 13, 16 ], [ 15, 15, 0 ] ] ]
gap> STOP_TEST( "tutorial.tst", 250000000);
