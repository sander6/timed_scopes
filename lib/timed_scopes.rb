module TimedScopes
  
  def self.included(base)
    base.__send__(:extend, TimedScopes::ClassMethods)
  end
  
  module ClassMethods
    
    def has_timed_scopes
      column_names.each do |column_name|
        if column_name =~ /^([\w\d_]+)_(at|on)$/
          named_scope :"#{$1}_after", lambda { |*args|
            time = args[0]
            order = args[1] || "DESC"
            {
              :conditions => [ "#{self.table_name}.#{column_name} > ?", time ],
              :order => "#{self.table_name}.#{column_name} #{order}"
            }
          }
          named_scope :"#{$1}_before", lambda { |*args|
            time = args[0]
            order = args[1] || "DESC"
            {
              :conditions => [ "#{self.table_name}.#{column_name} < ?", time ],
              :order => "#{self.table_name}.#{column_name} #{order}"
            }
          }
          named_scope :"#{$1}_between", lambda { |*args|
            start_time = args[0]
            end_time = args[1]
            order = args[2] || "DESC"
            {
              :conditions => [ "#{self.table_name}.#{column_name} > ? AND #{self.table_name}.#{column_name} < ?", start_time, end_time ],
              :order => "#{self.table_name}.#{column_name} #{order}"
            }
          }
        end
      end
    end
    
  end
  
end