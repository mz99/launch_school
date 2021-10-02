# sample board
# 1|2|3
# -|-|-
# 4|5|6
# -|-|-
# 7|8|9

# new board
#  | |
# -|-|-
#  | |
# -|-|-
#  | |

require 'byebug'

INITIAL_MARKER = ' '
PLAYER_MARKER = 'X'
COMPUTER_MARKER = 'O'
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                [[1, 5, 9], [3, 5, 7]]

def prompt(msg)
  puts "=> #{msg}"
end

# rubocop:disable Metrics/AbcSize
def display_board(brd)
  system 'clear'
  puts "You're a #{PLAYER_MARKER}. Computer is a #{COMPUTER_MARKER}"
  puts ""
  puts "     |     |"
  puts "  #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}"
  puts "     |     |"
  puts "-----|-----|-----"
  puts "     |     |"
  puts "  #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}"
  puts "     |     |"
  puts "-----|-----|-----"
  puts "     |     |"
  puts "  #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}"
  puts "     |     |"
  puts ""
end
# rubocop:enable Metrics/AbcSize

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board # {1=>' ', 2=>' ', 3=>' ', 4=>' ', 5=>' ', 6=>' ', 7=>' ', 8=>' ', 9=>' '}
end

def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER } # [1,2,3,4,5,6,7,8,9]
end

def player_places_piece!(brd)
  square = ''
  loop do
    prompt "Choose a square (#{joinor(empty_squares(brd))}):"
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    prompt "Sorry, that's not a valid choice."
  end

  brd[square] = PLAYER_MARKER
end

def joinor(array, delimitor=',', placeholder = 'or')
# accepts 1 or more arguments
# first argument must be an array, second argument will be delimitor, third argument will be final delimitor
# if array size is 2, no delimitor, just append 'or' to last element
# if array size > 2, use commas for delimitor except last element, append 'or'
# if array size is 1, no delimitor
  output = ''

  case array.size
  when 0
    output = ''
  when 1
    output = array[0]
  when 2
    output = "#{array[0]} or #{array[1]}"
  else
    b = []
    counter = 0
    while counter < array.size - 1
      b[counter] = array[counter]
      counter += 1
    end
    output = b.join("#{delimitor} ") + "#{delimitor} #{placeholder} "  + array[-1].to_s
  end

  output
end

def computer_places_piece!(brd)
  next_move = nil

  # COMPUTER Offense
  # check each subarray in WINNING_LINES to see if two squares within same row/column
  # already has filled by PLAYER_MARKER, if so then computer defensive move will be
  # the remaining empty square within that row/column. If the remaining square is already
  # filled with COMPUTER_MARKER, then move at random
  WINNING_LINES.each do |arr|
    temp = []

    arr.each do |e|
      if brd[e] == 'X'
        temp << 'X'
      elsif brd[e] == 'O'
        temp << 'O'
      else
        next_move = e
      end
    end

    if (temp.select {|t| t == 'O'}.size == 2) && !(temp.include?'X')
      return brd[next_move] = COMPUTER_MARKER
    end
  end

  # Pick square 5 if still available
  return brd[5] = COMPUTER_MARKER if brd[5] == ' '


  # COMPUTER DEFENSE
  # check each subarray in WINNING_LINES to see if two squares within same row/column
  # already has filled by PLAYER_MARKER, if so then computer defensive move will be
  # the remaining empty square within that row/column. If the remaining square is already
  # filled with COMPUTER_MARKER, then move at random
  WINNING_LINES.each do |arr|
    temp = []

    arr.each do |e|
      if brd[e] == 'X'
        temp << 'X'
      elsif brd[e] == 'O'
        temp << 'O'
      else
        next_move = e
      end
    end

    if (temp.select {|t| t == 'X'}.size == 2) && !(temp.include?'O')
      return brd[next_move] = COMPUTER_MARKER
    end
  end

  random_square = empty_squares(brd).sample
  brd[random_square] = COMPUTER_MARKER
end

def board_full?(brd)
  empty_squares(brd).empty?
end

def someone_won?(brd)
  !!detect_winner(brd)
end

def detect_winner(brd)
  WINNING_LINES.each do |line|
    if brd[line[0]] == PLAYER_MARKER &&
       brd[line[1]] == PLAYER_MARKER &&
       brd[line[2]] == PLAYER_MARKER
      return 'Player'
    elsif brd[line[0]] == COMPUTER_MARKER &&
          brd[line[1]] == COMPUTER_MARKER &&
          brd[line[2]] == COMPUTER_MARKER
      return 'Computer'
    end
  end
  nil
end

board = initialize_board # board = {1=>' ',2=>' ',3=>' ',4=>' ',5=>' ',6=>' ',7=>' ',8=>' ',9=>' '}
display_board(board)
player_score = 0
computer_score = 0

loop do
  board = initialize_board

  loop do
    display_board(board)

    player_places_piece!(board)
    break if someone_won?(board) || board_full?(board)

    computer_places_piece!(board)
    break if someone_won?(board) || board_full?(board)
  end

  display_board(board)

  if someone_won?(board)
    prompt "#{detect_winner(board)} won!"

    if detect_winner(board) == 'Player'
      player_score += 1
    elsif detect_winner(board) == 'Computer'
      computer_score += 1
    end
  else
    prompt "It's a tie!"
  end

  if player_score > 4
    puts "Player has won 5 times. Player wins the game!!"
    break
  elsif computer_score > 4
    puts "Computer has won 5 times. Computer wins the game!!"
    break
  end

  prompt "Play again? (y or n)"
  answer = gets.chomp
  break unless answer.downcase.start_with?('y')
end

prompt "Thanks for playing Tic Tac Toe! Good bye!"


# Computer AI: Defense
# iterate through WINNING_LINES, if any of the sub-arrays have 2 out of the elements
# already marked by PLAYER_MARKER, then computer_places_piece shall be the 3rd element of that array.
# retrace how the game works up to that point.
