CREATE FUNCTION next_ecosystem_metadata_sequence_number() RETURNS INTEGER
  AS $func$
    SELECT PG_ADVISORY_XACT_LOCK(5676211225851683);
    SELECT COALESCE(MAX("ecosystems"."metadata_sequence_number"), -1) + 1 FROM "ecosystems"
  $func$
  LANGUAGE SQL
