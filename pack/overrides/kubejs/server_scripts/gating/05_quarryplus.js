/**
 * quarryplus gating
 * gate: make it an endgame unlock
 */

ServerEvents.recipes((event) => {
  // quarryplus
  event.remove({ output: "quarryplus:quarry" });
  event.shaped("quarryplus:quarry", ["ESE", "SPS", "ESE"], {
    E: "thermal:enderium_ingot",
    S: "#forge:plates/steel",
    P: "ae2:engineering_processor",
  });

  // advanced quarry
  // even harder gate - requires multiple AE2 processors
  event.remove({ output: "quarryplus:adv_quarry" });
  event.shaped("quarryplus:adv_quarry", ["EQE", "QPQ", "EQE"], {
    E: "thermal:enderium_ingot",
    Q: "quarryplus:quarry",
    P: "ae2:engineering_processor",
  });
});
