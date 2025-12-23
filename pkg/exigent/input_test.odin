package exigent

import "core:mem"
import "core:testing"

fixture_context_create :: proc() -> ^Context {
	c := new(Context)
	c.input_prev = input_create()
	c.input_curr = input_create()
	return c
}

fixture_context_delete :: proc(c: ^Context) {
	input_destroy(c.input_prev)
	input_destroy(c.input_curr)
	free(c)
}

@(test)
test_key_down_sets_down_state :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_key_down(c, 65) // 'A' key
	testing.expect(t, input_is_key_down(c, 65), "Key should be down after input_key_down")
}

@(test)
test_key_down_sets_pressed_first_frame :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_key_down(c, 65)
	testing.expect(t, input_is_key_pressed(c, 65), "Key should be pressed on first frame")
}

@(test)
test_key_down_not_pressed_if_already_down :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_key_down(c, 65)
	input_swap(c) // Simulate next frame
	input_key_down(c, 65) // Press again
	testing.expect(t, !input_is_key_pressed(c, 65), "Key should not be pressed if already down")
	testing.expect(t, input_is_key_down(c, 65), "Key should still be down")
}

@(test)
test_key_up_clears_down_state :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_key_down(c, 65)
	input_key_up(c, 65)
	testing.expect(t, !input_is_key_down(c, 65), "Key should not be down after input_key_up")
}

@(test)
test_key_up_sets_released_state :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_key_down(c, 65)
	input_key_up(c, 65)
	testing.expect(t, input_is_key_released(c, 65), "Key should be released after input_key_up")
}

@(test)
test_key_up_clears_pressed_state :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_key_down(c, 65)
	input_key_up(c, 65)
	testing.expect(t, !input_is_key_pressed(c, 65), "Pressed state should be cleared on release")
}

@(test)
test_multiple_keys_independent :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_key_down(c, 65)
	input_key_down(c, 66)

	testing.expect(t, input_is_key_down(c, 65), "Key 65 should be down")
	testing.expect(t, input_is_key_down(c, 66), "Key 66 should be down")
	testing.expect(t, input_is_key_pressed(c, 65), "Key 65 should be pressed")
	testing.expect(t, input_is_key_pressed(c, 66), "Key 66 should be pressed")

	input_key_up(c, 65)

	testing.expect(t, !input_is_key_down(c, 65), "Key 65 should not be down after up")
	testing.expect(t, input_is_key_down(c, 66), "Key 66 should still be down")
	testing.expect(t, !input_is_key_pressed(c, 65), "Key 65 should not be pressed")
	testing.expect(t, input_is_key_pressed(c, 66), "Key 66 should still be pressed")
	testing.expect(t, input_is_key_released(c, 65), "Key 65 should be released")
	testing.expect(t, !input_is_key_released(c, 66), "Key 66 should not be released")
}

@(test)
test_mouse_down_sets_down_state :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_mouse_down(c, .Left)
	testing.expect(
		t,
		input_is_mouse_down(c, .Left),
		"Mouse button should be down after input_mouse_down",
	)
}

@(test)
test_mouse_down_sets_pressed_first_frame :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_mouse_down(c, .Left)
	testing.expect(
		t,
		input_is_mouse_pressed(c, .Left),
		"Mouse button should be pressed on first frame",
	)
}

@(test)
test_mouse_down_not_pressed_if_already_down :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_mouse_down(c, .Left)
	input_swap(c) // Simulate next frame
	input_mouse_down(c, .Left) // Press again
	testing.expect(
		t,
		!input_is_mouse_pressed(c, .Left),
		"Mouse button should not be pressed if already down",
	)
	testing.expect(t, input_is_mouse_down(c, .Left), "Mouse button should still be down")
}

@(test)
test_mouse_up_clears_down_state :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_mouse_down(c, .Left)
	input_mouse_up(c, .Left)
	testing.expect(
		t,
		!input_is_mouse_down(c, .Left),
		"Mouse button should not be down after input_mouse_up",
	)
}

@(test)
test_mouse_up_sets_released_state :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_mouse_down(c, .Left)
	input_mouse_up(c, .Left)
	testing.expect(
		t,
		input_is_mouse_released(c, .Left),
		"Mouse button should be released after input_mouse_up",
	)
}

@(test)
test_mouse_up_clears_pressed_state :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_mouse_down(c, .Left)
	input_mouse_up(c, .Left)
	testing.expect(
		t,
		!input_is_mouse_pressed(c, .Left),
		"Pressed state should be cleared on release",
	)
}

