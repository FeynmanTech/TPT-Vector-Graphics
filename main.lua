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

function aa.point ( x , y , r , g , b )

	r , g , b = r or 255 , g or 255 , b or 255

    for cx = math.floor ( x ) , math.ceil ( x ) do
            for cy = math.floor ( y ) , math.ceil ( y ) do

                local colx = 1 - math.abs ( x - cx )
                local coly = 1 - math.abs ( y - cy )
                local col = colx * coly

				if cx > 0 and cx <= 610 and cy > 0 and cy <= 380 and col > 0 then

					ra.point ( cx , cy )

					local cr = tonumber ( string.sub ( bit.tohex ( tpt.get_property ( 'dcolor' , cx , cy ) , 8 ) , 3 , 4 ) , 16 )
					local cg = tonumber ( string.sub ( bit.tohex ( tpt.get_property ( 'dcolor' , cx , cy ) , 8 ) , 5 , 6 ) , 16 )
					local cb = tonumber ( string.sub ( bit.tohex ( tpt.get_property ( 'dcolor' , cx , cy ) , 8 ) , 7 , 8 ) , 16 )
					local str = "0xFF" ..
						bit.tohex ( ( cr + col * r <= 255 and cr + col * r or 255 ) , 2 ) ..
						bit.tohex ( ( cg + col * g <= 255 and cg + col * g or 255 ) , 2 ) ..
						bit.tohex ( ( cb + col * b <= 255 and cb + col * b or 255 ) , 2 )

					tpt.set_property ( "dcolor" , str , cx , cy )
				end

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

function aa.line ( x1 , y1 , x2 , y2 , r , g , b )

        if ( x1 > x2 or y1 > y2 ) and not ( x1 > x2 and y1 > y2 ) then

                x1 , x2 = x2 , x1

                y1 , y2 = y2 , y1

        end

        local d = math.sqrt ( ( x2 - x1 ) ^ 2 + ( y2 - y1 ) ^ 2 )

        for k = 0 , d do

                local x , y = x1 + k * ( ( x2 - x1 ) / d ) , y1 + k * ( ( y2 - y1 ) / d )

                aa.point ( x , y , r , g , b )

        end

end

--I used this for testing out my line function.

function aa.star ( n , r , y )

	local cr , cg , cb

	for k = 0 , 360 , n do

		if y == 1 then

			cr = math.abs ( math.sin ( math.rad ( k ) ) * 255 )
			cg = math.abs ( math.sin ( math.rad ( ( k + 120 ) / 2 ) ) * 255 )
			cb = math.abs ( math.sin ( math.rad ( ( k + 240 ) / 2 ) ) * 255 )

		else

			cr , cg , cb = 255 , 255 , 255

		end

		print ( cr , cg , cb )

		aa.line ( 300 , 200 , 300 + math.sin ( math.rad ( k ) ) * r , 200 + math.cos ( math.rad ( k ) ) * r , cr , cg , cb )

    end

end

--Draws an ellipse (acc is the number of points it uses to draw it)

function aa.ellipse ( x , y , w , h , r , g , b )
        acc = acc or 5
        local n = 0
        while n <= 360 do -- I have no damn clue how the gap algorithm works, but I bet the website I got it from does.

				local opt1 , opt2 = 4 / ( w + h ) , math.sqrt ( 1 / ( ( w * math.cos ( math.rad ( n ) ) ) ^ 2 + ( h * math.sin ( math.rad ( n ) ) ) ^ 2 ) )

				local gap = ( opt1 < opt2 and opt1 or opt2 ) * 100

				aa.point ( x + math.sin ( math.rad ( n ) ) * w / 2 , y + math.cos ( math.rad ( n ) ) * h / 2 , r , g , b )

				n = n + gap

        end
end

--Draw a bezier curve (x1, y1, x2, y2, cx1, cy1, cx2, cy2)

function aa.bezier ( x1 , y1 , x4 , y4 , x2 , y2 , x3 , y3 , rc , gc , bc )

        local cx , cy , x , y

        local s , b = 0.01 , 0.0005

        for t = 0 , 1 , s + b do

			if x and y and cx and xy then

				local d = math.sqrt ( ( x - cx ) ^ 2 + ( y - cy ) ^ 2 )

				local s = d

			else

				s = 0.01

			end

			local cx = ( 1 - t ) ^ 3 * x1 + 3 * ( 1 - t ) ^ 2 * t * x2 + 3 * ( 1 - t ) * t ^ 2 * x3 + t ^ 3 * x4

            local cy = ( 1 - t ) ^ 3 * y1 + 3 * ( 1 - t ) ^ 2 * t * y2 + 3 * ( 1 - t ) * t ^ 2 * y3 + t ^ 3 * y4

            x = ( 1 - ( t + s ) ) ^ 3 * x1 + 3 * ( 1 - ( t + s ) ) ^ 2 * ( t + s ) * x2 + 3 * ( 1 - ( t + s ) ) * ( t + s ) ^ 2 * x3 + ( t + s ) ^ 3 * x4

            y = ( 1 - ( t + s ) ) ^ 3 * y1 + 3 * ( 1 - ( t + s ) ) ^ 2 * ( t + s ) * y2 + 3 * ( 1 - ( t + s ) ) * ( t + s ) ^ 2 * y3 + ( t + s ) ^ 3 * y4

            aa.line ( cx , cy , x , y , rc , gc , bc )

            cx , cy = x , y

        end

end

--Draw a randomly placed bezier curve (I used this for testing my bezier curve function)

function aa.bezrandom ( num , n )

	local m = {}

	for _ = 1 , num do

        for k = 1 , 8 do

                if math.floor ( k / 2 ) == k / 2 then

                        m [ k ] = math.random ( 1 , 380 )

                else

                        m [ k ] = math.random ( 1 , 610 )

                end

        end

		if n == 1 then

			r , g , b = 255 , 255 , 255

		else

			r , g , b = math.random ( 0 , 255 ) , math.random ( 0 , 255 ) , math.random ( 0 , 255 )

		end

        aa.bezier ( m[1], m[2], m[3], m[4], m[5], m[6], m[7], m[8] , r , g , b )

	end

end

--Draw a rasterized bezier curve

function ra.bezier ( x1 , y1 , x4 , y4 , x2 , y2 , x3 , y3 )

        for t = 0 , 1 , 0.01 do

                local x = (1 - t) ^ 3 * x1 + 3 * (1 - t ) ^ 2 * t * x2 + 3 * (1 - t ) * t ^ 2 * x3 + t ^ 3 * x4

                local y = (1 - t) ^ 3 * y1 + 3 * (1 - t ) ^ 2 * t * y2 + 3 * (1 - t ) * t ^ 2 * y3 + t ^ 3 * y4

                tpt.create ( x , y , 'dmnd' )

        end

end
