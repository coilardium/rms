defmodule Rms.Repo.Migrations.CreateTrigerUpdateStationCodeTblStations do
  use Ecto.Migration

  def change do
    execute(
      """
      CREATE TRIGGER [dbo].[Update_Stat_Code]
      ON [dbo].[tbl_stations]
      AFTER INSERT
      AS
      BEGIN
        WITH cteMaxBatchNum AS (
          SELECT MaxCount = COUNT(s.id)
          FROM dbo.tbl_stations AS s
        )
        UPDATE s
        SET station_code = (SELECT FORMAT(MaxCount, '0000') FROM cteMaxBatchNum)
        FROM dbo.tbl_stations AS s
        WHERE s.id in (SELECT id from INSERTED)
      END
      """,
      "DROP TRIGGER [dbo].[Update_Stat_Code]"
    )
  end
end
