--[[
 Toliss A21N mapping for the Yawman Arrow By Ryan Mikulovsky, CC0 1.0.
 
 Initial commit: 2024-12-22
 
 Inspired by Yawman's mapping for the MSFS PMDG 777.
 Thanks for Thomas Nield for suggesting looking into Lua for better controller support in XP12. Button numbers and their variable names came from Thomas.
 
 See Thomas' video and access example Lua scripts at https://www.youtube.com/watch?v=x8SMg33RRQ4
 
 Repository at https://github.com/rpmik/Lua-Yawman-Control-Toliss-A321x
]]
-- use local to prevent other unknown Lua scripts from overwriting variables (or vice versa)

local scriptedAircraft = "A21N"

local dref_lnav = "AirbusFBW/PullHDGSel"
local dref_vnav = "AirbusFBW/PullAltitude"
local dref_APPR = "AirbusFBW/APPRbutton"
local dref_LOC = "AirbusFBW/LOCbutton"

local dref_APAltHold = "AirbusFBW/PushAltitude"
local dref_APHdgHold = "AirbusFBW/PushHDGSel"
local dref_APVSHold = "AirbusFBW/PushVSSel"
local dref_APSPDHold = "AirbusFBW/PushSPDSel"
local dref_APSPD = "AirbusFBW/PullSPDSel"

local dref_AP1Button = "toliss_airbus/ap1_push"
local dref_AP1Disconnect = "toliss_airbus/ap_disc_left_stick"

local dref_APAlt = "AirbusFBW/PushButtonAltitude"
local dref_APAirSpeedUp = "sim/autopilot/airspeed_up"
local dref_APAirSpeedDown = "sim/autopilot/airspeed_down"

local dref_FlightDirector1 = "toliss_airbus/fd1_push"

local dref_APAdjust = {
	AltUp = "sim/autopilot/altitude_up",
	AltDown = "sim/autopilot/altitude_down",
	HdgUp = "sim/autopilot/heading_up",
	HdgDown = "sim/autopilot/heading_down",
	VSUp = "sim/autopilot/vertical_speed_up",
	VSDown = "sim/autopilot/vertical_speed_down",
	Baro1Up = "sim/instruments/barometer_up",
	Baro1Down = "sim/instruments/barometer_down",
	Baro1Std = "sim/instruments/barometer_std",
	Baro1Push = "toliss_airbus/capt_baro_push",
	Baro1Pull = "toliss_airbus/capt_baro_pull"
}

local dref_AutoThrottle = "AirbusFBW/ATHRbutton"

-- Planes can have different # of landing lights
local dref_LandingLightSwitches_Up = {
	"toliss_airbus/lightcommands/LLandLightUp",
	"toliss_airbus/lightcommands/RLandLightUp"
}

-- Planes can have different # of landing lights
local dref_LandingLightSwitches_Down = {
	"toliss_airbus/lightcommands/LLandLightDown",
	"toliss_airbus/lightcommands/RLandLightDown"
}

local dref_FlightControls = {
	pitchTrimUp = "sim/flight_controls/pitch_trim_up",
	pitchTrimDown = "sim/flight_controls/pitch_trim_down",
	brakesRegular = "sim/flight_controls/brakes_regular",
	brakesMax = "sim/flight_controls/brakes_toggle_max",
	flapsUp = "sim/flight_controls/flaps_up",
	flapsDown = "sim/flight_controls/flaps_down"
}

local dref_LRStandard = {
	flashLightRed = "sim/view/flashlight_red",
	glanceLeft = "sim/view/glance_left",
	glanceRight = "sim/view/glance_right",
	defaultView = "sim/view/default_view",
	chaseView = "sim/view/chase"
}


-- Clean up the code with this
local NoCommand = "sim/none/none"

local STICK_X = 0 
local STICK_Y = 1
local POLE_RIGHT = 2 
local POLE_LEFT = 3
local RUDDER = 4
local SLIDER_LEFT = 5
local SLIDER_RIGHT = 6 
local POV_UP = 0
local POV_RIGHT = 2
local POV_DOWN = 4
local POV_LEFT = 6
local THUMBSTICK_CLK = 8
local SIXPACK_1 = 9
local SIXPACK_2 = 10
local SIXPACK_3 = 11
local SIXPACK_4 = 12
local SIXPACK_5 = 13
local SIXPACK_6 = 14
local POV_CENTER = 15
local RIGHT_BUMPER = 16
local DPAD_CENTER = 17
local LEFT_BUMPER = 18
local WHEEL_DOWN = 19
local WHEEL_UP = 20
local DPAD_UP = 21
local DPAD_LEFT = 22
local DPAD_DOWN = 23
local DPAD_RIGHT = 24

