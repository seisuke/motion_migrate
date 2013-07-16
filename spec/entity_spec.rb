require "motion_migrate/schema"

module MotionMigrate
  describe do
    subject {
      Schema.define do
        entity "Post" do
          integer32 'test', optional: false
        end
      end.entities.first
    }

    it do
      expect( subject.name ).to eq "Post"
    end
  end

end
