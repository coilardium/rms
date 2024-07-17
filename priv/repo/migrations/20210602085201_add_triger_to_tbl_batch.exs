defmodule Rms.Repo.Migrations.AddTrigerToTblBatch do
  use Ecto.Migration

  def change do
    execute(
      """
      CREATE TRIGGER [dbo].[Update_BatchNum]
      ON [dbo].[tbl_batch]
      AFTER INSERT
      AS
      BEGIN
        WITH cteMaxBatchNum AS (
          SELECT MaxCount = COUNT(s.id)
          FROM dbo.tbl_batch AS s
          INNER JOIN INSERTED AS i ON i.batch_type = s.batch_type
        )
        UPDATE s
        SET batch_no = (SELECT FORMAT(MaxCount, '000000') FROM cteMaxBatchNum)
        FROM dbo.tbl_batch AS s
        WHERE s.id in (SELECT id from INSERTED)
      END
      """,
      "DROP TRIGGER [dbo].[Update_BatchNum]"
    )
  end
end
