return {
  ['q4i'] = function(args, kwargs, meta)

    -- alternative 1 - KO: return markdown
	    -- workaround 1 - KO: change order of treatment: shortcode, then quarto -- KO (maybe available only for filter)
    -- alternative 2 - OK : return AST object identical to the one produced by ![]() -- KO ?! the image is not in a Figure
	    -- BUG : even if the AST is identical, the TEX produced is different ?!
		-- BUG RESOLVED: return a Figure (in place of directly returning the Image)
    -- alternative 3 - ABANDONNED : produce the final output, format by format
	    -- choose filter instead of shortcode ?
 
	
	-- local arg1 = "https://imgur.com/c1iuv5g.png"
	-- local arg1 = "c1iuv5g"
	
	-- local caption = "issu de Imgur" -- arg2
	local caption = "Imgur" -- arg2
	
	
	local short_path = "c1iuv5g.png"
	local name_only = "c1iuv5g"
	

	local full_path = "https://imgur.com/" .. name_only .. ".png"
	local result = full_path

    -- result = "![](https://imgur.com/c1iuv5g.png)") -- KO
	-- result = "![]('https://imgur.com/c1iuv5g.png')" -- KO	
    result = '![]("https://imgur.com/c1iuv5g.png")' -- KO
    -- result = '![](https://imgur.com/c1iuv5g.png)' -- KO
	
	-- obj = pandoc.Str(result)


	local attr = ""	
	
	
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

  -- https://docs.juliahub.com/Pandoc/r82N1/0.4.2/api/#Pandoc.Figure





    -- obj = pandoc.Figure ( pandoc.Caption ( caption), pandoc.Plain ( pandoc.Image( caption, 'https://imgur.com/c1iuv5g.png' ) ) ) -- compile error
    -- obj = pandoc.Figure ( pandoc.Plain ( pandoc.Image( caption, 'https://imgur.com/c1iuv5g.png' ) ) ) -- compile error
	-- obj = pandoc.Figure ( pandoc.Image( caption, 'https://imgur.com/c1iuv5g.png' ) ) -- compile error
	
	-- cap = pandoc.Caption ( pandoc.ShortCaption ( pandoc.Str ('a caption') ) )
	-- cap = pandoc.Caption ( pandoc.Str ('a short caption') , pandoc.Str ('a long caption') )
	-- cap = pandoc.Caption ( 'a short caption' , 'a long caption' )
	-- cap = pandoc.Caption ( )
	
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
	
	-- obj = pandoc.Figure ( objimg, caption ) -- ERROR table expected, got string
	-- obj = pandoc.Figure ( objimg ) -- Inline, list of Inlines, or string expected, got table
	-- obj = pandoc.Figure ( objimg , Str ( caption ) ) -- attempt to call a nil value (global 'Str')
	-- obj = pandoc.Figure ( objimg , pandoc.Str ( caption ) ) -- table expected, got Inline
	-- obj = pandoc.Figure ( pandoc.Inline ( objimg ) ) -- attempt to call a table value (field 'Inline')
	-- https://github.com/pandoc/lua-filters/blob/master/diagram-generator/diagram-generator.lua: 
	--  local img_obj = pandoc.Image(alt, fname, "", img_attr)
	--  return pandoc.Figure(pandoc.Plain{img_obj}, caption, fig_attr)
	-- obj = pandoc.Figure ( pandoc.Plain ( objimg ) ) -- compile OK mais KO après
	-- obj = pandoc.Figure ( pandoc.Plain ( objimg ) , caption ) -- KO
	local fig_attr = {}
	-- obj = pandoc.Figure ( pandoc.Plain { objimg }, caption, fig_attr ) -- KO table expected, got string
	-- obj = pandoc.Figure ( pandoc.Plain { objimg } ) -- OK
	-- obj = pandoc.Figure ( pandoc.Plain { objimg } , pandoc.Caption {} ) --  attempt to call a nil value (field 'Caption')
	obj = pandoc.Figure ( pandoc.Plain { objimg } , pandoc.Inlines { caption } )
	
	quarto.log.output( obj )	
	
	
	
	
	
	
	
	
	
	
	-- obj = pandoc.Image ( {'""', [], []} [] { "https://imgur.com/c1iuv5g.png" } ) -- KO
	-- pandoc.Image({}, 'foo.png', 'no title', attr)

	-- pandoc.RawBlock('tex', "\\begin{figure}")
	-- pandoc.RawBlock('tex', "\includegraphics{without_files/mediabag/c1iuv5g.png}")
	-- pandoc.RawBlock('tex', "\\end{figure}")

    -- most simple
	-- obj = pandoc.Image( caption, 'https://imgur.com/c1iuv5g.png' ) -- no caption
	-- obj = pandoc.Para ( pandoc.Image( caption, 'https://imgur.com/c1iuv5g.png' ) ) -- no caption
	-- obj = pandoc.Para ( pandoc.Image( caption, 'https://imgur.com/c1iuv5g.png', 'another caption' ) ) -- no caption	
	
    -- with attr	
    -- obj = pandoc.Image({}, 'foo.png', 'no title', attr)
	-- obj = pandoc.Para ( pandoc.Image( caption, 'https://imgur.com/c1iuv5g.png', 'another caption', {("caption","A caption."),("title","The title"),("width","60%")} ) ) -- compile ERROR
	-- obj = pandoc.Para ( pandoc.Image( caption, 'https://imgur.com/c1iuv5g.png', 'another caption', [("caption","A caption."),("title","The title"),("width","60%")] ) ) -- compile ERROR
	
	
	-- obj = pandoc.Para ( Image( pandoc.Str(caption), 'https://imgur.com/c1iuv5g.png' ) ) -- pandoc.Para not correct
	-- obj = pandoc.Para{ pandoc.Image({pandoc.Str(caption)}, 'https://imgur.com/c1iuv5g.png'), pandoc.Str ("A") }-- ne retourne pas à la ligne

	-- obj = pandoc.Image({pandoc.Str('local_caption')}, 'https://imgur.com/c1iuv5g.png') -- no caption
	-- obj = pandoc.Image( pandoc.Str(caption), 'https://imgur.com/c1iuv5g.png', '', attr) -- no caption
	-- obj = pandoc.Para( pandoc.Image({pandoc.Str(caption)}, 'https://imgur.com/c1iuv5g.png' )) -- no caption
	-- obj = pandoc.Image( caption, 'https://imgur.com/c1iuv5g.png', '', attr) -- no caption
	-- obj = pandoc.Image( caption, 'https://imgur.com/c1iuv5g.png', '', 'caption or not ?', 'caption or not in attr ?') -- no caption
	-- obj = pandoc.Image( {}, 'https://imgur.com/c1iuv5g.png', 'title or not ?', 'caption or not ?') -- no caption	??
	
	
	
	-- BUG : caption does not appear in PDF !!! (where as native is identical between without.qmd and example.qmd ???!!!
	-- https://stackoverflow.com/questions/45030895/how-to-add-an-image-with-alt-tag-but-without-caption-in-pandoc
	-- Pandoc treats an image that is the only content of a paragraph as a figure and prints the alt text as a caption. You can append an escaped linebreak to suppress this behaviour:
	-- ![This is the caption](/url/of/image.png) \
	-- These 2 instructions does not render the same AST ?!
	-- pandoc without.qmd -t native ==> image embedded in a Figure
	-- quarto render --to native without.qmd ==> image embedded in a Para
	

    -- obj = pandoc.Image( caption, 'https://imgur.com/c1iuv5g.png' )	
	-- return pandoc.Inline ( obj ) -- attempt to call a table value (field 'Inline')
	-- return ( obj ) -- si obj est une Figure => error Inline, list of Inlines, or string expected, got table
	-- return ( obj ) -- si obj est une Image  => OK
	
	-- from 

	
	-- obj MUST BE Inline, list of Inlines, or string expected
	-- if obj is a figure => compile fails
	-- => convert obj from Figure to Blocks
	objconv = pandoc.Blocks( {obj} )	
	return ( objconv )
  end
}


