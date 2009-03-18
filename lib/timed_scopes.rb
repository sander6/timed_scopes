module TimedScopes
  
  def self.included(base)
    base.__send__(:extend, TimedScopes::ClassMethods)
  end
  
  module ClassMethods
    SCOPEABLE_COLUMN_TYPES = [ :datetime, :timestamp ]
    
    def has_timed_scopes
      return unless self.table_exists?
      timed_scopeable_columns.collect(&:name).each do |column_name|
        if column_name =~ /^([\w\d_]+)_(at|on)$/
          attr_prefix = $1
          at_or_on = $2
          named_scope :"#{attr_prefix}_after", lambda { |*args|
            time = at_or_on =~ /at/ ? Time.parse(args[0].to_s) : Date.parse(args[0].to_s)
            order = args[1].nil? ? "DESC" : args[1]
            
            options = {}
            options[:conditions] = [ "#{self.table_name}.#{column_name} > ?", time ]
            options[:order] = "#{self.table_name}.#{column_name} #{order}" if order
            options
          }

          named_scope :"#{attr_prefix}_#{at_or_on}_or_after", lambda { |*args|
            time = at_or_on =~ /at/ ? Time.parse(args[0].to_s) : Date.parse(args[0].to_s)
            order = args[1].nil? ? "DESC" : args[1]
            
            options = {}
            options[:conditions] = [ "#{self.table_name}.#{column_name} >= ?", time ]
            options[:order] = "#{self.table_name}.#{column_name} #{order}" if order
            options
          }
                    
          named_scope :"#{attr_prefix}_before", lambda { |*args|
            time = at_or_on =~ /at/ ? Time.parse(args[0].to_s) : Date.parse(args[0].to_s)
            order = args[1].nil? ? "DESC" : args[1]

            options = {}
            options[:conditions] = [ "#{self.table_name}.#{column_name} < ?", time ]
            options[:order] = "#{self.table_name}.#{column_name} #{order}" if order
            options
          }

          named_scope :"#{attr_prefix}_#{at_or_on}_or_before", lambda { |*args|
            time = at_or_on =~ /at/ ? Time.parse(args[0].to_s) : Date.parse(args[0].to_s)
            order = args[1].nil? ? "DESC" : args[1]

            options = {}
            options[:conditions] = [ "#{self.table_name}.#{column_name} <= ?", time ]
            options[:order] = "#{self.table_name}.#{column_name} #{order}" if order
            options
          }

          named_scope :"#{attr_prefix}_between", lambda { |*args|
            start_time = at_or_on =~ /at/ ? Time.parse(args[0].to_s) : Date.parse(args[0].to_s)
            end_time = at_or_on =~ /at/ ? Time.parse(args[1].to_s) : Date.parse(args[1].to_s)
            order = args[2].nil? ? "DESC" : args[2]

            options = {}
            options[:conditions] = [ "#{self.table_name}.#{column_name} > ? AND #{self.table_name}.#{column_name} < ?", start_time, end_time ]
            options[:order] = "#{self.table_name}.#{column_name} #{order}" if order
            options
          }
        end
      end
    end

    private

    # Returns an Array of column names for which we should add timed named scopes
    def timed_scopeable_columns
      columns.select{ |c| SCOPEABLE_COLUMN_TYPES.include?(c.type) }
    end
  end
  
end