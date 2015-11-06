require 'set'
require 'byebug'

class Game
  attr_accessor :fragment, :dictionary, :current_player, :previous_player

  def initialize(player1, player2)
    @fragment   = ""
    @dictionary = Set.new(File.open("ghost-dictionary.txt").map {|e| e.strip })
    @player1    = player1
    @player2    = player2

    @current_player = @player1
    @previous_player = @player2
  end
  
  def play_round
    if game_over?
      abort("Game over! #{@previous_player.name} wins!")
    else
      puts `clear`
      puts "It is #{@current_player.name}'s turn."
      take_turn(@current_player)
    end
  end

  def next_player!
    next_player = @previous_player
    @previous_player = @current_player
    @current_player = next_player
    play_round
  end

  def take_turn(player)
    puts "The current fragment is: #{@fragment}"
    letter = player.guess

    if valid_play?(letter)
      add_letter(letter)
      next_player!
    else
      player.alert_invalid_guess
      take_turn(player)
    end
  end

  def valid_play?(play)
    if play == "exit"
      concede
    else
      return false unless play =~ /[[:alpha:]]/
      return false unless @dictionary.any?{|word| word.start_with?(@fragment + play)}
    end
    true
  end

  def add_letter(letter)
    self.fragment << letter
  end

  def game_over?
    if @dictionary.include?(@fragment)
      return true
    else
      false
    end
  end

  def concede
    abort("#{@current_player.name} Forfeits!  Game over!")
  end
end



class Player
  attr_accessor :name

  def initialize(name)
    @name = name
  end
  
  def guess
    puts "Please choose the next letter."
    gets.chomp
  end

  def alert_invalid_guess
    puts `clear`
    puts "Your input is invalid, human!"
    puts "Either you failed to enter a valid letter, "
    puts "or no word can be made from the resulting string."
  end
end

augi = Player.new("Augustine")
comp = Player.new("Compey")
game = Game.new(augi, comp)
binding.pry 