-- Logic states to keep button assignments sane
local STILL_PRESSED = false -- track presses for everything
local MULTI_SIXPACK_PRESSED = false -- track presses for only the six pack where there's multiple six pack buttons involved
local DPAD_PRESSED = false
local BUMPERS_PRESSED = false

local CHASE_VIEW = false

local FRAME_COUNT = 0.0
local GoFasterFrameRate = 0.0
local PauseIncrementFrameCount = 0.0
local FrameRate = 0.0
local CurFrame = 0.0


function multipressTolissA21N_buttons() 
    -- if aircraft is an A21N then procede
    if PLANE_ICAO == scriptedAircraft then 
        FRAME_COUNT = FRAME_COUNT + 1.0  
		-- Base Config buttons that should almost always get reassigned except during a press
        if not STILL_PRESSED then -- avoid overwriting assignments during other activity
        	set_button_assignment(THUMBSTICK_CLK,dref_FlightControls.brakesRegular)
			set_button_assignment(DPAD_UP,NoCommand)
			set_button_assignment(DPAD_DOWN,NoCommand)
			set_button_assignment(DPAD_LEFT,"sim/general/zoom_out_fast")
			set_button_assignment(DPAD_RIGHT,"sim/general/zoom_in_fast")
			set_button_assignment(DPAD_CENTER,NoCommand)
			set_button_assignment(WHEEL_UP, NoCommand)
			set_button_assignment(WHEEL_DOWN, NoCommand)
			set_button_assignment(LEFT_BUMPER, NoCommand) -- multifunction
			set_button_assignment(RIGHT_BUMPER, NoCommand) -- multifunction
			set_button_assignment(SIXPACK_1,NoCommand)
			set_button_assignment(SIXPACK_2,NoCommand)
			set_button_assignment(SIXPACK_3,NoCommand)		
			set_button_assignment(SIXPACK_4,NoCommand)
			set_button_assignment(SIXPACK_5,NoCommand)
			set_button_assignment(SIXPACK_6,NoCommand)			
			set_button_assignment(POV_UP, dref_FlightControls.pitchTrimUp)
			set_button_assignment(POV_DOWN, dref_FlightControls.pitchTrimDown)
			set_button_assignment(POV_LEFT, dref_LRStandard.glanceLeft)
			set_button_assignment(POV_RIGHT, dref_LRStandard.glanceRight)
			set_button_assignment(POV_CENTER, NoCommand)
			--set_button_assignment(THUMBSTICK_CLK,"sim/flight_controls/brakes_toggle_regular")

        end 
        
        -- Get button status every frame
    
        right_bumper_pressed = button(RIGHT_BUMPER)
        left_bumper_pressed = button(LEFT_BUMPER)
        
        sp1_pressed = button(SIXPACK_1)
        sp2_pressed = button(SIXPACK_2)
        sp3_pressed = button(SIXPACK_3)
		sp4_pressed = button(SIXPACK_4)
		sp5_pressed = button(SIXPACK_5)
		sp6_pressed = button(SIXPACK_6)
		
		pov_up_pressed = button(POV_UP)
		pov_down_pressed = button(POV_DOWN)
		
		dpad_up_pressed = button(DPAD_UP)
		dpad_center_pressed = button(DPAD_CENTER)
		dpad_down_pressed = button(DPAD_DOWN)
		dpad_left_pressed = button(DPAD_LEFT)
		dpad_right_pressed = button(DPAD_RIGHT)
		
		wheel_up_pressed = button(WHEEL_UP)
		wheel_down_pressed = button(WHEEL_DOWN)
		
-- Start expanded control logic

		if dpad_center_pressed and not sp6_pressed and not DPAD_PRESSED then
			if not CHASE_VIEW then
				command_once(dref_LRStandard.chaseView)
				CHASE_VIEW = true
				DPAD_PRESSED = true
			elseif CHASE_VIEW then
				command_once(dref_LRStandard.defaultView)
				CHASE_VIEW = false
				DPAD_PRESSED = true
			end
		end
	
-- Auto pilot engage A 
		
		if right_bumper_pressed and not dpad_up_pressed and not last_button(RIGHT_BUMPER) then
			command_once(dref_AP1Button)

		end
		
