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
	DrawBackgroundFocused,
}

widget_begin :: proc(c: ^Context, key: Widget_Key, r: Rect) {
	c.num_widgets += 1

	w := new(Widget, c.temp_allocator)
	w.alpha = 255
	w.rect = r

	if c.widget_curr != nil {
		parent := c.widget_curr
		append(&c.widget_stack, c.widget_curr)
		c.widget_curr = nil
		w.parent = parent
		append(&w.parent.children, w)
	}

	c.widget_curr = w

	if c.widget_root == nil {
		c.widget_root = c.widget_curr
	}
}

widget_end :: proc(c: ^Context) {
	c.widget_curr.style = style_flat_copy(c)

	if len(c.widget_stack) > 0 {
		c.widget_curr = pop(&c.widget_stack)
	}
}

widget_flags :: proc(c: ^Context, flags: bit_set[Widget_Flags]) {
	c.widget_curr.flags += flags
}

// pick the top-most widget at the mouse_pos
@(private)
widget_pick :: proc(w: ^Widget, mouse_pos: [2]f32) -> (focus: ^Widget, found: bool) {
	if w == nil {
		return nil, false
	}

	// TODO: This requires that each parent always contains their children fully.
	// Should we assert this during widget building to prevent surprises? Or
	// do we want an alternate approach?
	if !rect_contains(w.rect, mouse_pos) {
		return nil, false
	}

	#reverse for child in w.children {
		descendent_focus, found := widget_pick(child, mouse_pos)
		if found {
			return descendent_focus, true
		}
	}

	return w, true
}

Widget_Interaction :: struct {
	clicked:  bool,
	hovering: bool,
}

widget_interaction :: proc(c: ^Context, w: ^Widget) -> (ret: Widget_Interaction) {
	widget_focus_key, ok := c.widget_focus_key.?
	if ok && c.widget_focus_key == w.key {
		ret.hovering = true
		if input_is_mouse_pressed(c, .Left) {
			ret.clicked = true
		}
	}
	return ret
}

hover_panel :: proc(c: ^Context, key: Widget_Key, r: Rect) -> Widget_Interaction {
	widget_begin(c, key, r)
	interact := widget_interaction(c, c.widget_curr)
	widget_flags(c, {.DrawBackgroundFocused} if interact.hovering else {.DrawBackground})
	widget_end(c)
	return interact
}
