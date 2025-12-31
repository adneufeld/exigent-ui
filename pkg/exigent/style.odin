package exigent

import "base:runtime"

Widget_Style :: struct {
	base:   Style,
	hover:  Style,
	active: Style,
}

Style :: struct {
	background: Color,
	text_color: Color,
	border:     Border_Style,
}

Color :: [3]u8

Border_Style :: struct {
	type:      Border_Type,
	thickness: int,
	color:     Color,
}

Border_Type :: enum {
	None,
	Square,
	// Rounded,
}

Widget_Type_Style :: struct {
	type:  Widget_Type,
	style: Widget_Style,
}

DEFAULT_STYLES := map[Widget_Type]Widget_Style{}

@(private)
style_default_register :: proc "contextless" (type: Widget_Type, style: Widget_Style) {
	if _, ok := DEFAULT_STYLES[type]; ok {
		context = runtime.default_context()
		panic("overriding existing default widget style")
	}
	DEFAULT_STYLES[type] = style
}

// Blend t percent of c2 into c1. This function uses float math so could be
// faster.
color_blend :: proc(c1, c2: Color, t: f32) -> (cb: Color) {
	assert(t >= 0 && t <= 1.0, "t must be a value from 0 and 1 (inclusive)")
	cb.r = u8(f32(c1.r) + (f32(c2.r) - f32(c1.r)) * t + 0.5)
	cb.g = u8(f32(c1.g) + (f32(c2.g) - f32(c1.g)) * t + 0.5)
	cb.b = u8(f32(c1.b) + (f32(c2.b) - f32(c1.b)) * t + 0.5)
	return cb
}

// Color_Type :: distinct string
// Color_Type_BACKGROUND :: Color_Type("background")
// Color_Type_BACKGROUND_HOVERED :: Color_Type("background_hovered")
// Color_Type_BACKGROUND_ACTIVE :: Color_Type("background_active") // ex. clicked
// Color_Type_BORDER :: Color_Type("border)")
// Color_Type_BORDER_HOVERED :: Color_Type("border_hovered")
// Color_Type_BORDER_ACTIVE :: Color_Type("border_active")
// Color_Type_INPUT :: Color_Type("input")

style_default_init :: proc(styles: ^[dynamic]Widget_Style, allocator := context.allocator) {
	// style.border_style = Border_Style {
	// 	color     = Color{200, 200, 200},
	// 	type      = .Square,
	// 	thickness = 2,
	// }

	// style.colors = make(map[Color_Type]Color, allocator)

	// style.colors[Color_Type_BACKGROUND] = Color{128, 128, 128}
	// style.colors[Color_Type_BACKGROUND_HOVERED] = color_blend(
	// 	style.colors[Color_Type_BACKGROUND],
	// 	WHITE,
	// 	0.3,
	// )
	// style.colors[Color_Type_BACKGROUND_ACTIVE] = color_blend(
	// 	style.colors[Color_Type_BACKGROUND],
	// 	BLACK,
	// 	0.3,
	// )

	// style.colors[Color_Type_INPUT] = color_blend(style.colors[Color_Type_BACKGROUND], WHITE, 0.5)

	append(styles, ..[]Widget_Style{})
}

style_push :: proc(c: ^Context, type: Widget_Type, style: Widget_Style) {
	append(&c.style_stack, Widget_Type_Style{type = type, style = style})
}

style_pop :: proc(c: ^Context) {
	assert(len(c.style_stack) > 1)
	pop(&c.style_stack)
}

style_get :: proc(c: ^Context, type: Widget_Type) -> Widget_Style {
	for wts in c.style_stack {
		if wts.type == type {
			return wts.style
		}
	}
	for wtype, wstyle in c.style_default {
		if wtype == type {
			return wstyle
		}
	}
	panic("missing style for widget")
}

// // Produces a flattened copy of the style stack for use in a widget
// @(private)
// style_flat_copy :: proc(c: ^Context) -> Style1 {
// 	colors_copy := make(map[Color_Type]Color, c.temp_allocator)
// 	border_style: Border_Style

// 	// by iterating forward through the style array when we append style overrides
// 	// to the end the result is overrides replace default or earlier overrides
// 	for s in c.style_stack {
// 		// flatten colours across multiple Style structs
// 		for ct, c in s.colors {
// 			colors_copy[ct] = c
// 		}
// 		// get first border style but skip Style structs with no border style
// 		if border_style == {} && s.border_style != {} {
// 			border_style = s.border_style
// 		}
// 	}

// 	return Style1{colors = colors_copy, border_style = border_style}
// }