-- autopilot control
	
		if sp1_pressed and last_button(SIXPACK_1) then
			set_button_assignment(RIGHT_BUMPER,dref_AutoThrottle)
			set_button_assignment(DPAD_LEFT, dref_APSPDHold)
			set_button_assignment(DPAD_RIGHT, dref_APSPD)

			if dpad_up_pressed then
				meterA21NInteraction(DPAD_PRESSED,dref_APAirSpeedUp, dref_APAirSpeedUp, 1.0, 2.0) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			elseif dpad_down_pressed then
				meterA21NInteraction(DPAD_PRESSED,dref_APAirSpeedDown, dref_APAirSpeedDown,1.0,2.0)
				DPAD_PRESSED = true
			end
			

		-- Pause Simulation
			if sp2_pressed and sp3_pressed and not MULTI_SIXPACK_PRESSED then
				command_once("sim/operation/pause_toggle")
				MULTI_SIXPACK_PRESSED = true
			end
			
			--STILL_PRESSED = true
		end
		
		if sp2_pressed and last_button(SIXPACK_2) then
			set_button_assignment(RIGHT_BUMPER,dref_FlightDirector1)
			set_button_assignment(DPAD_RIGHT, dref_lnav)
			set_button_assignment(DPAD_LEFT,dref_LOC) -- built-in XP12 command
			set_button_assignment(DPAD_DOWN, dref_APPR)
			set_button_assignment(DPAD_UP, dref_vnav)

					
			-- Flash Light
			if sp5_pressed and not MULTI_SIXPACK_PRESSED then
				command_once(dref_LRStandard.flashLightRed)
				MULTI_SIXPACK_PRESSED = true
			end
			
		end

		if sp3_pressed and last_button(SIXPACK_3) then


			set_button_assignment(RIGHT_BUMPER, dref_APAlt)
			set_button_assignment(SIXPACK_6,"sim/lights/landing_lights_toggle")
			set_button_assignment(DPAD_LEFT, dref_APAltHold)
			set_button_assignment(DPAD_RIGHT, dref_vnav)

			
			if dpad_up_pressed then
				meterA21NInteraction(DPAD_PRESSED, dref_APAdjust.AltUp, dref_APAdjust.AltUp, 1.0, 2.0) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			elseif dpad_down_pressed then
				meterA21NInteraction(DPAD_PRESSED, dref_APAdjust.AltDown, dref_APAdjust.AltDown, 1.0, 2.0)
				DPAD_PRESSED = true
			end
			
			if sp6_pressed and not MULTI_SIXPACK_PRESSED then
				-- Toliss A320 specific datarefs
				DataRef("LandingLightStatus_Left","ckpt/oh/ladningLightLeft/anim","readonly")
				DataRef("LandingLightStatus_Right","ckpt/oh/ladningLightRight/anim","readonly")

				-- Toliss A320 specific if statement....
				if LandingLightStatus_Left == 2 and LandingLightStatus_Right == 2 then
					for i,lights in ipairs(dref_LandingLightSwitches_Down) do
						command_once(lights)

					end	

					MULTI_SIXPACK_PRESSED = true
				else
					for i,lights in ipairs(dref_LandingLightSwitches_Up) do
						command_once(lights)
						
					end	

					MULTI_SIXPACK_PRESSED = true
				end
								

				
				MULTI_SIXPACK_PRESSED = true
				

				
			end
			

			
		end
		
		if sp5_pressed and last_button(SIXPACK_5) then
			set_button_assignment(RIGHT_BUMPER,dref_APHdgHold)
			set_button_assignment(DPAD_LEFT, dref_APHdgHold)
			set_button_assignment(DPAD_RIGHT, dref_lnav)
			
			if dpad_up_pressed then
				meterA21NInteraction(DPAD_PRESSED,dref_APAdjust.HdgUp, dref_APAdjust.HdgUp, 1.0, 3.0) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			elseif dpad_down_pressed then
				meterA21NInteraction(DPAD_PRESSED, dref_APAdjust.HdgDown, dref_APAdjust.HdgDown, 1.0, 3.0)
				DPAD_PRESSED = true
			end

		end
		
		if sp6_pressed and last_button(SIXPACK_6) then
			set_button_assignment(DPAD_LEFT, dref_APAdjust.Baro1Down)
			set_button_assignment(DPAD_RIGHT, dref_APAdjust.Baro1Up)
			set_button_assignment(RIGHT_BUMPER, dref_APVSHold)
			--set_button_assignment(DPAD_CENTER, "AirbusFBW/BaroStdCapt")
			--set_button_assignment(DPAD_CENTER,"sim/autopilot/vertical_speed")

			DataRef("dref_BaroStdCap", "AirbusFBW/BaroStdCapt","readonly")
			if dpad_up_pressed then
				meterA21NInteraction(DPAD_PRESSED, dref_APAdjust.VSUp, dref_APAdjust.VSUp, 1.0, 3.0) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			elseif dpad_down_pressed then
				meterA21NInteraction(DPAD_PRESSED, dref_APAdjust.VSDown, dref_APAdjust.VSDown, 1.0, 3.0)
				DPAD_PRESSED = true
			elseif dpad_center_pressed then
				if dref_BaroStdCap == 1 then
					meterA21NInteraction(DPAD_PRESSED, dref_APAdjust.Baro1Push, dref_APAdjust.Baro1Push, 1.0, 3.0)
				else
					meterA21NInteraction(DPAD_PRESSED, dref_APAdjust.Baro1Pull, dref_APAdjust.Baro1Pull, 1.0, 3.0)
				end
				DPAD_PRESSED = true
			end
			
		end

