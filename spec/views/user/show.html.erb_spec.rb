# Задача 64-1 — khsm: тест на шаблон страницы пользователя
# тесты на шаблон app/views/users/show.html.erb

require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  context 'any' do
    before(:each) do
      assign(:user, FactoryBot.build_stubbed(:user, name: 'Алёш'))

      render
    end

    # любой пользователь видит свое имя
    it 'sees his name' do
      expect(rendered).to match 'Алёш'
    end

    # любой, не текущий пользователь не видит кнопку для смены пароля
    it 'do not his change password' do
      expect(rendered).not_to match /пароль/
    end
  end

  context 'current user' do
    before(:each) do
      sign_in FactoryBot.create(:user)
      assign(:user, FactoryBot.build_stubbed(:user, id: 1, name: 'Алёш'))
      assign(:games, [FactoryBot.build_stubbed(:game)])
      stub_template 'users/_game.html.erb' => 'User game goes here'

      render
    end

    # на странице отрисовываются фрагменты с игрой
    it 'rendered partial' do
      # А потом просто в тесте проверить
      expect(rendered).to have_content 'User game goes here'
    end

    # текущий пользователь видит кнопку для смены пароля
    it 'sees change password' do
      expect(rendered).to match /пароль/
    end
  end
end
