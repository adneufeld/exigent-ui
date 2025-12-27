package demo

import ui "../pkg/exigent"
import "core:fmt"
import "core:strings"
import rl "vendor:raylib"

UI_ID :: enum uint {
	PANEL,
	BUTTON,
	LABEL1,
	LABEL2,
	LABEL3,
}

main :: proc() {
	rl.InitWindow(800, 600, "Exigent UI Demo")
	rl.SetTargetFPS(60)
	default_text_style_type := ui.Text_Style_Type("default")
	default_font: rl.Font = rl.GetFontDefault()

	ctx := &ui.Context{}
	ui.context_init(ctx)
	ui.text_style_init(
		default_text_style_type,
		ui.Text_Style {
			type = default_text_style_type,
			size = 28,
			spacing = 2,
			line_height = 30,
			font = &default_font,
			color = ui.BLACK,
		},
		measure_width,
	)

	for !rl.WindowShouldClose() {
		// Input - Check for released keys
		it := ui.input_key_down_iterator(ctx)
		for true {
			key, ok := ui.input_key_down_iterator_next(&it)
			if !ok {
				break
			}
			if rl.IsKeyReleased(rl.KeyboardKey(key)) {
				ui.input_key_up(ctx, key)
			}
		}
		// Input - Get all down keys
		for true {
			key := int(rl.GetKeyPressed())
			if key == 0 {
				break
			}
			ui.input_key_down(ctx, key)
		}
		// Input - Mouse
		ui.input_mouse_pos(ctx, rl.GetMousePosition())
		// TODO: This could be optimized
		if rl.IsMouseButtonDown(.LEFT) {
			ui.input_mouse_down(ctx, .Left)
		}
		if rl.IsMouseButtonReleased(.LEFT) {
			ui.input_mouse_up(ctx, .Left)
		}
		if rl.IsMouseButtonDown(.RIGHT) {
			ui.input_mouse_down(ctx, .Right)
		}
		if rl.IsMouseButtonReleased(.RIGHT) {
			ui.input_mouse_up(ctx, .Right)
		}
		if rl.IsMouseButtonDown(.MIDDLE) {
			ui.input_mouse_down(ctx, .Middle)
		}
		if rl.IsMouseButtonReleased(.MIDDLE) {
			ui.input_mouse_up(ctx, .Middle)
		}

		// Update - Build UI
		ui.begin(ctx, 800, 600)
		r := ui.Rect{0, 0, 800, 600}

		t1 := ui.rect_cut_top(&r, 100)
		t1 = ui.rect_inset(t1, ui.Inset{0, 90, 0, 90})
		ui.label(ctx, ui.key(UI_ID.LABEL1), t1, "Label: ")

		t2 := ui.rect_cut_top(&r, 100)
		t2 = ui.rect_inset(t2, ui.Inset{0, 90, 0, 90})
		ui.label(ctx, ui.key(UI_ID.LABEL2), t2, "Label: ")

		t3 := ui.rect_cut_top(&r, 100)
		t3 = ui.rect_inset(t3, ui.Inset{0, 90, 0, 90})
		ui.label(ctx, ui.key(UI_ID.LABEL3), t3, "Label: ")

		bot := r
		bot = ui.rect_inset(bot, ui.Inset{0, 90, 180, 90})
		if ui.button(ctx, ui.key(UI_ID.BUTTON), bot, "Click me!").clicked {
			fmt.printfln("clicked!")
		}
		ui.end(ctx)

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground(rl.DARKBLUE)

		ci := ui.cmd_iterator_create(
			ctx,
			ui.DEFAULT_CMDS_PER_WIDGET_HEURISTIC,
			context.temp_allocator,
		)
		draw_ui: for true {
			cmd := ui.cmd_iterator_next(&ci)
			switch c in cmd {
			case ui.Command_Done:
				break draw_ui
			case ui.Command_Rect:
				rl_color := rl.Color{c.color.r, c.color.g, c.color.b, c.alpha}
				switch c.border_style {
				case .None:
					rl.DrawRectangleV(
						rl.Vector2{c.rect.x, c.rect.y},
						rl.Vector2{c.rect.width, c.rect.height},
						rl_color,
					)
				case .Square:
					rl.DrawRectangleV(
						rl.Vector2{c.rect.x, c.rect.y},
						rl.Vector2{c.rect.width, c.rect.height},
						rl_color,
					)
					rl.DrawRectangleLinesEx(
						rl.Rectangle{c.rect.x, c.rect.y, c.rect.width, c.rect.height},
						f32(c.border_thickness),
						rl.Color{c.border_color.r, c.border_color.g, c.border_color.b, c.alpha},
					)
				}
			case ui.Command_Text:
				cstr := strings.clone_to_cstring(c.text, context.temp_allocator)
				f := cast(^rl.Font)c.style.font
				rcolor := rl.Color{c.style.color.r, c.style.color.g, c.style.color.b, 255}
				rl.DrawTextEx(f^, cstr, c.pos, c.style.size, c.style.spacing, rcolor)
			}
		}

		rl.DrawFPS(10, 10)
		rl.EndDrawing()
		free_all(context.temp_allocator)
	}

	ui.context_destroy(ctx)
	rl.CloseWindow()
}

measure_width :: proc(style: ui.Text_Style, text: string) -> f32 {
	cstr := strings.clone_to_cstring(text, context.temp_allocator)
	f := cast(^rl.Font)style.font
	m := rl.MeasureTextEx(f^, cstr, style.size, style.spacing)
	return m.x
}
