# Simple encoder and decoder.
Encodes the types and such aswel too.
`number`, `string`, `table`, `nil`, `boolean` should work entirely.

Metatables are not stored, but you can use `:metatable_name()` to deposit a
name for it, later decoding, the name can cause a function to run with
the name and input table as argument.

That way, perhaps userdata, thread, functions can be re-added by
the provided function.

---

If there is no more than two subsequent `nil`s in lists, it ist stored as
lists, i.e. avoiding the key-value stuff.

Dont rely on the allowance of `nil`s though.

Recognizing sets is not pointful. Recognizing lists of low - <16 - numbers
and lists of choices might help more.. But i dont want to go into compression..
Afaik what is done is what is pointful.
