defmodule Rms.Repo.Migrations.AddPendingInviceCosgntDashboadVw do
  use Ecto.Migration

    def change do
      execute"""
        DROP VIEW [dbo].[vw_consgnt_dashboard_params]

      """
    end

end
