class Player

  attr_accessor :warrior, :amount_healed_last_turn

  def init(warrior)
    @warrior = warrior
    @damage_history ||= DamageHistory.new self
    @full_health ||= warrior.health
    if @rested_since_last_fight.nil? then @rested_since_last_fight = true end
    if @amount_healed_last_turn.nil? then @amount_healed_last_turn = 0 end
    if @attacked_last_turn.nil? then @attacked_last_turn = false end
    if @archer.nil? then @archer = false end
    if @dont_retreat.nil? then @dont_retreat = false end
    # CHEAT
    @heal_counter ||= 20
  end

  def play_turn(warrior)
    #if warrior.feel.empty?
    #  warrior.walk!
    #else
    #  warrior.attack!
    #end

    init warrior
    @damage_history.update_damage_history
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
          if @rested_since_last_fight
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

  def attack!(direction = :forward)
    @warrior.attack! direction
    @attacked_last_turn = true
    @rested_since_last_fight = false
    @amount_healed_last_turn = 0
  end

  def rest!
    @warrior.rest!
    @rested_since_last_fight = true
    @amount_healed_last_turn = 2
  end

  def walk!(direction = :forward)
    @dont_retreat = false
    @warrior.walk! direction
    @amount_healed_last_turn = 0
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
            @target_health = [@damage_history.max + 1, ((@damage_history.select {|d| d > 0 }).min * 3) + 1].max
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

class DamageHistory < Array

  def initialize(player)
    @player = player
    @last_health = player.warrior.health
  end

  def update_damage_history
    self << @last_health - @player.warrior.health + @player.amount_healed_last_turn
    @last_health = @player.warrior.health
  end

end
