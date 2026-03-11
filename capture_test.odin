package exigent

import "core:testing"

@(test)
test_is_pointer_captured_false_by_default :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	testing.expect(t, !is_pointer_captured(c), "Pointer should not be captured by default")
}

@(test)
test_is_pointer_captured_true_when_hovered_widget_exists :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	c.hovered_widget_id = Widget_ID(1)

	testing.expect(t, is_pointer_captured(c), "Pointer should be captured when a widget is hovered")
}

@(test)
test_is_keyboard_captured_false_by_default :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	testing.expect(t, !is_keyboard_captured(c), "Keyboard should not be captured by default")
}

@(test)
test_is_keyboard_captured_true_when_text_input_active :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	text_input := new(Text_Input)
	defer free(text_input)
	c.active_text_input = text_input

	testing.expect(t, is_keyboard_captured(c), "Keyboard should be captured when text input is active")
}
