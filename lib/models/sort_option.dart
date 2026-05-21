enum SortOption {
  pokedexAsc('图鉴编号↑'),
  currentValueDesc('当前价值↓'),
  acquiredPriceDesc('入手价格↓'),
  acquiredDateDesc('入手时间↓');

  final String label;
  const SortOption(this.label);
}
