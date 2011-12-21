#---
# Excerpted from "Crafting Rails Applications",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material, 
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose. 
# Visit http://www.pragmaticprogrammer.com/titles/jvrails for more book information.
#---
require "action_controller"
#Mime::Type.register "application/pdf", :pdf

require "prawn"
require 'nokogiri'
require 'uri'
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
    size ="A4"
    
    if !page_xml_element.attributes["size"].nil?
      if page_xml_element.attributes["size"].value.index('[').nil?
        size = page_xml_element.attributes["size"].value.to_s
      else
        size = eval(page_xml_element.attributes["size"].value.to_s)
      end      
    else      
    end

    if first_page_flag
      first_page_flag = false
      pdf = Prawn::Document.new :page_size => size, :page_layout => orientation
    else
      pdf.start_new_page :layout => orientation
    end
    
    page_xml_element.children.each do |div_xml_element|
      div_x_offset = div_xml_element.attributes["x"].nil? ? 0 : div_xml_element.attributes["x"].value.to_i
      div_y_offset = div_xml_element.attributes["y"].nil? ? 0 : div_xml_element.attributes["y"].value.to_i

      div_xml_element.children.each do |item_xml_element|

        if item_xml_element.attributes["visible"].nil?
          visible = true
        else
          visible = item_xml_element.attributes["visible"].value == "true"
        end

        if visible
          case item_xml_element.name
          when 'cell'
            options = Hash.new
            options[:content] = item_xml_element.content
            options[:width] = item_xml_element.attributes["width"].nil? ? 100 : item_xml_element.attributes["width"].value.to_i
            options[:height] = item_xml_element.attributes["height"].nil? ? 100 : item_xml_element.attributes["height"].value.to_i
            options[:x] = div_x_offset + ( item_xml_element.attributes["x"].nil? ? 0 : item_xml_element.attributes["x"].value.to_i )
            options[:y] = div_y_offset + ( item_xml_element.attributes["y"].nil? ? 0 : item_xml_element.attributes["y"].value.to_i )

            if !item_xml_element.attributes["options"].nil?
              options.merge!(eval(item_xml_element.attributes["options"].value))
            end          

            pdf.cell(options)
          when 'text'          
            options = item_xml_element.attributes["options"].nil? ? Hash.new : eval(item_xml_element.attributes["options"].value)

            x = div_x_offset + ( item_xml_element.attributes["x"].nil? ? 0 : item_xml_element.attributes["x"].value.to_i )
            y = div_y_offset + ( item_xml_element.attributes["y"].nil? ? 0 : item_xml_element.attributes["y"].value.to_i )

            options[:at] = [ x, y ]

            pdf.text_box( item_xml_element.content, options )
          when 'image'

            options = item_xml_element.attributes["options"].nil? ? Hash.new : eval(item_xml_element.attributes["options"].value)

            x = div_x_offset + ( item_xml_element.attributes["x"].nil? ? 0 : item_xml_element.attributes["x"].value.to_i )
            y = div_y_offset + ( item_xml_element.attributes["y"].nil? ? 0 : item_xml_element.attributes["y"].value.to_i )
            width = item_xml_element.attributes["width"].nil? ? 100 : item_xml_element.attributes["width"].value.to_i
            height = item_xml_element.attributes["height"].nil? ? 100 : item_xml_element.attributes["height"].value.to_i

            options[:at] = [ x, y ]
            options[:width] = width
            options[:height] = height
           
            path = item_xml_element.attributes["path"]
            if !item_xml_element.attributes["path"].nil?
              if path.to_s.scan('http://').count == 1 then
                pdf.image(open(item_xml_element.attributes["path"].value),options)
              else
                pdf.image(item_xml_element.attributes["path"].value,options)
              end
            end

            #pdf.image(item_xml_element.attributes["path"].value,options) if !item_xml_element.attributes["path"].nil?

          when 'line'
            xA = div_x_offset + ( item_xml_element.attributes["xA"].nil? ? 0 : item_xml_element.attributes["xA"].value.to_i )
            yA = div_y_offset + ( item_xml_element.attributes["yA"].nil? ? 0 : item_xml_element.attributes["yA"].value.to_i )
            xB = div_x_offset + ( item_xml_element.attributes["xB"].nil? ? 0 : item_xml_element.attributes["xB"].value.to_i )
            yB = div_y_offset + ( item_xml_element.attributes["yB"].nil? ? 0 : item_xml_element.attributes["yB"].value.to_i )

            pdf.stroke do
              pdf.line([xA,yA],[xB,yB]) 
            end
                   
          end
        end
      end
    end
  end

  send_data(pdf.render, :filename => "#{filename}.pdf",
    :type => "application/pdf", :disposition => "attachment")
end