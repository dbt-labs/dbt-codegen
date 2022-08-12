select *, 2 as col2
from {{ ref('model_without_import_ctes') }}
where id = 1