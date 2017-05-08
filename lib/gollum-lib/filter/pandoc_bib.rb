require 'yaml'
require 'pathname'

# When using pandoc, put relevant bibliography metadata extracted in the YAML filter back in the document so it gets passed on to pandoc.
class Gollum::Filter::PandocBib < Gollum::Filter

  BIB_KEYS = ['bibliography', 'csl', 'link-citations', 'nocite']
  
  def process(data)
    data
  end

  def extract(data)
    return data unless supported_format? && bibliography_metadata_present? && using_pandoc?
    bib_metadata = {}

    BIB_KEYS.each do |bibliography_key|
      if path = @markup.metadata[bibliography_key]
        next unless file = @markup.wiki.file(path)
        path = Pathname.new("#{::File.join(::Dir.tmpdir, file.sha)}#{::File.extname(path)}")
        bib_metadata[bibliography_key] = path.to_s
        unless path.exist?
          path.open('w') do |copy_file|
            copy_file.write(file.raw_data)
          end
        end
      end
    end
    bib_metadata.empty? ? data : "#{bib_metadata.to_yaml}---\n#{data}"
  end

  private

  def supported_format?
    @markup.format == :markdown
  end

  def using_pandoc?
    GitHub::Markup::Markdown.implementation_name == 'pandoc-ruby'
  end

  def bibliography_metadata_present?
     @markup.metadata && @markup.metadata.keys.any? {|key| BIB_KEYS.include?(key)}
  end
end