-- parking brake			
		if left_bumper_pressed and last_button(LEFT_BUMPER) then
			set_button_assignment(SIXPACK_2,NoCommand)
			set_button_assignment(SIXPACK_1,NoCommand)

			if wheel_up_pressed or wheel_down_pressed then
				meterA21NInteraction(BUMPERS_PRESSED, dref_FlightControls.brakesMax, dref_brakesMax, 2.0, 20) -- at around two seconds, use larger increment
				BUMPERS_PRESSED = true
			end
			
--[[
			if not STILL_PRESSED then
				set_button_assignment(WHEEL_UP,"sim/flight_controls/brakes_toggle_max")
				set_button_assignment(WHEEL_DOWN,"sim/flight_controls/brakes_toggle_max")
			end
]]
				-- Cockpit camera height not implemented as it deals with the rudder axes.....
			if sp4_pressed and not MULTI_SIXPACK_PRESSED then
				if dpad_up_pressed then
					-- EFB but this doesn't quite work. A21N.
					--set_pilots_head(-0.60079902410507,1.5304770469666,-11.694169998169,306.1875,-17.333335876465)
				else
					-- Glareshield A21N ++
					set_pilots_head(0.015134000219405,1.6833950281143,-18.188461303711,1.5000001192093,-15.652445793152)
				end
				MULTI_SIXPACK_PRESSED = true
			elseif sp2_pressed and not MULTI_SIXPACK_PRESSED then
				-- Nav, CDU, Transponder, etc A21N ++
				set_pilots_head(0.017556000500917,1.6317000389099,-18.379537582397,0.75000005960464,-66.166664123535)
				MULTI_SIXPACK_PRESSED = true
			elseif sp5_pressed and not MULTI_SIXPACK_PRESSED then
				-- FMS A21N ++
				set_pilots_head(-0.1292339861393,1.5839866399765,-18.600280761719,0.56248474121094,-57.240859985352)
				MULTI_SIXPACK_PRESSED = true
			elseif sp1_pressed and not MULTI_SIXPACK_PRESSED then
				-- Overhead panel A21N ++
				set_pilots_head(0.01483799982816,1.6124039888382,-18.155378341675,359.4375,73.000053405762)
				MULTI_SIXPACK_PRESSED = true
			elseif sp3_pressed and not MULTI_SIXPACK_PRESSED then
				-- A21N tablet/EFB ++
				set_pilots_head(-0.87882500886917,1.758808016777,-18.469541549683,296.05264282227,-55.333354949951)
				MULTI_SIXPACK_PRESSED = true
			elseif sp6_pressed and not MULTI_SIXPACK_PRESSED then
				-- A21N pilot's view of throttles etc +
				set_pilots_head(-0.56307500600815,1.9947689771652,-18.069272994995,37.312484741211,-45.333343505859)
				MULTI_SIXPACK_PRESSED = true
			end
			
			--STILL_PRESSED = true
		end
				

