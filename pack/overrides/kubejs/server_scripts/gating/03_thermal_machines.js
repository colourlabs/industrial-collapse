/**
 * thermal machine gating
 * gate: interact with IE before getting into thermal stuff
 */

ServerEvents.recipes((event) => {
  // pulverizer
  event.remove({ output: "thermal:machine_pulverizer" });
  event.shaped("thermal:machine_pulverizer", ["STS", "TMT", "STS"], {
    S: "#forge:ingots/steel",
    T: "immersiveengineering:treated_wood_horizontal",
    M: "thermal:machine_frame",
  });

  // induction smelter
  event.remove({ output: "thermal:machine_smelter" });
  event.shaped("thermal:machine_smelter", ["SIS", "IMI", "SIS"], {
    S: "#forge:ingots/steel",
    I: "thermal:invar_ingot",
    M: "thermal:machine_frame",
  });

  // centrifuge
  event.remove({ output: "thermal:machine_centrifuge" });
  event.shaped("thermal:machine_centrifuge", ["SES", "EME", "SES"], {
    S: "#forge:ingots/steel",
    E: "immersiveengineering:component_iron",
    M: "thermal:machine_frame",
  });

  // fluid encapsulator
  event.remove({ output: "thermal:machine_bottler" });
  event.shaped("thermal:machine_bottler", ["SBS", "BMB", "SBS"], {
    S: "#forge:ingots/steel",
    B: "minecraft:glass_bottle",
    M: "thermal:machine_frame",
  });

  // fractionating still
  event.remove({ output: "thermal:machine_refinery" });
  event.shaped("thermal:machine_refinery", ["SCS", "CMC", "SCS"], {
    S: "#forge:ingots/steel",
    C: "immersiveengineering:component_steel",
    M: "thermal:machine_frame",
  });

  // sawmill
  event.remove({ output: "thermal:machine_sawmill" });
  event.shaped("thermal:machine_sawmill", ["STS", "TMT", "STS"], {
    S: "#forge:ingots/steel",
    T: "immersiveengineering:treated_wood_horizontal",
    M: "thermal:machine_frame",
  });

  // thermal machine frame
  // base frame requires IE steel so nothing in Thermal
  // can be crafted without touching IE first
  event.remove({ output: "thermal:machine_frame" });
  event.shaped("thermal:machine_frame", ["SIS", "I I", "SIS"], {
    S: "#forge:ingots/steel",
    I: "#forge:ingots/iron",
  });
});
