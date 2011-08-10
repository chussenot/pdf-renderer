xml.instruct!
xml.pdf do
  xml.page :orientation => "landscape" do
    xml.part :x => 0, :y => 100 do
    	xml.item  :type => 'cell',
    	          :name => "table_head", 
    	          :x => 105, :y => 395, 
    	          :width => 600, :height => 25
    	xml.item  :path => '/Users/dev/Documents/dev/gems/pdf-renderer/test/dummy/assets/logo.png',
    	          :type => 'image', 
    	          :options => '{ :at => [205,210], :width => 180 }'  	          
    end
  end
  xml.page do
    xml.part do
    	xml.item  "4 - FICHE DETAILLEE DES OBSTACLE & PRINCIPES D\'AMÉLIORATION*#{@test_content}", 
    	          :type => 'cell',    	          
    	          :name => "cell_a", 
    	          :x => 0, :y => 350, 
    	          :width => 25, :height => 400,
    	          :options => '{ :borders => [:left, :right] }'
    	xml.item  "Hello World",
    	          :type => 'text',
    	          :options => '{ :at => [4,260], :size => 15 }'
    end
  end  
end