SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,

    CASE
        WHEN pk.COLUMN_NAME IS NOT NULL THEN 1
        ELSE 0
    END AS IsPrimaryKey,

    CASE
        WHEN fk.parent_column IS NOT NULL THEN 1
        ELSE 0
    END AS IsForeignKey,

    fk.referenced_schema,
    fk.referenced_table,
    fk.referenced_column

FROM INFORMATION_SCHEMA.COLUMNS c

LEFT JOIN (
    SELECT
        KU.TABLE_SCHEMA,
        KU.TABLE_NAME,
        KU.COLUMN_NAME
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE KU
        ON TC.CONSTRAINT_NAME = KU.CONSTRAINT_NAME
    WHERE TC.CONSTRAINT_TYPE = 'PRIMARY KEY'
) pk
ON c.TABLE_SCHEMA = pk.TABLE_SCHEMA
AND c.TABLE_NAME = pk.TABLE_NAME
AND c.COLUMN_NAME = pk.COLUMN_NAME

LEFT JOIN (
    SELECT
        OBJECT_SCHEMA_NAME(fkc.parent_object_id) AS parent_schema,
        OBJECT_NAME(fkc.parent_object_id) AS parent_table,
        pc.name AS parent_column,

        OBJECT_SCHEMA_NAME(fkc.referenced_object_id) AS referenced_schema,
        OBJECT_NAME(fkc.referenced_object_id) AS referenced_table,
        rc.name AS referenced_column

    FROM sys.foreign_key_columns fkc
    JOIN sys.columns pc
        ON pc.object_id = fkc.parent_object_id
       AND pc.column_id = fkc.parent_column_id
    JOIN sys.columns rc
        ON rc.object_id = fkc.referenced_object_id
       AND rc.column_id = fkc.referenced_column_id
) fk
ON c.TABLE_SCHEMA = fk.parent_schema
AND c.TABLE_NAME = fk.parent_table
AND c.COLUMN_NAME = fk.parent_column

WHERE c.TABLE_NAME = 'NomDeTaTable'
ORDER BY c.ORDINAL_POSITION;