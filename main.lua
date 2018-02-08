-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
-- Smash Dots v2.0
-- Made by: Mehdi | Maham 
-- BESE-3

-- using the ads library
local ads = require("ads")
local androidAppID = "ca-app-pub-2780063832979747/6113475311"
local iosAppID = "ca-app-pub-2780063832979747/3020408116"
local adProvider = "admob"
local appId = ""

if ( system.getInfo( "platformName" ) == "Android" ) then
    appId = androidAppID
elseif ( system.getInfo( "platformName" ) == "iOS" ) then
	appId = iosAppID
end

local score = 0
local timesPlayed = 0
local discsPassed = 0
local createDiscWithDelay = nil
local pixelFont = native.newFont("PixelSplitter-Bold.ttf");

local loseText = nil
local playAgainText = nil

-- setting the score text
local scoreText = display.newText({text="0", font=pixelFont, fontSize=90})
scoreText.alpha = 0
scoreText.x = display.contentWidth/2
scoreText.y = 80

-- loading game sounds
local popSound = audio.loadSound("pop.wav")
local pop2Sound = audio.loadSound("pop2.wav")
local gameoverStream = audio.loadStream("deephit.wav")
local menuSound = audio.loadSound("menuselect.wav")
local gamestartSound = audio.loadStream("gamestart.wav")

-- Callback function for ad initialization.
-- @param 	event 	the event returned by ads.init()
-- @return	nil
local function adListener( event )
	local msg = event.response
    -- Quick debug message regarding the response
    -- from the ad library
    print( "Message from the ads library: ", msg )
 
    if ( event.isError ) then
        print( "Error, no ad received", msg )		
    end
end

-- Function to destroy an item from screen.
-- @param 	target 	the item to destroy/remove
-- @return 	nil
local function destroyOnEvent( target )
	display.remove(target)
end

-- This function contains logic related to displaying ads
-- @param  timesPlayed 	the number of times the game has been started
-- @return  nil
local function checkShowAd( timesPlayed )
	-- if user has already played the game 5 times, show ad
	if( math.fmod( timesPlayed, 5 ) == 0 ) then
		-- show interstitial ad if it is loaded
		if ( ads.isLoaded( "interstitial" ) ) then
			ads.show( "interstitial" )
		end
	end
end

-- Function to change the background color of display.
-- @param 	color 	the background color to be set
-- @return  nil
local function changeBackgroundColor( color )
	-- default value assignment (if null)
	color = color or "yellow"

	-- modifying the display background color
	if( color == "yellow" ) then
		display.setDefault( "background", 0.96, 0.67, 0.20 )
	elseif ( color == "blue" ) then
		-- very light blue
		display.setDefault( "background", 0.172, 0.24, 0.313 ) 
	elseif ( color == "purple" ) then
		display.setDefault( "background", 0.40, 0.25, 0.56 ) 
	elseif ( color == "green" ) then
		display.setDefault( "background", 0.24, 0.76, 0.50 ) 
	elseif ( color == "red" ) then
		display.setDefault( "background", 0.85, 0.11, 0.09 ) 
	end
end

-- Function to change the color of an item on screen.
-- @param 	item 	the item whose color needs to be changed
-- @param 	score 	the current game score
-- @return  nil
local function changeItemColor( item, score )
	-- setting color on basis of score
	-- (color themes unlocked according to score)
	if( score >= 16) then
		-- set item's fill color to light blue
		item:setFillColor( 0.50, 0.811, 0.87 )
	elseif( score >= 26) then
		-- gray
		item:setFillColor( 0.85, 0.87, 0.88 )
	elseif( score >= 76) then
		-- orange
		item:setFillColor( 0.94, 0.47, 0.29 )
	elseif( score >= 101) then
		-- light blue
		item:setFillColor( 0.50, 0.81, 0.87 )
	end
end

-- Function to set background theme according to score.
-- @param 	score 	the current game score
-- @return  nil
local function setBgColorTheme( score )
	-- setting color on basis of score
	-- (color themes unlocked according to score)
	if( score >= 16 ) then
		changeBackgroundColor("blue")
	elseif ( score >= 26 ) then
		changeBackgroundColor("purple")
	elseif ( score >= 76 ) then
		changeBackgroundColor("green")
	elseif ( score >= 101 ) then
		changeBackgroundColor("red")
	end
end

-- Function to update the game score and game score text on screen.
-- @param 	val    the amount to increment score by
-- @return  nil
local function incrementScore( val )
	score = score + (val or 1)
	timer.performWithDelay(500, function() scoreText.text = tostring(score); end)
	local scale = 1.4
	transition.to(scoreText, {time=500, alpha=1.0, xScale=scale, yScale=scale, transition=easing.outQuad, delay=500})
	transition.to(scoreText, {time=200, alpha=0.6, xScale=1/scale, yScale=1/scale, transition=easing.inQuad, delay=1000})

	setBgColorTheme(score)
