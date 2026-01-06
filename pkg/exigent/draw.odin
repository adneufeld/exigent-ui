package exigent

import "core:strings"

draw_rect :: proc(c: ^Context, r: Rect, color: Color, alpha: u8, border := Border_Style{}) {
	append(
		&c.draw_cmds,
		Command_Rect {
			rect = r,
			color = color,
			alpha = alpha,
			border = border,
			clip = c.widget_curr.clip,
		},
	)
}

draw_background :: proc(c: ^Context) {
	style := style_curr(c)
	draw_rect(c, c.widget_curr.rect, style.background, c.widget_curr.alpha, style.border)
}

draw_text :: proc {
	draw_text_aligned,
	draw_text_at_offset,
}

Text_Align_H :: enum {
	Left,
	Center,
	Right,
}

Text_Align_V :: enum {
	Top,
	Center,
	Bottom,
}

draw_text_aligned :: proc(
	c: ^Context,
	text: string,
	h_align: Text_Align_H,
	v_align: Text_Align_V,
) {
	assert(!strings.contains(text, "\n"), "multiline text not supported yet")
	text := text_clip(c, text, c.widget_curr.rect)

	text_style := text_style_curr(c)
	r := widget_get_rect(c)
	tw := text_width(c, text)

	offset: [2]f32

	switch h_align {
	case .Left:
		offset.x = 0
	case .Center:
		offset.x = (r.width - f32(tw)) * 0.5
	case .Right:
		offset.x = r.width - f32(tw)
	}

	switch v_align {
	case .Top:
		offset.y = 0
	case .Center:
		offset.y = (r.height - text_style.line_height) * 0.5
	case .Bottom:
		offset.y = r.height - text_style.line_height
	}

	draw_text_at_offset(c, text, offset)
}

// Widgets support a single text string and will be automatically split on newlines
draw_text_at_offset :: proc(c: ^Context, text: string, offset: [2]f32) {
	assert(!strings.contains(text, "\n"), "multiline text not supported yet")
	append(
		&c.draw_cmds,
		Command_Text {
			text = text,
			pos = [2]f32{c.widget_curr.rect.x, c.widget_curr.rect.y} + offset,
			style = text_style_curr(c),
			clip = c.widget_curr.clip,
		},
	)
}

