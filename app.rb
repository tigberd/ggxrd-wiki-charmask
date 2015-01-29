require 'RMagick'
require 'open-uri'
require 'sinatra'

set :public_folder, File.dirname(__FILE__) + '/tmp'

helpers do
  def random_str
    Array.new(8){[*:a..:z,*0..9].sample}.join
  end
end

get '/index' do
  erb :index
end

get '/diff' do
  background_image = Magick::ImageList.new('background.jpg')
  black_image = Magick::ImageList.new('black.jpg')
  composite_image = Magick::ImageList.new.from_blob(open(params[:url]).read)

  mask_image = background_image.composite(composite_image, 0, 0, Magick::DifferenceCompositeOp).threshold(250)

  save_image = black_image.composite(composite_image.composite(mask_image, 0, 0, Magick::CopyOpacityCompositeOp), 0, 0, Magick::OverCompositeOp)

  @filename = "#{random_str}.png"
  save_image.write("./tmp/#{@filename}")

  @mask_filename = "#{random_str}_mask.png"
  mask_image.write("./tmp/#{@mask_filename}")

  erb :diff
end
