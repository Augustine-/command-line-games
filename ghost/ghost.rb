require 'set'

class Game
  attr_accessor :fragment, 
  :dictionary, 
  :current_player, 
  :previous_player, 
  :losses

  attr_reader :player1, :player2

  def initialize(player1, player2)
    @fragment   = ""
    @dictionary = Set.new(File.open("ghost-dictionary.txt").map {|e| e.strip })
    @player1    = player1
    @player2    = player2

    @current_player = @player1
    @previous_player = @player2

    @losses = {
      @player1.name => 0,
      @player2.name => 0
    }
  end

  def ghost(player)
    spooky = "GHOST"
    num = @losses[player.name]
    spooky[0...num]
  end
  
  def run 
    until @losses.values.include?(5)
      puts `clear`
      puts "New round!"
      puts "#{@player1.name}: #{ghost(@player1)}" 
      puts "#{@player2.name}: #{ghost(@player2)}"
      puts "Press enter to begin..."
      gets.chomp
      play_round
    end
    puts "#{@player1.name}: #{ghost(@player1)}" 
    puts "#{@player2.name}: #{ghost(@player2)}"
    puts "Game over! #{@previous_player.name} wins!"
    gets.chomp
    start_page
  end

  def play_round
    if round_over?
      puts "Game over! #{@previous_player.name} wins!"
      puts "#{@current_player.name} lost by completing: '#{@fragment}'"
      @fragment = ""
      @losses[@current_player.name] += 1
      puts "Press enter to continue..."
      gets.chomp
    else
      next_player!
      puts `clear`
      puts "It is #{@current_player.name}'s turn."
      take_turn(@current_player)
    end
  end

  def next_player!
    next_player = @previous_player
    @previous_player = @current_player
    @current_player = next_player
  end

  def take_turn(player)
    puts "The current fragment is: #{@fragment}"
    letter = player.guess

    if valid_play?(letter)
      add_letter(letter)
      play_round
    else
      player.alert_invalid_guess
      take_turn(player)
    end
  end

  def valid_play?(play)
    if play == "exit"
      concede
    else
      return false unless play =~ /^[[:alpha:]]$/
      return false unless @dictionary.any?{|word| word.start_with?(@fragment + play)}
    end
    true
  end

  def add_letter(letter)
    self.fragment << letter
  end

  def round_over?
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
comp = Player.new("Jake")
game = Game.new(augi, comp)

def start_page
  augi = Player.new("Augustine")
  comp = Player.new("Jake")
  game = Game.new(augi, comp)


  puts `clear`
  puts "Welcome to GHOST! How to play: "
  puts "Two players take turns, each adding onto the same word, one letter at a time."
  puts "The goal is not to be the one who finishes a valid word, first."
  puts "You must choose a letter that leads to at least one valid word. No spamming 'Z'."
  puts "Finally, for every loss, you recieve one letter from the spooky word."
  puts "If you complete this spooky word, you lose. It's over."
  puts "Whenever you're ready, type 'start', and hit 'enter'. Have fun!"

  gets.chomp == "start" ? game.run : start_page
end

start_page

# binding.pry
# puts `clear`
# puts "To begin, register two players like so: "
# puts "augi = Player.new('Augustine')"
# puts "Then create a new game: "
# puts "my_game = Game.new(augi, jake)"
# puts "to begin, type 'my_game.run'. Enjoy!"