end

-- Function that contains logic for checking and
-- implementing 'perfect hit' functionality
-- @param  x  the circle tap event (disc pop event)
-- @retun  nil
local function checkPerfectHit( event )
    -- getting x, y coordinates of screen touch, converting to coordinates of circle
    local halfPoint = display.contentWidth/2

	-- if tapped in the middle of the screen, execute perfect hit (allows error of +- 10 pixels)
    if ( event.x >= halfPoint - 10) and (event.x <= halfPoint + 10) then
    	incrementScore( 5 )
    	local perfectText = display.newText({text="Perfect Hit!", x=display.contentWidth/2, font=pixelFont, fontSize=30})
    	transition.fadeOut(perfectText, {time=600, delay=1100})
    else
        incrementScore()
    end
end

-- Game start function.
-- 	> resets all the variables.
-- 	> cleans the display.
-- 	> starts the game loop.
local function resetGame()
	changeBackgroundColor( "yellow" )
	timesPlayed = timesPlayed + 1
	transition.to(scoreText, {time=500, y=80, xScale=1, yScale=1, alpha=0.6, transition=easing.inQuad})
	display.remove(loseText)	
	display.remove(playAgainText)
	score = 0
	scoreText.text = "0"
	discsPassed = 0
	createDiscWithDelay()
end

-- Function which handles game losing condition.
-- 	> stops game loop.
-- 	> displays score and game over text.
-- 	> displays option to play game again.
-- 	> handles showing of ad if the condition is met.
local function showYouLose()
	timer.performWithDelay(200, function() audio.play(gameoverStream); end)
	loseText = display.newText({text="Game Over!", font=pixelFont, fontSize=40, y=display.contentHeight/2, x=display.contentWidth/2})
	transition.from(loseText, {time=3000, y=-60, alpha=0, transition=easing.outElastic, delay=1000})
	transition.to(scoreText, {time=2000, y=display.contentHeight/2-90, xScale=1.2, yScale=1.2, alpha=1, transition=easing.outQuad})

	playAgainText = display.newText({text="Play Again", font=pixelFont, fontSize=20, y=display.contentHeight*0.9, x=display.contentWidth/2})
	transition.from(playAgainText, {time=1500, alpha=0, delay=2000})

	checkShowAd(timesPlayed)

	-- attach event listener to play again text
	-- this will restart the game if "Play Again" is pressed
	playAgainText:addEventListener("touch", function( event )
		if (event.phase == "began") then
			audio.play(menuSound)
			display.remove(loseText)	
			display.remove(playAgainText)
			timer.performWithDelay(800, function() 
				resetGame() 
			end)
			return true	
		end
	end)
end

-- Function to check game losing condition.
-- Triggered when the circle/discs complete animation.
-- @param  target	the disc/circle
-- @return nil
local function circleAnimationCompleteEvent( target )
	print(target)
	-- if disc has completed animation without being popped
	-- game has been lost
	if(target.y<0 or target.y>display.contentWidth) then
		print(target.y)
		showYouLose()
	end
	-- destroy disc which has completed its animation
	destroyOnEvent( target )
end

-- Function to create explosion animation for disc popping.
-- Achieved through simple particle creation, animation and destruction.
-- @param  x  the x coordinate for particle display
-- @param  y  the y coordinate for particle display
-- @retun  nil
local function createExplosion( x, y )
	local particles = {}
	for i=1,20 do
		particles[i] = display.newCircle(x, y, 5+math.random()*10)
		particles[i]:setFillColor(0.92, 0.92, 0.92)

		changeItemColor( particles[i], score )

		local r = (math.random()*60) + 120
		local distx = r * math.cos(math.pi*2/20*(i-1)+ math.random())
		local disty = r * math.sin(math.pi*2/20*(i-1)+ math.random())
		transition.to(particles[i], {time=400, x=distx, y=disty, transition=easing.outCubic, delta=true})
		transition.to(particles[i], {time=100+300*math.random(), x=scoreText.x, y=scoreText.y, alpha=0.2, transition=easing.inCubic, onComplete=destroyOnEvent, delay=400})
	end
end

