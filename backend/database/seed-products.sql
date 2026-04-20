-- ============================================================
-- EON Marketing & General Merchandise - Product Seed Data
-- Based on: facebook.com/eonmgm | San Juan
-- ============================================================
USE product_catalog;

-- ── Categories (safe upsert) ─────────────────────────────────
INSERT IGNORE INTO categories (name, description, slug) VALUES
  ('Lighting',    'LED and industrial lighting solutions',              'lighting'),
  ('Equipment',   'Power tools, generators, and heavy-duty equipment', 'equipment'),
  ('Accessories', 'Electrical accessories, fittings, and safety gear', 'accessories');

-- ── Helper: category ID lookups ──────────────────────────────
SET @lid = (SELECT category_id FROM categories WHERE slug='lighting'    LIMIT 1);
SET @eid = (SELECT category_id FROM categories WHERE slug='equipment'   LIMIT 1);
SET @aid = (SELECT category_id FROM categories WHERE slug='accessories' LIMIT 1);

-- ── Lighting Products ─────────────────────────────────────────
INSERT IGNORE INTO products (name, description, specifications, images, category_id, slug, featured) VALUES

('LED High Bay Light 100W UFO',
 'Industrial-grade UFO high bay light for warehouses, factories, and large commercial spaces. Die-cast aluminum housing with high-efficiency LED chips delivering up to 13,000 lumens. IP65 rated for dust and moisture resistance.',
 '{"Power":"100W","Lumens":"13000 lm","Color Temp":"6500K Cool White","Voltage":"AC100-277V","Beam Angle":"120 deg","IP Rating":"IP65","Lifespan":"50000 hours","CRI":">80","Housing":"Die-cast Aluminum","Warranty":"2 Years"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+High+Bay+100W","https://placehold.co/800x600/1a1a1a/00e676?text=High+Bay+Detail"]',
 @lid, 'led-high-bay-light-100w-ufo', 1),

('LED High Bay Light 200W UFO',
 'Heavy-duty 200W UFO high bay for large industrial spaces requiring high-intensity illumination. Suitable for ceilings 8-15 meters high. Built-in surge protection and thermal management system.',
 '{"Power":"200W","Lumens":"26000 lm","Color Temp":"6500K Cool White","Voltage":"AC100-277V","Beam Angle":"120 deg","IP Rating":"IP65","Lifespan":"50000 hours","CRI":">80","Mounting":"Hook or Bracket","Warranty":"2 Years"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+High+Bay+200W","https://placehold.co/800x600/1a1a1a/00e676?text=High+Bay+200W+Side"]',
 @lid, 'led-high-bay-light-200w-ufo', 0),

('LED Panel Light 36W Slim Recessed',
 'Ultra-slim recessed LED panel light perfect for office ceilings, retail spaces, and commercial interiors. Provides uniform, glare-free illumination with a sleek frameless design.',
 '{"Power":"36W","Lumens":"3600 lm","Color Temp":"4000K Neutral White","Size":"600mm x 600mm","Voltage":"AC220-240V","IP Rating":"IP44","Lifespan":"40000 hours","CRI":">80","Thickness":"10mm","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+Panel+36W","https://placehold.co/800x600/1a1a1a/00e676?text=Panel+Light+Installed"]',
 @lid, 'led-panel-light-36w-slim', 1),

('LED Flood Light 200W IP66',
 'Weatherproof outdoor LED flood light for perimeter security, building facades, sports courts, and parking areas. Double-sealed IP66 housing withstands heavy rain and dust.',
 '{"Power":"200W","Lumens":"20000 lm","Color Temp":"6500K Daylight","Voltage":"AC85-265V","Beam Angle":"120 deg","IP Rating":"IP66","Lifespan":"50000 hours","Material":"Die-cast Aluminum","Operating Temp":"-30C to +50C","Warranty":"2 Years"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+Flood+200W","https://placehold.co/800x600/1a1a1a/00e676?text=Flood+Light+Outdoor"]',
 @lid, 'led-flood-light-200w-ip66', 1),

