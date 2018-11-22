CREATE FUNCTION next_course_metadata_sequence_number() RETURNS INTEGER
  AS $func$
    SELECT PG_ADVISORY_XACT_LOCK(49102217655775016);
    SELECT COALESCE(MAX("courses"."metadata_sequence_number"), -1) + 1 FROM "courses"
  $func$
  LANGUAGE SQL
