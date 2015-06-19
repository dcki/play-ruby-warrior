class Player
  def play_turn(warrior)
      d = warrior.direction_of_stairs
      if warrior.feel(d).enemy?
          warrior.attack! d
      else
          warrior.walk! d
      end
  end
end
