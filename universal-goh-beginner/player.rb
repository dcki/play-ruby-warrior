class Player
    def play_turn(warrior)
        if !warrior.methods.include? :attack!
            # Level 1, non-epic mode.
            warrior.walk!
        elsif !warrior.methods.include? :rest!
            # Level 2.
            if warrior.feel.empty?
                warrior.walk!
            else
                warrior.attack!
            end
        else
            # Levels 3, 4, 5, 6.
            if warrior.feel.empty?
                @health_last_turn ||= warrior.health
                if @health_last_turn > warrior.health && !warrior.feel(:backward).wall? && warrior.health < 12 
                    warrior.walk! :backward
                elsif warrior.health > 18 || @health_last_turn > warrior.health
                    warrior.walk!
                else
                    warrior.rest!
                end
                @attacked_last_turn = false
            elsif warrior.feel.methods.include? :captive? && warrior.feel.captive?
                warrior.rescue!
            else
                warrior.attack!
                @attacked_last_turn = true
            end
            @health_last_turn = warrior.health
        end
    end
end
