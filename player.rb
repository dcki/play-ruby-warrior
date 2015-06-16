class Player
  def init(warrior)
    @warrior = warrior
    @health_last_turn ||= health
    @direction ||= :forward
    @attacked_last_turn ||= false
    @rested_last_turn ||= false
    @first_turn = @first_turn.nil? ? true : false
  end
  def opposite_direction
    if @direction == :backward
      return :forward
    else
      return :backward
    end
  end
  def rest!
    @attacked_last_turn = false
    @rested_last_turn = true
    @warrior.rest!
  end
  def feel(direction = :forward)
    @warrior.feel direction
  end
  def attack!(direction = :forward)
    @attacked_last_turn = true
    @rested_last_turn = false
    @warrior.attack!
  end
  def rescue!(direction = :forward)
    @attacked_last_turn = false
    @rested_last_turn = false
    @warrior.rescue! direction
  end
  def walk!(direction = :forward)
    @attacked_last_turn = false
    @rested_last_turn = false
    @warrior.walk! direction
  end
  def pivot!
    @direction = opposite_direction
    @warrior.pivot!
  end
  def health
    @warrior.health
  end
  def play_turn(warrior)

    init warrior

    # Assume stairs are in front so we want to search behind us first by
    # default, before moving toward the stairs.
    if @first_turn
      if feel(opposite_direction).wall?
        play_turn warrior
      else
        pivot!
      end
    elsif feel(@direction).empty?
      puts @direction
      if @attacked_last_turn && health > 1
        rest!
      elsif health >= @health_last_turn && health < 14
        rest!
      elsif health < @health_last_turn && health < 7
        if feel(opposite_direction).empty?
          walk! opposite_direction
        elsif feel(opposite_direction).captive?
          rescue! opposite_direction
        else
          attack! opposite_direction
        end
      else
        walk! @direction
      end
    elsif feel(@direction).captive?
      rescue! @direction
    elsif feel.wall?
      pivot!
    else
      attack! @direction
    end
  end
end
