
require 'cairo'
sx = 180       -- X coordinate of the Soyombo
sy = 25        -- Y coordinate of the Soyombo
s_table = {
	{	-- Big circle of the Sun
		name = "time",                  -- Type of status to display.
		args = "%M.%S",			-- Argument to the status.
		bg_color = 0xffffff,            -- Background color.
		bg_alpha = 0.2,			-- Background alpha.
		fg_color = 0xffffff,		-- Foreground color.
		fg_alpha = 0.5,			-- Foreground alpha.
		max = 60			-- Maximum value.
	},
	{	-- Inner circle of the Sun
		name = "time",
		args = "%I.%M",
		bg_color = 0xffffff,
		bg_alpha = 0.0,
		fg_color = 0xffffff,
		fg_alpha = 0.7,
		max = 12
	},
	{	-- Ying Yang
		name = "time",
		args = "%S",
		max = 60
	},
	{	-- Left bar 1
		name = "cpu",
		args = "cpu0",
		bg_color = 0xffffff,
		bg_alpha = 0.2,
		fg_color = 0xffffff,
		fg_alpha = 0.5,
		max = 100,
		x = 1				-- NOTE: Don't edit
	},
	{	-- Left bar 2
		name = "cpu",
		args = "cpu1",
		bg_color = 0xffffff,
		bg_alpha = 0.2,
		fg_color = 0xffffff,
		fg_alpha = 0.5,
		max = 100,
		x = 17				-- NOTE: Don't edit

	},
	{	-- Right bar 1
		name = "cpu",
		args = "cpu2",
		bg_color = 0xffffff,
		bg_alpha = 0.2,
		fg_color = 0xffffff,
		fg_alpha = 0.5,
		max = 100,
		x = 114				-- NOTE: Don't edit

	},
	{	-- Right bar 2
		name = "cpu",
		args = "cpu3",
		bg_color = 0xffffff,
		bg_alpha = 0.2,
		fg_color = 0xffffff,
		fg_alpha = 0.5,
		max = 100,
		x = 130				-- NOTE: Don't edit
	},
	{	-- Upper triangle
		name = "battery_percent",
		args = "BAT0",
		bg_color = 0xffffff,
		bg_alpha = 0.2,
		fg_color = 0xffffff,
		fg_alpha = 0.5,
		max = 100,
	},
	{	-- Lower triangle
		name = "acpitemp",
		args = "",
		bg_color = 0xffffff,
		bg_alpha = 0.2,
		fg_color = 0xffffff,
		fg_alpha = 0.5,
		max = 100
	},
	{	-- Upper horizontal bar
		name = "swapperc",
		args = "",
		bg_color = 0xffffff,
		bg_alpha = 0.2,
		fg_color = 0xffffff,
		fg_alpha = 0.5,
		max = 100
	},
	{	-- Lower horizontal bar
		name = "memperc",
		args = "",
		bg_color = 0xffffff,
		bg_alpha = 0.2,
		fg_color = 0xffffff,
		fg_alpha = 0.5,
		max = 100
	},
}

function rgb_to_r_g_b(colour,alpha)
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function draw_triangle(cr, x, y, w, h, color, alpha)
	cairo_move_to(cr, x, y)
	cairo_line_to(cr, x - (w / 2), y - h)
	cairo_line_to(cr, x + (w / 2), y - h)
	cairo_close_path(cr)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(color, alpha))
	cairo_fill(cr)
end

function draw_line(cr, x, y, w, h, color, alpha)
	cairo_move_to(cr, x, y)
	cairo_line_to(cr, x, y - h)
	cairo_line_to(cr, x + w, y - h)
	cairo_line_to(cr, x + w, y)
	cairo_close_path(cr)
	cairo_set_source_rgba(cr, rgb_to_r_g_b(color, alpha))
	cairo_fill(cr)	
end

function load_image(cr, filename, x, y)
	local temp = cairo_image_surface_create_from_png(filename)
	cairo_set_source_surface(cr, temp, x, y)
	cairo_paint(cr)
	cairo_surface_destroy(temp)
end

function draw_rotated_image(cr, x, y, angle)
   local temp = cairo_image_surface_create_from_png("Soyombo/img1.png")
   local w = cairo_image_surface_get_width(temp)
   local h = cairo_image_surface_get_height(temp)
   local temp2 = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, h, w)
   local cr2 = cairo_create(temp2)
   cairo_translate(cr2, h * 0.5, w * 0.5)
   cairo_rotate(cr2, angle)
   cairo_translate(cr2, -w * 0.5, -h * 0.5)
   cairo_set_source_surface(cr2, temp, 0, 0)
   cairo_set_operator(cr2, CAIRO_OPERATOR_SOURCE)
   cairo_paint(cr2)
   cairo_set_source_surface(cr, temp2, x, y)
   cairo_paint(cr)
   cairo_surface_destroy(temp)
   cairo_surface_destroy(temp2)
   cairo_destroy(cr2)
end

function get_value(i)
	local value = tonumber( conky_parse( string.format('${%s %s}', s_table[i]["name"], s_table[i]["args"]) ) )
	if value == nil then
		return 0
	else
		return value
	end
