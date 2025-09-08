class_name Dialogue
extends RefCounted

## The person speaking this line.
var speaker: Speakers

## The line spoken.
var line: String

## Possible speakers of the dialogue
enum Speakers { MOM, DAD, BABY }
