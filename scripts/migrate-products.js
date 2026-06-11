// Replaces all products with the official EONMGM product list
// Run: node scripts/migrate-products.js

const products = [
  {
    name: 'LED Canopy',
    brand: 'Comets',
    specs: { 'Wattage': '100W / 150W / 200W', 'IP Rating': 'IP65 Waterproof', 'Voltage': 'AC85-265V' },
    description: 'High-performance LED canopy light designed for gas stations, parking structures, and covered outdoor areas. IP65 waterproof with wide voltage range.',
  },
  {
    name: 'LED Highmast',
    brand: 'Comets',
    specs: { 'Wattage': '200W / 300W / 400W', 'IP Rating': 'IP65 Waterproof', 'Voltage': 'AC85-265V' },
    description: 'Heavy-duty LED highmast light for large outdoor areas including ports, stadiums, and industrial yards. IP65 waterproof, high-lumen output.',
  },
  {
    name: 'LED Streetlight',
    brand: 'Comets',
    specs: { 'Wattage': '100W / 150W / 200W / 300W', 'IP Rating': 'IP65 Waterproof', 'Voltage': 'AC110-265V' },
    description: 'Energy-efficient LED street light for roads, highways, and public pathways. Wide wattage range with IP65 protection for all-weather performance.',
  },
  {
    name: 'LED Wall Washer',
    brand: 'Comets',
    specs: { 'Wattage': '36x3W', 'Control': 'DMX512', 'IP Rating': 'IP65 Waterproof', 'Voltage': 'AC110-240V' },
    description: 'Professional LED wall washer light for architectural and decorative illumination. DMX512 controllable with IP65 waterproof rating for indoor and outdoor use.',
  },
  {
    name: 'LED Linear Bar',
    brand: 'Comets',
    specs: { 'Wattage': '36x1W', 'Color': 'RGB or Warm White', 'Control': 'DMX512 or None', 'IP Rating': 'IP65 Waterproof', 'Voltage': 'DC24V' },
    description: 'Versatile LED linear bar light available in RGB or warm white. Ideal for facade lighting, signage, and decorative applications with optional DMX512 control.',
  },
  {
    name: 'LED Pixel Light',
    brand: 'Comets',
    specs: { 'LED': '6pcs 3535 RGB', 'Color': 'RGB', 'Shell': 'Transparent Flat Cover', 'Control': 'DMX512', 'IP Rating': 'IP65 Waterproof', 'Voltage': 'DC24V' },
    description: 'RGB LED pixel light for dynamic lighting effects and programmable displays. DMX512 controllable with IP65 waterproof rating, suitable for entertainment and architectural use.',
  },
  {
    name: 'LED Highbay',
    brand: 'Comets',
    specs: { 'Wattage': '100W / 150W / 200W', 'IP Rating': 'IP65 Waterproof', 'Voltage': 'AC85-277V' },
    description: 'Industrial LED high bay light for warehouses, factories, and gymnasiums. High-efficiency design with IP65 waterproof rating and broad voltage compatibility.',
  },
  {
    name: 'LED Fluorescent T8',
    brand: 'Infinity',
    specs: { 'Wattage': '10W (60cm) / 20W (120cm)', 'Color Temperature': 'Daylight', 'Voltage': 'AC220V' },
    description: 'Energy-saving LED fluorescent T8 tube replacement for offices, retail, and commercial spaces. Available in 60cm and 120cm lengths with daylight color temperature.',
  },
  {
    name: 'LED Emergency Light',
    brand: 'Globe',
    specs: { 'Wattage': '2x3W', 'Color Temperature': 'Daylight', 'Material': 'Thermoplastic ABS', 'Voltage': 'AC220V' },
    description: 'Reliable LED emergency light for safety and evacuation lighting in commercial and residential buildings. Durable ABS thermoplastic housing with daylight output.',
  },
  {
    name: 'LED Grill Light with Tube',
    brand: 'Infinity',
    specs: { 'Wattage': '1x10W / 1x20W / 2x10W / 2x20W', 'Voltage': 'AC220V' },
    description: 'LED grill light with integrated tube for offices, retail spaces, and commercial ceilings. Available in multiple wattage configurations for flexible installation.',
  },
];

function slugify(str) {
  return str.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

function htmlEscape(s) {
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function toHtmlTable(specs) {
  const rows = Object.entries(specs)
    .map(([k, v]) => `<tr><td><strong>${htmlEscape(k)}</strong></td><td>${htmlEscape(v)}</td></tr>`)
    .join('');
  return `<table><tbody>${rows}</tbody></table>`;
}

function sqlEscape(s) {
  return String(s).replace(/\\/g, '\\\\').replace(/'/g, "\\'");
}

// Delete all existing products
console.log('DELETE FROM products;');
console.log('ALTER TABLE products AUTO_INCREMENT = 1;');

// Insert new products (category_id 2 = Lighting)
for (const p of products) {
  const slug = slugify(p.name);
  const specs = sqlEscape(toHtmlTable(p.specs));
  const desc = sqlEscape(p.description);
  const name = sqlEscape(p.name);
  const brand = sqlEscape(p.brand);
  console.log(
    `INSERT INTO products (name, brand, description, specifications, category_id, slug, featured, status, images) ` +
    `VALUES ('${name}', '${brand}', '${desc}', '${specs}', 2, '${slug}', 0, 'active', '[]');`
  );
}

console.log('SELECT product_id, name, slug FROM products ORDER BY product_id;');
