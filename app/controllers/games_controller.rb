require 'open-uri'
require 'json'
class GamesController < ApplicationController

  def new
    @start_time = Time.now
    @letters = generate_grid
  end

  def score
    @end_time = Time.now
    @result = run_game(params[:word], params[:letter], params[:start_time], @end_time)
  end

  def generate_grid
    charset = ("A".."Z").to_a
    random_grid = []
    9.times do
      random_grid << charset.sample
    end
    random_grid
  end

  def serialize(attempt)
    url = "https://wagon-dictionary.herokuapp.com/#{attempt}"
    attempt_serialized = URI.open(url).read
    JSON.parse(attempt_serialized)
  end

  def word_check(letters, word)
    check = true
    letters=letters.split(" ")
    word.chars.each do |char|
      letters.include?(char.upcase) ? letters.delete_at(letters.index(char.upcase)) : check = false
    end
    return check
  end

  def outputs(check)
    case check
    when "not_english"
      { score: 0, message: "The given word is not an english word!", time: 0 }
    when "not_grid"
      { score: 0, message: "The given word is not in the grid!", time: 0 }
    end
  end

  def make_score(length, time)
    ((length / time)).round(1) * 10
  end

  def run_game(attempt, grid, start_time, end_time)
    result = serialize(attempt)
    end_time = end_time.to_s
    a = Time.parse(start_time)
    b = Time.parse(end_time)

    time = b - a
    if result["found"] == false
      outputs("not_english")
    elsif word_check(grid, attempt) == false
      outputs("not_grid")
    else
      { score: make_score(attempt.length, time), message: "Well done!", time: (time), word: attempt }
    end
  end


end
