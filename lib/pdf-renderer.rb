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
  
  pdf = nil
  
  # Parse XML output
  layout_xml = Nokogiri::XML(render_to_string(options))
  
  layout_xml = Nokogiri::XML(render_to_string(options)) do |config|
    config.noent.noblanks           # NOBLANKS - Remove blank nodes / NOENT - Substitute entities
  end

  first_page_flag = true
  
  pdf_xml_element = layout_xml.children[0]
  pdf_xml_element.children.each do |page_xml_element|
    orientation = page_xml_element.attributes["orientation"].nil? ? :portrait : page_xml_element.attributes["orientation"].value.to_sym

    if first_page_flag
      first_page_flag = false
      pdf = Prawn::Document.new :page_layout => orientation
    else
      pdf.start_new_page :layout => orientation
    end
    
    page_xml_element.children.each do |part_xml_element|
      part_x_offset = part_xml_element.attributes["x"].nil? ? 0 : part_xml_element.attributes["x"].value.to_i
      part_y_offset = part_xml_element.attributes["y"].nil? ? 0 : part_xml_element.attributes["y"].value.to_i
      
      part_xml_element.children.each do |item_xml_element|
        type = item_xml_element.attributes["type"].nil? ? "" : item_xml_element.attributes["type"].value

        case type
        when 'cell'
          options = Hash.new
          options[:content] = item_xml_element.content
          options[:width] = item_xml_element.attributes["width"].nil? ? 100 : item_xml_element.attributes["width"].value.to_i
          options[:height] = item_xml_element.attributes["height"].nil? ? 100 : item_xml_element.attributes["height"].value.to_i
          options[:x] = part_x_offset + ( item_xml_element.attributes["x"].nil? ? 0 : item_xml_element.attributes["x"].value.to_i )
          options[:y] = part_y_offset + ( item_xml_element.attributes["y"].nil? ? 0 : item_xml_element.attributes["y"].value.to_i )
          
          if !item_xml_element.attributes["options"].nil?
            options.merge!(eval(item_xml_element.attributes["options"].value))
          end          
          
          pdf.cell(options)
        when 'text'
          options = item_xml_element.attributes["options"].nil? ? nil : eval(item_xml_element.attributes["options"].value)
          pdf.text_box( item_xml_element.content, options )
        when 'image'
          options = item_xml_element.attributes["options"].nil? ? nil : eval(item_xml_element.attributes["options"].value)
          pdf.image(item_xml_element.attributes["path"].value,options) if !item_xml_element.attributes["path"].nil?
        end
      end
    end
  end

  send_data(pdf.render, :filename => "#{filename}.pdf",
    :type => "application/pdf", :disposition => "attachment")
end