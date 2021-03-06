module AresMUSH    
  module test
    class AttributeSetCmd
      include CommandHandler
      
      attr_accessor :target_name, :ability_name, :die_step
      
      def parse_args
        # Admin version
        if (cmd.args =~ /\//)
          args = cmd.parse_args(ArgParser.arg1_equals_arg2_slash_arg3)
          self.target_name = titlecase_arg(args.arg1)
          self.attribute_name = titlecase_arg(args.arg2)
          self.die_step = downcase_arg(args.arg3)
        else
          args = cmd.parse_args(ArgParser.arg1_equals_arg2)
          self.target_name = enactor_name
          self.attribute_name = titlecase_arg(args.arg1)
          self.die_step = downcase_arg(args.arg2)
        end
        self.die_step = test.format_die_step(self.die_step)
      end
      
      def required_args
        [self.target_name, self.attribute_name, self.die_step]
      end
      
      def check_valid_die_step
        return nil if self.die_step == '0'
        return t('test.invalid_die_step') if !test.is_valid_die_step?(self.die_step)
        return nil
      end
      
      def check_valid_ability
        return t('test.invalid_ability_name') if !test.is_valid_attribute_name?(self.ability_name)
        return nil
      end
      
      def check_can_set
        return nil if enactor_name == self.target_name
        return nil if test.can_manage_attribute?(enactor)
        return t('dispatcher.not_allowed')
      end     
      
      def check_chargen_locked
        return nil if test.can_manage_attribute?(enactor)
        Chargen.check_chargen_locked(enactor)
      end
      
      def check_rating
        return nil if test.can_manage_attribute?(enactor)
        testcheck_max_starting_rating(self.die_step, 'max_attribute_step')
      end
      
      def handle
        ClassTargetFinder.with_a_character(self.target_name, client, enactor) do |model|
          attr = test.find_attribute(model, self.attribute_name)
          
          if (attr && self.die_step == '0')
            attr.delete
            client.emit_success t('test.attribute_removed')
            return
          end
          
          if (attr)
            attr.update(die_step: self.die_step)
          else
            testAttribute.create(name: self.attribute_name, die_step: self.die_step, character: model)
          end
         
          client.emit_success t('test.attribute_set')
        end
      end
    end
  end
end