package exigent

import "core:mem"
main :: proc() {

}

Context :: struct {
	allocator, temp_allocator:   mem.Allocator,
	screen_width, screen_height: int,
	root, curr:                  ^Widget,
	widget_stack:                [dynamic]^Widget,
	num_widgets:                 int,
	style:                       [dynamic]Style,
	is_building:                 bool, // when between context_begin/context_end
	widget_iterator:             Widget_Iterator, // available after context_end
}

context_default_init :: proc(
	c: ^Context,
	allocator := context.allocator,
	temp_allocator := context.temp_allocator,
) {
	context.allocator = allocator
	c.allocator = allocator
	context.temp_allocator = temp_allocator
	c.temp_allocator = temp_allocator

	c.widget_stack.allocator = c.temp_allocator
	c.style.allocator = c.allocator

	style := Style{}
	style_default_init(&style, allocator)
	append(&c.style, style)
}

begin :: proc(c: ^Context, screen_width, screen_height: int) {
	c.screen_width = screen_width
	c.screen_height = screen_height
	c.num_widgets = 0
	c.is_building = true
}

end :: proc(c: ^Context) {
	assert(len(c.widget_stack) == 0, "every widget_begin must have a widge_end")
	assert(len(c.style) == 1, "every style_push must have a style_pop")
	c.is_building = false
	widget_iterator_init(c, &c.widget_iterator)
	c.root = nil
	c.curr = nil
}

context_cmd_next :: proc(c: ^Context) -> Command {
	assert(c.is_building == false, "must end before iterating commands")

	for true {
		if len(c.widget_iterator.next) <= 0 {
			clear(&c.widget_iterator.next)
			return Command_Done{}
		}

		next := pop(&c.widget_iterator.next)

		// add children to front for BFS which is back-to-front rendering with
		// our Widget tree by following parent to child in order
		inject_at(&c.widget_iterator.next, 0, ..next.children[:])

		if .DrawBackground in next.flags {
			assert(Color_Type_BACKGROUND in next.style.colors)
			color := next.style.colors[Color_Type_BACKGROUND]
			return Command_Rect{rect = next.rect, color = color, alpha = next.alpha}
		}
		// else continue popping to look for the next drawable widget
	}

	return Command_Done{}
}

Command :: union {
	Command_Done,
	Command_Rect,
}

Command_Done :: struct {}

Command_Rect :: struct {
	rect:  Rect,
	color: Color,
	alpha: u8,
}

// Lifetime: temp_allocator
@(private)
Widget_Iterator :: struct {
	next: [dynamic]^Widget,
}

@(private)
widget_iterator_init :: proc(c: ^Context, wi: ^Widget_Iterator) {
	wi.next.allocator = c.temp_allocator
	reserve(&wi.next, c.num_widgets)
	append(&wi.next, c.root)
}
