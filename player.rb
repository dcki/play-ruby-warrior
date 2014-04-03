class Player

  def play_turn(warrior)
    init warrior
    update_damage_history
    unless rest_or_run
      if warrior.feel.empty?
        # Rest once after every fight so we don't
        # need to retreat as many times.
        if @rest_since_last_fight
          warrior.walk!
        else
          rest!
        end
      else
        attack!
      end
    end
  end
  
  def init(warrior)
    @damage_history ||= []
    @full_health ||= @last_health ||= warrior.health
    if @rest_since_last_fight.nil? then @rest_since_last_fight = true end
    @warrior = warrior
    # CHEAT
    @heal_counter ||= 3
  end

  def update_damage_history
    if @last_health - @warrior.health > 0
      @damage_history << @last_health - @warrior.health
    end
    @last_health = @warrior.health
  end

  def attack!
    @warrior.attack!
    @rest_since_last_fight = false
  end

  def rest!
    # CHEAT
    if @heal_counter > 0
      @warrior.rest!
      @heal_counter -= 1
    end
    @rest_since_last_fight = true
  end

  def rest_or_run
    return false
    #if @warrior.health == @full_health then @target_health = nil; return false end
    #if @target_health.nil?
    #  if @damage_history.max >= @warrior.health
    #    if @damage_history.max >= @full_health * 0.1
    #      @target_health = @damage_history.max + 1#, (@damage_history.min * 2) + 1].max
    #      @warrior.walk! :backward
    #    else
    #      rest!
    #    end
    #    return true
    #  else
    #    return false
    #  end
    #else
    #  if @warrior.health >= @target_health
    #    @target_health = nil
    #    return false
    #  else
    #    rest!
    #    return true
    #  end
    #end
  end

end
