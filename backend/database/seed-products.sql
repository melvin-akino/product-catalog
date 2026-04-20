-- ============================================================
-- EON Marketing & General Merchandise — Product Seed Data
-- Based on: facebook.com/eonmgm | San Juan
-- ============================================================
USE product_catalog;

-- ── Categories (upsert-safe) ─────────────────────────────────
INSERT IGNORE INTO categories (name, description, slug) VALUES
  ('Lighting',    'LED and industrial lighting solutions',          'lighting'),
  ('Equipment',   'Power tools, generators, and heavy-duty equipment', 'equipment'),
  ('Accessories', 'Electrical accessories, fittings, and safety gear', 'accessories');

-- ── Lighting Products ─────────────────────────────────────────
INSERT IGNORE INTO products (name, description, specifications, images, category_id, slug, featured) VALUES

('LED High Bay Light 100W UFO',
 'Industrial-grade UFO high bay light designed for warehouses, factories, and large commercial spaces. Features die-cast aluminum housing with high-efficiency LED chips delivering up to 13,000 lumens. IP65 rated for dust and moisture resistance.',
 '{"Power":"100W","Lumens":"13,000 lm","Color Temperature":"6500K Cool White","Input Voltage":"AC100–277V","Beam Angle":"120°","IP Rating":"IP65","Lifespan":"50,000 hours","CRI":">80","Housing":"Die-cast Aluminum","Warranty":"2 Years"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+High+Bay+100W","https://placehold.co/800x600/1a1a1a/00e676?text=High+Bay+Detail"]',
 (SELECT category_id FROM categories WHERE slug='lighting' LIMIT 1),
 'led-high-bay-light-100w-ufo', 1),

('LED High Bay Light 200W UFO',
 'Heavy-duty 200W UFO high bay for large industrial spaces requiring high-intensity illumination. Suitable for ceilings 8–15 meters high. Built-in surge protection and thermal management system ensures long operational life.',
 '{"Power":"200W","Lumens":"26,000 lm","Color Temperature":"6500K Cool White","Input Voltage":"AC100–277V","Beam Angle":"120°","IP Rating":"IP65","Lifespan":"50,000 hours","CRI":">80","Mounting":"Hook / Bracket","Warranty":"2 Years"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+High+Bay+200W","https://placehold.co/800x600/1a1a1a/00e676?text=High+Bay+200W+Side"]',
 (SELECT category_id FROM categories WHERE slug='lighting' LIMIT 1),
 'led-high-bay-light-200w-ufo', 0),

('LED Panel Light 36W Slim Recessed',
 'Ultra-slim recessed LED panel light perfect for office ceilings, retail spaces, and commercial interiors. Provides uniform, glare-free illumination with a sleek frameless design. Easy drop-ceiling installation.',
 '{"Power":"36W","Lumens":"3,600 lm","Color Temperature":"4000K Neutral White","Size":"600mm × 600mm","Input Voltage":"AC220–240V","IP Rating":"IP44","Lifespan":"40,000 hours","CRI":">80","Thickness":"10mm","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+Panel+36W","https://placehold.co/800x600/1a1a1a/00e676?text=Panel+Light+Installed"]',
 (SELECT category_id FROM categories WHERE slug='lighting' LIMIT 1),
 'led-panel-light-36w-slim', 1),

('LED Flood Light 200W IP66',
 'Weatherproof outdoor LED flood light built for perimeter security, building facades, sports courts, and parking areas. Double-sealed IP66 housing withstands heavy rain and dust. Wide 120° beam covers large areas efficiently.',
 '{"Power":"200W","Lumens":"20,000 lm","Color Temperature":"6500K Daylight","Input Voltage":"AC85–265V","Beam Angle":"120°","IP Rating":"IP66","Lifespan":"50,000 hours","Material":"Die-cast Aluminum + Tempered Glass","Operating Temp":"-30°C to +50°C","Warranty":"2 Years"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+Flood+200W","https://placehold.co/800x600/1a1a1a/00e676?text=Flood+Light+Outdoor"]',
 (SELECT category_id FROM categories WHERE slug='lighting' LIMIT 1),
 'led-flood-light-200w-ip66', 1),

('LED Flood Light 100W IP65',
 'Mid-range outdoor flood light suitable for driveways, gardens, building entrances, and small courts. Adjustable mounting bracket allows up to 180° vertical rotation. Energy-saving replacement for 400W halogen floods.',
 '{"Power":"100W","Lumens":"10,000 lm","Color Temperature":"6500K Daylight","Input Voltage":"AC85–265V","IP Rating":"IP65","Lifespan":"50,000 hours","Material":"Aluminum Alloy","Mounting":"Adjustable Bracket","Warranty":"2 Years"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+Flood+100W"]',
 (SELECT category_id FROM categories WHERE slug='lighting' LIMIT 1),
 'led-flood-light-100w-ip65', 0),

