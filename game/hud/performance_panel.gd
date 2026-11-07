class_name PerformancePanel
extends PanelContainer

const SAMPLE_COUNT: int = 1000
const REFRESH_SECONDS: float = 0.25
const GRAPH_MAX_MS: float = 50.0
const TARGET_MS: Array[float] = [1000.0 / 144.0, 1000.0 / 60.0, 1000.0 / 30.0]
const GOOD_COLOR: Color = Color("7ee787")
const SLOW_COLOR: Color = Color("ffb35c")
const BAD_COLOR: Color = Color("ff6b6b")
const GUIDE_COLOR: Color = Color(1, 1, 1, 0.2)
const VSYNC_NAMES: Array[String] = ["off", "on", "adaptive", "mailbox"]
const BYTES_PER_MIB: float = 1024.0 * 1024.0

var frame_times_ms: PackedFloat32Array = []
var next_sample: int = 0
var last_tick_usec: int = 0
var last_refresh_usec: int = 0

@onready var stats_label: Label = $Content/Stats
@onready var graph: Control = $Content/Graph


func _ready() -> void:
	graph.draw.connect(_draw_graph)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		visible = not visible
		RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(), visible)
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	var now := Time.get_ticks_usec()
	if last_tick_usec > 0:
		_record((now - last_tick_usec) / 1000.0)
	last_tick_usec = now

	if not visible or now - last_refresh_usec < REFRESH_SECONDS * 1_000_000.0:
		return
	last_refresh_usec = now
	stats_label.text = _report()
	graph.queue_redraw()


func _record(frame_ms: float) -> void:
	if frame_times_ms.size() < SAMPLE_COUNT:
		frame_times_ms.append(frame_ms)
	else:
		frame_times_ms[next_sample] = frame_ms
	next_sample = (next_sample + 1) % SAMPLE_COUNT


func _report() -> String:
	if frame_times_ms.is_empty():
		return "Collecting samples..."

	var sorted := frame_times_ms.duplicate()
	sorted.sort()
	var total_ms := 0.0
	for frame_ms in sorted:
		total_ms += frame_ms
	var count := sorted.size()
	var viewport_rid := get_viewport().get_viewport_rid()
	var window_size := DisplayServer.window_get_size()

	var lines: Array[String] = [
		(
			"FPS        now %6.1f   avg %6.1f"
			% [Engine.get_frames_per_second(), count * 1000.0 / total_ms]
		),
		"Lows       1%% %6.1f   0.1%% %6.1f" % [_low_fps(sorted, 0.01), _low_fps(sorted, 0.001)],
		(
			"Frame ms   avg %5.2f  min %5.2f  max %5.2f"
			% [total_ms / count, sorted[0], sorted[count - 1]]
		),
		(
			"           p50 %5.2f  p95 %5.2f  p99 %5.2f  p99.9 %5.2f"
			% [
				_percentile(sorted, 0.5),
				_percentile(sorted, 0.95),
				_percentile(sorted, 0.99),
				_percentile(sorted, 0.999)
			]
		),
		(
			"CPU ms     process %5.2f  physics %5.2f  render %5.2f"
			% [
				Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
				Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
				RenderingServer.viewport_get_measured_render_time_cpu(viewport_rid)
			]
		),
		(
			"GPU ms     render %5.2f"
			% RenderingServer.viewport_get_measured_render_time_gpu(viewport_rid)
		),
		(
			"Render     draw calls %d  objects %d  primitives %d"
			% [
				Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
				Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
				Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)
			]
		),
		(
			"Memory     static %.1f MiB  video %.1f MiB"
			% [
				Performance.get_monitor(Performance.MEMORY_STATIC) / BYTES_PER_MIB,
				Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / BYTES_PER_MIB
			]
		),
		(
			"Objects    nodes %d  orphans %d  objects %d"
			% [
				Performance.get_monitor(Performance.OBJECT_NODE_COUNT),
				Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),
				Performance.get_monitor(Performance.OBJECT_COUNT)
			]
		),
		(
			"Physics    active %d  pairs %d  islands %d  tick %d Hz"
			% [
				Performance.get_monitor(Performance.PHYSICS_2D_ACTIVE_OBJECTS),
				Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS),
				Performance.get_monitor(Performance.PHYSICS_2D_ISLAND_COUNT),
				Engine.physics_ticks_per_second
			]
		),
		(
			"Entities   players %d  bullets %d  bulbs %d"
			% [
				get_tree().get_node_count_in_group(Constants.PLAYERS_GROUP),
				get_tree().get_node_count_in_group(Constants.BULLETS_GROUP),
				get_tree().get_node_count_in_group(Constants.BULBS_GROUP)
			]
		),
		(
			"Display    %dx%d  vsync %s  max fps %s"
			% [
				window_size.x,
				window_size.y,
				VSYNC_NAMES[DisplayServer.window_get_vsync_mode()],
				str(Engine.max_fps) if Engine.max_fps > 0 else "unlimited"
			]
		),
		(
			"GPU        %s (%s)"
			% [
				RenderingServer.get_video_adapter_name(),
				RenderingServer.get_current_rendering_method()
			]
		),
		"Window     last %d frames (%.1f s)" % [count, total_ms / 1000.0],
	]
	return "\n".join(lines)


func _percentile(sorted: PackedFloat32Array, fraction: float) -> float:
	return sorted[floori(fraction * (sorted.size() - 1))]


func _low_fps(sorted: PackedFloat32Array, fraction: float) -> float:
	var worst_count := maxi(1, floori(sorted.size() * fraction))
	var worst_ms := 0.0
	for i in worst_count:
		worst_ms += sorted[sorted.size() - 1 - i]
	return worst_count * 1000.0 / worst_ms


func _draw_graph() -> void:
	var size_px := graph.size
	graph.draw_rect(Rect2(Vector2.ZERO, size_px), Color(0, 0, 0, 0.35))
	for target_ms in TARGET_MS:
		var guide_y := _graph_y(target_ms, size_px.y)
		graph.draw_line(Vector2(0, guide_y), Vector2(size_px.x, guide_y), GUIDE_COLOR)

	var count := frame_times_ms.size()
	if count < 2:
		return
	var bar_width := size_px.x / SAMPLE_COUNT
	var oldest := next_sample if count == SAMPLE_COUNT else 0
	for i in count:
		var frame_ms := frame_times_ms[(oldest + i) % count]
		var top := _graph_y(frame_ms, size_px.y)
		var bar := Rect2(i * bar_width, top, maxf(bar_width, 1.0), size_px.y - top)
		graph.draw_rect(bar, _frame_color(frame_ms))


func _graph_y(frame_ms: float, height: float) -> float:
	return height * (1.0 - minf(frame_ms / GRAPH_MAX_MS, 1.0))


func _frame_color(frame_ms: float) -> Color:
	if frame_ms <= TARGET_MS[1]:
		return GOOD_COLOR
	if frame_ms <= TARGET_MS[2]:
		return SLOW_COLOR
	return BAD_COLOR