@(test)
test_all_mouse_buttons :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	buttons := []Mouse_Button{.Left, .Right, .Middle}

	for btn in buttons {
		input_mouse_down(c, btn)
		testing.expectf(t, input_is_mouse_down(c, btn), "Button %v should be down", btn)
		testing.expectf(t, input_is_mouse_pressed(c, btn), "Button %v should be pressed", btn)
		input_mouse_up(c, btn)
		testing.expectf(
			t,
			!input_is_mouse_down(c, btn),
			"Button %v should not be down after up",
			btn,
		)
		testing.expectf(t, input_is_mouse_released(c, btn), "Button %v should be released", btn)
	}
}

@(test)
test_multiple_mouse_buttons_independent :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_mouse_down(c, .Left)
	input_mouse_down(c, .Right)

	testing.expect(t, input_is_mouse_down(c, .Left), "Left button should be down")
	testing.expect(t, input_is_mouse_down(c, .Right), "Right button should be down")
	testing.expect(t, input_is_mouse_pressed(c, .Left), "Left button should be pressed")
	testing.expect(t, input_is_mouse_pressed(c, .Right), "Right button should be pressed")

	input_mouse_up(c, .Left)

	testing.expect(t, !input_is_mouse_down(c, .Left), "Left button should not be down after up")
	testing.expect(t, input_is_mouse_down(c, .Right), "Right button should still be down")
	testing.expect(t, !input_is_mouse_pressed(c, .Left), "Left button should not be pressed")
	testing.expect(t, input_is_mouse_pressed(c, .Right), "Right button should still be pressed")
	testing.expect(t, input_is_mouse_released(c, .Left), "Left button should be released")
	testing.expect(t, !input_is_mouse_released(c, .Right), "Right button should not be released")
}

@(test)
test_mouse_pos_sets_position :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	pos := [2]f32{100, 200}
	input_mouse_pos(c, pos)
	testing.expect(t, c.input_curr.mouse_pos == pos, "Mouse position should be set correctly")
}

@(test)
test_mouse_pos_persists_across_frames :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	pos := [2]f32{150, 250}
	input_mouse_pos(c, pos)
	testing.expect(t, c.input_curr.mouse_pos == pos, "Mouse position should be set")

	input_swap(c)
	testing.expect(t, c.input_curr.mouse_pos == pos, "Mouse position should persist after swap")
}

@(test)
test_swap_preserves_key_down_state :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_key_down(c, 65)
	testing.expect(t, input_is_key_down(c, 65), "Key should be down before swap")

	input_swap(c)
	testing.expect(t, input_is_key_down(c, 65), "Key should still be down after swap")
}

@(test)
test_swap_clears_key_pressed_state :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_key_down(c, 65)
	testing.expect(t, input_is_key_pressed(c, 65), "Key should be pressed before swap")

	input_swap(c)
	testing.expect(t, !input_is_key_pressed(c, 65), "Key should not be pressed after swap")
}

@(test)
test_swap_clears_key_released_state :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_key_down(c, 65)
	input_key_up(c, 65)
	testing.expect(t, input_is_key_released(c, 65), "Key should be released before swap")

	input_swap(c)
	testing.expect(t, !input_is_key_released(c, 65), "Key should not be released after swap")
}

@(test)
test_swap_preserves_mouse_down_state :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_mouse_down(c, .Left)
	testing.expect(t, input_is_mouse_down(c, .Left), "Mouse button should be down before swap")

	input_swap(c)
	testing.expect(
		t,
		input_is_mouse_down(c, .Left),
		"Mouse button should still be down after swap",
	)
}

@(test)
test_swap_clears_mouse_pressed_state :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_mouse_down(c, .Left)
	testing.expect(
		t,
		input_is_mouse_pressed(c, .Left),
		"Mouse button should be pressed before swap",
	)

	input_swap(c)
	testing.expect(
		t,
		!input_is_mouse_pressed(c, .Left),
		"Mouse button should not be pressed after swap",
	)
}

@(test)
test_swap_clears_mouse_released_state :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_mouse_down(c, .Left)
	input_mouse_up(c, .Left)
	testing.expect(
		t,
		input_is_mouse_released(c, .Left),
		"Mouse button should be released before swap",
	)

	input_swap(c)
	testing.expect(
		t,
		!input_is_mouse_released(c, .Left),
		"Mouse button should not be released after swap",
	)
}

@(test)
test_swap_preserves_mouse_pos :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	pos := [2]f32{123, 456}
	input_mouse_pos(c, pos)
	testing.expect(t, c.input_curr.mouse_pos == pos, "Mouse pos should be set before swap")

	input_swap(c)
	testing.expect(t, c.input_curr.mouse_pos == pos, "Mouse pos should persist after swap")
}

