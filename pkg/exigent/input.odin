package exigent

import ba "core:container/bit_array"

Input :: struct {
	mouse_pos:      [2]f32,
	key_down:       ba.Bit_Array,
	mouse_down:     bit_set[Mouse_Button],
	// cleared at end of frame since it is based on comparison with last frame
	key_pressed:    ba.Bit_Array,
	key_released:   ba.Bit_Array,
	mouse_pressed:  bit_set[Mouse_Button],
	mouse_released: bit_set[Mouse_Button],
}

Mouse_Button :: enum {
	Left,
	Right,
	Middle,
}

@(private)
input_create :: proc(
	min_index: int = 0,
	max_index: int = 512,
	allocator := context.allocator,
) -> ^Input {
	i := new(Input, allocator)
	ba.init(&i.key_down, max_index, min_index, allocator)
	ba.init(&i.key_pressed, max_index, min_index, allocator)
	ba.init(&i.key_released, max_index, min_index, allocator)
	return i
}

@(private)
input_destroy :: proc(i: ^Input, allocator := context.allocator) {
	context.allocator = allocator
	ba.destroy(&i.key_down)
	ba.destroy(&i.key_pressed)
	ba.destroy(&i.key_released)
	free(i, allocator)
}

@(private)
input_swap :: proc(c: ^Context) {
	c.input_prev, c.input_curr = c.input_curr, c.input_prev

	// copy persistent values to curr frame
	c.input_curr.mouse_pos = c.input_prev.mouse_pos
	copy(c.input_curr.key_down.bits[:], c.input_prev.key_down.bits[:])
	c.input_curr.mouse_down = c.input_prev.mouse_down

	// clear frame-specific values
	ba.clear(&c.input_curr.key_pressed)
	ba.clear(&c.input_curr.key_released)
	c.input_curr.mouse_pressed = {}
	c.input_curr.mouse_released = {}

}

input_key_down :: proc(c: ^Context, key: int) {
	ba.set(&c.input_curr.key_down, key)
	if !ba.get(&c.input_prev.key_down, key) {
		ba.set(&c.input_curr.key_pressed, key)
	}
}

input_is_key_down :: proc(c: ^Context, key: int) -> bool {
	return ba.get(&c.input_curr.key_down, key)
}

// Whether the key was pressed down this exact frame
input_is_key_pressed :: proc(c: ^Context, key: int) -> bool {
	return ba.get(&c.input_curr.key_pressed, key)
}

input_key_up :: proc(c: ^Context, key: int) {
	ba.unset(&c.input_curr.key_down, key)
	ba.unset(&c.input_curr.key_pressed, key)
	ba.set(&c.input_curr.key_released, key)
}

// Whether the key was released this exact frame
input_is_key_released :: proc(c: ^Context, key: int) -> bool {
	return ba.get(&c.input_curr.key_released, key)
}

input_mouse_pos :: proc(c: ^Context, pos: [2]f32) {
	c.input_curr.mouse_pos = pos
}

input_get_mouse_pos :: proc(c: ^Context) -> [2]f32 {
	return c.input_curr.mouse_pos
}

input_get_mouse_delta :: proc(c: ^Context) -> [2]f32 {
	return c.input_curr.mouse_pos - c.input_prev.mouse_pos
}

input_mouse_down :: proc(c: ^Context, btn: Mouse_Button) {
	c.input_curr.mouse_down += {btn}
	if btn not_in c.input_prev.mouse_down {
		c.input_curr.mouse_pressed += {btn}
	}
}

input_mouse_up :: proc(c: ^Context, btn: Mouse_Button) {
	c.input_curr.mouse_down -= {btn}
	c.input_curr.mouse_pressed -= {btn}
	c.input_curr.mouse_released += {btn}
}

input_is_mouse_down :: proc(c: ^Context, btn: Mouse_Button) -> bool {
	return btn in c.input_curr.mouse_down
}

// Whether the mouse button was released this exact frame
input_is_mouse_released :: proc(c: ^Context, btn: Mouse_Button) -> bool {
	return btn in c.input_curr.mouse_released
}

// Whether the mouse button was pressed down this exact frame
input_is_mouse_pressed :: proc(c: ^Context, btn: Mouse_Button) -> bool {
	return btn in c.input_curr.mouse_pressed
}

Key_Down_Iterator :: struct {
	iterator: ba.Bit_Array_Iterator,
}

input_key_down_iterator :: proc(c: ^Context) -> Key_Down_Iterator {
	return Key_Down_Iterator{iterator = ba.make_iterator(&c.input_curr.key_down)}
}

// Returns false when done
input_key_down_iterator_next :: proc(it: ^Key_Down_Iterator) -> (int, bool) {
	return ba.iterate_by_set(&it.iterator)
}