-- DPAD_up mode
		if dpad_up_pressed and last_button(DPAD_UP) then

			set_button_assignment(RIGHT_BUMPER, dref_AutoThrottle) -- there's only a toggle (Will investigate later)
			--set_button_assignment(WHEEL_UP,"sim/flight_controls/flaps_down")
			--set_button_assignment(WHEEL_DOWN,"sim/flight_controls/flaps_up")
			set_button_assignment(POV_LEFT,"sim/view/glance_left")
			set_button_assignment(POV_RIGHT,"sim/view/glance_right")
			set_button_assignment(POV_UP,"sim/view/straight_up")
			set_button_assignment(POV_DOWN,"sim/view/straight_down")
	
			set_button_assignment(DPAD_LEFT,NoCommand)
			set_button_assignment(DPAD_RIGHT,NoCommand)

			if wheel_up_pressed then
				meterA21NInteraction(DPAD_PRESSED, dref_FlightControls.flapsDown, dref_FlightControls.flapsDown, 1.0, 10) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			elseif wheel_down_pressed then
				meterA21NInteraction(DPAD_PRESSED, dref_FlightControls.flapsUp, dref_FlightControls.flapsUp, 1.0, 10) -- at around two seconds, use larger increment
				DPAD_PRESSED = true
			end
			
			if dpad_left_pressed then
				-- Pilot's seat A21N
				--headX, headY, headZ, heading, pitch = get_pilots_head()
				--print(headX .. "," .. headY .. "," .. headZ .. "," .. heading .. "," .. pitch)
				set_pilots_head(-0.56307500600815,1.9947689771652,-18.069272994995,0.18748500943184,-13.833337783813)

			elseif dpad_right_pressed then
				-- Copilot's seat A21N
				set_pilots_head(0.48643887042999,1.9947689771652,-18.065872192383,0.18748500943184,-13.833337783813)

			end


		end
		
-- DPAD_down mode
		if dpad_down_pressed and last_button(DPAD_DOWN) then

			set_button_assignment(RIGHT_BUMPER, dref_AP1Disconnect)

		end

-- All buttons need to be released to end STILL_PRESSED phase
		if not sp1_pressed and not sp2_pressed and not sp3_pressed and not sp4_pressed and not sp5_pressed and not sp6_pressed and not right_bumper_pressed and not left_bumper_pressed and not dpad_center_pressed and not dpad_down_pressed and not dpad_left_pressed and not dpad_right_pressed then
			STILL_PRESSED = false
		end

		if not sp1_pressed and not sp2_pressed and not sp3_pressed and not sp4_pressed and not sp5_pressed and not sp6_pressed then
			MULTI_SIXPACK_PRESSED = false
		end 
		
		if not dpad_up_pressed and not dpad_left_pressed and not dpad_right_pressed and not dpad_down_pressed and not dpad_center_pressed then
			DPAD_PRESSED = false
		end
		
		if not left_bumper_pressed and not right_bumper_pressed then
			BUMPERS_PRESSED = false
		end
		
    end 
end

-- If aircraft's interactive Command increment is not continuous or continuous and too fast, use framerate to meter incrementing
function meterA21NInteraction(boolButtonPressed, strCommandName1, strCommandName2, floatSeconds, floatIntervalSpeed)
		-- floatIntervalSpeed -- generally, higher is slower. 
		
		-- Set metering based on current frame rate
		DataRef("FrameRatePeriod","sim/operation/misc/frame_rate_period","writable")
		CurFrame = FRAME_COUNT
		
		if not boolButtonPressed then
			FrameRate = 1/FrameRatePeriod
			-- Roughly calculate how many frames to wait before incrementing based on floatSeconds
			GoFasterFrameRate = (floatSeconds * FrameRate) + CurFrame -- start five seconds of slow increments
		end

		if CurFrame < GoFasterFrameRate then
			if not boolButtonPressed then
				command_once(strCommandName1)
				-- calculate frame to wait until continuing
				-- if floatSeconds is 2 then we'll wait around 1 second before continuing so as to allow a single standalone increment
				PauseIncrementFrameCount = ((floatSeconds/2) * FrameRate) + CurFrame
			else
				-- wait a beat with PauseIncrementFrameCount then continue
				if (CurFrame > PauseIncrementFrameCount) and (CurFrame % floatIntervalSpeed) == 0 then
					command_once(strCommandName1)
				end
			end
		elseif CurFrame >= GoFasterFrameRate and boolButtonPressed then
			-- If current frame is divisible by five then issue a command -- helps to delay the command in a regular interval
			if (CurFrame % floatIntervalSpeed) == 0 then
				command_once(strCommandName2)
			end
		end			
end


-- Don't mess with other configurations
if PLANE_ICAO == scriptedAircraft then 
	clear_all_button_assignments()
	
--	set_axis_assignment(POLE_LEFT, "reverse", "reverse")
--	set_axis_assignment(POLE_RIGHT, "speedbrakes", "normal") -- Toliss expects Normal
--set_axis_assignment(STICK_X, "roll", "normal" )
--set_axis_assignment(STICK_Y, "pitch", "normal" )

--set_axis_assignment(RUDDER, "yaw", "normal" )

	do_every_frame("multipressTolissA21N_buttons()")
end
