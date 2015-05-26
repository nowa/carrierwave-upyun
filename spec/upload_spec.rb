require File.dirname(__FILE__) + '/spec_helper'

require "open-uri"
ActiveRecord::Base.raise_in_transactional_callbacks = true
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')

describe "Upload" do
  def setup_db
    ActiveRecord::Schema.define(:version => 1) do
      create_table :photos do |t|
        t.column :image, :string
      end
    end
  end

  def drop_db
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
  end

  class PhotoUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    version :small do
      process :resize_to_fill => [120, 120]
    end

    def store_dir
      "photos"
    end
  end

  class Photo < ActiveRecord::Base
    mount_uploader :image, PhotoUploader
  end


  before :all do
    setup_db
  end

  after :all do
    drop_db
  end

  context "Upload Image" do
    it "does upload image" do
      f = load_file("foo.jpg")
      puts Benchmark.measure {
        @photo = Photo.create(image: f)
      }
      expect(@photo.errors.count).to eq 0
      puts "Uploaded: #{@photo.image.url}"
      
      res = open(@photo.image.url)
      
      expect(res).not_to be_nil
      expect(res.size).to eq f.size
      
      small_res = open(@photo.image.small.url)
      expect(small_res).not_to be_nil
      
      f1 = load_file("foo.gif")
      p1 = Photo.create(image: f1)
      res = open(p1.image.url)
      expect(res.size).to eq f1.size
    end
  end
  
  describe 'CarrierWave::SanitizedFile' do
    it 'should have responed_to identifier' do
      f = CarrierWave::Storage::UpYun::File.new(nil, nil, nil)
      expect(f).to respond_to(:identifier)
      expect(f).to respond_to(:filename)
    end
  end
end
