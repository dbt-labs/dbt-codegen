select *, 2 as col2
from {{ ref('model_without_import_ctes') }} as m
left join (select 2 as col_a from {{ ref('data__a_relation') }}) as a on a.col_a = m.id
where id = 1