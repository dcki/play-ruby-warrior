class Player

  def play_turn(warrior)
    #if warrior.feel.empty?
    #  warrior.walk!
    #else
    #  warrior.attack!
    #end

    init warrior
    update_damage_history
    if @attacked_last_turn && warrior.feel.empty?
      @archer = false
      @dont_retreat = true
    end
    if rest_or_run
      @attacked_last_turn = false
    else
      if warrior.feel.empty?
        if @damage_history.last > 0 # Archer shot at us
          @archer = true
          walk!
        else
          # Rest after every fight so we don't
          # need to retreat as many times.
          if @rest_since_last_fight
            walk!
          else
            rest!
          end
          @attacked_last_turn = false
        end
      else
        attack!
      end
    end
  end
  
  def init(warrior)
    @warrior = warrior
    @damage_history ||= []
    @full_health ||= @last_health ||= warrior.health
    if @rest_since_last_fight.nil? then @rest_since_last_fight = true end
    if @attacked_last_turn.nil? then @attacked_last_turn = false end
    if @archer.nil? then @archer = false end
    if @dont_retreat.nil? then @dont_retreat = false end
    # CHEAT
    @heal_counter ||= 20
  end

  def update_damage_history
    @damage_history << @last_health - @warrior.health
    @last_health = @warrior.health
  end

  def attack!(direction = :forward)
    @warrior.attack! direction
    @attacked_last_turn = true
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

  def walk!(direction = :forward)
    @dont_retreat = false
    @warrior.walk! direction
  end

  def rest_or_run
    if @archer
      return false
    else
      greatest_damage_seen = @damage_history.max
      if @warrior.health == @full_health then @target_health = nil; return false end
      if @target_health.nil?
        if greatest_damage_seen >= @warrior.health
          if greatest_damage_seen >= @full_health * 0.1
            @target_health = @damage_history.max + 1#, (@damage_history.min * 2) + 1].max
            if @dont_retreat
              rest!
            else
              walk! :backward
            end
          else
            rest!
          end
          return true
        else
          return false
        end
      else
        if @warrior.health >= @target_health
          @target_health = nil
          return false
        else
          rest!
          return true
        end
      end
    end
  end

end
