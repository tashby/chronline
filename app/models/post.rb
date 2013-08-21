class Post < ActiveRecord::Base
  SLUG_PATTERN = %r[(\d{4}/\d{2}/\d{2}/)?[a-z_\d\-]+]
  include FriendlyId

  self.table_name = :articles

  friendly_id :title, use: [:slugged, :history]

  attr_accessible :author_ids, :body, :image_id, :previous_id, :published_at,
   :section, :subtitle, :teaser, :title

  belongs_to :image
  has_and_belongs_to_many :authors, class_name: 'Staff',
    join_table: :posts_authors

  serialize :section, Taxonomy::Serializer.new

  validates :body, presence: true
  validates :title, presence: true, length: { maximum: 90 }
  validates :authors, presence: true
  validates :teaser, length: { maximum: 200 }


  def self.published
    self
      .where('published_at IS NOT NULL')
      .where(['published_at < ?', DateTime.now])
  end

  # Stolen from http://snipt.net/jpartogi/slugify-javascript/
  def normalize_friendly_id(title, max_chars=100)
    return nil if title.nil?  # record won't save -- title presence is validated
    removelist = %w(a an as at before but by for from is in into like of off on
onto per since than the this that to up via with)
    r = /\b(#{removelist.join('|')})\b/i

    s = title.downcase  # convert to lowercase
    s.gsub!(r, '')
    s.strip!
    s.gsub!(/[^-\w\s]/, '')  # remove unneeded chars
    s.gsub!(/[-\s]+/, '-')   # convert spaces to hyphens
    s = s[0...max_chars].chomp('-')

    (published_at || Date.today).strftime('%Y/%m/%d/') + s
  end

  def published?
    not published_at.nil? and published_at < DateTime.now
  end

  def render_body
    EmbeddedMedia.new(body).to_s
  end

  ##
  # Reader for section attribute. Creates a Taxonomy object if section is a
  # string.
  #
  def section
    unless self[:section].is_a?(Taxonomy)
      self[:section] = Taxonomy.new(self[:section])
    end
    self[:section]
  end
end

# Necessary to avoid autoload namespacing conflict
require_dependency 'blog/post'