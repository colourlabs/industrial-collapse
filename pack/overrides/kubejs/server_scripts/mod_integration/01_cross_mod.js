/**
 * cross mod integration, literally a mess but whatever
 * ties IE, thermal, AE2 and extreme reactors
 */

ServerEvents.recipes((event) => {
  // IE -> Thermal 

  // IE Slag processed by Thermal Smelter
  // (IE Arc Furnace produces slag as a byproduct - give it a use)
  event.recipes.thermal.smelter([Item.of("thermal:slag").withChance(0.5), "minecraft:gravel"], ["immersiveengineering:slag", "#forge:dusts/sand"]);

  // thermal pulverizer as early alternative to IE Crusher
  // slightly less efficient to reward building the crusher
  event.recipes.thermal.pulverizer(["1x #forge:dusts/copper", Item.of("#forge:dusts/gold").withChance(0.05)], "#forge:ores/copper");

  // IE Treated Wood -> Thermal input
  // sawmill processes treated wood into useful components
  event.recipes.thermal.sawmill(["2x minecraft:stick", Item.of("immersiveengineering:hemp_fiber").withChance(0.5)], "immersiveengineering:treated_wood_horizontal");

  // Thermal -> AE2

  // thermal induction smelter can craft AE2 alloys
  // gives Thermal a role in AE2 processor production
  event.recipes.thermal.smelter(["ae2:certus_quartz_crystal"], ["ae2:certus_quartz_dust", "minecraft:sand"]);

  // IE -> Extreme Reactors

  // yellorium processed through IE Crusher gives more output
  // rewards using IE ore processing for reactor fuel
  event.custom({
    type: "immersiveengineering:crusher",
    input: { tag: "forge:ores/yellorite" },
    result: { base_ingredient: { tag: "forge:dusts/yellorium" }, count: 2 },
    energy: 3000,
    secondaries: [],
  });

  // Thermal -> Extreme Reactors

  // thermal smelter processes Yellorium dust into ingots
  // with a small bonus output
  event.recipes.thermal.smelter(["2x bigreactors:yellorium_ingot"], ["#forge:dusts/yellorium", "#forge:dusts/coal"]);

  // AE2 -> Flux Networks

  // flux Plug/Point require AE2 processors
  // gates wireless power behind having an AE2 network
  event.remove({ output: "fluxnetworks:flux_plug" });
  event.shaped("fluxnetworks:flux_plug", ["LPL", "PCP", "LPL"], {
    L: "ae2:logic_processor",
    P: "#forge:plates/steel",
    C: "fluxnetworks:flux_core",
  });

  event.remove({ output: "fluxnetworks:flux_point" });
  event.shaped("fluxnetworks:flux_point", ["LPL", "PCP", "LPL"], {
    L: "ae2:logic_processor",
    P: "#forge:plates/steel",
    C: "fluxnetworks:flux_core",
  });

  // IE -> QuarryPlus

  // marker (area selector for quarry) requires IE components
  // so even setting up the quarry needs IE investment
  event.remove({ output: "quarryplus:marker" });
  event.shaped("2x quarryplus:marker", [" S ", "SCS", " S "], {
    S: "#forge:ingots/steel",
    C: "immersiveengineering:component_steel",
  });
});
