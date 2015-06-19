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
class Player
    def init(warrior)

        @warrior = warrior
        @mode ||= :first_turn
        @have_seen_both_walls_or_stairs ||= true
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
    def look(direction = :forward)
        @warrior.look direction
    end
    def shoot!
        @warrior.shoot!
    end
    # Note: this relies on enemies doing more damage (3) than the warrior can
    # heal (2) in one turn.
    def enemy_attacked
        health < @health_last_turn
    end
    def enemy_in_range
        #space = @warrior.look[1]
        #if !space.empty? && !space.captive? && !space.wall? && !space.to_s == 'Sludge' && !space.to_s == 'Thick Sludge'
        @warrior.look[1..2].each do |space|
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

        #if feel.empty?
        #    if enemy_in_range
        #        shoot!
        #    elsif @attacked_last_turn
        #        rest!
        #    elsif @no_enemy_attack_since_last_victory
        #        walk!
        #    elsif !enemy_attacked && health < 10
        #        rest!
        #    elsif enemy_attacked && health < 8
        #        walk! :backward
        #    else
        #        walk!
        #    end
        #elsif feel.captive?
        #    rescue!
        #elsif feel.wall?
        #    pivot!
        #elsif health < 4
        #    walk! :backward
        #else
        #    attack!
        #end
    end
    def play_turn(warrior)

        init warrior

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
        #if @first_turn
        #    if feel(:backward).wall?
        #        play_turn warrior
        #    else
        #        pivot!
        #    end
        #elsif feel.empty?
        #    if enemy_in_range
        #        shoot!
        #        # 1 is archer damage (3) minus amount healed when
        #        # resting (2).
        #    elsif @attacked_last_turn && health > 1
        #        rest!
        #    elsif @no_enemy_attack_since_last_victory
        #        walk!
        #    elsif !enemy_attacked && health < 10
        #        rest!
        #    elsif enemy_attacked && health < 8
        #        walk! :backward
        #    else
        #        walk!
        #    end
        #elsif feel.captive?
        #rescue!
        #elsif feel.wall?
        #    pivot!
        #else
        #    attack!
        #end


        @health_last_turn = health
    end
end

# There can be a thing on top of the stairs that hides them. E.g. on one
# level a captive is on the stairs until you rescue them. The plan below
# was not written with that in mind and may be disrupted by that.
# - fight_until_only_empty_and_wall must account for the fact that stairs
#   may be revealed on the way to the wall.
# - the case where no stairs or walls can be seen at first must do the
#   same.
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
#           Remember that you have not seen both walls yet
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
