{{ audit_helper.compare_row_counts(
    a_relation = ref('raw_nation'),
    b_relation = source('tpch_sample', 'NATION')
) }}
