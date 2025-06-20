SELECT 
    t.$1::number AS N_NATIONKEY,
    t.$2::varchar AS N_NAME,
    t.$3::number AS N_REGIONKEY,
    t.$4::varchar AS N_COMMENT
FROM @{{ source('s3_dv_stage', 'NATION') }} (FILE_FORMAT => 'TPCH_CSV_FMT') t