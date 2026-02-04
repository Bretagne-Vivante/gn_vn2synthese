CREATE OR REPLACE FUNCTION src_faune_france.fct_tri_c_check_bzh_cover()
RETURNS trigger
LANGUAGE plpgsql
AS
$$
DECLARE
  lon_txt text;
  lat_txt text;
  lon_val double precision;
  lat_val double precision;
  p4326   geometry(point, 4326);
  cover   geometry(multipolygon, 4326);
BEGIN
  -- Primary coords used by your upsert trigger
  lon_txt := NULLIF(new.item #>> '{observers,0,coord_lon}', '');
  lat_txt := NULLIF(new.item #>> '{observers,0,coord_lat}', '');

  -- Optional fallback (uncomment if you want it)
  IF lon_txt IS NULL OR lat_txt IS NULL THEN
    lon_txt := NULLIF(new.item #>> '{observers,0,gps_lon}', '');
    lat_txt := NULLIF(new.item #>> '{observers,0,gps_lat}', '');
  END IF;

  -- Missing coords => reject
  IF lon_txt IS NULL OR lat_txt IS NULL THEN
    RETURN NULL;
  END IF;

  lon_val := lon_txt::double precision;
  lat_val := lat_txt::double precision;

  -- Basic sanity range
  IF lon_val < -180 OR lon_val > 180 OR lat_val < -90 OR lat_val > 90 THEN
    RETURN NULL;
  END IF;

  p4326 := ST_SetSRID(ST_MakePoint(lon_val, lat_val), 4326);

  -- Bretagne cover (already 4326)
  SELECT a.geom_4326
  INTO cover
  FROM ref_geo.l_areas a
  WHERE a.id_area = 750552
    AND a.geom_4326 IS NOT NULL;

  IF cover IS NULL THEN
    -- Do not block everything if config missing
    RAISE WARNING 'BZH cover geom_4326 missing for id_area=750552, skip filtering';
    RETURN NEW;
  END IF;

  -- bbox prefilter then exact test
  IF (p4326 && cover) AND ST_Intersects(p4326, cover) THEN
    RETURN NEW;
  END IF;

  RETURN NULL;
END;
$$;

-- Install trigger BEFORE your AFTER upsert trigger
DROP TRIGGER IF EXISTS tri_c_check_bzh_cover ON src_faune_france.observations_json;

CREATE TRIGGER tri_c_check_bzh_cover
BEFORE INSERT OR UPDATE
ON src_faune_france.observations_json
FOR EACH ROW
EXECUTE FUNCTION src_faune_france.fct_tri_c_check_bzh_cover();
