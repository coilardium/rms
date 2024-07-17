defmodule Rms.Repo.Migrations.AddCategoryIdAndUsableFlag do
  use Ecto.Migration

  def up do
    alter table(:tbl_condition) do
      add :cond_category_id,
          references(:tbl_condition_category, column: :id, on_delete: :nilify_all)

      add :is_usable, :string
    end
  end

  def down do
    alter table(:tbl_condition) do
      remove :is_usable
      remove :cond_category_id
    end
  end
end
