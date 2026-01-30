
INSERT INTO ref_nomenclatures.t_c_synonyms (
    id_type,
    type_mnemonique,
    cd_nomenclature,
    mnemonique,
    label_default,
    initial_value,
    id_nomenclature,
    meta_create_date,
    meta_update_date,
    id_synonyme,
    addon_values,
    id_source
) values
-- 1) Passage en vol
(
    124,
    'OCC_COMPORTEMENT',
    10,
    'Passage en vol',
    'Passage en vol',
    'FLY',
    554,
    NOW(),
    NOW(),
    192,
    '{"visionature_json_path": "{observers,0,details,0,condition}"}',
    29
)
,
-- 2) Repos
(
    124,
    'OCC_COMPORTEMENT',
    17,
    'Repos',
    'Repos',
    'LAID',
    561,
    NOW(),
    NOW(),
    198,
    '{"visionature_json_path": "{observers,0,details,0,condition}"}',
    29
),
-- 3) Chant
(
    124,
    'OCC_COMPORTEMENT',
    18,
    'Chant',
    'Chant',
    'AUDIO',
    562,
    NOW(),
    NOW(),
    197,
    '{"visionature_json_path": "{observers,0,details,0,condition}"}',
    29
),
-- 4) Trouvé mort
(
    7,
    'ETA_BIO',
    3,
    'Trouvé mort',
    'Trouvé mort',
    '2',
    155,
    NOW(),
    NOW(),
    193,
    '{"visionature_json_path": "{observers,0, has_death}"}',
    29
),
-- 5) Douteux
(
    101,
    'STATUT_VALID',
    3,
    'Douteux',
    'Douteux',
    'question',
    317,
    NOW(),
    NOW(),
    194,
    '{"visionature_json_path": "{observers,0,admin_hidden_type}"}',
    29
),
-- 6) Invalide
(
    101,
    'STATUT_VALID',
    4,
    'Invalide',
    'Invalide',
    'refused',
    318,
    NOW(),
    NOW(),
    195,
    '{"visionature_json_path": "{observers,0,admin_hidden_type}"}',
    29
),
-- 7) Non réalisable
(
    101,
    'STATUT_VALID',
    5,
    'Non réalisable',
    'Non réalisable',
    'incomplete',
    319,
    NOW(),
    NOW(),
    196,
    '{"visionature_json_path": "{observers,0,admin_hidden_type}"}',
    29
);


---mise à jour

update ref_nomenclatures.t_c_synonyms
set id_nomenclature=554,
meta_update_date=now(),
id_source=29
where id_synonyme=49;


update ref_nomenclatures.t_c_synonyms
set addon_values='{"visionature_json_path": "{observers,0,atlas_code}"}',
meta_update_date=now(),
id_source=29
where id_synonyme BETWEEN 31 AND 48;


