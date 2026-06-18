/**
 * AE2 gating
 * gate: IE steel + thermal machine frame required for core
 */

ServerEvents.recipes((event) => {
  // ME controller
  // main bit of an AE2 network, gate behind Thermal Machine Frame + IE Steel
  event.remove({ output: "ae2:controller" });
  event.shaped("ae2:controller", ["SMS", "MCM", "SMS"], {
    S: "immersiveengineering:steel_scaffolding_standard",
    M: "thermal:machine_frame",
    C: "ae2:fluix_crystal",
  });

  // ME Drive
  // gate behind IE steel plates
  event.remove({ output: "ae2:drive" });
  event.shaped("ae2:drive", ["PFP", "F F", "PFP"], {
    P: "#forge:plates/steel",
    F: "ae2:fluix_crystal",
  });

  // ME chest
  event.remove({ output: "ae2:chest" });
  event.shaped("ae2:chest", ["PCP", "C C", "PCP"], {
    P: "#forge:plates/steel",
    C: "ae2:certus_quartz_crystal",
  });

  // ME terminal
  // gate behind thermal enderium - signals late Thermal progression
  event.remove({ output: "ae2:terminal" });
  event.shaped("ae2:terminal", ["GQG", "QEQ", "GQG"], {
    G: "minecraft:glass_pane",
    Q: "ae2:certus_quartz_crystal",
    E: "thermal:enderium_ingot",
  });

  // blank pattern
  // autocrafting patterns require thermal electrum
  event.remove({ output: "ae2:blank_pattern" });
  event.shaped("4x ae2:blank_pattern", ["EGE", "GQG", "EGE"], {
    E: "thermal:electrum_ingot",
    G: "minecraft:glass",
    Q: "ae2:certus_quartz_crystal",
  });

  // fluix crystal
  // require thermal lumium as a binding agent
  event.remove({ output: "ae2:fluix_crystal" });
  event.shapeless("ae2:fluix_crystal", ["ae2:charged_certus_quartz_crystal", "minecraft:redstone", "minecraft:quartz", "thermal:lumium_ingot"]);

  // certus quartz doubling via IE crushed
  event.custom({
    type: "immersiveengineering:crusher",
    input: { tag: "forge:ores/certus_quartz" },
    result: { base_ingredient: { item: "ae2:certus_quartz_dust" }, count: 2 },
    energy: 3000,
    secondaries: [],
  });

  event.custom({
    type: "immersiveengineering:crusher",
    input: { item: "ae2:certus_quartz_crystal" },
    result: { base_ingredient: { item: "ae2:certus_quartz_dust" }, count: 1 },
    energy: 1500,
    secondaries: [],
  });
});