('LED Flood Light 100W IP65',
 'Mid-range outdoor flood light for driveways, gardens, building entrances, and small courts. Adjustable mounting bracket allows up to 180 degrees vertical rotation. Replaces 400W halogen floods.',
 '{"Power":"100W","Lumens":"10000 lm","Color Temp":"6500K Daylight","Voltage":"AC85-265V","IP Rating":"IP65","Lifespan":"50000 hours","Material":"Aluminum Alloy","Mounting":"Adjustable Bracket","Warranty":"2 Years"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+Flood+100W"]',
 @lid, 'led-flood-light-100w-ip65', 0),

('LED Street Light 80W',
 'High-efficiency LED street light for road illumination, pathways, and parking lots. Features photocell sensor option and dusk-to-dawn operation. Aerodynamic housing reduces wind load on poles.',
 '{"Power":"80W","Lumens":"9600 lm","Color Temp":"6000K","Voltage":"AC85-265V","IP Rating":"IP66","Lifespan":"50000 hours","Mounting":"Slip Fitter 40-60mm","Beam Pattern":"Type II-III Road Pattern","Warranty":"3 Years"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+Street+Light+80W","https://placehold.co/800x600/1a1a1a/00e676?text=Street+Light+Pole"]',
 @lid, 'led-street-light-80w', 0),

('LED Tube Light T8 18W 4ft',
 'Direct LED T8 replacement tube for fluorescent fixtures. Works as plug-and-play with existing ballast or ballast-bypass for direct line voltage. Ideal for offices, stores, garages, and corridors.',
 '{"Power":"18W","Replaces":"36W Fluorescent","Lumens":"1800 lm","Color Temp":"6500K Cool White","Length":"1200mm 4ft","Base":"G13 T8","Voltage":"AC85-265V","CRI":">80","Lifespan":"30000 hours","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+T8+Tube+18W"]',
 @lid, 'led-tube-t8-18w-4ft', 0),

('LED Bulb A60 12W E27',
 'Energy-saving LED replacement for standard incandescent bulbs. Fits all standard E27 sockets. Instant full brightness with no warm-up time. Suitable for residential, office, and retail use.',
 '{"Power":"12W","Replaces":"75W Incandescent","Lumens":"1200 lm","Color Temp":"6500K or 4000K or 3000K","Base":"E27","Voltage":"AC220-240V","CRI":">80","Lifespan":"25000 hours","Dimmable":"No","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+Bulb+12W+E27"]',
 @lid, 'led-bulb-a60-12w-e27', 0),

('Emergency LED Batten Light 2ft 18W',
 'Dual-function LED batten with built-in rechargeable battery backup. Operates normally on mains power and automatically switches to emergency mode during outages. 3-hour backup duration.',
 '{"Power":"18W normal / 6W emergency","Lumens":"1800 lm","Color Temp":"6500K","Battery":"3.7V 4400mAh Li-ion","Emergency Duration":"3 hours","Voltage":"AC220-240V","Length":"600mm 2ft","IP Rating":"IP20","Lifespan":"30000 hours","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Emergency+LED+Batten","https://placehold.co/800x600/1a1a1a/00e676?text=Emergency+Light+Battery"]',
 @lid, 'emergency-led-batten-18w', 1),

('Solar LED Street Light All-in-One 30W',
 'Self-contained solar street light with integrated solar panel, lithium battery, and PIR motion sensor. No wiring required — perfect for remote roads, subdivisions, and pathways without grid power.',
 '{"Solar Panel":"30W Monocrystalline","LED Power":"30W","Lumens":"3000 lm","Battery":"25600mAh Lithium","Motion Sensor":"PIR 8-10m Range","Charge Time":"6-8 hours full sun","Work Time":"10-12 hours","IP Rating":"IP65","Pole Dia":"50-70mm","Warranty":"2 Years"}',
 '["https://placehold.co/800x600/111111/00e676?text=Solar+Street+Light+30W","https://placehold.co/800x600/1a1a1a/00e676?text=Solar+Light+Installed"]',
 @lid, 'solar-led-street-light-30w', 1),

