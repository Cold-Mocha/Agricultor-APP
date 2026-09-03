insert into public.official_crops(id, common_name, scientific_name, category, color_token, icon_asset) values
('avellano-europeo', 'Avellano europeo', 'Corylus avellana', 'frutal', 'cropOrchard', 'assets/icons/crops/custom-crop.svg'),
('cerezo', 'Cerezo', 'Prunus avium', 'frutal', 'cropFruit', 'assets/icons/crops/custom-crop.svg'),
('frambuesa', 'Frambuesa', 'Rubus idaeus', 'berry', 'cropBerry', 'assets/icons/crops/custom-crop.svg'),
('maiz', 'Maíz', 'Zea mays', 'cereal', 'cropCereal', 'assets/icons/crops/custom-crop.svg'),
('papa', 'Papa', 'Solanum tuberosum', 'tuberculo', 'cropRoot', 'assets/icons/crops/custom-crop.svg'),
('physalis', 'Physalis', 'Physalis peruviana', 'frutal', 'cropFruit', 'assets/icons/crops/physalis.svg'),
('trigo', 'Trigo', 'Triticum aestivum', 'cereal', 'cropCereal', 'assets/icons/crops/custom-crop.svg'),
('vid', 'Vid', 'Vitis vinifera', 'frutal', 'cropVine', 'assets/icons/crops/custom-crop.svg'),
('apicultura', 'Apicultura', null, 'apicultura', 'cropApiary', 'assets/icons/crops/apiary.svg')
on conflict (id) do update set common_name = excluded.common_name, scientific_name = excluded.scientific_name,
category = excluded.category, color_token = excluded.color_token, icon_asset = excluded.icon_asset;
