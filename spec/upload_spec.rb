# frozen_string_literal: true

require_relative "./spec_helper"

describe "Upload" do
  before :all do
    ActiveRecord::Schema.define(version: 1) do
      create_table :photos do |t|
        t.column :image, :string
      end
    end
  end

  after :all do
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  context "Upload Image" do
    it "does upload image" do
      f = load_file("foo.jpg")
      Photo.transaction do
        puts Benchmark.measure {
          @photo = Photo.create(image: f)
        }
      end
      expect(@photo.errors.count).to eq 0

      @photo.reload
      expect(@photo.image.url).to include("/photos/")

      res = open(@photo.image.url)
      expect(res).not_to be_nil
      expect(res.size).to eq f.size
    end
  end

  describe "CarrierWave::SanitizedFile" do
    it "should have responed_to identifier" do
      f = CarrierWave::Storage::UpYun::File.new(nil, nil, nil)
      expect(f).to respond_to(:identifier)
      expect(f).to respond_to(:filename)
    end
  end
end
