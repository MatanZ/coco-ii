DeclareCategory("IsTensor", IsCocoObject);
TensorFam := NewFamily("TensorFam", IsTensor);
DeclareInfoClass("InfoTensor");
DeclareGlobalFunction("NullTensor");
DeclareGlobalFunction("DenseTensorFromEntries");
DeclareOperation("EntryOfTensor", [IsTensor, IsPosInt, IsPosInt, IsPosInt]);
DeclareOperation("SetEntryOfTensor", [IsTensor and IsMutable, 
        IsPosInt, IsPosInt, IsPosInt, IsObject]);
DeclareOperation("IncrementEntryOfTensor", [IsTensor and IsMutable,
        IsPosInt, IsPosInt, IsPosInt]);
DeclareGlobalFunction("SetMates");
DeclareGlobalFunction("GetMates");
DeclareGlobalFunction( "ReflexiveColors" );
DeclareProperty("IsTensorOfCoherentAlgebra", IsTensor);
DeclareGlobalFunction("CollapsedTensor");
DeclareAttribute("MergingsOfTensor", IsTensor);
DeclareOperation("CharacterTable", [IsTensor]);
DeclareAttribute("CharacterTableOfTensor", IsTensor);
DeclareGlobalFunction("IsGoodSet");
DeclareGlobalFunction("CocoComplexProduct");
DeclareGlobalFunction("WLStep");
DeclareGlobalFunction("WLStabilize");
DeclareGlobalFunction("GoodSets");
DeclareGlobalFunction("SymmetricGoodSets");
DeclareGlobalFunction("AllMergings");
DeclareProperty( "IsCommutative", IsTensor );
DeclareOperation( "Mates", [IsTensor] );
