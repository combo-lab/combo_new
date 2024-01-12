%{
  configs: [
    %{
      name: "default",
      strict: true,
      checks: [
        # Additional and reconfigured checks
        {Credo.Check.Readability.StrictModuleLayout, []},
        {Credo.Check.Design.AliasUsage, if_nested_deeper_than: 4, if_called_more_often_than: 1},
        {Credo.Check.Readability.AliasAs, []},
        {Credo.Check.Readability.WithCustomTaggedTuple, []},
        {Credo.Check.Warning.UnsafeToAtom, []},

        # Disabled checks
        {Credo.Check.Design.TagFIXME, false},
        {Credo.Check.Design.TagTODO, false},
        {Credo.Check.Readability.ModuleDoc, false},
        {Credo.Check.Readability.PredicateFunctionNames, false},
        {Credo.Check.Readability.AliasOrder, false},
        {Credo.Check.Refactor.LongQuoteBlocks, false},
        {Credo.Check.Refactor.Nesting, false}
      ]
    }
  ]
}
