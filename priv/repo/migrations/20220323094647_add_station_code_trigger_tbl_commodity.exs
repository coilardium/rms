defmodule Rms.Repo.Migrations.AddStationCodeTriggerTblCommodity do
  use Ecto.Migration

  def change do
    execute(
      """
      CREATE TRIGGER [dbo].[Update_Com_Code]
      ON [dbo].[tbl_commodity]
      AFTER INSERT
      AS
      BEGIN
        WITH cteMaxBatchNum AS (
          SELECT MaxCount = COUNT(s.id)
          FROM dbo.tbl_commodity AS s
        )
        UPDATE s
        SET commodity_code = (SELECT FORMAT(MaxCount, '0000') FROM cteMaxBatchNum)
        FROM dbo.tbl_commodity AS s
        WHERE s.id in (SELECT id from INSERTED)
      END
      """,
      "DROP TRIGGER [dbo].[Update_Com_Code]"
    )
  end
end
