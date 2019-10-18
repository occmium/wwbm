# (c) goodprogrammer.ru

require 'rails_helper'

# Тестовый сценарий для модели игрового вопроса,
# в идеале весь наш функционал (все методы) должны быть протестированы.
RSpec.describe GameQuestion, type: :model do

  # задаем локальную переменную game_question, доступную во всех тестах этого сценария
  # она будет создана на фабрике заново для каждого блока it, где она вызывается
  let(:game_question) { FactoryBot.create(:game_question, a: 2, b: 1, c: 4, d: 3) }

  # группа тестов на игровое состояние объекта вопроса
  context 'game status' do
    # Задача 63-1 — khsm: тест на GameQuestion#help_hash
    # тест на метод help_hash модели GameQuestion
    it 'correct .help_hash' do
      hh = game_question.help_hash
      expect(hh).to eq({})

      hh[:key_one] = "value_one"
      hh[:key_two] = "value_two"
      hh[:key_three] = "value_three"
      game_question.save

      new_question = GameQuestion.find(game_question.id)
      expect(new_question.help_hash).to eq({key_one: "value_one",
                        key_two: "value_two",
                        key_three: "value_three"})
    end

    # тест на правильную генерацию хэша с вариантами
    it 'correct .variants' do
      expect(game_question.variants).to eq({'a' => game_question.question.answer2,
                                            'b' => game_question.question.answer1,
                                            'c' => game_question.question.answer4,
                                            'd' => game_question.question.answer3})
    end

    it 'correct .answer_correct?' do
      # именно под буквой b в тесте мы спрятали указатель на верный ответ
      expect(game_question.answer_correct?('b')).to be_truthy
    end
  end

  # help_hash у нас имеет такой формат:
  # {
  #   fifty_fifty: ['a', 'b'], # При использовании подсказски остались варианты a и b
  #   audience_help: {'a' => 42, 'c' => 37 ...}, # Распределение голосов по вариантам a, b, c, d
  #   friend_call: 'Василий Петрович считает, что правильный ответ A'
  # }
  #

  context 'user helpers' do
    it 'correct audience_help' do
      expect(game_question.help_hash).not_to include(:audience_help)

      game_question.add_audience_help

      expect(game_question.help_hash).to include(:audience_help)

      ah = game_question.help_hash[:audience_help]
      expect(ah.keys).to contain_exactly('a', 'b', 'c', 'd')
    end

    # Задача 63-2 — khsm: тест на GameQuestion#fifty_fifty
    # проверяет использование подсказки 50/50.
    it 'correct 50_50' do
      expect(game_question.help_hash).not_to include(:fifty_fifty)

      game_question.add_fifty_fifty

      expect(game_question.help_hash).to include(:fifty_fifty)
      expect(game_question.help_hash[:fifty_fifty].length).to eq(2)
    end

    # Задача 63-3 — khsm: тест на GameQuestion#friend_call
    # проверяет работу подсказки "звонок другу"
    it 'correct friend_call' do
      expect(game_question.help_hash).not_to include(:friend_call)
      game_question.add_friend_call
      expect(game_question.help_hash[:friend_call].last).to be_in(%w(A B C D))
    end
  end

  # Задача 61-2 — khsm: тесты на GameQuestion#text/level
  context 'methods' do
    # тест на наличие методов делегатов level и text
    it 'correct .level & .text delegates' do
      expect(game_question.text).to eq(game_question.question.text)
      expect(game_question.level).to eq(game_question.question.level)
    end

    #  Задача 61-5 — kshm: тест на GameQuestion#correct_answer_key
    it 'correct .correct_answer_key' do
      expect(game_question.correct_answer_key).to eq('b')
    end
  end
end