-- Event handler for circle tap
-- @param  event  the circle tap event
-- @retun  nil
local function circleTappedEvent( event )
    if ( event.phase == "began" ) then
    	checkPerfectHit(event)
        transition.cancel(event.target)
        createExplosion(event.x, event.y)
        audio.play(pop2Sound)
        event.target:removeEventListener("touch", circleTappedEvent)
        transition.to(event.target, {time=400, xScale=1.4, yScale=1.4, alpha=0, transition=easing.outQuad, onComplete=destroyOnEvent})
        createDiscWithDelay()
    end
    return true  --prevents touch propagation to underlying objects
end

-- Function to create a new disc/circle.
local function createDiscRaw( x, y, d, xdist, ydist )
	local circ1 = display.newCircle(x, y, 30)
	circ1:setFillColor(0.92, 0.92, 0.92)
	circ1:addEventListener("touch", circleTappedEvent)

	-- change color of discs on score increase
	changeItemColor( circ1, score )	

	transition.to(circ1, {time=d, y=ydist, transition = easing.outQuad, delta=true})
	transition.to(circ1, {time=d, y=-ydist, transition = easing.inQuad, delta=true, delay=d})
	transition.to(circ1, {time=d*2, x=xdist, transition = easing.linear, delta=true, onComplete=circleAnimationCompleteEvent})
end

-- Function that sets circle's animation direction and animation speed
-- It calls the createDiscRaw() function with the parameters (x, y co-ordinates,
-- animation speed, and direction
local function createDisc( distance, speed )
	local difficultyStep = 15
	local difficulty = math.min(math.floor(discsPassed/difficultyStep), 3)
	local discType = math.random(0, difficulty)
	local d = 1000/speed
	local dist = display.contentHeight*0.80*distance + display.contentHeight*0.25
	if discType == 0 then
		-- Top left
		createDiscRaw(0, -60, d, display.contentWidth, dist)
	elseif discType == 1 then
		-- Top right
		createDiscRaw(display.contentWidth, -60, d, -display.contentWidth, dist)
	elseif discType == 2 then
		-- Bottom left
		createDiscRaw(0, display.contentHeight+60, d, display.contentWidth, -dist)
	elseif discType == 3 then
		-- Bottom right
		createDiscRaw(display.contentWidth, display.contentHeight+60, d, -display.contentWidth, -dist)
	end
	discsPassed = discsPassed + 1
end

-- Function that calculates the circle's animation speed and distance from next disc
local function discTimerFunction( event )
	local discDistance = 0.5+0.5*math.random()
	local discSpeed = (0.8+math.random()*1.3)/discDistance * 0.6
	createDisc(discDistance, discSpeed)
end

-- Game loop for creating discs
createDiscWithDelay = function()
	local thatTimer = timer.performWithDelay(300, discTimerFunction)
end

-- game start logic
-- default start screen color
changeBackgroundColor("yellow")

-- initialize ad library and load ad
ads.init( adProvider, appId, adListener )
ads.load( "interstitial" ) 

-- create & place text for start screen display
local startScreenGroup = display.newGroup()
local logo1Text = display.newText({text="Smash", font=pixelFont, fontSize=70, x=display.contentWidth/2, y=display.contentHeight/2-60, parent=startScreenGroup})
local logo2Text = display.newText({text="Dots", font=pixelFont, fontSize=70, x=display.contentWidth/2, y=display.contentHeight/2+20, parent=startScreenGroup})
local playNowText = display.newText({text="Play Now", font=pixelFont, fontSize=20, x=display.contentWidth/2, y=display.contentHeight*0.9, parent=startScreenGroup})
playNowText.alpha = 0
startScreenGroup.anchorX = 0.5
startScreenGroup.anchorY = 0.5

-- transitions for text appearance on start screen
transition.from(logo1Text, {time=1200, xScale=0.1, yScale=0.1, alpha=0.2, transition=easing.outBounce, delay=300})
transition.from(logo2Text, {time=1200, xScale=0.1, yScale=0.1, alpha=0.2, transition=easing.outBounce, delay=300})
transition.fadeIn(playNowText, {time=600, delay=1100})
transition.blink(playNowText, {time=3000, delay=1800})

timer.performWithDelay(600, function() audio.play(gamestartSound); end)

-- event listener for the "Play Now" text
-- starts the game
function playNowTappedEvent( event )
	if(event.phase == "began") then
		audio.play(menuSound)
		transition.fadeOut(startScreenGroup, {time=400, onComplete=function() resetGame(); end})
		playNowText:removeEventListener("touch", playNowTappedEvent)
		return true
	end
end

-- attaching event listener to "Play Now" text to start the game
playNowText:addEventListener("touch", playNowTappedEvent)

-- attaching a function to play "pop" sound on each touch event
Runtime:addEventListener("touch", function( event )
	if(event.phase == "began") then
		audio.play(popSound)
		return true
	end 
end)