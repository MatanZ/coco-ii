DeclareGlobalFunction("CentralizerAlgebra");
DeclareAttribute("StructureConstantsOfColorGraph", IsColorGraph);
DeclareGlobalFunction("AlgebraicAutomorphismGroup");
DeclareProperty("IsCoherentAlgebra", IsColorGraph);
DeclareOperation("CoherentSubalgebra", [IsColorGraph, IsList]);
DeclareOperation("CoherentSubalgebras", [IsColorGraph]);
DeclareOperation("TranspositionOnColors", [IsColorGraph]);
