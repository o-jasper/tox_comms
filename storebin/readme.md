Simple encoder and decoder. Encodes the types and such aswel too.
(numbers, strings tables should work entirely.)

Metatables are not stored, but you can use `:metatable_name()` to deposit a
name for it, later decoding, the name can cause a function to run with
the name and input table as argument.

That way, perhaps userdata, thread, functions can be re-added by
the provided function.
