/**
 * extreme reactors gating
 * gate: make it a late game energy source
 */

ServerEvents.recipes((event) => {
  // reactor casing
  // requires IE Steel + thermal invar
  event.remove({ output: "bigreactors:basic_reactorcasing" });
  event.shaped("4x bigreactors:basic_reactorcasing", ["ISI", "SFS", "ISI"], {
    I: "thermal:invar_ingot",
    S: "#forge:ingots/steel",
    F: "minecraft:iron_bars",
  });

  // reactor controller
  // requires AE2 Logic Processor - hard gates reactor behind AE2
  event.remove({ output: "bigreactors:basic_reactorcontroller" });
  event.shaped("bigreactors:basic_reactorcontroller", ["CLC", "LRL", "CLC"], {
    C: "bigreactors:basic_reactorcasing",
    L: "ae2:logic_processor",
    R: "minecraft:redstone_block",
  });

  // reactor power tap (RF output port)
  // requires Flux Networks component + AE2 to connect to Flux
  event.remove({ output: "bigreactors:basic_reactorpowertapfe_active" });
  event.shaped("bigreactors:basic_reactorpowertapfe_active", ["CFC", "FCF", "CFC"], {
    C: "bigreactors:basic_reactorcasing",
    F: "ae2:calculation_processor",
  });
});
