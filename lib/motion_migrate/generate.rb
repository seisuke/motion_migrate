module MotionMigrate
  class Model
    include MotionMigrate::MotionGenerate::Entity
    include MotionMigrate::MotionGenerate::Parser
    include MotionMigrate::MotionGenerate::Property
    include MotionMigrate::MotionGenerate::Relationship
  end

  class Generate
    class << self
      def build
        # raise "! No models defined in 'app/models', add models to this folder if you want to generate the database model." if schema
        schema = File.open("db/schema.rb") { |file| eval(file.read) }

        builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
          xml.model(database_model_attributes) do
            schema.entities.each do |entity|
              xml.entity(:name => entity.name, :representedClassName => entity.name, :syncable => "YES") do
                entity.attributes.each do |attribute|
                  xml.attribute(attribute.to_hash)
                end
                entity.relationships.each do |relationship|
                  xml.relationship(relationship.to_hash)
                end
              end
            end
          end
        end
        builder.to_xml
      end

      def database_model_attributes
        {
          :name => "",
          :userDefinedModelVersionIdentifier => "",
          :type => "com.apple.IDECoreDataModeler.DataModel",
          :documentVersion => "1.0",
          :lastSavedToolsVersion => "1811",
          :systemVersion => "11D50",
          :minimumToolsVersion => "Automatic",
          :macOSVersion => "Automatic",
          :iOSVersion => "Automatic"
        }
      end
    end
  end
end
