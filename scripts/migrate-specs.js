// Converts JSON product specifications to 2-column HTML key-value tables
// Run: node scripts/migrate-specs.js | /c/Windows/System32/OpenSSH/ssh.exe ... mariadb ...

const products = [
  { id: 2,  specs: {"Power":"200W","Lumens":"26000 lm","Color Temp":"6500K Cool White","Voltage":"AC100-277V","Beam Angle":"120 deg","IP Rating":"IP65","Lifespan":"50000 hours","CRI":">80","Mounting":"Hook or Bracket","Warranty":"2 Years"} },
  { id: 3,  specs: {"Power":"36W","Lumens":"3600 lm","Color Temp":"4000K Neutral White","Size":"600mm x 600mm","Voltage":"AC220-240V","IP Rating":"IP44","Lifespan":"40000 hours","CRI":">80","Thickness":"10mm","Warranty":"1 Year"} },
  { id: 4,  specs: {"Power":"200W","Lumens":"20000 lm","Color Temp":"6500K Daylight","Voltage":"AC85-265V","Beam Angle":"120 deg","IP Rating":"IP66","Lifespan":"50000 hours","Material":"Die-cast Aluminum","Operating Temp":"-30C to +50C","Warranty":"2 Years"} },
  { id: 5,  specs: {"Power":"100W","Lumens":"10000 lm","Color Temp":"6500K Daylight","Voltage":"AC85-265V","IP Rating":"IP65","Lifespan":"50000 hours","Material":"Aluminum Alloy","Mounting":"Adjustable Bracket","Warranty":"2 Years"} },
  { id: 6,  specs: {"Power":"80W","Lumens":"9600 lm","Color Temp":"6000K","Voltage":"AC85-265V","IP Rating":"IP66","Lifespan":"50000 hours","Mounting":"Slip Fitter 40-60mm","Beam Pattern":"Type II-III Road Pattern","Warranty":"3 Years"} },
  { id: 7,  specs: {"Power":"18W","Replaces":"36W Fluorescent","Lumens":"1800 lm","Color Temp":"6500K Cool White","Length":"1200mm 4ft","Base":"G13 T8","Voltage":"AC85-265V","CRI":">80","Lifespan":"30000 hours","Warranty":"1 Year"} },
  { id: 8,  specs: {"Power":"12W","Replaces":"75W Incandescent","Lumens":"1200 lm","Color Temp":"6500K or 4000K or 3000K","Base":"E27","Voltage":"AC220-240V","CRI":">80","Lifespan":"25000 hours","Dimmable":"No","Warranty":"1 Year"} },
  { id: 9,  specs: {"Power":"18W normal / 6W emergency","Lumens":"1800 lm","Color Temp":"6500K","Battery":"3.7V 4400mAh Li-ion","Emergency Duration":"3 hours","Voltage":"AC220-240V","Length":"600mm 2ft","IP Rating":"IP20","Lifespan":"30000 hours","Warranty":"1 Year"} },
  { id: 10, specs: {"Solar Panel":"30W Monocrystalline","LED Power":"30W","Lumens":"3000 lm","Battery":"25600mAh Lithium","Motion Sensor":"PIR 8-10m Range","Charge Time":"6-8 hours full sun","Work Time":"10-12 hours","IP Rating":"IP65","Pole Dia":"50-70mm","Warranty":"2 Years"} },
  { id: 11, specs: {"Rated Output":"3.0 KVA / 2.4 KW","Max Output":"3.3 KVA","Engine":"4-Stroke OHV Air-Cooled","Fuel":"Gasoline RON 91+","Tank":"15L","Runtime":"8-10 hours at 75% load","Start":"Recoil + Electric","Outlets":"2x 230V AC + 1x 12V DC","Frequency":"60Hz","Warranty":"1 Year"} },
  { id: 12, specs: {"Capacity":"5000VA / 4000W","Input Range":"140-260V AC","Output":"220V +-8%","Frequency":"50/60Hz","Time Delay":"5 seconds","Protection":"Over/Under Voltage, Short Circuit","Outlets":"6x Universal","Display":"Digital Voltmeter","Warranty":"1 Year"} },
  { id: 13, specs: {"Power":"850W","Chuck":"13mm Keyless","Speed":"0-3000 RPM variable","Max Torque":"18 Nm","Modes":"Drill / Hammer Drill","Voltage":"220-240V AC","Cable":"2.5m","Weight":"1.9kg","Includes":"Auxiliary Handle, Depth Stop","Warranty":"1 Year"} },
  { id: 14, specs: {"Power":"850W","Disc Size":"100mm 4 inch","Speed":"12000 RPM","Spindle":"M10","Voltage":"220-240V AC","Cable":"2.0m","Weight":"1.7kg","Includes":"Grinding Disc, Cutting Disc, Safety Guard, Handle","Warranty":"1 Year"} },
  { id: 15, specs: {"Rated Output":"200A","Input":"220V single phase","Duty Cycle":"60% at 200A","Electrode Dia":"1.6-4.0mm","OCV":"75V","Efficiency":">85%","Power Factor":">0.93","Weight":"4.2kg","Protection":"Over-current, Over-heat, Over-voltage","Warranty":"1 Year"} },
  { id: 16, specs: {"Motor":"1.5HP 1100W","Tank":"24 Liters","Max Pressure":"8 Bar 116 PSI","Air Delivery":"125 L/min","Noise":"72 dB","Power":"220V 60Hz","Weight":"18kg","Oil-Free":"Yes","Connections":"1x 1/4 inch Quick-Connect + Gauge","Warranty":"1 Year"} },
  { id: 17, specs: {"Length":"10 Meters","Outlets":"4-Gang Universal","Wire":"3x1.5mm sq Copper","Max Current":"16A","Max Power":"3520W","Voltage":"250V AC","Plug":"3-Pin Grounded","Switch":"Master + Individual Outlet Switches","Cable":"PVC Flexible","Warranty":"6 Months"} },
  { id: 18, specs: {"AC Current":"0-400A","DC Current":"0-400A","AC/DC Voltage":"0-600V","Resistance":"0-40M Ohm","Capacitance":"0-100uF","Frequency":"0-10MHz","Temperature":"-20C to 400C","Display":"4000 Count LCD","Auto-Ranging":"Yes","Battery":"AAA x2","Warranty":"1 Year"} },
  { id: 19, specs: {"Poles":"2-Pole","Rated Current":"30A","Trip Curve":"C-Curve","Breaking Capacity":"6kA","Rated Voltage":"230/400V AC","Frequency":"50/60Hz","Standard":"IEC 60898","Mounting":"35mm DIN Rail","Certifications":"CE RoHS","Warranty":"1 Year"} },
  { id: 20, specs: {"Size":"1/2 inch 13mm ID","Length":"50 Meters per Roll","Material":"PVC Flame Retardant","Max Temp":"70C","Standard":"IEC 60670","Application":"Concealed and Exposed Wiring","UV Resistant":"Yes","Flame Retardant":"Yes"} },
  { id: 21, specs: {"Dimensions":"200mm x 200mm x 80mm","Material":"Polycarbonate PC","IP Rating":"IP67","Color":"Light Gray","Knockouts":"8x M20","Hardware":"Stainless Steel Screws","Operating Temp":"-40C to +120C","Standard":"IEC 60670","Warranty":"1 Year"} },
  { id: 22, specs: {"Quantity":"200 pieces assorted","Sizes":"100mmx2.5mm 100pcs + 150mmx3.6mm 60pcs + 200mmx4.8mm 40pcs","Material":"Nylon PA66","Tensile":"8kg / 18kg / 22kg by size","Temp":"-40C to +85C","Color":"Natural White","Package":"Resealable Bag"} },
  { id: 23, specs: {"Standard":"ANSI/ISEA Z89.1-2014","Class":"Type II Class E 20000V","Shell":"HDPE High-Density Polyethylene","Suspension":"6-Point Ratchet Adjustable","Brim":"Full Brim","Weight":"430g","Colors":"White / Yellow / Orange / Red","Temp":"-30C to +50C","Warranty":"3 Years"} },
  { id: 24, specs: {"Width":"19mm","Length":"10m per roll","Quantity":"10 rolls assorted","Material":"PVC","Thickness":"0.18mm","Adhesive":"Rubber-based Pressure Sensitive","Temp":"-10C to +80C","Voltage Rating":"600V","Flame Retardant":"Yes","Colors":"Red Blue Black Yellow Green White Brown Orange Gray Violet"} },
];

function htmlEscape(s) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function toHtmlTable(specs) {
  const rows = Object.entries(specs)
    .map(([k, v]) => `<tr><td><strong>${htmlEscape(k)}</strong></td><td>${htmlEscape(String(v))}</td></tr>`)
    .join('');
  return `<table><tbody>${rows}</tbody></table>`;
}

function sqlEscape(s) {
  return s.replace(/\\/g, '\\\\').replace(/'/g, "\\'");
}

for (const { id, specs } of products) {
  const html = sqlEscape(toHtmlTable(specs));
  console.log(`UPDATE products SET specifications='${html}' WHERE product_id=${id};`);
}
