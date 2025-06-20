SELECT t.$1::number AS R_REGIONKEY,
       t.$2::varchar AS R_NAME,
       t.$3::varchar AS R_COMMENT
FROM @{{ source('s3_dv_stage', 'REGION') }} (FILE_FORMAT => 'TPCH_CSV_FMT') t