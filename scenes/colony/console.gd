extends LineEdit

@export var output: RichTextLabel


func _ready() -> void:
	text_submitted.connect(run_command.unbind(1))


func _dataify(string: String) -> Variant:
	var sv: Variant = str_to_var(string)
	return sv if sv else string


func run_command() -> void:
	var split := SmartSplitter.split(text)
	print("SPLIT: " + str(split))
	var cmdname := split[0]
	var args := []
	print("ARGS: " + str(args))
	for i in range(1, split.size()):
		args.append(_dataify(split[i]))

	callv("_cmd_" + cmdname, args)


func _cmd_gd(txt: String) -> void:
	var gd := GDScript.new()
	gd.source_code = """
func _init() -> void:
	%s
""" % txt
	print("SOURCE: " + gd.source_code)
	gd.reload()
	gd.new()


# unfinished forever hopefully
class Parser:
	const TERMINATOR := "♣"

	var input: String
	var pos: int


	static func parse(string: String) -> Array:
		return Parser.new()._parse(string)


	func _peek() -> String:
		return input[pos]


	func _eat() -> void:
		if _peek() == TERMINATOR:
			assert(false, "eof reached")
		pos += 1


	func _parse(string: String) -> Array:
		input = string + TERMINATOR
		pos = 0

		var c := _peek()

		var things := []
		things.append(_read())
		while c != TERMINATOR:
			things.append(_read())

		return things


	func _read() -> Variant:
		while _peek() != TERMINATOR:
			if _peek().is_valid_int():
				return _read_number()
			pass
		return null # TODO do the rest ig


	func _read_number() -> Variant:
		var s := ""
		while not _ws(_peek()):
			s += _peek()
			_eat()

		if s.is_valid_float():
			return float(s)
		return int(s)


	func _ws(s: String) -> bool:
		return s.strip_edges() == ""

class SmartSplitter:
	var stack := []
	var input: String
	var pos: int


	static func split(string: String) -> PackedStringArray:
		return SmartSplitter.new()._parse(string)


	func _parse(inp: String) -> PackedStringArray:
		input = inp
		var psa := PackedStringArray()
		var build := ""

		while pos < input.length():
			var c := input[pos]
			if _ws(c) and stack.is_empty():
				psa.append(build)
				build = ""
				_eat()
				continue
			if c == "\"":
				if not stack.is_empty() and stack.back() == c:
					build += stack.pop_back()
					_eat()
					continue
				stack.append("\"")
				build += c
				_eat()
				continue


			build += c
			_eat()

		psa.append(build)

		return psa


	func _eat() -> void:
		pos += 1


	func _ws(s: String) -> bool:
		return s.strip_edges() == ""
