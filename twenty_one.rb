def create_new_deck(deck)
  suites = ['Hearts', 'Spades', 'Diamonds', 'Clubs']

  suites.each do |suite|
    (2..10).each do |n|
      deck << { "#{n} of #{suite}" => n }
    end
  end

  suites.each do |suite|
    deck << { "Jack of #{suite}" => 10 }
    deck << { "Queen of #{suite}" => 10 }
    deck << { "King of #{suite}" => 10 }
    deck << { "Ace of #{suite}" => [1, 11] }
  end

  10.times { deck.shuffle! }
end

def hit(cards, deck)
  cards << deck.shift
end

def show_cards(cards, show_dealer_cards=true)
  cards_output = []

  cards.each do |card|
    cards_output << card.keys
  end

  if show_dealer_cards == true
    cards_output.join(' and ')
  else
    cards_output[0][0] + " and an unknown card"
  end
end

def cards_values(cards, show_dealer_value=true)
  cards_value = []

  cards.each do |card|
    cards_value << card.values[0]
  end

  if show_dealer_value == true
    handle_aces(cards_value)
  else
    cards_value[0]
  end
end

def handle_aces(arr)
  # if subarray [1,11] exists in array
  # sum up all numbers in array as subtotal, leaving [1,11] to be evaluated last
  # if subtotal + 11 > 21, then subtotal + 1
  # else subtotal + 11
  # if subarray [1,11] doesn't exist in array, return original array
  if arr.include?([1, 11])
    sub_total = arr.select { |a| a != [1, 11] }.sum
    aces = arr.select { |a| a == [1, 11] }

    # iterate through all aces and accumulate the total if it doesn't go over 21
    aces.each do |a|
      if (sub_total + a[1]) > 21
        sub_total += a[0]
      else
        sub_total += a[1]
      end
    end
    sub_total
  else
    arr.sum
  end
end

def busted?(cards_value)
  true if cards_value > 21
end

def should_dealer_hit?(cards_value)
  true if cards_value < 17
end

def determine_winner(player_cards_value, dealer_cards_value)
  if busted? player_cards_value
    return "Dealer wins!"
  elsif busted? dealer_cards_value
    return "Player wins!"
  end

  if player_cards_value > dealer_cards_value
    "Player wins!"
  elsif dealer_cards_value > player_cards_value
    "Dealer wins!"
  else
    "It's a tie!!"
  end
end

loop do
  system 'clear'
  deck = []
  create_new_deck(deck)

  player_cards = []
  dealer_cards = []

  # follow rules of blackjack and alternatingly draw cards for player and dealer
  hit(player_cards, deck)
  hit(dealer_cards, deck)
  hit(player_cards, deck)
  hit(dealer_cards, deck)

  puts "Your cards are: #{show_cards(player_cards)} with a value of #{cards_values(player_cards)}"
  puts "Dealer's cards are: #{show_cards(dealer_cards, false)}. Dealer's cards value is atleast #{cards_values(dealer_cards, false)}"

  loop do
    puts "Would you like to hit (h) or stand (s)?"
    answer = gets.chomp
    break unless answer.downcase.start_with?('h')
    hit(player_cards, deck)
    if busted?(cards_values(player_cards))
      puts "Your cards value is #{cards_values(player_cards)}, you have busted!"
      break
    else
      puts "Your cards are: #{show_cards(player_cards)} with a value of #{cards_values(player_cards)}"
    end
  end

  if busted?(cards_values(player_cards))
    puts "You lost this round!"
    break
  end

  loop do
    if busted?(cards_values(dealer_cards))
      puts "Dealer cards value is #{cards_values(dealer_cards)}, dealer has busted!"
      break
    end
    if should_dealer_hit?(cards_values(dealer_cards))
      puts "Dealer cards are: #{show_cards(dealer_cards)} with a value of #{cards_values(dealer_cards)}. Dealer will hit"
      hit(dealer_cards, deck)
    else
      puts "Dealer cards are: #{show_cards(dealer_cards)} with a value of #{cards_values(dealer_cards)}. Dealer will stand"
      break
    end
  end

  puts determine_winner(cards_values(player_cards), cards_values(dealer_cards))

  puts "Press 'q' to quit the game, any other key to play again!"
  response = gets.chomp.downcase
  break if response.start_with?('q')
end
