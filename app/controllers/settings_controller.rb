class SettingsController < ApplicationController
  allow_unauthenticated_access

  # A escolha de tema é client-side (localStorage, aplicada pelo theme_controller).
  # Esta tela só lista os temas disponíveis para o preview e a seleção. A ordem aqui
  # é a ordem do grid. Para um tema novo: bloco [data-theme] no CSS + entrada aqui.
  THEMES = [
    { id: "system",     name: "Sistema" },
    { id: "light",      name: "Claro" },
    { id: "blue",       name: "Blue" },
    { id: "black",      name: "Preto" },
    { id: "catppuccin", name: "Catppuccin" },
    { id: "gruvbox",    name: "Gruvbox" },
    { id: "kanagawa",   name: "Kanagawa" }
  ].freeze

  def show
    @themes = THEMES
  end
end
