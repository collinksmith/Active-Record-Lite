require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    if class_name == "Human"
      "#{class_name.downcase}s"
    else
      class_name.underscore.pluralize
    end
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    name = name.to_s
    @foreign_key = options[:foreign_key] || "#{name.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.camelize.singularize
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    name = name.to_s
    @foreign_key = options[:foreign_key] || "#{self_class_name.underscore}_id".to_sym
    @primary_key = options[:primary_key] || :id
    @class_name = options[:class_name] || name.camelize.singularize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method(name) do
      params = {"#{options.table_name}.#{options.primary_key}" =>
                self.send(options.foreign_key)}

      options.model_class.where(params).first
    end

    assoc_options[name.to_sym] = options
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      params = {"#{options.table_name}.#{options.foreign_key}" =>
                self.send(options.primary_key)}

      options.model_class.where(params)
    end
    
      assoc_options[name.to_sym] = options
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
