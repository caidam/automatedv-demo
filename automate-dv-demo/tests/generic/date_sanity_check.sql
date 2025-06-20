{% test date_sanity_check(model, column_name) %}

SELECT *
FROM {{ model }}
WHERE
    {{ column_name }} > CURRENT_TIMESTAMP()

{% endtest %}