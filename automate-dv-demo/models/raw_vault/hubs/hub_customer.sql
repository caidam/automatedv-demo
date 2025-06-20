{%- set source_model = "v_stg_orders" -%}
{%- set src_pk = "CUSTOMER_PK" -%}
{%- set src_nk = "CUSTOMERKEY" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ automate_dv.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts,
                   src_source=src_source, source_model=source_model) }}

-- union all 

-- select null as CUSTOMER_PK, 268100 as CUSTOMER_KEY, '1992-01-09'::date as LOAD_DATE, 'TPCH-ORDERS' as RECORD_SOURCE