end

function set_src_rgba(cr, i, bg)
	if bg == 1 then 
		cairo_set_source_rgba(cr, rgb_to_r_g_b(s_table[i]["bg_color"], s_table[i]["bg_alpha"]))
	else
		cairo_set_source_rgba(cr, rgb_to_r_g_b(s_table[i]["fg_color"], s_table[i]["fg_alpha"]))
	end
end

function conky_Soyombo_stats()

   if conky_window == nil then return end
   local cs = cairo_xlib_surface_create(
      conky_window.display, 
      conky_window.drawable,
      conky_window.visual, 
      conky_window.width,
      conky_window.height)
   
   local cr = cairo_create(cs)	
	
   local updates = conky_parse('${updates}')
   update_num = tonumber(updates)
   
   if update_num > 5 then
      local pct = 0
      local i = 0
      load_image(cr, "Soyombo/img4.png", sx - 180, sy + 80) -- Mongolian map
      load_image(cr, "Soyombo/img5.png", sx + 37, sy + 97) -- Moon
		
      -- The big circle of the Sun.
      pct = get_value(1) / s_table[1]["max"]
      cairo_set_line_width(cr, 30)
      local angle_start = - math.pi / 2
      local angle_finish = 3 * math.pi / 2
      local t_arc = pct * (angle_finish - angle_start)
      cairo_arc(cr, sx + 74, sy + 87, 11, angle_start, angle_finish)
      set_src_rgba(cr, 1, 1)
      cairo_stroke(cr)
      cairo_arc(cr, sx + 74, sy + 87, 11, angle_start, angle_start + t_arc)
      set_src_rgba(cr, 1, 0)
      cairo_stroke(cr)
		
      -- Inner circle of the Sun
      pct = get_value(2) / s_table[2]["max"]
      cairo_set_line_width(cr, 20)
      angle_start = - math.pi / 2
      angle_finish = 3 * math.pi /2
      t_arc = pct * (angle_finish - angle_start)
      cairo_arc(cr, sx + 74, sy + 87, 10, angle_start, angle_finish)
      set_src_rgba(cr, 2, 1)
      cairo_stroke(cr)
      cairo_arc(cr, sx + 74, sy + 87, 10, angle_start, angle_start + t_arc)
      set_src_rgba(cr, 2, 0)
      cairo_stroke(cr)
      
      -- Ying Yang
      i = get_value(3)
      pct = i * 360 / s_table[3]["max"]
      -- Rotate the image.
      draw_rotated_image(cr, sx + 40, sy + 185, pct * math.pi / 180)

      -- Draw the fire
      if i % 2 == 0 then
	 load_image(cr, "Soyombo/img3.png", sx + 57, sy)
      else
	 load_image(cr, "Soyombo/img2.png", sx + 57, sy)
      end
      
      -- Vertical Bars
      for i = 4, 7 do 
	 pct = get_value(i) * 159 / 100
	 draw_line(cr, sx + s_table[i]["x"], sy + 300, 16, 159, s_table[i]["bg_color"], s_table[i]["bg_alpha"])
	 draw_line(cr, sx + s_table[i]["x"], sy + 300, 16, pct, s_table[i]["fg_color"], s_table[i]["fg_alpha"])
      end
      -- Triangles.
      -- Upper triangle
      i = get_value(8)
      pct = i * 20 / s_table[8]["max"]
      i = i * 64 / s_table[8]["max"]
      draw_triangle(cr, sx + 75, sy + 300, 64, 20, s_table[8]["bg_color"], s_table[8]["bg_alpha"])
      draw_triangle(cr, sx + 75, sy + 300, i, pct, s_table[8]["fg_color"], s_table[8]["fg_alpha"])
      -- Lower triangle
      i = get_value(9)
      pct = i * 20 / s_table[9]["max"]
      i = i * 64 / s_table[9]["max"]
      draw_triangle(cr, sx + 75, sy + 160, 64, 20, s_table[9]["bg_color"], s_table[9]["bg_alpha"])
      draw_triangle(cr, sx + 75, sy + 160, i, pct, s_table[9]["fg_color"], s_table[9]["fg_alpha"])
		
      -- Horizontal bars.
      -- Upper bar.
      pct = get_value(10) * 67 / s_table[10]["max"]
      draw_line(cr, sx + 40, sy + 180, 67, 14, s_table[10]["bg_color"], s_table[10]["bg_alpha"])
      draw_line(cr, sx + 40, sy + 180, pct, 14, s_table[10]["bg_color"], s_table[10]["bg_alpha"])
      -- Lower bar.
      pct = get_value(11) * 67 / s_table[11]["max"]
      draw_line(cr, sx + 40, sy + 273, 67, 14, s_table[11]["bg_color"], s_table[11]["bg_alpha"])	
      draw_line(cr, sx + 40, sy + 273, pct, 14, s_table[11]["bg_color"], s_table[11]["bg_alpha"])	
      cairo_stroke(cr)
      
   end

   cairo_destroy(cr)
   cairo_surface_destroy(cs)
end
