SELECT 
    N_NATIONKEY,
    N_NAME,
    lower(N_NAME) AS N_NAME_LOWER,
    N_REGIONKEY,
    N_COMMENT
FROM {{ ref('raw_nation') }}