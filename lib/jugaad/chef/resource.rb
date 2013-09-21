class Chef
  class Resource
    def to_text
      ivars = instance_variables.map { |ivar| ivar.to_sym } - HIDDEN_IVARS
      text = "# Declared by Jugaad\n\n"
      text << self.class.dsl_name + "(\"#{name}\") do\n"
      ivars.each do |ivar|
        if (value = instance_variable_get(ivar)) && !(value.respond_to?(:empty?) && value.empty?)
          value_string = value.respond_to?(:to_text) ? value.to_text : value.inspect
          text << "  #{ivar.to_s.sub(/^@/,'')}( #{value_string})\n" if jugaadable?(ivar)
        end
      end
      [@not_if, @only_if].flatten.each do |conditional|
        text << "  #{conditional.to_text}\n"
      end
      text << "end\n"
    end

    def jugaadable?(ivar)
      resource_attribute = ivar.to_s.sub(/^@/,'')
      if resource_attribute == 'recipe_name'
        false
      elsif  resource_attribute == 'cookbook_name'
        false
      elsif ((self.class.dsl_name == "service")  and (resource_attribute == 'startup_type'))
        false
      else
        true
      end
    end
  end
end
