{{ config(severity='warn') }}
-- singular test : dbt test -s test_type:singular

select count(*)
from {{ ref('raw_nation') }}
having count(*) > 0
