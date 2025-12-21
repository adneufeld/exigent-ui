package demo

import ui "../pkg/exigent"
import "core:mem"
import rl "vendor:raylib"

UI_ID :: enum uint {
	PANEL,
}

main :: proc() {
	rl.InitWindow(800, 600, "Exigent UI Demo")
	rl.SetTargetFPS(60)

	ctx := &ui.Context{}
	ui.context_default_init(ctx)

	for !rl.WindowShouldClose() {
		// Update
		ui.begin(ctx, 800, 600)
		r := ui.Rect{0, 0, 800, 600}
		r = ui.rect_inset(r, ui.inset(30))
		ui.panel2(ctx, ui.key(UI_ID.PANEL), r)
		ui.end(ctx)

		// Draw
		rl.BeginDrawing()
		rl.ClearBackground(rl.DARKBLUE)

		draw_ui: for true {
			cmd := ui.context_cmd_next(ctx)
			switch c in cmd {
			case ui.Command_Done:
				break draw_ui
			case ui.Command_Rect:
				rl_color := rl.Color{c.color.r, c.color.g, c.color.b, c.alpha}
				rl.DrawRectangleV(
					rl.Vector2{c.rect.x, c.rect.y},
					rl.Vector2{c.rect.width, c.rect.height},
					rl_color,
				)
			}
		}

		rl.DrawFPS(10, 10)
		rl.EndDrawing()
		free_all(context.temp_allocator)
	}

	rl.CloseWindow()
}
