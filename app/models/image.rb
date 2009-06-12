class Image < ActiveRecord::Base
  has_attached_file :upload,
    :url => '/system/:class/:attachment/:id_partition/:basename-:style.:extension',
    :path => File.join(Rails.root, 'public/system/:class/:attachment/:id_partition/:basename-:style.:extension'),
    :styles => { '48x48' => '2304@' }
end