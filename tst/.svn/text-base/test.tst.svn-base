
gap> c7 := CyclicGroup(IsPermGroup, 7);;
gap> fano := Set(Orbit(c7, [1,2,4], OnSets));;
gap> a8 := AlternatingGroup(8);;
gap> cgr := ColorGraph(a8, [fano], OnSetsSets);
<color graph of order 120 and rank 5>

gap> CentralizerAlgebra(AlternatingGroup(8), [fano], OnSetsSets);
<color graph of order 120 and rank 5>

gap> g := Group((1,2,3,4,5));;
gap> cgr := CentralizerAlgebra(g);
<color graph of order 5 and rank 5>

gap> Rank(cgr);
5

gap> Order(cgr);
5

gap> sub := CoherentSubalgebras(cgr);;
gap> Length(sub);
2

gap> List(sub, Rank);
[ 5, 3 ]

gap> fano := Set(Orbit(Group((1,2,3,4,5,6,7)), [1,2,4], OnSets));;
gap> orb := Orbit(AlternatingGroup(8), fano, OnSetsSets);;
gap> g := Operation(AlternatingGroup(8), orb, OnSetsSets);;
gap> cgr := CentralizerAlgebra(g); 
<color graph of order 120 and rank 5>
gap> sub := CoherentSubalgebras(cgr);;
gap> Length(sub);
