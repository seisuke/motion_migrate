module MotionMigrate
  class Schema

    attr_accessor :entities

    def self.define(&block)
      schema = new
      schema.entities = []
      schema.instance_eval(&block)
      schema
    end

    def entity(name, &block)
      entity = Entity.new(name)
      entity.instance_eval(&block)
      @entities << entity
    end

  end

  class Attribute

    TYPE_MAPPING = {
      integer16:     'Integer 16',
      integer32:     'Integer 32',
      integer64:     'Integer 64',
      decimal:       'Decimal',
      double:        'Double',
      float:         'Float',
      string:        'String',
      boolean:       'Boolean',
      datetime:      'Date',
      binary:        'Binary Data',
      transformable: 'Transformable'
    }

    def self.convert_type(type)
      TYPE_MAPPING[type]
    end

    def initialize(name, type, options = {})
      @attributeType = self.class.convert_type(type)
      @name = name.to_s
      @optional = options[:optional] || 'YES'
      @syncable = options[:syncable] || 'YES'

      if !options[:default].nil?
        @defaultValueString = options.delete(:default)
      elsif [:integer16, :integer32, :integer64].include?(type)
        @defaultValueString = "0"
      elsif [:float, :double, :decimal].include?(type)
        @defaultValueString  = "0.0"
      end
    end

    def to_hash
      hash = Hash.new
      hash[:name] = @name
      hash[:attributeType] = @attributeType
      hash[:optional] = @optional
      hash[:syncable] = @syncable
      hash[:defaultValueString] if @defaultValueString
      hash
    end
  end

  class Relationship

    def initialize(entity, name, options = {})
      @name = name.to_s
      @optional = options[:optional] || 'YES'
      @syncable = options[:syncable] || 'YES'
      @deletionRule = options[:deletionRule] || 'Nullify'
      @maxCount = options[:maxCount] || 1
      @minCount = options[:minCount] || 1

      if options[:toMany]
        @to_many = options[:toMany]
      end

      if options[:inverse]
        entity, relation = options[:inverse].split('.')
        @destinationEntity = @inverseEntity = entity.name.classify
        @inverseName = relation
      else
        @destinationEntity = @inverseEntity = name.to_s.classify
        if options[:plural_inverse]
          @inverseName = entity.name.underscore.pluralize
        else
          @inverseName = entity.name.underscore
        end

      end

    end

    def to_hash
      hash = Hash.new
      hash[:name] = @name
      hash[:optional] = @optional
      hash[:syncable] = @syncable
      hash[:deletionRule] = @deletionRule
      hash[:destinationEntity] = @destinationEntity
      hash[:inverseEntity] = @inverseEntity
      hash[:inverseName] = @inverseName
      hash[:maxCount] = @maxCount
      hash[:minCount] = @minCount

      hash[:toMany] = @to_many if @to_many

      hash
    end

  end

  class Entity

    attr_accessor :name, :attributes, :relationships

    def initialize(name)
      @name = name.to_s
      @attributes = []
      @relationships = []
    end

    Attribute::TYPE_MAPPING.keys.each do |type|
      define_method(type) do |name, options = {}|
        @attributes << Attribute.new(name, type, options)
      end
    end

    # def belongs_to(name, options = {})
    #   @relationships << Relationship.new(self, name, {plural_inverse: true}.merge(options))
    # end

    def has_one(name, options = {})
      @relationships << Relationship.new(self, name)
    end

    def has_many(name, options = {})
      @relationships << Relationship.new(self, name, {maxCount: -1, toMany: 'YES'}.merge(options) )
    end

  end

end
