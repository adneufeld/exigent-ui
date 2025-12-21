package exigent

import "base:intrinsics"
Widget :: struct {
	key:      Widget_Key,
	parent:   ^Widget,
	children: [dynamic]^Widget,
	rect:     Rect,
	style:    Style,
	alpha:    u8,
	flags:    bit_set[Widget_Flags],
}

// Create a uint enum and give one unique entry per widget
Widget_Key :: distinct uint

key :: proc(id: $T) -> Widget_Key where intrinsics.type_is_enum(T) {
	return Widget_Key(uint(id))
}

Widget_Flags :: enum {
	DrawBackground,
}

widget_begin :: proc(c: ^Context, key: Widget_Key, r: Rect) {
	c.num_widgets += 1

	w := new(Widget, c.temp_allocator)
	w.alpha = 255
	w.rect = r
	w.style = style_flat_copy(c)

	if c.curr != nil {
		parent := c.curr
		append(&c.widget_stack, c.curr)
		c.curr = nil
		w.parent = parent
		append(&w.parent.children, w)
	}

	c.curr = w

	if c.root == nil {
		c.root = c.curr
	}
}

widget_end :: proc(c: ^Context) {
	if len(c.widget_stack) > 0 {
		c.curr = pop(&c.widget_stack)
	}
}

widget_flags :: proc(c: ^Context, flags: bit_set[Widget_Flags]) {
	c.curr.flags += flags
}

panel2 :: proc(c: ^Context, key: Widget_Key, r: Rect) {
	widget_begin(c, key, r)
	widget_flags(c, {.DrawBackground})
	r := r
	r = rect_inset(r, inset(20))
	left, right := rect_cut(r, CUT_H_HALF)

	style := Style {
		colors = make(map[Color_Type]Color, c.temp_allocator),
	}
	style.colors[Color_Type_BACKGROUND] = Color{255, 49, 166}
	style_push(c, style)
	panel(c, key + 1000, left)

	style_pop(c)
	widget_end(c)
}

panel :: proc(c: ^Context, key: Widget_Key, r: Rect) {
	widget_begin(c, key, r)
	widget_flags(c, {.DrawBackground})
	widget_end(c)
}
