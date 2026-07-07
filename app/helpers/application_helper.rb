module ApplicationHelper
  # Título dos grupos de posts da home ("2026 - Julho"). Também gera a âncora
  # correspondente para o sumário lateral via parameterize.
  def month_group_title(month)
    "#{month.year} - #{l(month, format: "%B").capitalize}"
  end
end
