class Image < ActiveRecord::Base
  attr_accessible :caption, :location
  mount_uploader :original, ImageUploader

  def to_jq_upload
    [{
      name: "picture1.jpg",
      size: 902604,
      url: "http:\/\/example.org\/files\/picture1.jpg",
      thumbnail_url: "http:\/\/example.org\/files\/thumbnail\/picture1.jpg",
      delete_url: "http:\/\/example.org\/files\/picture1.jpg",
      delete_type: "DELETE",
     }]
  end
end