('LED Street Light 80W',
 'High-efficiency LED street light designed for road illumination, pathways, and parking lots. Features a photocell sensor option and dusk-to-dawn operation capability. Aerodynamic housing reduces wind load on poles.',
 '{"Power":"80W","Lumens":"9,600 lm","Color Temperature":"6000K","Input Voltage":"AC85–265V","IP Rating":"IP66","Lifespan":"50,000 hours","Mounting":"Slip Fitter 40–60mm","Beam Pattern":"Type II / III Road Pattern","Warranty":"3 Years"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+Street+Light+80W","https://placehold.co/800x600/1a1a1a/00e676?text=Street+Light+Pole"]',
 (SELECT category_id FROM categories WHERE slug='lighting' LIMIT 1),
 'led-street-light-80w', 0),

('LED Tube Light T8 18W 4ft',
 'Direct LED T8 replacement tube for fluorescent fixtures. Works as plug-and-play with existing ballast or ballast-bypass for direct line voltage. Ideal for offices, stores, garages, and corridors.',
 '{"Power":"18W","Replaces":"36W Fluorescent","Lumens":"1,800 lm","Color Temperature":"6500K Cool White / 4000K Neutral","Length":"1200mm (4ft)","Base":"G13 (T8)","Input Voltage":"AC85–265V","CRI":">80","Lifespan":"30,000 hours","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+T8+Tube+18W"]',
 (SELECT category_id FROM categories WHERE slug='lighting' LIMIT 1),
 'led-tube-t8-18w-4ft', 0),

('LED Bulb A60 12W E27',
 'Energy-saving LED replacement for standard incandescent bulbs. Fits all standard E27 sockets. Instant full brightness with no warm-up time. Suitable for residential, office, and retail lighting.',
 '{"Power":"12W","Replaces":"75W Incandescent","Lumens":"1,200 lm","Color Temperature":"6500K / 4000K / 3000K","Base":"E27","Input Voltage":"AC220–240V","CRI":">80","Lifespan":"25,000 hours","Dimmable":"Non-dimmable","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=LED+Bulb+12W+E27"]',
 (SELECT category_id FROM categories WHERE slug='lighting' LIMIT 1),
 'led-bulb-a60-12w-e27', 0),

('Emergency LED Batten Light 2ft 18W',
 'Dual-function LED batten with built-in rechargeable battery backup. Operates normally on mains power and automatically switches to emergency mode during power outages. 3-hour backup duration. Ideal for offices, corridors, stairwells.',
 '{"Power":"18W (Normal) / 6W (Emergency)","Lumens":"1,800 lm","Color Temperature":"6500K","Battery":"3.7V 4400mAh Li-ion","Emergency Duration":"3 Hours","Input Voltage":"AC220–240V","Length":"600mm (2ft)","IP Rating":"IP20","Lifespan":"30,000 hours","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Emergency+LED+Batten","https://placehold.co/800x600/1a1a1a/00e676?text=Emergency+Light+Battery"]',
 (SELECT category_id FROM categories WHERE slug='lighting' LIMIT 1),
 'emergency-led-batten-18w', 1),

('Solar LED Street Light All-in-One 30W',
 'Self-contained solar street light with integrated solar panel, lithium battery, and PIR motion sensor. No wiring required — perfect for remote roads, subdivisions, and pathways where grid power is unavailable. Auto on/off at dusk/dawn.',
 '{"Solar Panel":"30W Monocrystalline","LED Power":"30W","Lumens":"3,000 lm","Battery":"25,600mAh Lithium","Motion Sensor":"PIR 8–10m Range","Charging Time":"6–8 hours full sun","Working Time":"10–12 hours","IP Rating":"IP65","Pole Diameter":"50–70mm","Warranty":"2 Years"}',
 '["https://placehold.co/800x600/111111/00e676?text=Solar+Street+Light+30W","https://placehold.co/800x600/1a1a1a/00e676?text=Solar+Light+Installed"]',
 (SELECT category_id FROM categories WHERE slug='lighting' LIMIT 1),
 'solar-led-street-light-30w', 1),

-- ── Equipment Products ────────────────────────────────────────