@(test)
test_iterator_empty_when_no_keys :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	it := input_key_down_iterator(c)
	key, ok := input_key_down_iterator_next(&it)
	testing.expect(t, !ok, "Iterator should return false when no keys are pressed")
}

@(test)
test_iterator_finds_single_key :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_key_down(c, 65)
	it := input_key_down_iterator(c)
	key, ok := input_key_down_iterator_next(&it)
	testing.expect(t, ok, "Iterator should find a key")
	testing.expect(t, key == 65, "Iterator should return the correct key")
	key2, ok2 := input_key_down_iterator_next(&it)
	testing.expect(t, !ok2, "Iterator should exhaust after one key")
}

@(test)
test_iterator_finds_multiple_keys :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_key_down(c, 65)
	input_key_down(c, 66)
	input_key_down(c, 67)

	it := input_key_down_iterator(c)
	found_keys := make([dynamic]int, 0, 3, context.temp_allocator)
	defer delete(found_keys)

	for {
		key, ok := input_key_down_iterator_next(&it)
		if !ok {break}
		append(&found_keys, key)
	}

	testing.expect(t, len(found_keys) == 3, "Iterator should find all three keys")
	// Check that all keys are found (order may vary)
	found_65, found_66, found_67 := false, false, false
	for k in found_keys {
		switch k {
		case 65:
			found_65 = true
		case 66:
			found_66 = true
		case 67:
			found_67 = true
		}
	}
	testing.expect(t, found_65 && found_66 && found_67, "All keys should be found")
}

@(test)
test_iterator_order :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	// Press keys in order
	input_key_down(c, 10)
	input_key_down(c, 20)
	input_key_down(c, 30)

	it := input_key_down_iterator(c)
	key1, ok1 := input_key_down_iterator_next(&it)
	key2, ok2 := input_key_down_iterator_next(&it)
	key3, ok3 := input_key_down_iterator_next(&it)
	key4, ok4 := input_key_down_iterator_next(&it)

	testing.expect(t, ok1 && ok2 && ok3 && !ok4, "Iterator should find exactly three keys")
	testing.expect(t, key1 < key2 && key2 < key3, "Keys should be returned in ascending order")
}

@(test)
test_iterator_exhausts :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_key_down(c, 65)
	it := input_key_down_iterator(c)

	// Exhaust the iterator
	for {
		_, ok := input_key_down_iterator_next(&it)
		if !ok {break}
	}

	// Try again - should still be exhausted
	key, ok := input_key_down_iterator_next(&it)
	testing.expect(t, !ok, "Iterator should remain exhausted")
}

@(test)
test_key_press_and_hold_sequence :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	// Frame 1: Press
	input_key_down(c, 65)
	testing.expect(t, input_is_key_pressed(c, 65), "Frame 1: pressed=true")
	testing.expect(t, input_is_key_down(c, 65), "Frame 1: down=true")
	testing.expect(t, !input_is_key_released(c, 65), "Frame 1: released=false")

	// Frame 2: Hold (swap, then press again)
	input_swap(c)
	input_key_down(c, 65)
	testing.expect(t, !input_is_key_pressed(c, 65), "Frame 2: pressed=false")
	testing.expect(t, input_is_key_down(c, 65), "Frame 2: down=true")
	testing.expect(t, !input_is_key_released(c, 65), "Frame 2: released=false")

	// Frame 3: Release
	input_key_up(c, 65)
	testing.expect(t, !input_is_key_pressed(c, 65), "Frame 3: pressed=false")
	testing.expect(t, !input_is_key_down(c, 65), "Frame 3: down=false")
	testing.expect(t, input_is_key_released(c, 65), "Frame 3: released=true")
}

@(test)
test_key_rapid_press_release :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	// Press and release in same frame
	input_key_down(c, 65)
	input_key_up(c, 65)
	testing.expect(t, !input_is_key_pressed(c, 65), "Pressed should be false after down then up")
	testing.expect(t, !input_is_key_down(c, 65), "Down should be false after up")
	testing.expect(t, input_is_key_released(c, 65), "Released should be true after up")
}

