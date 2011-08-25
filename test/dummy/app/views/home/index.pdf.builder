xml.instruct!
xml.pdf do
  xml.page :orientation => "landscape" do
    xml.div :x => 0, :y => 100 do
    	xml.cell  :name => "table_head", 
    	          :x => 105, :y => 395, 
    	          :width => 600, :height => 25
    	xml.image :path => '/Users/dev/Documents/dev/gems/pdf-renderer/test/dummy/assets/logo.png',
    	          :x => 0, :y => 0,
    	          :width => 100, :height => 100
    end
  end
  xml.page do
    xml.div :x => 100, :y => 200 do
    	xml.cell  "4 - FICHE DETAILLEE DES OBSTACLE & PRINCIPES D\'AMÉLIORATION*#{@test_content}", 
    	          :name => "cell_a", 
    	          :x => 0, :y => 350, 
    	          :width => 25, :height => 400,
    	          :options => '{ :borders => [:left, :right] }'
    	xml.text  "Hello World",
    	          :x => 4, :y => 10,
    	          :options => '{ :size => 15 }'
    end
  end  
end