('Portable Gasoline Generator 3.0 KVA',
 'Reliable single-phase portable generator powered by a 4-stroke air-cooled gasoline engine. Features an AVR (Automatic Voltage Regulator) for stable output, ideal for households, construction sites, and small businesses during power interruptions.',
 '{"Rated Output":"3.0 KVA / 2.4 KW","Max Output":"3.3 KVA","Engine":"4-Stroke OHV Air-Cooled","Fuel Type":"Gasoline (RON 91+)","Tank Capacity":"15L","Running Time":"8–10 hours at 75% load","Starting System":"Recoil + Electric Start","Outlets":"2× 230V AC + 1× 12V DC","Frequency":"60Hz","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Generator+3KVA","https://placehold.co/800x600/1a1a1a/00e676?text=Generator+Engine"]',
 (SELECT category_id FROM categories WHERE slug='equipment' LIMIT 1),
 'portable-generator-3kva', 1),

('Automatic Voltage Regulator (AVR) 5000VA',
 'Protects appliances and equipment from voltage fluctuations, spikes, and brownouts. Features microprocessor-controlled step voltage regulation and time-delay relay to protect compressors. Wide input range suits Philippine grid conditions.',
 '{"Capacity":"5000VA / 4000W","Input Voltage Range":"140–260V AC","Output Voltage":"220V ±8%","Frequency":"50/60Hz","Time Delay Relay":"5 seconds","Protection":"Over-voltage, Under-voltage, Short Circuit","Outlets":"6× Universal Outlets","Display":"Digital Voltmeter","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=AVR+5000VA","https://placehold.co/800x600/1a1a1a/00e676?text=AVR+Rear+Panel"]',
 (SELECT category_id FROM categories WHERE slug='equipment' LIMIT 1),
 'automatic-voltage-regulator-5000va', 1),

('Electric Drill 13mm 850W Variable Speed',
 'Versatile corded electric drill for drilling into wood, metal, concrete (with hammer mode). Variable speed trigger and reversible rotation for screwdriving. Robust all-metal chuck ensures secure bit clamping.',
 '{"Power":"850W","Chuck Capacity":"13mm Keyless","No-Load Speed":"0–3000 RPM (Variable)","Max Torque":"18 Nm","Modes":"Drill / Hammer Drill","Voltage":"220–240V AC","Cable Length":"2.5m","Weight":"1.9kg","Includes":"Auxiliary Handle, Depth Stop","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Electric+Drill+850W","https://placehold.co/800x600/1a1a1a/00e676?text=Drill+Chuck+Close-up"]',
 (SELECT category_id FROM categories WHERE slug='equipment' LIMIT 1),
 'electric-drill-13mm-850w', 0),

('Angle Grinder 4" 850W',
 'Heavy-duty angle grinder for cutting, grinding, and polishing metal, stone, and concrete. Ergonomic anti-vibration handle and spindle lock for quick disc changes. Safety guard included. Suitable for construction, fabrication, and maintenance work.',
 '{"Power":"850W","Disc Size":"100mm (4\")","No-Load Speed":"12,000 RPM","Spindle Thread":"M10","Voltage":"220–240V AC","Cable Length":"2.0m","Weight":"1.7kg","Includes":"Grinding Disc, Cutting Disc, Safety Guard, Auxiliary Handle","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Angle+Grinder+4in","https://placehold.co/800x600/1a1a1a/00e676?text=Grinder+Side+View"]',
 (SELECT category_id FROM categories WHERE slug='equipment' LIMIT 1),
 'angle-grinder-4in-850w', 0),

('MMA Welding Machine ARC 200A Inverter',
 'Compact inverter-based arc welding machine delivering stable, high-quality welds. IGBT technology provides smooth welding on mild steel, stainless, and cast iron using standard electrodes. Lightweight design for portability on job sites.',
 '{"Rated Output":"200A","Input Voltage":"220V ±15% Single Phase","Duty Cycle":"60% @ 200A","Electrode Diameter":"1.6–4.0mm","Open Circuit Voltage":"75V","Efficiency":">85%","Power Factor":">0.93","Weight":"4.2kg","Protection":"Over-current, Over-heat, Over-voltage","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Welding+Machine+200A","https://placehold.co/800x600/1a1a1a/00e676?text=Welder+Panel"]',
 (SELECT category_id FROM categories WHERE slug='equipment' LIMIT 1),
 'mma-welding-machine-200a', 1),

