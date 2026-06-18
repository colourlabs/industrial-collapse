/**
 * waystones gating
 * prevents easy fast travel at the start
 * gate: thermal midgame (Signalum) + IE (treated wood)
 */

ServerEvents.recipes((event) => {
  event.remove({ output: "waystones:waystone" });
  event.remove({ output: "waystones:mossy_waystone" });
  event.remove({ output: "waystones:sandy_waystone" });
  event.remove({ output: "waystones:warp_scroll" });
  event.remove({ output: "waystones:warp_stone" });

  event.shaped("waystones:waystone", ["STS", "TCT", "STS"], {
    S: "thermal:signalum_ingot",
    T: "immersiveengineering:treated_wood_horizontal",
    C: "minecraft:compass",
  });

  // warp scroll
  event.shaped("waystones:warp_scroll", ["IPI", "PEP", "IPI"], {
    I: "immersiveengineering:treated_wood_horizontal",
    P: "minecraft:paper",
    E: "minecraft:ender_pearl",
  });

  // warp stone
  event.shaped("waystones:warp_stone", ["LQL", "QEQ", "LQL"], {
    L: "thermal:lumium_ingot",
    Q: "ae2:fluix_crystal",
    E: "minecraft:ender_eye",
  });
});
