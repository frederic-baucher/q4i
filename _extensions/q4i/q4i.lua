return {
  ['q4i'] = function(args, kwargs, meta)
	-- positional args
	-- arg1 = raw_path = "https://imgur.com/c1iuv5g.png" / arg1 = "c1iuv5g" / arg1 = "c1iuv5g.png"
	-- arg2 = caption = "issu de Imgur" -- arg2
	-- named arguments
	-- licence-type = licence-type='Creative Commons Attribution 4.0 International license'
	-- licence-url = licence-url='https://www.peppercarrot.com/en/license'
    -- attribution = attribution='Copyright © David Revoy 2023' 

	-- By Wolfgang Moroder- Own work, CC BY-SA 3.0, https://commons.wikimedia.org/w/index.php?curid=132387237
	-- licence-type = licence-type='Own work, CC BY-SA 3.0'
	-- licence-url = licence-url='https://commons.wikimedia.org/w/index.php?curid=132387237'
    -- attribution = attribution='By Wolfgang Moroder'
    -- attribution-url = https://commons.wikimedia.org/wiki/User:Moroder
	
	-- Photo de <a href="https://unsplash.com/fr/@markusspiske?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Markus Spiske</a> sur <a href="https://unsplash.com/fr/photos/iar-afB0QQw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
	-- licence-type = licence-type='Own work, CC BY-SA 3.0'
	-- licence-url = licence-url='https://commons.wikimedia.org/w/index.php?curid=132387237'
    -- attribution = 
    -- attribution-url = 
	-- host-url = https://unsplash.com/fr/photos/iar-afB0QQw?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText
	-- original-source = host-url
	-- host-id = unsplash, wikipedia, (jamais imgur)
	-- hostname = if no id => name
	-- author-url = https://unsplash.com/fr/@markusspiske?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText
    -- author-name = 'Markus Spiske'
	
	
	
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

	-- ### get the named args ###
	-- host the original image (sometimes imgur is the TECHNICAL host of an image hosted by Wikipedia)
	local original_host_id = ''
	local original_source_url = pandoc.utils.stringify(kwargs["original-source-url"])
	local source = pandoc.utils.stringify(kwargs["source"])
	local attribution = pandoc.utils.stringify(kwargs["attribution"])
	local licence_url = pandoc.utils.stringify(kwargs["licence-url"])
	local licence_type = pandoc.utils.stringify(kwargs["licence-type"])	

	local raw_path = ''
	if ( #args > 0 ) then
		raw_path = args[1]
	else
		error("q4i: No path to the image")
	end
	quarto.log.output ( "q4i: begin - raw_path = " .. raw_path )	

	local path_type = ''
	local filename = ''
	i, j = string.find ( raw_path, '/' )
	if ( i ) then
		path_type = 'full'	
		i, j = string.find ( raw_path, 'http://' )
		if ( i == 1 ) then
			path_type = 'internet'
		end
		i, j = string.find ( raw_path, 'https://' )
		if ( i == 1 ) then
			path_type = 'internet'
		end
	else
		path_type = 'filename'
		filename = raw_path
	end
	quarto.log.output ( "q4i: begin - path_type = " .. path_type )	

	
    -- file extension
	file_extension = ''
	i, j = string.find ( raw_path, '.png' )
	if ( i ) then file_extension = '.png' end
	i, j = string.find ( raw_path, '.jpg' )	
	if ( i ) then file_extension = '.jpg' end
	i, j = string.find ( raw_path, '.jpeg' )		
	if ( i ) then file_extension = '.jpeg' end	
	
	
	
	if ( path_type == 'filename' ) or ( path_type == 'full' ) then
		if ( #file_extension > 0 ) then
			quarto.log.output ( "q4i: filename with extension = " .. filename  )				
		else
			filename = raw_path .. ".png"
		end
	else
		if ( #file_extension > 0 ) then
			quarto.log.output ( "q4i: filename with extension = " .. filename  )				
		else
			msg='file extension compulsory in http or https.'
			quarto.log.error ( "q4i: error " .. msg )	
			error ( { code=105 } )
		end
	end
	
	quarto.log.output ( "q4i: filename with extension = " .. filename  )	
	
	
	
	
	local full_path = ''
	local technical_host_id = ''

	local procedure = 'imgur'

	local author = ''	
	if ( #args > 2 ) then
		procedure = args[3]
	end

	-- get procedure from filename
	i = string.find(raw_path, "unsplash")
	if i == nil then
		quarto.log.output ( "q4i: no unsplash in raw_path = " .. raw_path )	
	else
		procedure = 'unsplash'
	end
	
	-- parse args in case of unsplash
	if ( procedure == 'unsplash' ) then
		if ( #args > 3 ) then
			author = args[4]
		else
			-- syntaxe of filename
			-- name1[-name2]-photoid-unsplash.ext: photoid is supposed to be 11 characters long
			-- ahmed-8WoLNcom210-unsplash.jpg: name in one part			
			-- topsphere-media-utMdPdGDc8M-unsplash.jpg: name in two parts
			-- username: topsphere-media / user id: @zvessels55
			-- Photo de <a href="https://unsplash.com/fr/@zvessels55?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">TopSphere Media</a> sur <a href="https://unsplash.com/fr/photos/utMdPdGDc8M?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>
  
			i = string.find(raw_path, "/")
			if  path_type == 'filename' then
				quarto.log.output ( "q4i: no slash in raw_path = " .. raw_path )	
			else
				-- raise error: no path in unsplash img path that should be a filename !
				msg='unsplash: first arg should be a filename not a path.'
				quarto.log.error ( "q4i: error " .. msg )	
				error ( { code=110 } )
			end  
			
			-- Credit sentence
			-- en: Photo by Jeremy Bishop on Unsplash
			-- fr: Photo de Jeremy Bishop sur Unsplash
			-- https://unsplash.com/license: Utilisations commerciales et non commerciales / Aucune autorisation additionnelle nécessaire (’l'attribution d’un crédit sera appréciée !)
			local t = {}                   -- table to store the indices
			local i = 0
			local j = 0
			while true do
			  i = string.find(raw_path, "-", i+1)    -- find 'next' newline
			  if i == nil then 
				part = string.sub ( raw_path, j, #raw_path )
				table.insert(t, part)
				quarto.log.output ( "q4i: part = " .. part )	
				break
			end
			  part = string.sub ( raw_path, j, i-1 )
			  j = i+1
			  quarto.log.output ( "q4i: part = " .. part )	
			  table.insert(t, part)
			end
			local l = #t -- table.getn(t) deprecated
			quarto.log.output ( "q4i: number of part in filename = " .. l )
			full_path = "assets/img/unsplash/" .. filename
			-- author = 'test'
			if (l == 4) then
				t1 = t[1]
				t2 = t[2]
				-- author = t[1] .. ' ' .. t[2]
				t1 = t1:sub(1,1):upper()..t1:sub(2) -- first capitalized
				t2 = t2:sub(1,1):upper()..t2:sub(2) -- first capitalized
				author = t1 .. ' ' .. t2
			elseif (l == 3) then
				author = t[1]
			else
				-- raise error
				msg = 'badly structured unsplash filename.'
				quarto.log.error ( "q4i: error " .. msg )
				error ( { code=107 } )
			end
			-- author = 'test'
		end
		attribution = 'Photo by ' .. author .. ' on Unsplash'
		quarto.log.output ( "q4i: unsplash - attribution = " .. attribution )				
	end

	
	if ( procedure == 'imgur' ) then
		if ( path_type == 'filename' ) then
			full_path = "assets/img/imgur/" .. filename
		else
			-- may be http, https or full
			full_path = raw_path
		end
	end
	
	-- check if author is compulsory
	if false then
		-- raise error, author is compulsory
	end
	
	
	
	-- ###########################  MANAGE THE CAPTION - BEGIN  ###########################  
	
	local label = ''
	if ( #args > 1 ) then
		label = args[2]
	end
	
	-- local short_path = "c1iuv5g.png"
	-- local name_only = "c1iuv5g"
	-- local full_path = "https://imgur.com/" .. name_only .. ".png"			

	local result = full_path

	local attr = ""	

	if ( #original_source_url == 0 ) then
		quarto.log.output ( "q4i: begin - source = " .. source )				
		original_source_url = source
	else
		quarto.log.output ( "q4i: begin - #original_source_url = " .. #original_source_url )				

	end

	i, j = string.find ( original_source_url, 'unsplash' )
	if ( i ) then 
		original_host_id = 'unsplash'
		quarto.log.output ( "q4i: begin - host_id = " .. host_id )				
	end

	i, j = string.find ( original_source_url, 'wikimedia' )
	if ( i ) then 
		original_host_id = 'wikimedia'
		quarto.log.output ( "q4i: begin - host_id = " .. host_id )		
	end

	local caption = label
	
	if ( #attribution > 0 ) then
		if ( #caption > 0 ) then
			caption = caption .. '. ' .. attribution .. '.'
		else
			caption = attribution
		end
	end
	
	if ( #licence_url > 0) then
		if ( #licence_type > 0) then
			-- caption = caption .. '<A HREF="' .. licence_url .. '">' .. licence_type .. '</A>'
			caption = caption .. ' - ' .. licence_type .. ' (' .. licence_url .. ')'
		else
			caption = caption .. ' ' .. licence_type
		end
	else
		caption = caption .. ' ' .. licence_type
	end

	if ( #original_source_url > 0) then
		if ( #caption == 0 ) then
			caption = 'source: ' .. original_source_url
		else	
			caption = caption .. ' [source: ' .. original_source_url .. ']'
		end
	end
	
	
	-- si hosted locally or technical_host_id is imgur => original_source_url compulsory

	
	
	if ( ( technical_host_id == 'imgur' ) or ( technical_host_id == 'local' ) ) then
		quarto.log.output ( "q4i: begin - check caption = " .. caption )		
		if ( #caption == 0 ) then
			error ( 'q4i - source arg compulsory if imgur or local' )		
		end
	else
		quarto.log.output ( "q4i: begin - check original_source_url - technical_host_id = " .. technical_host_id )		
	end
		
	
	local licence_url = pandoc.utils.stringify(kwargs["licence-url"])
	if ( licence_url ) then 
		quarto.log.output ( "q4i: begin - licence_url = " .. licence_url )
	else
		quarto.log.output ( "q4i: begin - no licence_url" )
	end

	local attribution = pandoc.utils.stringify(kwargs["attribution"])
	if ( attribution ) then 
		quarto.log.output ( "q4i: begin - attribution = " .. attribution )
	else
		quarto.log.output ( "q4i: begin - no attribution" )
	end

	local licence_type = pandoc.utils.stringify(kwargs["licence-type"])
	if ( licence_type ) then 
		quarto.log.output ( "q4i: begin - licence_type = " .. licence_type )
	else
		quarto.log.output ( "q4i: begin - no licence_type" )
	end

	
	-- TO DO : manage the caption with label and all named arguments (attribution, licence_type, ...)
	
	-- ###########################  MANAGE THE CAPTION - END  ###########################  

	
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
	
    objimg = pandoc.Image( caption, full_path , the_title, img_attr )	
	
	
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


