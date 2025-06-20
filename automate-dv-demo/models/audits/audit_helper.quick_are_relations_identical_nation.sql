{{ audit_helper.quick_are_relations_identical(
    a_relation = ref('raw_nation'),
    b_relation = source('tpch_sample', 'NATION')
) }}
