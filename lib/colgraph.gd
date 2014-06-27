DeclareCategory("IsColorGraph", IsCocoObject);
ColorGraphFam := NewFamily("ColorGraphFam");
DeclareGlobalFunction("ColorGraph");
DeclareAttribute("GroupOfColorGraph", IsColorGraph);
DeclareGlobalFunction("TwoOrbitNumberOfColorGraph");
DeclareGlobalFunction( "TwoOrbitRepresentative" );
DeclareAttribute("GroupRankOfColorGraph", IsColorGraph);
DeclareOperation("EdgeColorOfColorGraph", [IsColorGraph, IsPosInt, IsPosInt]);
DeclareOperation("RowOfColorGraph", [IsColorGraph, IsPosInt]);
DeclareOperation("ColumnOfColorGraph", [IsColorGraph, IsPosInt]);
DeclareOperation("BaseGraphOfColorGraph", [IsColorGraph, IsInt]);
DeclareOperation("SetEdgeOrbitColorOfColorGraph", 
	[IsColorGraph, IsPosInt, IsPosInt, IsPosInt]);
DeclareAttribute("ColorAutomorphismGroup", IsColorGraph);
DeclareOperation( "ColorRepresentative", [IsColorGraph, IsInt] );
DeclareOperation( "Fibres", [IsColorGraph] );
DeclareOperation( "Neighbors", [IsColorGraph, IsInt, IsInt]);
DeclareOperation("IsHomogeneous", [IsColorGraph] );
