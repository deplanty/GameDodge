extends Node


func bold(text: String) -> String:
	return "[b]%s[/b]" % text


func underline(text: String) -> String:
	return "[u]%s[/u]" % text


func italic(text: String) -> String:
	return "[i]%s[/i]" % text


func center(text: String) -> String:
	return "[center]%s[/center]" % text
