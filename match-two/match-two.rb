require 'byebug'

class Card
  attr_accessor :revealed, :value
  def initialize(value)
    @revealed = false
    @value = value
  end

  def display_card
    @revealed ? @value : "?"
  end

  def hide
    @revealed = false
  end

  def reveal
    @revealed = true
  end
end

class Board
  attr_accessor :values, :grid

  def initialize
    @grid = []
    populate
  end

  def populate
    values = (("a".."h").to_a + ("a".."h").to_a)
    cards = []

    values.each do |value|
        cards << Card.new(value)
    end
    cards.shuffle!

    until cards.empty?
        row = []

        until row.length >= 4
          row << cards.shift
        end

        @grid << row
    end
  end

  def render
    @grid.each do |row|
      print "\n"
      row.each do |card|
        print "[#{card.display_card}]"
      end
    end
  end

  def reveal(guess)
    card = @grid[guess[0]][guess[1]]
    card.reveal unless card.revealed
    card.value
  end

  def won?
    @grid.all? do |row|
      row.all? { |card| card.revealed  }
    end
  end
end

class Game
  def initialize
    @board = Board.new
  end

  def run
    @board.render
    guess = prompt
    make_guess(guess)
    run unless @board.won?
  end

  def prompt
    guess = []

    puts "\nPlease input a Y coordinate for your guess."
    guess << gets.chomp.to_i
    puts "\nPlease input an X coordinate for your guess."
    guess << gets.chomp.to_i

    guess
  end

  def make_guess(guess)
    previous_guess = guess
    @board.reveal(guess)
    system("clear")
    @board.render

    second_guess = prompt
    @board.reveal(second_guess)
    system("clear")
    @board.render

    if @board.reveal(guess) == @board.reveal(second_guess)
      puts "\nMatch found!"
    else
      puts "\nNo match!"
      @board.grid[guess[0]][guess[1]].hide
      @board.grid[second_guess[0]][second_guess[1]].hide
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  g = Game.new
  g.run
end
