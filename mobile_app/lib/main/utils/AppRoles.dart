// ignore_for_file: file_names

import 'package:flutter/material.dart';

const industryList = ["Agriculture","Automotive","Construction","Domestic Jobs","Electronics","Iron & Steel","Mining","Paints","Pharma","Textile","Others"];
const learnIndustryList = ["Agriculture","Automotive","Construction","Domestic Jobs","Electronics","Iron & Steel","Mining","Paints","Pharma","Soft Skills","Textile","Other Topics"];
const filterIndustryList = ["Select", "Agriculture","Automotive","Construction","Domestic Jobs","Electronics","Iron & Steel","Mining","Paints","Pharma","Textile","Others"];

const roleList = {
  "Agriculture": ['Select', 'Agri Service Provider', 'Animal Wellness Executive', 'Dairy Farmer', 'Gardener', 'Green House Operator', 'Helper-Agri', 'Irrigation Service Technician', 'Non-Timber Forest Produce Collector', 'Organic Grower', 'Others-Agri', 'Quality Control Technician', 'Quality seed grower', 'Seed Processing Worker', 'Soil and Water Test Lab Analyst', 'Solar Pump Technician', 'Tractor Operator'],
  "Paints": ['Select', 'Decorative Painter', 'Helper-Paints', 'Industrial Liquid Painter', 'Jr. Decorative Painter', 'Others-Paints', 'Powder Coater', 'Protective and Marine Painter', 'Quality Control Technician', 'Safety Officer- Critical Paints', 'Wood Polisher'],
  "Pharma": ['Select', 'Helper-Pharma', 'Logistics Assistant', 'Mechanical Fitter-Pharma Equipment', 'Others-Pharma', 'Production Machine Operator-Pharma', 'Quality Control Chemist-Pharma', 'Safety Officer-Pharma', 'Store Assistant-Pharma', 'Store Manager-Large Stores', 'Tele Sales Executive-Pharma', 'Warehouse Assistant'],
  "Electronics": ['Select', 'Access Control Commissioning Technician', 'Access Control Design Technician', 'Access Control Installation Technician', 'Access Control Service Technician', 'CCTV Commissioning Technician', 'CCTV Design Technician', 'CCTV Installation Technician', 'CCTV Service Technician', 'Control Panel Wireman', 'Digital Cable Technician', 'ELV Service Engineer', 'ELV Technician', 'EMS Technician-(Electronic Chip Mounting)', 'Engineer', 'Field Cabling Technician', 'Field Installation Technician', 'Fire Alarm Commissioning Technician', 'Fire Alarm Installation Technician', 'Fire Alarm Service Engineer', 'Foreman', 'HVAC Technician', 'Helper', 'Helper-Electronics', 'IT Coordinator', 'Installation Technician-Computer Peripherals', 'Jr. Engineer', 'LED repair Technician', 'Mobile hardware repair Technician', 'Others-Electronics', 'PLC Project Engineer', 'PLC Service Engineer', 'PLC Techncian', 'Pick and Place Assemply Operator', 'Rigger', 'Safety Officer', 'Service Engineer', 'Service Technician-Computer Peripherals', 'Service Technician-Home Appliances', 'Service Technician-Networking and Storage', 'Service Technician-RACW (Refrigerator, AC, Washing Machine)', 'Service Technician-UPS and Inverter', 'Solar Design Technician', 'Solar Installation Technician', 'Solar Service Technician', 'Sr. Engineer', 'Supervisor', 'TV Repair Technician', 'Technician', 'Wireman'],
  "Automotive": ['Select', '2-3 Wheeler Technician', 'Auto Finance Sales', 'Auto Service Technician', 'CNC Machining Technician', 'Car Washer and Technician', 'Dealership Sales', 'Dealership Telecaller', 'E-Auto Asst Technician', 'E-Auto Driver', 'Engineer', 'Foreman', 'Helper', 'Helper-Automotive', 'Jr. Engineer', 'Machining and Quality', 'Others-Automotive', 'Quality control officer', 'Repair Paint Auto Body', 'Rigger', 'Safety Officer', 'Showeroom Hostess', 'Sr. Engineer', 'Supervisor', 'Technician', 'Welding Technician-Auto', 'Wireman'],
  "Textile": ['Select', 'Carding Operator', 'Hand Spinning Operator', 'Hank Dyer', 'Helper-Textiles', 'Others-Textiles', 'Quality Officer', 'Ring Frame Doffer', 'Ring Frame Tenter', 'Stenter Machine Operator', 'Tenter Machine Operator', 'Two Shaft Handloom Weaver', 'Warper'],
  "Construction": ['Select', 'Asst. Electrician', 'Bar Bender-Steel', 'Carpenter', 'Decorator', 'Engineer', 'Foreman', 'Helper', 'Helper-Construction', 'Jr. Engineer', 'Mason', 'Mason Concrete', 'Mason Tiling', 'Others-Construction', 'Painter', 'Rigger', 'Safety Officer', 'Sr. Engineer', 'Supervisor', 'Technician', 'Wireman'],
  "Iron & Steel": ['Select', 'Bearing Maintenance Technician', 'Conveyor Operator and Maintenance', 'Electronic Operator and Assembly', 'Engineer', 'Fitter- Electrical Assembly', 'Fitter- Hydraulic and Pneumatic System', 'Fitter- Instrumentation', 'Fitter- Levelling Aligning and Balancer', 'Foreman', 'Helper', 'Helper-Iron and Steel', 'Housekeeping with Machine', 'Jr. Engineer', 'Locomotive Driver', 'Machinist', 'Mobile Equipment Operator', 'Others-Iron and Steel', 'Overhead Crane Operator', 'Plasma Cutter', 'Quality Officer', 'Rigger', 'Rigger- Heavy Material', 'Safety Officer', 'Sr. Engineer', 'Supervisor', 'Technician', 'Tungsten-Inert Gas Welder', 'Wireman'],
  "Mining": ['Select', 'Bulldozer Operator', 'Explosive Handler', 'HEMM Mechanic', 'Helper-Mining', 'Jack Hammer Operator', 'Loader Operator', 'Mechanic Fitter', 'Mine Electrician', 'Mine Welder', 'Others-Mining', 'Quality Control Officer-Lab', 'Safety Operator', 'Shot Firer Blaster', 'Wire Saw Operator'],
  "Domestic Jobs": ['Select', 'Cycle Repairing Technician', 'Delivery Boy', 'Domestic Electrician', 'Domestic Plumber', 'Fire Safety Officer', 'First Aid Officer', 'Helper-Domestic', 'Others-Domestic'],
  "Others": ['Select', 'Others'],
  "Select": ['Select'],
};