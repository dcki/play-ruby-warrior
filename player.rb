class Player
  def init(warrior)
    @warrior = warrior
    @health_last_turn ||= health
    @attacked_last_turn ||= false
    @rested_last_turn_after_attack ||= false
    @first_turn = @first_turn.nil? ? true : false

    if !enemy_attacked &&
      (@rested_last_turn_after_attack || @no_enemy_attack_since_last_victory)
      @no_enemy_attack_since_last_victory = true
    else
      @no_enemy_attack_since_last_victory = false
    end
  end
  def rest!
    if @attacked_last_turn
      @rested_last_turn_after_attack = true
    else
      @rested_last_turn_after_attack = false
    end
    @attacked_last_turn = false
    @warrior.rest!
  end
  def feel(direction = :forward)
    @warrior.feel direction
  end
  def attack!(direction = :forward)
    @attacked_last_turn = true
    @rested_last_turn_after_attack = false
    @warrior.attack!
  end
  def rescue!(direction = :forward)
    @attacked_last_turn = false
    @rested_last_turn_after_attack = false
    @warrior.rescue! direction
  end
  def walk!(direction = :forward)
    @attacked_last_turn = false
    @rested_last_turn_after_attack = false
    @warrior.walk! direction
  end
  def pivot!
    @warrior.pivot!
  end
  def health
    @warrior.health
  end
  # Note: this relies on enemies doing more damage (3) than the warrior can
  # heal (2) in one turn.
  def enemy_attacked
    health < @health_last_turn
  end
  def play_turn(warrior)

    init warrior

    # Best known for level 7, still not good enough. :p
    # It was good enough, but -s option produces misleading victory message. :/
    #@cheater_pumpkin_eater_actions = ['pivot!', 'walk!', 'attack!', 'attack!', 'attack!', 'attack!', 'attack!', 'walk! :backward', 'rest!', 'walk!', 'walk!', 'walk!', 'attack!', 'attack!', 'walk!', 'walk!']
    #@action_index ||= 0
    #eval(@cheater_pumpkin_eater_actions[@action_index])
    #@action_index += 1
    #return

    #warrior.listen
    #warrior.distance

    # Assume stairs are in front so we want to search behind us first by
    # default, before moving toward the stairs.
    if @first_turn
      if feel(:backward).wall?
        play_turn warrior
      else
        pivot!
      end
    elsif feel.empty?
      # 1 is max enemy ranged damage encountered (3) minus amount healed when
      # resting (2).
      if @attacked_last_turn && health > 1
        rest!
      elsif @no_enemy_attack_since_last_victory
        walk!
      elsif !enemy_attacked && health < 10
        rest!
      elsif enemy_attacked && health < 8
        walk! :backward
      else
        walk!
      end
    elsif feel.captive?
      rescue!
    elsif feel.wall?
      pivot!
    else
      attack!
    end
    @health_last_turn = health
  end
end


#class Player
#  def init(warrior)
#    @warrior = warrior
#    @health_last_turn ||= health
#    @under_attack = @health_last_turn > health
#    @direction ||= :backward
#  end
#  def health
#    @warrior.health
#  end
#  def opposite_direction
#    if  @direction == :forward
#      return :backward
#    else
#      return :forward
#    end
#  end
#  def play_turn(warrior)
#    
#    init warrior
#      
#    if warrior.feel(@direction).empty?
#      if @under_attack && health < 12
#        warrior.walk! :backward
#        #warrior.walk!
#      elsif @under_attack
#        warrior.walk!
#      elsif warrior.health < 20
#        warrior.rest!
#      else
#        warrior.walk! @direction
#      end
#    elsif warrior.feel(@direction).captive?
#      warrior.rescue! @direction
#    elsif @direction == :backward
#    #elsif warrior.feel(@direction).wall?
#      @direction = opposite_direction
#      warrior.walk!
#    else
#      warrior.attack! @direction
#    end
#    
#    @health_last_turn = health
#  end
#end
#
#class Player
#
#  def play_turn(warrior)
#
#    initialize
#
#    is_taking_damage?(warrior)
#    actions(warrior)
#    record_health(warrior)
#
#  end
#
#  def initialize
#    #sets up some necessary variable values
#    @max_health = 20
#    if @health == nil then @health = @max_health end 
#  end
#
#  def is_taking_damage?(warrior)
#    #checks current health vs previous health to see if we are being attacked
#    @under_attack = warrior.health < @health
#  end
#
#  def actions(warrior) 
#    #potential actions the warrior can take to respond to situations
#
#    #   if warrior.feel(:backward).empty? == true and @rescue_count != 1
#    #     warrior.walk!(:backward)
#    #   elsif warrior.feel(:backward).empty? == false
#    #     warrior.rescue!(:backward)
#    #     @rescue_count = 1
#    #   else
#
#    if warrior.feel.wall? == true
#      warrior.pivot!
#    else
#      if @under_attack == true and warrior.feel.empty? == true
#        if warrior.health < 10
#          warrior.walk!(:backward)
#        else
#          warrior.walk!
#        end
#      elsif @under_attack == true and warrior.feel.empty? == false
#        if warrior.feel.captive?
#          warrior.rescue!
#        else
#          warrior.attack!
#        end
#      elsif @under_attack == false and warrior.feel.empty? == true and warrior.health == @max_health
#        warrior.walk!
#      elsif @under_attack == false and warrior.feel.empty? == false and warrior.health == @max_health
#        if warrior.feel.captive?
#          warrior.rescue!
#        else
#          warrior.attack!
#        end
#      elsif @under_attack == false and warrior.health < @max_health
#        warrior.rest!
#      end
#    end
#  end
#
#  def record_health(warrior)
#    #recurds current health, where @health is equivilent to health from previous turn
#    @health = warrior.health
#  end
#end
