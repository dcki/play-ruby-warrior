class Player
    def play_turn(warrior)

        @warrior = warrior
        @mode ||= :first_turn
        @have_seen_both_walls_or_stairs ||= true

        case @mode
        when :first_turn
            do_first_turn
        when :fight_until_only_empty_and_wall, :fight_until_see_wall_or_stairs
            fight_until_only_empty_and_wall
        when :fight_to_stairs
            fight_to_stairs
        when :pivot_and_fight_until_only_empty_and_wall
            pivot_and_fight_until_only_empty_and_wall
        end
    end
    def do_first_turn
        if see :stairs, :forward
            if only_see([:empty, :wall], :backward)
                @mode = :fight_to_stairs
                play_turn @warrior
            else
                pivot!
                @mode = :fight_until_only_empty_and_wall
            end
        elsif see :stairs, :backward
            if only_see([:empty, :wall], :forward)
                pivot!
                @mode = :fight_to_stairs
            else
                @mode = :fight_until_only_empty_and_wall
                play_turn @warrior
            end
        else # Don't see stairs.
            if see :wall, :forward
                if only_see([:wall, :empty], :forward)
                    pivot!
                    @mode = :fight_to_stairs
                else
                    @mode = :fight_until_only_empty_and_wall
                    play_turn @warrior
                end
            elsif see :wall, :backward
                if only_see([:wall, :empty], :backward)
                    @mode = :fight_to_stairs
                    play_turn @warrior
                else
                    pivot!
                    @mode = :fight_until_only_empty_and_wall
                end
            else
                @mode = :fight_until_see_wall_or_stairs
                play_turn @warrior
            end
        end
    end
    def fight_until_only_empty_and_wall
        
        if see(:stairs)
            walk! :backward
            @mode = :pivot_and_fight_until_only_empty_and_wall
        elsif see(:wall) && only_see([:empty, :wall])
            pivot!
            @mode = :fight_to_stairs
        else
            advance!
        end
    end
    def fight_to_stairs
        advance!
    end
    def pivot_and_fight_until_only_empty_and_wall
        pivot!
        @mode = :fight_until_only_empty_and_wall
    end
    def advance!

        if feel.empty?
            # When the archer is at sight index 1, it will deal 2 rounds of damage before it can be killed at range or directly. So since damage is the same either way, we can either favor travelling further or hanging back in case there is another archer directly behind the first one and we need to be able to retreat quickly if necessary.
            if see :archer, :forward, 1
                if health > 6
                    shoot!
                else
                    walk! :backward
                end
            elsif see :archer, :forward, 2
                if see :captive
                    walk!
                elsif health > 3
                    shoot!
                else
                    walk! :backward
                end
            elsif see :wizard, :forward, 1..2
                if see :captive
                    walk!
                else
                    shoot!
                end
            elsif see :sludge, :forward, 1
                if health > 6
                    walk!
                else
                    rest!
                end
            elsif see :thick_sludge, :forward, 1
                if health > 12
                    walk!
                else
                    rest!
                end
            elsif see(:stairs) && only_see([:empty, :wall, :stairs])
                walk!
            elsif health > 9
                walk!
            else
                rest!
            end
        elsif feel.captive?
            rescue!
        elsif feel.wall?
            raise "Uh oh, this shouldn't happen. Walls should be seen before we get to them."
        elsif health < 4 &&
            (see(:sludge, :forward, 0) || see(:thick_sludge, :forward, 0)) &&
            (see(:archer, :forward, 1) || see(:archer, :forward, 2))
            walk! :backward
        elsif (see(:sludge, :forward, 0) || see(:thick_sludge, :forward, 0))
            attack!
        else
            raise "Uh oh, don't know what to do."
        end
    end
    def enemy_in_range
        look[1..2].each do |space|
            #if space.contains(:archer) || space.contains(:wizard)
            if space.contains :wizard
                return true
            end
        end
        return false
    end
    def see(what, direction = :forward, range = (0..-1))
        
        spaces = look(direction)
        if range.class == Fixnum
            if spaces[range].contains what
                return true
            else
                return false
            end
        else
            look(direction)[range].each do |space|
                return true if space.contains what
            end
            return false
        end
    end
    # TODO
    # only_see([:stairs, :empty, :wall]) should be false if there is a captive on the stairs. Is that what it really returns?
    # Even if it does, maybe the logic here should be re-done.
    def only_see(things, direction = :forward)

        things = [things] if things.class == Symbol

        look(direction).each do |space|

            something_else = true
            things.each do |thing|
                something_else = false if space.contains thing
            end
            return false if something_else
        end
    end
    def rest!
        @warrior.rest!
    end
    def feel(direction = :forward)
        @warrior.feel direction
    end
    def attack!(direction = :forward)
        @warrior.attack!
    end
    def rescue!(direction = :forward)
        @warrior.rescue! direction
    end
    def walk!(direction = :forward)
        @warrior.walk! direction
    end
    def pivot!
        @warrior.pivot!
    end
    def health
        @warrior.health
    end
    def look(direction = :forward)
        @warrior.look direction
    end
    def shoot!
        @warrior.shoot!
    end
end
class RubyWarrior::Space
    def contains(what)

        case what
        when :stairs
            return self.stairs?
        when :empty
            return self.empty?
        when :wall
            return self.wall?
        when :sludge
            return self.to_s == 'Sludge'
        when :thick_sludge
            return self.to_s == 'Thick Sludge'
        when :archer
            return self.to_s == 'Archer'
        when :wizard
            return self.to_s == 'Wizard'
        when :captive
            return self.captive?
        else
            raise ArgumentError, "Space::contains does not know how to handle #{what}"
        end
    end
end
