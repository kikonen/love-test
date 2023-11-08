print("utils")

function table_size(t)
 count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

function printf(...) io.write(string.format(...)) end

function pack_table(...)
  return { n = select("#", ...), ... }
end

function print_table(t, levels)
   printf("%s\n", format_table(t, "", levels or 5))
end

function format_table(t, indent, levels)
   local sb = ""

   indent = indent or ""

   if type(t) == "table" then
      if table_size(t) > 0 then
         local first = true
         for k, v in pairs(t) do
            if not first then
               sb = sb .. "\n"
            end

            sb = sb .. string.format("%s%s: ", indent, k)

            if type(v) == "table" and levels > 1 then
               v = format_table(v, indent .. "  ", levels - 1)
               if #v > 0 then
                  sb = sb .. "\n"
               else
                  v = "{}"
               end
            end
            sb = sb .. string.format("%s", v)

            first = false
         end
      end
    else
       sb = sb .. string.format("%s%s", indent, t)
    end

   return sb
end

function dbg(levels, ...)
   local args = pack_table(...)
   for i = 1, args.n do
      printf("------------------\n")
      print_table(args[i], levels or 3)
   end
end

function trace(label, levels, ...)
   local args = pack_table(...)
   printf("[START: %s]\n", label)
   for i = 1, args.n do
      printf("----------%i/%i (%s)--------------------\n", i, args.n, label)
      print_table(args[i], levels or 3)
   end
   printf("------------------------------\n")
   printf("%s\n", debug.traceback())
   printf("[END: %s]\n", label)
end
