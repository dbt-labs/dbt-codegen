select 
    col_a as col_A,
    col_b as col_B
from {{ ref('data__a_relation') }}
