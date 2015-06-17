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
  def enemy_in_range
    space = @warrior.look[1]
    if !space.empty? && !space.captive? && !space.wall?
      return true
    else
      return false
    end
  end
  def play_turn(warrior)

    init warrior

    # There can be a thing on top of the stairs that hides them. E.g. on one
    # level a captive is on the stairs until you rescue them. The plan below
    # was not written with that in mind and may be disrupted by that.
    #
    # On the first turn, decide which direction to go and start in that
    # direction:
    #   if (stairs in view forward)
    #       if (anything other than empty and wall backward)
    #           pivot and fight_until_only_empty_and_wall
    #       else
    #           fight_to_stairs.
    #       end
    #   elsif (stairs in view backward)
    #       if (anything other than empty and wall forward)
    #           fight_until_only_empty_and_wall
    #       else
    #           pivot and fight_to_stairs
    #       end
    #   else # Don't see stairs.
    #       if (see wall in front)
    #           if (see only wall and empty in front)
    #               pivot and fight_to_stairs
    #           else
    #               fight_until_only_empty_and_wall
    #           end
    #       elsif (see wall backward)
    #           if (see only wall and empty backward)
    #               fight_to_stairs
    #           else
    #               pivot and fight_until_only_empty_and_wall
    #           end
    #       else
    #           fight until you see wall or stairs and then re-decide.
    #       end
    #   end
    #
    # On subsequent turns:
    #   if (haven't seen wall or stairs)
    #       if (see stairs)
    #           pivot and fight_until_only_empty_and_wall.
    #       elsif (see wall)
    #           if (see anything other than empty)
    #               fight until you see only wall or stairs.
    #           else
    #               pivot and fight_until_only_empty_and_wall.
    #           end
    #       end
    #   elsif (see wall in front and not stairs)
    #       if (only empty and wall in front)
    #           fight until you see only wall or stairs.
    #       
    #     

    #puts warrior.look[1].to_s

    #'Archer'
    #'Wizard'
    #'Sludge'
    #'Thick Sludge'

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
      if enemy_in_range
        warrior.shoot!
      # 1 is archer damage (3) minus amount healed when
      # resting (2).
      elsif @attacked_last_turn && health > 1
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
