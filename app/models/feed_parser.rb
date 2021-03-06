require 'imgkit'
require 'webpage_preview_generator'

class FeedParser
  include SourceLogger

  def create_item(feed_entry, source,source_image)
    logger.info "Got Feed Entry For Source <#{source.name}>: #{feed_entry.title}"
    image_url = get_image(feed_entry)
    webpage_preview_url = WebpagePreviewGenerator.instance.generate(webpage_preview_name(feed_entry)+".jpg",feed_entry.url) if !image_url
    summary = parsed_summary(feed_entry) if source.has_summary

    Item.new({
                 :title => feed_entry.title,
                 :url => feed_entry.url,
                 :author => feed_entry.author,
                 :date => feed_entry.published,
                 :image => image_url,
                 :summary => summary,
                 :source => source,
                 :source_image => source_image,
                 :webpage_preview => webpage_preview_url,
             })
  end


  private

  MIN_AREA = 10000

  def webpage_preview_name(feed_entry)
    feed_entry.title[0..4]+feed_entry.published.strftime("%d%m%y%H%M%S")
  end

  def get_image(feed_entry)
    content = Nokogiri::HTML(feed_entry.content || feed_entry.summary)
    images = content.css('img').map { |i| i['src'].gsub(/\?.*/,'') if i['src'] }
    biggest_image(images.compact)
  end

  def biggest_image(images)
    final_image_url = nil
    final_image_area = nil

    images.each do |img|
      logger.info "Checking Image: #{img}"
      image_size = FastImage.size(URI.escape img) if img.length < 256
      image_area = image_size[0] * image_size[1] if image_size
      if (image_area && image_area > (final_image_area || MIN_AREA))
        final_image_url = img
        final_image_area = image_area
      end
    end
    final_image_url
  end

  def parsed_summary(feed_entry)
    summary = feed_entry.content || feed_entry.summary
    (summary = summary.gsub(/<.*?>/, "").gsub(/\n/, " ").slice(0,300)) if summary
    (summary = summary + "...") if summary && summary != ""
    summary
  end

end
