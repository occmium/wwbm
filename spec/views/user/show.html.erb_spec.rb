# Задача 64-1 — khsm: тест на шаблон страницы пользователя
# тесты на шаблон app/views/users/show.html.erb

require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  before(:each) do
    assign(:user, FactoryBot.build_stubbed(:user, id: 1, name: 'Алёш'))
    assign(:games, [FactoryBot.build_stubbed(:game)])
    render
  end

  # пользователь видит свое имя
  it 'sees his name' do
    expect(rendered).to match 'Алёш'
  end

  # текущий пользователь (и только он) видит кнопку для смены пароля
  it 'only sees his change password' do
    expect(rendered).not_to match /пароль/

    sign_in FactoryBot.create(:user)
    render
    expect(rendered).to match /пароль/
  end

  # на странице отрисовываются фрагменты с игрой
  it 'rendered partial' do
    stub_template 'users/_game.html.erb' => 'User game goes here'
    render
    # А потом просто в тесте проверить
    expect(rendered).to have_content 'User game goes here'
  end
end
