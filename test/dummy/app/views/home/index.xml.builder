xml.instruct!
xml.pdf do
  xml.pages :orientation => "landscape" do
    xml.part :x => 0, :y => 100 do
    	xml.item :name => "table_head", :x => 105, :y => 395, :width => 600, :height => 25, :type => 'cell'
    	xml.item '4 - FICHE DETAILLEE DES OBSTACLE & PRINCIPES D\'AMÉLIORATION*', :options => '{ :borders => [:left, :right] }', :name => "cell_a", :x => 0, :y => 350, :width => 25, :height => 400, :type => 'cell'
    end
  end
end