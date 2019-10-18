# (c) goodprogrammer.ru

require 'rails_helper'
require 'support/my_spec_helper' # наш собственный класс с вспомогательными методами

# Тестовый сценарий для игрового контроллера
# Самые важные здесь тесты:
#   1. на авторизацию (чтобы к чужим юзерам не утекли не их данные)
#   2. на четкое выполнение самых важных сценариев (требований) приложения
#   3. на передачу граничных/неправильных данных в попытке сломать контроллер
#
RSpec.describe GamesController, type: :controller do
  # обычный пользователь
  let(:user) { FactoryBot.create(:user) }
  # админ
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  # игра с прописанными игровыми вопросами
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  # группа тестов для незалогиненного юзера (Анонимус)
  context 'Anon' do
    # из экшена show анона посылаем
    it 'kick from #show' do
      # вызываем экшен
      get :show, id: game_w_questions.id
      # проверяем ответ
      expect(response.status).not_to eq(200) # статус не 200 ОК
      expect(response).to redirect_to(new_user_session_path) # devise должен отправить на логин
      #  Задача 62-4 — khsm: тест на GamesController#show (без юзера)
      # Анонимный (незалогиненный) посетитель не может вызвать действие show у GamesController
      expect(response).not_to render_template('show') # и отрендерить шаблон show
      expect(flash[:alert]).to be # во flash должен быть прописана ошибка
    end

    #  Задача 62-4 — khsm: тест на GamesController#show (без юзера)
    # Напишите тесты, которые проверяют, что аноним не может
    # также вызывать и все другие действия этого контроллера.
    it 'kick from #create' do
      game = assigns(:game) # вытаскиваем из контроллера поле @game
      # вызываем экшен
      post :create
      # проверяем ответ
      expect(game).to be_nil
      expect(response.status).not_to eq(200) # статус не 200 ОК
      expect(response).to redirect_to(new_user_session_path) # devise должен отправить на логин
      expect(flash[:alert]).to be # во flash должен быть прописана ошибка
    end

    # и все другие действия этого контроллера.
    it 'kick from #answer' do
      game = assigns(:game) # вытаскиваем из контроллера поле @game
      # вызываем экшен
      put :answer, id: game_w_questions.id
      # проверяем ответ
      expect(game).to be_nil
      expect(response.status).not_to eq(200) # статус не 200 ОК
      expect(response).to redirect_to(new_user_session_path) # devise должен отправить на логин
      expect(flash[:alert]).to be # во flash должен быть прописана ошибка
    end

    # и все другие действия этого контроллера.
    it 'kick from #take_money' do
      game = assigns(:game) # вытаскиваем из контроллера поле @game
      # вызываем экшен
      put :take_money, id: game_w_questions.id
      # проверяем ответ
      expect(game).to be_nil
      expect(response.status).not_to eq(200) # статус не 200 ОК
      expect(response).to redirect_to(new_user_session_path) # devise должен отправить на логин
      expect(flash[:alert]).to be # во flash должен быть прописана ошибка
    end

    # и все другие действия этого контроллера.
    it 'kick from #help' do
      game = assigns(:game) # вытаскиваем из контроллера поле @game
      # вызываем экшен
      put :help, id: game_w_questions.id
      # проверяем ответ
      expect(game).to be_nil
      expect(response.status).not_to eq(200) # статус не 200 ОК
      expect(response).to redirect_to(new_user_session_path) # devise должен отправить на логин
      expect(flash[:alert]).to be # во flash должен быть прописана ошибка
    end
  end

  # группа тестов на экшены контроллера, доступных залогиненным юзерам
  context 'Usual user' do
    # перед каждым тестом в группе
    before(:each) { sign_in user } # логиним юзера user с помощью спец. Devise метода sign_in

    # юзер может создать новую игру
    it 'creates game' do
      # сперва накидаем вопросов, из чего собирать новую игру
      generate_questions(15)

      post :create
      game = assigns(:game) # вытаскиваем из контроллера поле @game

      # проверяем состояние этой игры
      expect(game.finished?).to be_falsey
      expect(game.user).to eq(user)
      # и редирект на страницу этой игры
      expect(response).to redirect_to(game_path(game))
      expect(flash[:notice]).to be
    end

    # юзер видит свою игру
    it '#show game' do
      get :show, id: game_w_questions.id
      game = assigns(:game) # вытаскиваем из контроллера поле @game
      expect(game.finished?).to be_falsey
      expect(game.user).to eq(user)

      expect(response.status).to eq(200) # должен быть ответ HTTP 200
      expect(response).to render_template('show') # и отрендерить шаблон show
    end

    # Задача 62-1 — khsm: тест на GamesController#show (чужая игра)
    # юзер не видит чужую игру
    it '#show not your game' do
      someone_game = FactoryBot.create(:game_with_questions)
      get :show, id: someone_game.id
      expect(someone_game.finished?).to be_falsey
      expect(someone_game.user).not_to eq(user)

      expect(flash[:alert]).to be # flash должен быть
      expect(response.status).not_to eq(200) # не должен быть ответ HTTP 200
      expect(response).to redirect_to(root_path) # перенаправление в корень
    end

    # юзер отвечает на игру корректно - игра продолжается
    it 'answers correct' do
      # передаем параметр params[:letter]
      put :answer, id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key
      game = assigns(:game)

      expect(game.finished?).to be_falsey
      expect(game.current_level).to be > 0
      expect(response).to redirect_to(game_path(game))
      expect(flash.empty?).to be_truthy # удачный ответ не заполняет flash
    end

    # Задача 62-5 — khsm: тест на GamesController#answer (неправильный ответ)
    # юзер отвечает на вопрос некорректно - игра завершается
    # проверяет случай "неправильный ответ игрока".
    it 'answers incorrect' do
      # передаем параметр params[:letter]
      put :answer, id: game_w_questions.id, letter: 'a'
      game = assigns(:game)

      expect(game.finished?).to be_truthy
      expect(game.status).to eq(:fail)
      expect(response).to redirect_to(user_path(user))
      expect(flash[:alert]).to be # неудачный ответ заполняет flash
    end

    # Задача 62-2 — khsm: тест на GamesController#take_money
    # пользователь берет деньги до конца игры
    it 'takes money' do
      # вручную поднимем уровень вопроса до выигрыша 200
      game_w_questions.update_attribute(:current_level, 2)

      put :take_money, id: game_w_questions.id
      game = assigns(:game)
      expect(game.finished?).to be_truthy
      expect(game.prize).to eq(200)

      # пользователь изменился в базе, надо в коде перезагрузить!
      user.reload
      expect(user.balance).to eq(200)

      expect(response).to redirect_to(user_path(user))
      expect(flash[:warning]).to be
    end

    # тест на отработку "помощи зала"
    it 'uses audience help' do
      # сперва проверяем что в подсказках текущего вопроса пусто
      expect(game_w_questions.current_game_question.help_hash[:audience_help]).not_to be
      expect(game_w_questions.audience_help_used).to be_falsey

      # фигачим запрос в контроллен с нужным типом
      put :help, id: game_w_questions.id, help_type: :audience_help
      game = assigns(:game)

      # проверяем, что игра не закончилась, что флажок установился, и подсказка записалась
      expect(game.finished?).to be_falsey
      expect(game.audience_help_used).to be_truthy
      expect(game.current_game_question.help_hash[:audience_help]).to be
      expect(game.current_game_question.help_hash[:audience_help].keys).to contain_exactly('a', 'b', 'c', 'd')
      expect(response).to redirect_to(game_path(game))
    end

    # Задача 62-3 — khsm: тест на GamesController#create (вторая игра)
    # Пользователь не может начать две игры. Если он начинает вторую,
    # его перенаправляют на первую
    it 'try to create second game' do
      # убедились что есть игра в работе
      expect(game_w_questions.finished?).to be_falsey

      # отправляем запрос на создание, убеждаемся что новых Game не создалось
      expect { post :create }.to change(Game, :count).by(0)

      game = assigns(:game) # вытаскиваем из контроллера поле @game
      expect(game).to be_nil

      # и редирект на страницу старой игры
      expect(response).to redirect_to(game_path(game_w_questions))
      expect(flash[:alert]).to be
    end
  end
end
