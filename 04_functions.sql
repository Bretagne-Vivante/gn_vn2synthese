/* Function to get taxo group from visionature id_species */

CREATE OR REPLACE FUNCTION src_lpodatas.fct_get_taxo_group_values_from_vn(_key TEXT, _site TEXT, _id INTEGER, OUT _result TEXT) RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
BEGIN
    EXECUTE 'select item ->> $1 from import_vn.taxo_groups_json where taxo_groups_json.id = $3 and taxo_groups_json.site like $2 limit 1;'
        INTO _result
        USING _key, _site, _id;
END ;
$$;

ALTER FUNCTION src_lpodatas.fct_get_taxo_group_values_from_vn(_key TEXT, _sie TEXT, _id INTEGER, OUT _result TEXT) OWNER TO geonature;
COMMENT ON FUNCTION src_lpodatas.fct_get_taxo_group_values_from_vn(_key TEXT, _site TEXT, _id INTEGER, OUT _result TEXT) IS 'Function to get taxo group from visionature id_species';


/* Function to get taxref datas from VN id_sp */

CREATE OR REPLACE FUNCTION src_lpodatas.fct_get_taxref_values_from_vn(_field_name ANYELEMENT, _id_species INTEGER, OUT _result ANYELEMENT) RETURNS ANYELEMENT
    LANGUAGE plpgsql
AS
$$
BEGIN
    EXECUTE format(
            'SELECT taxref.%I from src_lpodatas.cor_vn_taxref join taxonomie.taxref on cor_vn_taxref.taxref_id = taxref.cd_nom where vn_id = $1 limit 1',
            _field_name)
        INTO _result
        USING _id_species;
END ;
$$;

ALTER FUNCTION src_lpodatas.fct_get_taxref_values_from_vn(_field_name ANYELEMENT, _id_species INTEGER, OUT _result ANYELEMENT) OWNER TO geonature;

COMMENT ON FUNCTION src_lpodatas.fct_get_taxref_values_from_vn(_field_name ANYELEMENT, _id_species INTEGER, OUT _result ANYELEMENT) IS 'Function to get taxref datas from VN id_sp';

/* Function to get visionature species datas from VN id_sp */

CREATE OR REPLACE FUNCTION src_lpodatas.fct_get_species_values_from_vn(_key ANYELEMENT, _id_species INTEGER, OUT _result ANYELEMENT) RETURNS ANYELEMENT
    LANGUAGE plpgsql
AS
$$
BEGIN
    EXECUTE 'select item ->> $1 from import_vn.species_json where species_json.id = $2 limit 1;'
        INTO _result
        USING _key, _id_species;
END ;
$$;

ALTER FUNCTION src_lpodatas.fct_get_species_values_from_vn(_key ANYELEMENT, _id_species INTEGER, OUT _result ANYELEMENT) OWNER TO geonature;

COMMENT ON FUNCTION src_lpodatas.fct_get_species_values_from_vn(_key ANYELEMENT, _id_species INTEGER, OUT _result ANYELEMENT) IS 'Function to get visionature species datas from VN id_sp';

/* Function to get observer full name from VisioNature observer universal id*/

CREATE FUNCTION src_lpodatas.fct_get_observer_full_name_from_vn(_id_universal INTEGER, OUT _result TEXT) RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
BEGIN
    EXECUTE
        format(
                'select concat(UPPER(item ->> ''name''), '' '', item ->> ''surname'') as text from import_vn.observers_json where observers_json.id_universal = $1 limit 1')
        INTO _result
        USING _id_universal;
END ;
$$;

ALTER FUNCTION src_lpodatas.fct_get_observer_full_name_from_vn(_id_universal INTEGER, OUT _result TEXT) OWNER TO geonature;

COMMENT ON FUNCTION src_lpodatas.fct_get_observer_full_name_from_vn(_id_universal INTEGER, OUT _result TEXT) IS 'Function to get observer full name from VisioNature observer universal id';

/* Function to get entity name from VisioNature observer universal id */

