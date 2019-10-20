# Задача 65-1 — Фича «Просмотр чужого профиля»
# Напишите фичу на просмотр профиля другого игрока.
# Создайте в базе пару игр и проверьте, что на профиле игрока правильно
# выводится даты игр, выигрыши и так далее. Не забудьте убедиться,
# что пользователь не видит ссылку на смену пароля.

# Как и в любом тесте, подключаем помощник rspec-rails
require 'rails_helper'

# Начинаем описывать функционал, связанный с созданием игры
RSpec.feature 'USER creates a game', type: :feature do
  # Чтобы посетитель мог просмотреть чужую игру, нам надо
  # создать пользователя
  let(:user) { FactoryBot.create :user }

  # и создать в базе пару игр
  # Обратите внимание, что дата игр, выйгрыши и так далее нам
  # здесь важны, так как именно их мы потом будем проверяеть
  let!(:games) { [
    FactoryBot.create(:game, id: 7, user: user, prize: 100500,
                      finished_at: "2019-10-20 00:02:00",
                      created_at: "2019-10-20 00:00:00",
                      current_level: 0,
                      is_failed: false
    ),
    FactoryBot.create(:game, id: 8, user: user, prize: 999999,
                      finished_at: "2019-10-20 22:22:00",
                      created_at: "2019-10-20 22:22:00",
                      fifty_fifty_used: true,
                      current_level: 888,
                      is_failed: true
    )
  ] }

  # Сценарий успешного присмотра посетителем профиля игрока
  scenario '& quest show successfully' do
    # Заходим на главную
    visit '/'

    # Ожидаем, что на экране имя пользователя
    expect(page).to have_content user.name

    # Ожидаем, что на экране количестро игр пользователя
    expect(page).to have_content '2'

    # Кликаем по пользователю
    click_link user.name

    # Ожидаем, что попадем на нужный url
    expect(page).to have_current_path '/users/1'

    # Ожидаем, что на экране будут "маловероятные" выйгрыши
    expect(page).to have_content '100 500 ₽'
    expect(page).to have_content '999 999 ₽'

    # Ожидаем, что на экране будут даты игр
    expect(page).to have_content '20 окт., 00:00'
    expect(page).to have_content '20 окт., 22:22'

    # Ожидаем, что на экране будут все статусы кроме (победа, в процессе)
    expect(page).to have_content 'деньги'
    expect(page).to have_content 'проигрыш'

    # Ожидаем, что на экране будет название подсказки
    expect(page).to have_content '50/50'

    # Ожидаем, что на экране будут "маловероятные" уровни игр
    expect(page).to have_content ' 0 '
    expect(page).to have_content ' 888 '

    # Не ожидаем, что на экране будет ссыль на смену пароля
    expect(page).not_to have_content 'пароль'
  end

  # Сценарий успешного присмотра пользователем ссыли на смену пароля
  scenario '& can change pass' do
    # Залогинемся
    login_as user

    # Заходим на главную
    visit '/'

    # Кликаем по пользователю
    click_link user.name

    # Ожидаем, что на экране будет ссыль на смену пароля
    expect(page).to have_content 'пароль'

    # save_and_open_page
  end
end