('Air Compressor 1.5HP 24L Oil-Free',
 'Quiet, oil-free air compressor for inflation, spray painting, nailing, and light pneumatic tools. Belt-less direct-drive motor reduces maintenance. Thermal overload protection prevents motor burnout. Portable with carry handle and wheels.',
 '{"Motor":"1.5HP (1100W)","Tank Capacity":"24 Liters","Max Pressure":"8 Bar (116 PSI)","Free Air Delivery":"125 L/min","Noise Level":"72 dB","Power Supply":"220V / 60Hz","Weight":"18kg","Oil-Free":"Yes","Connections":"1× 1/4\" Quick-Connect, 1× Gauge","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Air+Compressor+24L","https://placehold.co/800x600/1a1a1a/00e676?text=Compressor+Tank"]',
 (SELECT category_id FROM categories WHERE slug='equipment' LIMIT 1),
 'air-compressor-1-5hp-24l', 0),

('Heavy Duty Extension Cord 10M 4-Gang',
 'Industrial-grade extension cord built for workshops and construction sites. Thick 3×1.5mm² copper wire handles high-current loads safely. Individual switch per outlet with LED indicator. Cord reel design prevents tangling.',
 '{"Length":"10 Meters","Outlets":"4-Gang Universal","Wire Gauge":"3×1.5mm² Copper","Max Current":"16A","Max Power":"3,520W","Voltage Rating":"250V AC","Plug Type":"3-Pin (Grounded)","Switch":"Master Switch + Individual Outlet Switches","Cable":"PVC Jacketed Flexible","Warranty":"6 Months"}',
 '["https://placehold.co/800x600/111111/00e676?text=Extension+Cord+10M","https://placehold.co/800x600/1a1a1a/00e676?text=Extension+Cord+Outlets"]',
 (SELECT category_id FROM categories WHERE slug='equipment' LIMIT 1),
 'heavy-duty-extension-cord-10m', 0),

('Digital Clamp Meter Auto-Ranging 400A',
 'Professional auto-ranging clamp meter for measuring AC/DC current up to 400A without disconnecting circuits. Also measures voltage, resistance, capacitance, frequency, and temperature. Data hold and MAX/MIN recording.',
 '{"AC Current":"0–400A","DC Current":"0–400A","AC/DC Voltage":"0–600V","Resistance":"0–40MΩ","Capacitance":"0–100µF","Frequency":"0–10MHz","Temperature":"-20°C to 400°C","Display":"4000 Count LCD","Auto-Ranging":"Yes","Data Hold":"Yes","Battery":"AAA × 2","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Clamp+Meter+400A","https://placehold.co/800x600/1a1a1a/00e676?text=Clamp+Meter+Display"]',
 (SELECT category_id FROM categories WHERE slug='equipment' LIMIT 1),
 'digital-clamp-meter-400a', 0),

-- ── Accessories Products ──────────────────────────────────────

('MCB Circuit Breaker 2P 30A DIN Rail',
 'Double-pole miniature circuit breaker for overload and short-circuit protection in residential and commercial panels. DIN rail mount. IEC 60898 compliant. Provides reliable protection for circuits up to 30A.',
 '{"Poles":"2-Pole (Double Pole)","Rated Current":"30A","Tripping Characteristic":"C-Curve","Breaking Capacity":"6kA (6000A)","Rated Voltage":"230/400V AC","Frequency":"50/60Hz","Standard":"IEC 60898","Mounting":"35mm DIN Rail","Certifications":"CE, RoHS","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=MCB+Breaker+30A","https://placehold.co/800x600/1a1a1a/00e676?text=MCB+DIN+Rail"]',
 (SELECT category_id FROM categories WHERE slug='accessories' LIMIT 1),
 'mcb-circuit-breaker-2p-30a', 0),

('PVC Flexible Conduit 1/2" × 50M Roll',
 'Flexible PVC electrical conduit for routing and protecting wiring in walls, ceilings, and exposed installations. UV-resistant and flame-retardant formulation. Compatible with standard conduit fittings and connectors.',
 '{"Size":"1/2 inch (13mm ID)","Length":"50 Meters per Roll","Material":"PVC (Flame Retardant)","Color":"Orange / Gray (varies)","Max Temperature":"70°C","Standards":"IEC 60670","Application":"Concealed & Exposed Wiring","UV Resistant":"Yes","Flame Retardant":"Yes","Warranty":"N/A"}',
 '["https://placehold.co/800x600/111111/00e676?text=PVC+Conduit+50M"]',
 (SELECT category_id FROM categories WHERE slug='accessories' LIMIT 1),
 'pvc-flexible-conduit-half-inch-50m', 0),

