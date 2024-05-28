-- example of logging to a file on the SD card and to data flash
local file_name = "GNSS_DATA.csv"
local file

-- index for the data and table
local gps_lat = 1
local gps_lon = 2
local gps_spd = 3
--local gps_course = 3
local interesting_data = {}


local function write_to_file()

  if not file then
    error("Could not open file")
  end

  -- write data
  -- separate with comas and add a carriage return
  file:write(tostring(millis()) .. ", " .. table.concat(interesting_data,", ") .. "\n")

  -- make sure file is upto date
  file:flush()

end

local function write_to_dataflash()

  -- care must be taken when selecting a name, must be less than four characters and not clash with an existing log type
  -- format characters specify the type of variable to be logged, see AP_Logger/README.md
  -- https://github.com/ArduPilot/ardupilot/tree/master/libraries/AP_Logger
  -- not all format types are supported by scripting only: i, L, e, f, n, M, B, I, E, and N
  -- lua automatically adds a timestamp in micro seconds
  logger:write('SCR1','gps_lat,gps_lon,gps_spd','fff',interesting_data[gps_lat],interesting_data[gps_lon],interesting_data[gps_spd])

  -- it is also possible to give units and multipliers
  logger:write('SCR2','gps_lat,gps_lon,gps_spd','fff','ddd','---',interesting_data[gps_lat],interesting_data[gps_lon],interesting_data[gps_spd])

end

function update()
  local gps_position = ahrs:get_position() --gps:location(1)
  local latitude = gps_position:lat()
  local longitude = gps_position:lng()

  if gps_position then
    gcs:send_text(0, string.format("Home - Lat:%.1f Long:%.1f ", gps_position:lat(), gps_position:lng()))
  end


  interesting_data[gps_lat] = gps_position:lat()
  interesting_data[gps_lon] = gps_position:lng()
  interesting_data[gps_spd] = gps:ground_speed(1)
  --gps:ground_course(1)
  

  write_to_file()
  write_to_dataflash()


  -- Reschedule the function to run again after 1000 milliseconds (1 second)
  return update, 1000
end


-- make a file
-- note that this appends to the same the file each time, you will end up with a very big file
-- you may want to make a new file each time using a unique name
file = io.open(file_name, "a")
if not file then
  error("Could not make file")
end

-- write the CSV header
file:write('Time Stamp(ms), gps_lat,gps_course,gps_spd\n')
file:flush()

return update, 10000