-- ── Equipment Products ────────────────────────────────────────

('Portable Gasoline Generator 3.0 KVA',
 'Reliable single-phase portable generator with 4-stroke air-cooled gasoline engine. Features an AVR for stable output, ideal for households, construction sites, and businesses during power interruptions.',
 '{"Rated Output":"3.0 KVA / 2.4 KW","Max Output":"3.3 KVA","Engine":"4-Stroke OHV Air-Cooled","Fuel":"Gasoline RON 91+","Tank":"15L","Runtime":"8-10 hours at 75% load","Start":"Recoil + Electric","Outlets":"2x 230V AC + 1x 12V DC","Frequency":"60Hz","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Generator+3KVA","https://placehold.co/800x600/1a1a1a/00e676?text=Generator+Engine"]',
 @eid, 'portable-generator-3kva', 1),

('Automatic Voltage Regulator 5000VA',
 'Protects appliances from voltage fluctuations, spikes, and brownouts. Microprocessor-controlled step voltage regulation with time-delay relay. Wide input range suits Philippine grid conditions.',
 '{"Capacity":"5000VA / 4000W","Input Range":"140-260V AC","Output":"220V +-8%","Frequency":"50/60Hz","Time Delay":"5 seconds","Protection":"Over/Under Voltage, Short Circuit","Outlets":"6x Universal","Display":"Digital Voltmeter","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=AVR+5000VA","https://placehold.co/800x600/1a1a1a/00e676?text=AVR+Rear+Panel"]',
 @eid, 'automatic-voltage-regulator-5000va', 1),

('Electric Drill 13mm 850W Variable Speed',
 'Versatile corded electric drill for wood, metal, and concrete (with hammer mode). Variable speed trigger and reversible rotation for screwdriving. Robust all-metal chuck for secure bit clamping.',
 '{"Power":"850W","Chuck":"13mm Keyless","Speed":"0-3000 RPM variable","Max Torque":"18 Nm","Modes":"Drill / Hammer Drill","Voltage":"220-240V AC","Cable":"2.5m","Weight":"1.9kg","Includes":"Auxiliary Handle, Depth Stop","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Electric+Drill+850W","https://placehold.co/800x600/1a1a1a/00e676?text=Drill+Chuck+Close-up"]',
 @eid, 'electric-drill-13mm-850w', 0),

('Angle Grinder 4 inch 850W',
 'Heavy-duty angle grinder for cutting, grinding, and polishing metal, stone, and concrete. Ergonomic anti-vibration handle and spindle lock for quick disc changes. Safety guard included.',
 '{"Power":"850W","Disc Size":"100mm 4 inch","Speed":"12000 RPM","Spindle":"M10","Voltage":"220-240V AC","Cable":"2.0m","Weight":"1.7kg","Includes":"Grinding Disc, Cutting Disc, Safety Guard, Handle","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Angle+Grinder+4in","https://placehold.co/800x600/1a1a1a/00e676?text=Grinder+Side+View"]',
 @eid, 'angle-grinder-4in-850w', 0),

('MMA Welding Machine ARC 200A Inverter',
 'Compact inverter-based arc welding machine delivering stable, high-quality welds. IGBT technology provides smooth welding on mild steel, stainless, and cast iron using standard electrodes.',
 '{"Rated Output":"200A","Input":"220V single phase","Duty Cycle":"60% at 200A","Electrode Dia":"1.6-4.0mm","OCV":"75V","Efficiency":">85%","Power Factor":">0.93","Weight":"4.2kg","Protection":"Over-current, Over-heat, Over-voltage","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Welding+Machine+200A","https://placehold.co/800x600/1a1a1a/00e676?text=Welder+Panel"]',
 @eid, 'mma-welding-machine-200a', 1),

