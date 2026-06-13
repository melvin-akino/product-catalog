-- Fix product specifications: convert single-row multi-column to one <tr> per spec
-- Run: docker exec -i eon_mysql mariadb -u root -peon_secret product_catalog < fix-specs.sql

UPDATE products SET specifications = '<table><tbody><tr><td><strong>Wattage</strong></td><td>100W / 150W / 200W</td></tr><tr><td><strong>IP Rating</strong></td><td>IP65 Waterproof</td></tr><tr><td><strong>Voltage</strong></td><td>AC85-265V</td></tr></tbody></table>' WHERE product_id = 1;

UPDATE products SET specifications = '<table><tbody><tr><td><strong>Wattage</strong></td><td>200W / 300W / 400W</td></tr><tr><td><strong>IP Rating</strong></td><td>IP65 Waterproof</td></tr><tr><td><strong>Voltage</strong></td><td>AC85-265V</td></tr></tbody></table>' WHERE product_id = 2;

UPDATE products SET specifications = '<table><tbody><tr><td><strong>Wattage</strong></td><td>100W / 150W / 200W / 300W</td></tr><tr><td><strong>IP Rating</strong></td><td>IP65 Waterproof</td></tr><tr><td><strong>Voltage</strong></td><td>AC110-265V</td></tr></tbody></table>' WHERE product_id = 3;

UPDATE products SET specifications = '<table><tbody><tr><td><strong>Wattage</strong></td><td>36x3W</td></tr><tr><td><strong>Control</strong></td><td>DMX512</td></tr><tr><td><strong>IP Rating</strong></td><td>IP65 Waterproof</td></tr><tr><td><strong>Voltage</strong></td><td>AC110-240V</td></tr></tbody></table>' WHERE product_id = 4;

UPDATE products SET specifications = '<table><tbody><tr><td><strong>Wattage</strong></td><td>36x1W</td></tr><tr><td><strong>Color</strong></td><td>RGB or Warm White</td></tr><tr><td><strong>Control</strong></td><td>DMX512 or None</td></tr><tr><td><strong>IP Rating</strong></td><td>IP65 Waterproof</td></tr><tr><td><strong>Voltage</strong></td><td>DC24V</td></tr></tbody></table>' WHERE product_id = 5;

UPDATE products SET specifications = '<table><tbody><tr><td><strong>LED</strong></td><td>6pcs 3535 RGB</td></tr><tr><td><strong>Color</strong></td><td>RGB</td></tr><tr><td><strong>Shell</strong></td><td>Transparent Flat Cover</td></tr><tr><td><strong>Control</strong></td><td>DMX512</td></tr><tr><td><strong>IP Rating</strong></td><td>IP65 Waterproof</td></tr><tr><td><strong>Voltage</strong></td><td>DC24V</td></tr></tbody></table>' WHERE product_id = 6;

UPDATE products SET specifications = '<table><tbody><tr><td><strong>Wattage</strong></td><td>100W / 150W / 200W</td></tr><tr><td><strong>IP Rating</strong></td><td>IP65 Waterproof</td></tr><tr><td><strong>Voltage</strong></td><td>AC85-277V</td></tr></tbody></table>' WHERE product_id = 7;

UPDATE products SET specifications = '<table><tbody><tr><td><strong>Wattage</strong></td><td>10W (60cm) / 20W (120cm)</td></tr><tr><td><strong>Color Temperature</strong></td><td>Daylight</td></tr><tr><td><strong>Voltage</strong></td><td>AC220V</td></tr></tbody></table>' WHERE product_id = 8;

UPDATE products SET specifications = '<table><tbody><tr><td><strong>Wattage</strong></td><td>2x3W</td></tr><tr><td><strong>Color Temperature</strong></td><td>Daylight</td></tr><tr><td><strong>Material</strong></td><td>Thermoplastic ABS</td></tr><tr><td><strong>Voltage</strong></td><td>AC220V</td></tr></tbody></table>' WHERE product_id = 9;

UPDATE products SET specifications = '<table><tbody><tr><td><strong>Wattage</strong></td><td>1x10W / 1x20W / 2x10W / 2x20W</td></tr><tr><td><strong>Voltage</strong></td><td>AC220V</td></tr></tbody></table>' WHERE product_id = 10;
