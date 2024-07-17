defmodule Rms.Repo.Migrations.AddDocSequenceNumber do
  use Ecto.Migration

  def up do
    execute """
    IF NOT EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DocSeqNumber]') AND type = 'SO')
    CREATE SEQUENCE DocSeqNumber
    START WITH 1
    INCREMENT BY 1
    """
  end

  def down do
    execute """
    DROP SEQUENCE DocSeqNumber;
    """
  end
end