('Air Compressor 1.5HP 24L Oil-Free',
 'Quiet, oil-free air compressor for inflation, spray painting, nailing, and light pneumatic tools. Belt-less direct-drive motor reduces maintenance. Thermal overload protection prevents burnout.',
 '{"Motor":"1.5HP 1100W","Tank":"24 Liters","Max Pressure":"8 Bar 116 PSI","Air Delivery":"125 L/min","Noise":"72 dB","Power":"220V 60Hz","Weight":"18kg","Oil-Free":"Yes","Connections":"1x 1/4 inch Quick-Connect + Gauge","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Air+Compressor+24L","https://placehold.co/800x600/1a1a1a/00e676?text=Compressor+Tank"]',
 @eid, 'air-compressor-1-5hp-24l', 0),

('Heavy Duty Extension Cord 10M 4-Gang',
 'Industrial-grade extension cord for workshops and construction sites. Thick copper wire handles high-current loads safely. Individual switch per outlet with LED indicator.',
 '{"Length":"10 Meters","Outlets":"4-Gang Universal","Wire":"3x1.5mm sq Copper","Max Current":"16A","Max Power":"3520W","Voltage":"250V AC","Plug":"3-Pin Grounded","Switch":"Master + Individual Outlet Switches","Cable":"PVC Flexible","Warranty":"6 Months"}',
 '["https://placehold.co/800x600/111111/00e676?text=Extension+Cord+10M","https://placehold.co/800x600/1a1a1a/00e676?text=Extension+Cord+Outlets"]',
 @eid, 'heavy-duty-extension-cord-10m', 0),

('Digital Clamp Meter Auto-Ranging 400A',
 'Professional auto-ranging clamp meter measuring AC/DC current up to 400A without disconnecting circuits. Also measures voltage, resistance, capacitance, frequency, and temperature.',
 '{"AC Current":"0-400A","DC Current":"0-400A","AC/DC Voltage":"0-600V","Resistance":"0-40M Ohm","Capacitance":"0-100uF","Frequency":"0-10MHz","Temperature":"-20C to 400C","Display":"4000 Count LCD","Auto-Ranging":"Yes","Battery":"AAA x2","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Clamp+Meter+400A","https://placehold.co/800x600/1a1a1a/00e676?text=Clamp+Meter+Display"]',
 @eid, 'digital-clamp-meter-400a', 0),

-- ── Accessories Products ──────────────────────────────────────

('MCB Circuit Breaker 2P 30A DIN Rail',
 'Double-pole miniature circuit breaker for overload and short-circuit protection in residential and commercial panels. DIN rail mount. IEC 60898 compliant.',
 '{"Poles":"2-Pole","Rated Current":"30A","Trip Curve":"C-Curve","Breaking Capacity":"6kA","Rated Voltage":"230/400V AC","Frequency":"50/60Hz","Standard":"IEC 60898","Mounting":"35mm DIN Rail","Certifications":"CE RoHS","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=MCB+Breaker+30A","https://placehold.co/800x600/1a1a1a/00e676?text=MCB+DIN+Rail"]',
 @aid, 'mcb-circuit-breaker-2p-30a', 0),

('PVC Flexible Conduit 1/2 inch x 50M Roll',
 'Flexible PVC electrical conduit for routing and protecting wiring in walls, ceilings, and exposed installations. UV-resistant and flame-retardant. Compatible with standard fittings and connectors.',
 '{"Size":"1/2 inch 13mm ID","Length":"50 Meters per Roll","Material":"PVC Flame Retardant","Max Temp":"70C","Standard":"IEC 60670","Application":"Concealed and Exposed Wiring","UV Resistant":"Yes","Flame Retardant":"Yes"}',
 '["https://placehold.co/800x600/111111/00e676?text=PVC+Conduit+50M"]',
 @aid, 'pvc-flexible-conduit-half-inch-50m', 0),

