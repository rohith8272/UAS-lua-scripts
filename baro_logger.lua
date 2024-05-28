-- example of logging to a file on the SD card and to data flash
local file_name = "BARO_DATA.csv"
local file

-- index for the data and table
local temp_e = 1
local temp = 2
local press = 3

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
  logger:write('SCR1','temp_ext,temp,press','fff',interesting_data[temp_e],interesting_data[temp],interesting_data[press])

  -- it is also possible to give units and multipliers
  logger:write('SCR2','temp_ext,temp,press','fff','ddd','---',interesting_data[temp_e],interesting_data[temp],interesting_data[press])

end

function update()

  -- get some interesting data
  interesting_data[temp_e] = baro:get_external_temperature()
  interesting_data[temp] =  baro:get_temperature()
  interesting_data[press] = baro:get_pressure()
  --interesting_data[press] = baro:get_pressure()

  -- write to then new file the SD card
  write_to_file()

  -- write to a new log in the data flash log
  write_to_dataflash()

  return update, 1000 -- reschedules the loop
end

-- make a file
-- note that this appends to the same the file each time, you will end up with a very big file
-- you may want to make a new file each time using a unique name
file = io.open(file_name, "a")
if not file then
  error("Could not make file")
end

-- write the CSV header
file:write('Time Stamp(ms), temp_ext(C),temp(C),press(Pa)\n')
file:flush()

return update, 10000
