class_name Dialogue
extends RefCounted

## The person speaking this line.
var speaker: Speakers

## The expression to display on the speaker's face. Defaults to NEUTRAL.
var expression: Expressions = Expressions.NEUTRAL

## The line spoken.
var line: String

## Possible speakers of the dialogue
enum Speakers { MOM, DAD, BABY }

## Possible expresssions displayed by Mom and the Baby
enum Expressions { CRYING, SCARED, ANNOYED, NEUTRAL, SURPRISED, SMILING, JOYFUL }
