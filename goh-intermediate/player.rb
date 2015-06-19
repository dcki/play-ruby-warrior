class Player
    def initialize
        @enemy_names = [ 'Sludge', 'Thick Sludge', 'Archer', 'Wizard' ]
    end
    def surrounded_count
        sum = 0
        sum += 1 if @warrior.feel.enemy? && !@warrior.feel.captive?
        sum += 1 if @warrior.feel(:left).enemy? && !@warrior.feel(:left).captive?
        sum += 1 if @warrior.feel(:right).enemy? && !@warrior.feel(:right).captive?
        sum += 1 if @warrior.feel(:backward).enemy? && !@warrior.feel(:backward).captive?
        #sum += 1 if @warrior.feel.enemy?
        #sum += 1 if @warrior.feel(:left).enemy?
        #sum += 1 if @warrior.feel(:right).enemy?
        #sum += 1 if @warrior.feel(:backward).enemy?
        sum
    end
    def feel(direction = :forward)
        @warrior.feel direction
    end
    def feel_anywhere(what)
        case what
        when :enemy
            return feel.enemy? || feel(:right).enemy? || feel(:left).enemy? || feel(:backward).enemy?
        when :captive
            return friendly_captive?(feel) ||
                friendly_captive?(feel(:right)) ||
                friendly_captive?(feel(:left)) ||
                friendly_captive?(feel(:backward))
        #when :captive_foe
        #    return (feel.captive? && enemy_name?(feel.to_s)) || feel(:right).captive? || feel(:left).captive? || feel(:backward).captive?
        when :empty
            return feel.empty? || feel(:right).empty? || feel(:left).empty? || feel(:backward).empty?
        when :wall
            return feel.wall? || feel(:right).wall? || feel(:left).wall? || feel(:backward).wall?
        when :stairs
            return feel.stairs? || feel(:right).stairs? || feel(:left).stairs? || feel(:backward).stairs?
        end
    end
    def friendly_captive?(space)
        return !(@enemy_names.include? space.to_s) && space.captive?
    end
    def play_turn(warrior)
        @warrior = warrior
        d = warrior.direction_of_stairs
        if surrounded_count > 1
            if warrior.feel.enemy? && :forward != d
                warrior.bind!
            elsif warrior.feel(:left).enemy? && :left != d
                warrior.bind! :left
            elsif warrior.feel(:right).enemy? && :right != d
                warrior.bind! :right
            elsif warrior.feel(:backward).enemy? && :backward != d
                warrior.bind! :backward
            end
        elsif feel_anywhere :captive
            if friendly_captive? feel
                warrior.rescue!
            elsif friendly_captive? feel :right
                warrior.rescue! :right
            elsif friendly_captive? feel :left
                warrior.rescue! :left
            elsif friendly_captive? feel :backward
                warrior.rescue! :backward
            end
        elsif warrior.feel(d).enemy?
            warrior.attack! d
        else
            warrior.walk! d
        end
    end
end
