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
      expect(@photo.image.url).to include("/photos/")

      res = URI.open(@photo.image.url)
      expect(res).not_to be_nil
      expect(res.size).to eq f.size
    end
  end

  describe "CarrierWave::SanitizedFile" do
    it "should have responed_to identifier" do
      uploader = PhotoUploader.new
      f = CarrierWave::Storage::UpYun::File.new(uploader, nil, "foo/bar.jpg")
      expect(f.filename).to eq("bar.jpg")
      expect(f.extension).to eq("jpg")
      expect(f.escaped_path).to eq("foo%2Fbar.jpg")
    end
  end
end