CREATE OR REPLACE FUNCTION src_lpodatas.fct_get_entity_from_observer_site_uid(_uid INTEGER, _site TEXT, OUT _result TEXT) RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
BEGIN
    SELECT INTO _result
        CASE WHEN ent.item ->> 'short_name' = '-' THEN NULL ELSE ent.item ->> 'short_name' END
        FROM
            import_vn.observers_json usr
                JOIN import_vn.entities_json ent
                     ON (usr.site, cast(usr.item ->> 'id_entity' AS INT)) = (ent.site, ent.id)
        WHERE
              usr.id_universal = _uid
          AND usr.site = _site;
END;
$$;

ALTER FUNCTION src_lpodatas.fct_get_entity_from_observer_site_uid(_uid INTEGER, _site TEXT, OUT _result TEXT) OWNER TO geonature;

COMMENT ON FUNCTION src_lpodatas.fct_get_entity_from_observer_site_uid(_uid INTEGER, _site TEXT, OUT _result TEXT) IS 'Function to get entity name from VisioNature observer universal id';

/* Function to generate an array of behaviours from VisioNature datas */

DROP FUNCTION IF EXISTS src_lpodatas.fct_get_behaviours_texts_array_from_id_array(_behaviours JSONB, OUT _result TEXT[]);

CREATE OR REPLACE FUNCTION src_lpodatas.fct_get_behaviours_texts_array_from_id_array(_behaviours JSONB, OUT _result TEXT[]) RETURNS TEXT[]
    LANGUAGE plpgsql
AS
$$
DECLARE
    _array_id TEXT[];
BEGIN
    IF _behaviours IS NOT NULL THEN
        SELECT
            array_agg(u.x)::TEXT[]
            INTO _array_id
            FROM
                (SELECT
                     t.value ->> '@id' AS x
                     FROM
                         jsonb_array_elements(_behaviours) AS t) AS u;

        SELECT INTO _result
            array_agg(item ->> 'text')
            FROM
                import_vn.field_details_json
            WHERE
                id IN (SELECT unnest(_array_id));
    ELSE
        SELECT NULL INTO _result;
    END IF;
END;
$$;

ALTER FUNCTION src_lpodatas.fct_get_behaviours_texts_array_from_id_array(_behaviours JSONB, OUT _result TEXT[]) OWNER TO geonature;

COMMENT ON FUNCTION src_lpodatas.fct_get_behaviours_texts_array_from_id_array(_behaviours JSONB, OUT _result TEXT[]) IS 'Function to generate an array of behaviours from VisioNature datas';


/* list visionature medias URL from medias details */

DROP FUNCTION IF EXISTS src_lpodatas.fct_get_medias_url_from_visionature_medias_array(_medias JSONB, OUT _result TEXT);

CREATE OR REPLACE FUNCTION src_lpodatas.fct_get_medias_url_from_visionature_medias_array(_medias JSONB, OUT _result TEXT) RETURNS TEXT
    LANGUAGE plpgsql
AS
$$
BEGIN
    IF _medias IS NOT NULL THEN
        SELECT
            string_agg(u.x, ', ')::TEXT
            INTO _result
            FROM
                (SELECT
                     t.value ->> 'path' AS x
                     FROM
                         jsonb_array_elements(_medias) AS t) AS u;
    ELSE
        SELECT NULL INTO _result;
    END IF;
END;
$$;

ALTER FUNCTION src_lpodatas.fct_get_medias_url_from_visionature_medias_array(_medias JSONB, OUT _result TEXT) OWNER TO geonature;

COMMENT ON FUNCTION src_lpodatas.fct_get_medias_url_from_visionature_medias_array(_medias JSONB, OUT _result TEXT) IS 'Function to list medias URL from VisioNature datas';

/* Function to get observation generated UUID */


CREATE FUNCTION src_lpodatas.fct_get_observation_uuid(_site character varying, _id integer, OUT _uuid uuid) RETURNS uuid
    LANGUAGE plpgsql
AS
$$
BEGIN
    EXECUTE format(
            'SELECT uuid from import_vn.uuid_xref where site like $1 and id = $2 limit 1')
        INTO _uuid
        USING _site, _id;
END ;
$$;

ALTER FUNCTION src_lpodatas.fct_get_observation_uuid(_site character varying, _id integer, OUT _uuid uuid)  OWNER TO geonature;

COMMENT ON FUNCTION src_lpodatas.fct_get_observation_uuid IS 'Function to get observation generated UUID';
