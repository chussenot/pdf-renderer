xml.instruct!
xml.pdf do
  xml.page :orientation => "landscape" do
    xml.part do
      xml.item :comment => @test_content
    end
  end
  
end