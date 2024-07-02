-- This script is an example of reading from the CAN bus

-- Load CAN driver1. The first will attach to a protocol of 10

local CAN_BUF_LEN = 25
local driver1 = CAN:get_device(CAN_BUF_LEN)


if not driver1  then
   gcs:send_text(0,"No scripting CAN interfaces found")
   return
end

-- Type conversion functions
-- unsigned integer 8 bit
function get_uint8(frame, ofs)
    return frame:data(ofs)
 end

-- unsigned integer 16 bit
 function get_uint16(frame, ofs)
    -- protocol is big endian
    return (frame:data(ofs)<<8) + frame:data(ofs + 1)
 end
 
-- signed integer 16 bit
 function get_int16(frame, ofs)
    local v = get_uint16(frame, ofs)
    if v & 0x8000 ~= 0 then
       return v - 65536
    end
    return v
 end
 
-- signed integer 8 bit
function get_int8(frame, ofs)
    local v = get_uint8(frame, ofs)
    if v & 0x80 then
       return v - 256
    end
    return v
end
 
 


 

-- Message ID is 16 bits left shifted by 8 in the CAN frame ID.
-- driver2:add_filter(uint32_t(0xFFFF) << 8, uint32_t(341) << 8)


function can_log(frame)
    local id = frame:id_signed()
    logger.write('EFCN','Id,B0,B1,B2,B3,B4,B5,B6,B7', 'iBBBBBBBB',
                 id,
                 frame:data(0), frame:data(1), frame:data(2), frame:data(3),
                 frame:data(4), frame:data(5), frame:data(6), frame:data(7))
end


function show_frame(dnum, frame)
    gcs:send_text(0,string.format("CAN[%u] msg from " .. tostring(frame:id()) .. ": %i, %i, %i, %i, %i, %i, %i, %i", dnum, frame:data(0), frame:data(1), frame:data(2), frame:data(3), frame:data(4), frame:data(5), frame:data(6), frame:data(7)))
    gcs:send_named_float("RPM",frame:data(0))
    gcs:send_named_float("CHT",frame:data(1))
    gcs:send_named_float("MAT",frame:data(2))
    gcs:send_named_float("D4",frame:data(3))
    gcs:send_named_float("D5",frame:data(4))
    gcs:send_named_float("D6",frame:data(5))
    gcs:send_named_float("D7",frame:data(6))
    gcs:send_named_float("D8",frame:data(7))
end



function update()

   -- see if we got any frames
   if driver1 then
      frame = driver1:read_frame()
      
      if frame then
         gcs:send_text(0,"driver 1")
         local id = frame:id_signed()
         gcs:send_text(0,id)
         show_frame(1, frame)

      end
   end

  return update, 10

end

return update()