gap> LoadPackage("coco");
true
gap> START_TEST( "basic tests" );


# first, we define a group
gap> d5 := Group((1,2,3,4,5), (2,5)(3,4));;

# then, we construct the color graph
gap> cgr_d5 := ColorGraph( d5 );;

gap> Order(cgr_d5);
5

gap> Rank(cgr_d5);
3

gap> IsPrimitive(cgr_d5);
true

# We define a second group
gap> c6 := Group((1,2,3,4,5,6));;

# then, we construct the color graph
gap> cgr_c6 := ColorGraph( c6 );;

gap> Order(cgr_c6);
6

gap> Rank(cgr_c6);
6

gap> IsPrimitive(cgr_c6);
false

# a more complicated example: we construct an srg first
# described by Brouwer, Ivanov, and Klin
# It is not very important to understand right now all details of how the
# group is constructed.

gap> c7 := Group((1,2,3,4,5,6,7));;
gap> fano := Set(Orbit(c7, [1,2,4], OnSets));
[ [ 1, 2, 4 ], [ 1, 3, 7 ], [ 1, 5, 6 ], [ 2, 3, 5 ], [ 2, 6, 7 ],
  [ 3, 4, 6 ], [ 4, 5, 7 ] ]

gap> a8 := AlternatingGroup(8);;

# we use a double semicolon to suppress the output
gap> orbit := Orbit( a8, fano, OnSetsSets );;
gap> Length( orbit );
120

# compute the induced action
gap> g := Action( a8, orbit, OnSetsSets );;

gap> cgr := ColorGraph( g );
<color graph of order 120 and rank 5>

# compute the mergings
gap> mergings := CoherentSubalgebras( cgr );;

gap> srg := First( mergings, IsPrimitive );
<color graph of order 120 and rank 3>

gap> Size( AutomorphismGroup( srg ) );
1290240

# the following commands were introduced:
# Group - construct a permutation group from generators
# ColorGraph - construct the centralizer algebra of a transitive 
#              permutation group
# Order - number of points
# Rank - number of colors
# CoherentSubalgebras - all mergings of an association scheme
# AutomorphismGroup - automorphism group of an association scheme
# 
# 

gap> STOP_TEST( "test060615.tst", 10000000);
