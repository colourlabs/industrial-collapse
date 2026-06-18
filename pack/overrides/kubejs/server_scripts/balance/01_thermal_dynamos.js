/**
 * make thermal dynamos less powerful, encourages people to use big reactors
 * requires: kubejs-thermal
 */

ServerEvents.recipes((event) => {
  // stirling Dynamo (solid fuels)
  event.recipes.thermal.stirling_fuel("minecraft:coal").energy(16000);
  event.recipes.thermal.stirling_fuel("minecraft:charcoal").energy(12000);
  event.recipes.thermal.stirling_fuel("minecraft:coal_block").energy(144000);
  event.recipes.thermal.stirling_fuel("minecraft:blaze_rod").energy(20000);

  // compression dynamo (fluid fuels)
  // creosote stays cheap - it's a free IE byproduct
  event.recipes.thermal.compression_fuel(Fluid.of("immersiveengineering:creosote", 100)).energy(15000);

  // biodiesel nerfed - too powerful at scale
  event.recipes.thermal.compression_fuel(Fluid.of("immersiveengineering:biodiesel", 100)).energy(60000);

  // magmatic dynamo (lava)
  // lava is renewable via nether so just nuke it lol
  event.recipes.thermal.magmatic_fuel(Fluid.of("minecraft:lava", 100)).energy(30000);

  // numismatic dynamo (gems/coins)
  event.recipes.thermal.numismatic_fuel("minecraft:emerald").energy(50000);
  event.recipes.thermal.numismatic_fuel("minecraft:diamond").energy(150000);
});