('Weatherproof Junction Box IP67 200x200mm',
 'Heavy-duty polycarbonate enclosure for outdoor and industrial electrical connections. IP67 waterproof seal protects against dust and temporary water immersion. Includes 8 cable knockouts.',
 '{"Dimensions":"200mm x 200mm x 80mm","Material":"Polycarbonate PC","IP Rating":"IP67","Color":"Light Gray","Knockouts":"8x M20","Hardware":"Stainless Steel Screws","Operating Temp":"-40C to +120C","Standard":"IEC 60670","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Junction+Box+IP67","https://placehold.co/800x600/1a1a1a/00e676?text=Junction+Box+Open"]',
 @aid, 'weatherproof-junction-box-ip67', 0),

('Cable Tie Nylon 200pcs Assorted',
 'Assorted nylon cable tie kit for organizing wires in electrical panels, server racks, workshops, and home use. High-grade PA66 nylon for UV and chemical resistance. Three sizes included.',
 '{"Quantity":"200 pieces assorted","Sizes":"100mmx2.5mm 100pcs + 150mmx3.6mm 60pcs + 200mmx4.8mm 40pcs","Material":"Nylon PA66","Tensile":"8kg / 18kg / 22kg by size","Temp":"-40C to +85C","Color":"Natural White","Package":"Resealable Bag"}',
 '["https://placehold.co/800x600/111111/00e676?text=Cable+Ties+200pcs"]',
 @aid, 'cable-tie-nylon-200pcs-assorted', 0),

('Safety Helmet Full Brim Hard Hat Class E',
 'Full-brim industrial hard hat providing protection from falling objects, electrical hazards (Class E 20000V), and impact. Six-point ratchet suspension for secure adjustable fit.',
 '{"Standard":"ANSI/ISEA Z89.1-2014","Class":"Type II Class E 20000V","Shell":"HDPE High-Density Polyethylene","Suspension":"6-Point Ratchet Adjustable","Brim":"Full Brim","Weight":"430g","Colors":"White / Yellow / Orange / Red","Temp":"-30C to +50C","Warranty":"3 Years"}',
 '["https://placehold.co/800x600/111111/00e676?text=Hard+Hat+Class+E","https://placehold.co/800x600/1a1a1a/00e676?text=Hard+Hat+Interior"]',
 @aid, 'safety-helmet-full-brim-class-e', 0),

('Electrical Insulation Tape PVC 19mm x 10M 10-Pack',
 'PVC insulation tape for wrapping, bundling, and color-coding electrical wires. Excellent adhesion to PVC, rubber, and metal. Flame-retardant and moisture-resistant. 10-color assorted pack.',
 '{"Width":"19mm","Length":"10m per roll","Quantity":"10 rolls assorted","Material":"PVC","Thickness":"0.18mm","Adhesive":"Rubber-based Pressure Sensitive","Temp":"-10C to +80C","Voltage Rating":"600V","Flame Retardant":"Yes","Colors":"Red Blue Black Yellow Green White Brown Orange Gray Violet"}',
 '["https://placehold.co/800x600/111111/00e676?text=Insulation+Tape+10-Pack"]',
 @aid, 'electrical-insulation-tape-10-pack', 0);

-- ── Update company info ───────────────────────────────────────
UPDATE company_info SET
  name    = 'EON Marketing and General Merchandise',
  address = 'San Juan, Metro Manila, Philippines',
  phone   = '+63 917 000 0000',
  email   = 'eonmgm@gmail.com',
  tagline = 'Your One-Stop Shop for Equipment and Lighting Solutions'
WHERE company_id = 1;

-- ── Update Facebook link ──────────────────────────────────────
UPDATE social_media_links SET url = 'https://www.facebook.com/eonmgm' WHERE platform = 'Facebook';

-- ── Result ───────────────────────────────────────────────────
SELECT CONCAT('Seeded ', COUNT(*), ' products successfully') AS result FROM products;
