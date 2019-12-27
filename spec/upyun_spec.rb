# frozen_string_literal: true

require_relative "./spec_helper"

describe "UpYun" do
  it "should store" do
    f = load_file("foo.jpg")

    uploader = PhotoUploader.new
    uploader.store!(f)
    expect(uploader.url).to include("/photos/")

    res = URI.open(uploader.url)
    expect(res).not_to be_nil
    expect(res.size).to eq f.size
  end

  it "should cache" do
    f = load_file("foo.jpg")

    uploader = PhotoUploader.new
    uploader.cache!(f)
    expect(uploader.url).to include("/uploads/tmp/")

    res = URI.open(uploader.url)
    expect(res).not_to be_nil
    expect(res.size).to eq f.size

    uploader.store!
    expect(uploader.url).to include("/photos/")
    res = URI.open(uploader.url)
    expect(res).not_to be_nil
    expect(res.size).to eq f.size
  end
end
