--ra: Rasterized. I only ever use it for testing algorithms.

--All functions preceded by a _ (such as aa._line) are old functions, DO NOT use them. They don't work well.

aa = aa or {}

ra = ra or {}

--Plot a single PIXEL

function ra.point ( x , y ) 
	if ( x > 0 and x < 611 and y > 0 and y < 381 ) then
		tpt.create ( x , y , 'dmnd' )
	end
end

--Plot a single antialiased point (only one color available right now)

function aa.point ( x , y )

	for cx = math.floor ( x ) , math.ceil ( x ) do
		for cy = math.floor ( y ) , math.ceil ( y ) do

			local colx = 1 - math.abs ( x - cx )
			local coly = 1 - math.abs ( y - cy )
			local col = colx * coly

			ra.point ( cx , cy )

			local ccol = tonumber ( string.sub ( bit.tohex ( tpt.get_property ( 'dcolor' , cx , cy ) , 8 ) , 3 , 4 ) , 16 )

			local str = "0xFF" .. string.rep ( bit.tohex ( ( ccol + col * 255 <= 255 and ccol + col * 255 or 255 ) , 2 ) , 3 )

			tpt.set_property ( "dcolor" , str , cx , cy )

		end
	end

end

--Draw a line (OLD)

function aa._line ( firstx , firsty , secondx , secondy )
	if firstx > secondx then
		firstx , secondx = secondx , firstx
	end
	if firsty > secondy then
		firsty , secondy = secondy , firsty
	end
	y = firsty

	local s = 1

	for x = firstx , secondx , s do
		aa.point ( x , y )
		y = y + ( secondy - firsty ) / ( secondx - firstx ) * s
	end

	x = firstx

	for y = firsty , secondy , s do
		aa.point ( x , y )
		x = x + ( secondx - firstx ) / ( secondy - firsty ) * s
	end
end

--Draw a line

function aa.line ( x1 , y1 , x2 , y2 )

	if ( x1 > x2 or y1 > y2 ) and not ( x1 > x2 and y1 > y2 ) then

		x1 , x2 = x2 , x1

		y1 , y2 = y2 , y1

	end

	local d = math.sqrt ( ( x2 - x1 ) ^ 2 + ( y2 - y1 ) ^ 2 )

	for k = 0 , d do

		local x , y = x1 + k * ( ( x2 - x1 ) / d ) , y1 + k * ( ( y2 - y1 ) / d )

		aa.point ( x , y )

	end

end

--I used this for testing out my line function.

function aa.star ( n , r )

	for k = 0 , 360 , n do

		aa.line ( 300 , 200 , 300 + math.sin ( math.rad ( k ) ) * r , 200 + math.cos ( math.rad ( k ) ) * r )

	end

end

--Draws an ellipse (acc is the number of points it uses to draw it, gap is...well, hard to explain. It's best set to 0.1 or so)

function aa.ellipse ( x , y , w , h , acc , gap )
	acc = acc or 5
	gap = gap or 0.25
	local n = 0
	while n <= 360 do
		aa.line ( 	x + math.sin( math.rad ( n ) ) * w / 2 , y + math.cos ( math.rad ( n ) ) * h / 2 ,
					x + math.sin ( math.rad ( n + acc ) ) * w / 2 , y + math.cos ( math.rad ( n + acc ) ) * h / 2 )
		n = n + acc + gap
	end
end

--Draw a bezier curve (x1, y1, x2, y2, cx1, cy1, cx2, cy2)

function aa.bezier ( x1 , y1 , x4 , y4 , x2 , y2 , x3 , y3 )

	local cx , cy

	local s , b = 0.01 , 0.0005

	for t = 0 , 1 , s + b do

		local cx = ( 1 - t ) ^ 3 * x1 + 3 * ( 1 - t ) ^ 2 * t * x2 + 3 * ( 1 - t ) * t ^ 2 * x3 + t ^ 3 * x4

		local cy = ( 1 - t ) ^ 3 * y1 + 3 * ( 1 - t ) ^ 2 * t * y2 + 3 * ( 1 - t ) * t ^ 2 * y3 + t ^ 3 * y4

		local x = ( 1 - ( t + s ) ) ^ 3 * x1 + 3 * ( 1 - ( t + s ) ) ^ 2 * ( t + s ) * x2 + 3 * ( 1 - ( t + s ) ) * ( t + s ) ^ 2 * x3 + ( t + s ) ^ 3 * x4

		local y = ( 1 - ( t + s ) ) ^ 3 * y1 + 3 * ( 1 - ( t + s ) ) ^ 2 * ( t + s ) * y2 + 3 * ( 1 - ( t + s ) ) * ( t + s ) ^ 2 * y3 + ( t + s ) ^ 3 * y4

		aa.line ( cx , cy , x , y )

		cx , cy = x , y

	end

end

--Draw a randomly placed bezier curve (I used this for testing my bezier curve function)

function aa.bezrandom ( )

	local m = {}
	for k = 1 , 8 do

		if math.floor ( k / 2 ) == k / 2 then

			m [ k ] = math.random ( 1 , 380 )

		else

			m [ k ] = math.random ( 1 , 610 )

		end

	end

	aa.bezier ( m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8] )

end

--Draw a rasterized bezier curve

function ra.bezier ( x1 , y1 , x4 , y4 , x2 , y2 , x3 , y3 )

	for t = 0 , 1 , 0.01 do

		local x = (1 - t) ^ 3 * x1 + 3 * (1 - t ) ^ 2 * t * x2 + 3 * (1 - t ) * t ^ 2 * x3 + t ^ 3 * x4

		local y = (1 - t) ^ 3 * y1 + 3 * (1 - t ) ^ 2 * t * y2 + 3 * (1 - t ) * t ^ 2 * y3 + t ^ 3 * y4

		tpt.create ( x , y , 'dmnd' )

	end

end
