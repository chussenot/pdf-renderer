#---
# Excerpted from "Crafting Rails Applications",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/jvrails for more book information.
#---
require "action_controller"
Mime::Type.register "application/pdf", :pdf

require "prawn"
require "yaml"
require 'nokogiri'
ActionController::Renderers.add :pdf do |filename, options|
  
  # Set default options
  layout_xml = Nokogiri::XML(render_to_string(options))
  
  first_page = true
  
  pdf_xml_element = layout_xml_document.children[0]
  pdf_xml_element.children.each do |page_xml_element|
    orientation = page_xml_element.attributes["orientation"].nil? ? :portrait : page_xml_element.attributes["orientation"].to_sym
    
    if first_page
      first_page = false
      pdf = Prawn::Document.new :page_layout => orientation
    else
      pdf.start_new_page :layout => orientation
    end
    
    page_xml_element.children.each do |part_xml_element|
      part_x_offset = part_xml_element.attributes["x"].nil? ? 0 : part_xml_element.attributes["x"].value.to_i
      part_y_offset = part_xml_element.attributes["y"].nil? ? 0 : part_xml_element.attributes["y"].value.to_i
      
      part_xml_element.children.each do |item_xml_element|
        type = item_xml_element.attributes["type"].value
        
        case type
        when 'cell'
          options = Hash.new
          options[:content] = section[key].to_s
          options[:width] = content_layout["width"]
          options[:height] = content_layout["height"]
          options[:x] = section_offset_x + content_layout["x"]
          options[:y] = section_offset_y + content_layout["y"]
          
          if !content_layout["options"].nil?
            options.merge!(eval(content_layout["options"]))
          end
          
           pdf.cell(options)
        when 'text'
          options = content_layout["options"].nil? ? nil : eval(content_layout["options"])
          pdf.text_box( section[key].to_s, options )
        end
      end
    end
  end
  
  layout_content_xml

  pdf.cell( { :content => layout_xml.inspect } )

  send_data(pdf.render, :filename => "#{filename}.pdf",
    :type => "application/pdf", :disposition => "attachment")
end