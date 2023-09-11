return {
  ['q4i'] = function(args, kwargs, meta)
	-- examples of args
	-- local arg1 = "https://imgur.com/c1iuv5g.png"
	-- local arg1 = "c1iuv5g"
	-- local caption = "issu de Imgur" -- arg2

	-- WITHOUT.QMD
	-- no caption (if a line is just afetr)
	-- ![issu de Imgur](https://imgur.com/c1iuv5g.png)
	-- après l'image

	-- the image is displayed in the same order as markdown but NO CAPTION
	-- .
	-- ![issu de Imgur](https://imgur.com/c1iuv5g.png)	

	-- EXAMPLE.QMD		
    -- the image is displayed in the same order as markdown but no caption :(
	-- .{{< q4i 'https://imgur.com/c1iuv5g.png' 'issu de Imgur' >}}
  
    -- caption visible BUT the image is displayed somewhere
	-- .
	-- {{< q4i 'https://imgur.com/c1iuv5g.png' 'issu de Imgur' >}}

	
    -- KO - alternative 1 : return markdown
	    -- workaround 1 - KO: change order of treatment: shortcode, then quarto -- KO (maybe available only for filter)
    -- OK - alternative 2 : return AST object identical to the one produced by ![]() -- KO ?! the image is not in a Figure
	    -- BUG : even if the AST is identical, the TEX produced is different ?!
		-- BUG RESOLVED: return a Figure (in place of directly returning the Image)
    -- AB - ABANDONNED - alternative 3  : produce the final output, format by format
	    -- choose filter instead of shortcode ?

	-- BUG : caption does not appear in PDF !!! (where as native is identical between without.qmd and example.qmd ???!!!
	-- https://stackoverflow.com/questions/45030895/how-to-add-an-image-with-alt-tag-but-without-caption-in-pandoc
	-- Pandoc treats an image that is the only content of a paragraph as a figure and prints the alt text as a caption. You can append an escaped linebreak to suppress this behaviour:
	-- ![This is the caption](/url/of/image.png) \
	-- These 2 instructions does not render the same AST ?!
	-- pandoc without.qmd -t native ==> image embedded in a Figure
	-- quarto render --to native without.qmd ==> image embedded in a Para

		
	local caption = "Imgur" -- arg2
	
	local short_path = "c1iuv5g.png"
	local name_only = "c1iuv5g"
	

	local full_path = "https://imgur.com/" .. name_only .. ".png"
	local result = full_path

	local attr = ""	
	
-- AST produced by pandoc without.qmd -t native
-- Figure                                                             
  -- ( "" , [] , [] )                                                 
  -- (Caption                                                         
     -- Nothing                                                       
     -- [ Plain                                                       
         -- [ Str "issu" , Space , Str "de" , Space , Str "Imgur" ]   
     -- ])                                                            
  -- [ Plain                                                          
      -- [ Image                                                      
          -- ( "" , [] , [] )                                         
          -- [ Str "issu" , Space , Str "de" , Space , Str "Imgur" ]  
          -- ( "https://imgur.com/c1iuv5g.png" , "" )                 
      -- ]                                                            
  -- ]                                                                
	
	-- https://pandoc.org/lua-filters.html#pandoc.image
	-- Image (caption, src[, title[, attr]])
	-- Creates a Image inline element
	local img_attr = {}	
	local the_title = "the title"
    objimg = pandoc.Image( caption, 'https://imgur.com/c1iuv5g.png' , the_title, img_attr )	
	
	
	-- https://pandoc.org/lua-filters.html#pandoc.figure
	-- Figure (content[, caption[, attr]])
	-- Creates a Figure element (Block element)
	-- content: figure block content
	-- caption: figure caption
	-- attr: element attributes
	
	-- Code example: https://github.com/pandoc/lua-filters/blob/master/diagram-generator/diagram-generator.lua: 
	--  local img_obj = pandoc.Image(alt, fname, "", img_attr)
	--  return pandoc.Figure(pandoc.Plain{img_obj}, caption, fig_attr)
	local fig_attr = {}
	-- caption = "Figure: " .. caption -- NO IN PDF => Figure 1:Figure:  Imgur
	obj = pandoc.Figure ( pandoc.Plain { objimg } , pandoc.Inlines { caption } )
	
	-- quarto.log.output( obj )	

	
	-- obj MUST BE Inline, list of Inlines, or string expected
	-- if obj is a figure => compile fails
	-- => convert obj from Figure to Blocks
	objconv = pandoc.Blocks( {obj} )	
	return ( objconv )
  end
}