('Weatherproof Junction Box IP67 200×200×80mm',
 'Heavy-duty polycarbonate enclosure for outdoor and industrial electrical connections. IP67 waterproof seal protects against dust ingress and temporary water immersion. Includes 8 cable knockouts and stainless steel mounting hardware.',
 '{"Dimensions":"200mm × 200mm × 80mm","Material":"Polycarbonate (PC)","IP Rating":"IP67","Color":"Light Gray","Cable Knockouts":"8× M20","Cover Screws":"4× Stainless Steel","Operating Temp":"-40°C to +120°C","Transparent Lid":"Optional","Standard":"IEC 60670","Warranty":"1 Year"}',
 '["https://placehold.co/800x600/111111/00e676?text=Junction+Box+IP67","https://placehold.co/800x600/1a1a1a/00e676?text=Junction+Box+Open"]',
 (SELECT category_id FROM categories WHERE slug='accessories' LIMIT 1),
 'weatherproof-junction-box-ip67', 0),

('Cable Tie Nylon Self-Locking 200pcs Assorted',
 'Assorted nylon cable tie kit for organizing wires and cables in electrical panels, server racks, workshops, and home use. Made from high-grade PA66 nylon for UV and chemical resistance. Includes three sizes for different bundle diameters.',
 '{"Quantity":"200 pieces (assorted)","Sizes Included":"100mm × 2.5mm (100pcs), 150mm × 3.6mm (60pcs), 200mm × 4.8mm (40pcs)","Material":"Nylon PA66","Tensile Strength":"8kg / 18kg / 22kg (by size)","Operating Temp":"-40°C to +85°C","Color":"Natural / White","UV Resistant":"Standard grade","Package":"Resealable Bag","Warranty":"N/A"}',
 '["https://placehold.co/800x600/111111/00e676?text=Cable+Ties+200pcs"]',
 (SELECT category_id FROM categories WHERE slug='accessories' LIMIT 1),
 'cable-tie-nylon-200pcs-assorted', 0),

('Safety Helmet Full Brim Hard Hat Class E',
 'Full-brim industrial hard hat providing superior protection from falling objects, electrical hazards (Class E, 20,000V), and impact. Six-point ratchet suspension for a secure, adjustable fit. Suitable for construction, electrical work, and utilities.',
 '{"Standard":"ANSI/ISEA Z89.1-2014","Class":"Type II Class E (Electrical 20,000V)","Shell Material":"High-Density Polyethylene (HDPE)","Suspension":"6-Point Ratchet Adjustable","Brim Type":"Full Brim","Weight":"430g","Colors":"White / Yellow / Orange / Red","Operating Temp":"-30°C to +50°C","Accessory Slots":"Yes (ear muffs, face shields)","Warranty":"3 Years"}',
 '["https://placehold.co/800x600/111111/00e676?text=Hard+Hat+Class+E","https://placehold.co/800x600/1a1a1a/00e676?text=Hard+Hat+Interior"]',
 (SELECT category_id FROM categories WHERE slug='accessories' LIMIT 1),
 'safety-helmet-full-brim-class-e', 0),

('Electrical Insulation Tape PVC 19mm × 10M (10-pack)',
 'High-quality PVC insulation tape for wrapping, bundling, and color-coding electrical wires and cables. Excellent adhesion to PVC, rubber, and metal surfaces. Flame-retardant and moisture-resistant formulation. Available in 10-color assorted pack.',
 '{"Width":"19mm","Length":"10 meters per roll","Quantity":"10 rolls (assorted colors)","Material":"PVC","Thickness":"0.18mm","Adhesive":"Rubber-based Pressure Sensitive","Temperature Range":"-10°C to +80°C","Voltage Rating":"600V","Flame Retardant":"Yes","Colors":"Red, Blue, Black, Yellow, Green, White, Brown, Orange, Gray, Violet","Warranty":"N/A"}',
 '["https://placehold.co/800x600/111111/00e676?text=Insulation+Tape+10-Pack"]',
 (SELECT category_id FROM categories WHERE slug='accessories' LIMIT 1),
 'electrical-insulation-tape-10-pack', 0);

-- ── Update company info to reflect EON identity ──────────────
UPDATE company_info SET
  name    = 'EON Marketing and General Merchandise',
  address = 'San Juan, Metro Manila, Philippines',
  phone   = '+63 (0) 917 000 0000',
  email   = 'eonmgm@gmail.com',
  tagline = 'Your One-Stop Shop for Equipment & Lighting Solutions'
WHERE company_id = 1;

-- ── Update social links ───────────────────────────────────────
UPDATE social_media_links SET url = 'https://www.facebook.com/eonmgm' WHERE platform = 'Facebook';

-- ── Verify seed ───────────────────────────────────────────────
SELECT CONCAT('✓ Seeded ', COUNT(*), ' products') AS status FROM products;
