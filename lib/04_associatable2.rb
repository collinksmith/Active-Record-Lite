require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      source_table = source_options.table_name
      through_table = through_options.table_name

      results = DBConnection.execute(<<-SQL, id)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        INNER JOIN
          #{source_table}
          ON
            #{through_table}.#{source_options.foreign_key} =
            #{source_table}.#{source_options.primary_key}
        WHERE
          #{through_table}.#{through_options.primary_key} = ?
      SQL

      source_options.model_class.parse_all(results).first
    end
  end

  def has_many_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      source_table = source_options.table_name
      through_table = through_options.table_name

      on_condition = self.class.get_on_condition(through_options, 
                                      source_options, 
                                      through_table, 
                                      source_table)
      where_condition = self.class.get_where_condition(through_table, through_options)
    
      if through_options.is_a?(BelongsToOptions)
        search_value = self.attributes[through_options.foreign_key]

      elsif through_options.is_a?(HasManyOptions)
        search_value = self.attributes[:id]
      end

      results = DBConnection.execute(<<-SQL, search_value)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        INNER JOIN
          #{source_table}
          ON
            #{on_condition}
        WHERE
          #{where_condition} = ?
      SQL

      source_options.model_class.parse_all(results)
    end
  end

  def get_on_condition(through_options, source_options, through_table, source_table)
    if through_options.is_a?(BelongsToOptions)
      return <<-SQL
        #{source_table}.#{source_options.foreign_key} =
        #{through_table}.#{through_options.primary_key}
      SQL
    elsif through_options.is_a?(HasManyOptions)
      return <<-SQL
        #{through_table}.#{source_options.foreign_key} = #{source_table}.#{source_options.primary_key}
      SQL
    end
  end

  def get_where_condition(through_table, through_options)
    if through_options.is_a?(BelongsToOptions)
      return "#{through_table}.#{through_options.primary_key}"

    elsif through_options.is_a?(HasManyOptions)
      return "#{through_table}.#{through_options.foreign_key}"
    end
  end
end