@(test)
test_mouse_click_sequence :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	// Frame 1: Press
	input_mouse_down(c, .Left)
	testing.expect(t, input_is_mouse_pressed(c, .Left), "Frame 1: pressed=true")
	testing.expect(t, input_is_mouse_down(c, .Left), "Frame 1: down=true")
	testing.expect(t, !input_is_mouse_released(c, .Left), "Frame 1: released=false")

	// Frame 2: Hold
	input_swap(c)
	input_mouse_down(c, .Left)
	testing.expect(t, !input_is_mouse_pressed(c, .Left), "Frame 2: pressed=false")
	testing.expect(t, input_is_mouse_down(c, .Left), "Frame 2: down=true")
	testing.expect(t, !input_is_mouse_released(c, .Left), "Frame 2: released=false")

	// Frame 3: Release
	input_mouse_up(c, .Left)
	testing.expect(t, !input_is_mouse_pressed(c, .Left), "Frame 3: pressed=false")
	testing.expect(t, !input_is_mouse_down(c, .Left), "Frame 3: down=false")
	testing.expect(t, input_is_mouse_released(c, .Left), "Frame 3: released=true")
}

@(test)
test_simultaneous_inputs :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	// Press multiple keys and mouse buttons
	input_key_down(c, 65)
	input_key_down(c, 66)
	input_mouse_down(c, .Left)
	input_mouse_down(c, .Right)

	testing.expect(t, input_is_key_down(c, 65), "Key 65 down")
	testing.expect(t, input_is_key_down(c, 66), "Key 66 down")
	testing.expect(t, input_is_mouse_down(c, .Left), "Mouse Left down")
	testing.expect(t, input_is_mouse_down(c, .Right), "Mouse Right down")
	testing.expect(t, input_is_key_pressed(c, 65), "Key 65 pressed")
	testing.expect(t, input_is_key_pressed(c, 66), "Key 66 pressed")
	testing.expect(t, input_is_mouse_pressed(c, .Left), "Mouse Left pressed")
	testing.expect(t, input_is_mouse_pressed(c, .Right), "Mouse Right pressed")

	// Swap frame
	input_swap(c)

	// Release some
	input_key_up(c, 65)
	input_mouse_up(c, .Left)

	testing.expect(t, !input_is_key_down(c, 65), "Key 65 not down after up")
	testing.expect(t, input_is_key_down(c, 66), "Key 66 still down")
	testing.expect(t, !input_is_mouse_down(c, .Left), "Mouse Left not down after up")
	testing.expect(t, input_is_mouse_down(c, .Right), "Mouse Right still down")
	testing.expect(t, !input_is_key_pressed(c, 65), "Key 65 not pressed after swap")
	testing.expect(t, !input_is_key_pressed(c, 66), "Key 66 not pressed after swap")
	testing.expect(t, !input_is_mouse_pressed(c, .Left), "Mouse Left not pressed after swap")
	testing.expect(t, !input_is_mouse_pressed(c, .Right), "Mouse Right not pressed after swap")
	testing.expect(t, input_is_key_released(c, 65), "Key 65 released")
	testing.expect(t, input_is_mouse_released(c, .Left), "Mouse Left released")
}

@(test)
test_release_unpressed_key :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	// Release a key that was never pressed
	input_key_up(c, 65)
	testing.expect(t, !input_is_key_down(c, 65), "Unpressed key should not be down")
	testing.expect(t, input_is_key_released(c, 65), "Unpressed key should be released")
	testing.expect(t, !input_is_key_pressed(c, 65), "Unpressed key should not be pressed")
}

@(test)
test_double_press_same_key :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_key_down(c, 65)
	testing.expect(t, input_is_key_pressed(c, 65), "First press should set pressed")
	testing.expect(t, input_is_key_down(c, 65), "First press should set down")

	input_key_down(c, 65) // Press again
	testing.expect(
		t,
		input_is_key_pressed(c, 65),
		"Second press should still have pressed (from first)",
	)
	testing.expect(t, input_is_key_down(c, 65), "Second press should keep down")
}

@(test)
test_double_release_same_key :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	input_key_down(c, 65)
	input_key_up(c, 65)
	testing.expect(t, input_is_key_released(c, 65), "First release should set released")

	input_key_up(c, 65) // Release again
	testing.expect(t, !input_is_key_down(c, 65), "Second release should keep not down")
	testing.expect(t, input_is_key_released(c, 65), "Second release should set released again")
	testing.expect(t, !input_is_key_pressed(c, 65), "Should not be pressed")
}

@(test)
test_release_unpressed_mouse_button :: proc(t: ^testing.T) {
	c := fixture_context_create()
	defer fixture_context_delete(c)

	// Release a mouse button that was never pressed
	input_mouse_up(c, .Left)
	testing.expect(t, !input_is_mouse_down(c, .Left), "Unpressed mouse button should not be down")
	testing.expect(
		t,
		input_is_mouse_released(c, .Left),
		"Unpressed mouse button should be released",
	)
	testing.expect(
		t,
		!input_is_mouse_pressed(c, .Left),
		"Unpressed mouse button should not be pressed",
	)
}
