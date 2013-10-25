# encoding: utf-8
# rubocop:disable all
# Adds class methods to AR::Base that allows for declaring and invoking
# simple where/order scopes.
#
# filterable_by_keys will produce scopes named "with_#{key}" and can
# take two different types of values for each key:
#  * A symbol, in which case the scope will do a simple where(symbol => value)
#  * A string, in which case the scope will do a simple where(symbol, value)
#  * A hash with a value for the :finder key (a symbol or string, as above)
#    and any of the following options:
#     * :joins     - any joins required for the scope.
#     * :scopes    - a single symbol, or an array of symbols representing any
#                    scopes to apply to the scope.
#     * :transform - a symbol representing a method that will transform the
#                    search term. This module provides :percent_wrap,
#                    which will wrap the term in percent symbols for use
#                    with LIKE operators.

module SearchByKeyedScopes
  extend ActiveSupport::Concern

  module ClassMethods
    def eval_scopes(scopes = nil)
      if !scopes.is_a? Array
        return self if scopes.nil?
        scopes = [ scopes ]
      end

      rel = self
      scopes.each { |scope| rel = rel.send(scope) }
      rel
    end

    def filterable_by_keys(keys = {})
      self.class_eval do
        scope :filter_by, lambda { |key, value|
          if respond_to? "with_#{key}"
            send("with_#{key}", value)
          else
            logger.warn "Not implemented: #{self}.with_#{key}"
            nil
          end
        }
      end

      keys.each do |field, stmt|
        scope_name = "with_#{field}".to_sym
        finder = stmt
        joins = scopes = where = includes = nil

        if stmt.is_a? Hash
          finder = stmt[:finder]
          joins = stmt[:joins]
          includes = stmt[:includes]
          scopes = stmt[:scopes]
          transform = stmt[:transform]
        end

        transform ||= :identity

        self.class_eval do
          if finder.is_a? Symbol
            scope scope_name, lambda { |term|
              term = term[0] if term.is_a?(Array) && term.size == 1
              eval_scopes(scopes).includes(includes).joins(joins) \
                .where(finder => transform_value(transform, term))
            }
          elsif finder.is_a? String
            scope scope_name, lambda { |term|
              term = term[0] if term.is_a?(Array) && term.size == 1
              eval_scopes(scopes).includes(includes).joins(joins) \
                .where(finder, transform_value(transform, term))
            }
          end
        end
      end
    end

    def sortable_by_keys(keys = {})
      self.class_eval do
        scope :order_by, lambda { |key, args_or_dir = 'asc'|
          if !key.nil? and respond_to? "order_by_#{key}"
            send("order_by_#{key}", args_or_dir)
          else
            unless key.nil?
              logger.warn "Not implemented: #{self}.order_by_#{key}"
            end
            nil
          end
        }
      end

      keys.each do |field, stmt|
        scope_name = "order_by_#{field}".to_sym
        field = stmt
        joins = scopes = nil

        if stmt.is_a? Hash
          field = stmt[:field]
          joins = stmt[:joins]
          scopes = stmt[:scopes]
        end
        fail "Invalid sortable_by_keys field: #{field}, arguments
        #{stmt} no field can be found" if field.blank?
        class_eval do
          scope scope_name, lambda do |dir = 'asc'|
            eval_scopes(scopes).joins(joins).order("#{field} #{dir}")
          end
        end
      end
    end

    def transform_value(transforms, value)
      transformed = value
      transforms = transforms.is_a?(Array) ? transforms : [transforms]
      transforms.reject(&:nil?).each { |t| transformed = send(t, transformed) }
      transformed
    end

    def identity(value)
      value
    end

    def percent_wrap(value)
      "%#{value}%"
    end

    def strip_nonnumerics(value)
      value.gsub(/[^0-9]/, '')
    end

    def always_true(value)
      true
    end

    def always_false(value)
      false
    end

    def to_i(value)
      value.to_i
    end

    def to_list(value)
      if value.is_a? String
        value.split(',')
      else
        value
      end
    end

    def to_i_list(value)
      to_list(value).map(&:to_i)
    end
  end
end
# rubocop:enable all
