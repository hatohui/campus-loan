/// Bundled seed catalogue used to pre-populate the local cache on first run.
///
/// This guarantees the app is useful immediately and fully offline (before any
/// successful network fetch). The shape intentionally mirrors the public API's
/// `GET /objects` response — free-form `data` maps, mixed key casing, prices as
/// both numbers and strings, and some `data: null` entries — so it flows through
/// the exact same [DeviceModel] mapper as live data.
const List<Map<String, dynamic>> kDeviceSeedData = [
  {
    'id': 'seed-1',
    'name': 'Apple iPhone 15 Pro',
    'data': {'color': 'Titanium', 'capacity': '256 GB', 'price': 1099.00, 'year': 2023},
  },
  {
    'id': 'seed-2',
    'name': 'Google Pixel 8',
    'data': {'color': 'Obsidian', 'capacity': '128 GB', 'price': 699},
  },
  {
    'id': 'seed-3',
    'name': 'Apple MacBook Pro 16',
    'data': {
      'year': 2023,
      'Price': r'$2,499.00',
      'CPU model': 'Apple M3 Pro',
      'Hard disk size': '1 TB',
    },
  },
  {
    'id': 'seed-4',
    'name': 'Dell XPS 13 Laptop',
    'data': {'price': 999.99, 'Screen size': '13.4 inch', 'year': 2022},
  },
  {
    'id': 'seed-5',
    'name': 'Apple iPad Air',
    'data': {'capacity': '64 GB', 'price': 599},
  },
  {
    // data: null — exercises the missing-attributes fallback path.
    'id': 'seed-6',
    'name': 'Logitech MX Master 3 Mouse',
    'data': null,
  },
  {
    // No price — exercises the standard-deposit fallback and price sort.
    'id': 'seed-7',
    'name': 'Sony WH-1000XM5 Headphones',
    'data': {'color': 'Black', 'Bluetooth': '5.2'},
  },
  {
    'id': 'seed-8',
    'name': 'Apple Watch Series 9',
    'data': {'price': 399, 'case size': '45 mm'},
  },
  {
    'id': 'seed-9',
    'name': 'Samsung 27" 4K Monitor',
    'data': {'price': '349.50', 'resolution': '3840x2160'},
  },
  {
    'id': 'seed-10',
    'name': 'Nintendo Switch OLED Console',
    'data': {'price': 349, 'storage': '64 GB'},
  },
];
