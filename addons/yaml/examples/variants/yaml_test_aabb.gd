extends YAMLTest
## Test suite for AABB YAML serialization and styling

# Test values with different complexity
var test_values = {
	"simple": AABB(Vector3(1, 2, 3), Vector3(4, 5, 6)),
	"zero": AABB(Vector3.ZERO, Vector3.ZERO),
	"negative": AABB(Vector3(-1, -2, -3), Vector3(4, 5, 6)),
	"large": AABB(Vector3(1000, 2000, 3000), Vector3(4000, 5000, 6000)),
	"decimal": AABB(Vector3(1.5, 2.5, 3.5), Vector3(4.5, 5.5, 6.5)),
}

func _init():
	test_name = "🧩 AABB YAML Tests"

## Test basic serialization/deserialization without styles
func test_basic_serialization() -> void:
	for name in test_values:
		var aabb = test_values[name]
		var result = YAML.stringify(aabb)

		assert_stringify_success(result, name)
		if result.has_error():
			continue

		print_rich("• %s: %s" % [name, truncate(result.get_data())])

		# Parse back and verify
		var parse_result = YAML.parse(result.get_data())
		assert_roundtrip(parse_result, aabb, is_aabb_equal, name)

## Test different container forms (map vs sequence)
func test_container_forms() -> void:
	var aabb = AABB(Vector3(1, 2, 3), Vector3(4, 5, 6))

	# Map form (default)
	var map_style = YAML.create_style()
	map_style.set_container_form(YAMLStyle.FORM_MAP)
	var map_result = YAML.stringify(aabb, map_style)

	assert_stringify_success(map_result, "map form")
	if not map_result.has_error():
		print_rich("• Map form:")
		print_rich(map_result.get_data())

		# Verify it contains map indicators
		assert_yaml_has_feature(map_result.get_data(), "position:", "Contains 'position:' key")

	# Sequence form
	var seq_style = YAML.create_style()
	seq_style.set_container_form(YAMLStyle.FORM_SEQ)
	var seq_result = YAML.stringify(aabb, seq_style)

	assert_stringify_success(seq_result, "sequence form")
	if not seq_result.has_error():
		print_rich("• Sequence form:")
		print_rich(seq_result.get_data())

		# Verify it doesn't contain map indicators
		assert_yaml_lacks_feature(seq_result.get_data(), "position:", "Does not contain 'position:' key")

	# Test roundtrip for both forms
	assert_roundtrip(YAML.parse(map_result.get_data()), aabb, is_aabb_equal, "map form")
	assert_roundtrip(YAML.parse(seq_result.get_data()), aabb, is_aabb_equal, "sequence form")

## Test different flow styles (block vs flow)
func test_flow_styles() -> void:
	var aabb = AABB(Vector3(1, 2, 3), Vector3(4, 5, 6))

	# Test flow style (compact)
	var flow_style = YAML.create_style()
	flow_style.set_flow_style(YAMLStyle.FLOW_SINGLE)
	var flow_result = YAML.stringify(aabb, flow_style)

	assert_stringify_success(flow_result, "flow style")
	if not flow_result.has_error():
		print_rich("• Flow style:")
		print_rich(flow_result.get_data())

		# Verify it contains flow indicators (brackets)
		assert_yaml_has_feature(flow_result.get_data(), "{", "Contains opening brace")
		assert_yaml_has_feature(flow_result.get_data(), "}", "Contains closing brace")

	# Test block style (expanded)
	var block_style = YAML.create_style()
	block_style.set_flow_style(YAMLStyle.FLOW_NONE)
	var block_result = YAML.stringify(aabb, block_style)

	assert_stringify_success(block_result, "block style")
	if not block_result.has_error():
		print_rich("• Block style:")
		print_rich(block_result.get_data())

		# Verify indentation
		assert_yaml_has_feature(block_result.get_data(), "\n ", "Contains proper indentation")

	# Test roundtrip for both styles
	assert_roundtrip(YAML.parse(flow_result.get_data()), aabb, is_aabb_equal, "flow style")
	assert_roundtrip(YAML.parse(block_result.get_data()), aabb, is_aabb_equal, "block style")

## Test nested styles for position and size components
func test_nested_styles() -> void:
	var aabb = AABB(Vector3(1, 2, 3), Vector3(4, 5, 6))

	# Create parent style
	var parent_style = YAML.create_style()

	# Create different styles for position and size
	var position_style = YAML.create_style()
	position_style.set_flow_style(YAMLStyle.FLOW_SINGLE)

	var size_style = YAML.create_style()
	size_style.set_flow_style(YAMLStyle.FLOW_NONE)

	# Apply nested styles
	parent_style.set_child("position", position_style)
	parent_style.set_child("size", size_style)

	var result = YAML.stringify(aabb, parent_style)

	assert_stringify_success(result, "nested styles")
	if not result.has_error():
		print_rich("• Nested styles (position=flow, size=block):")
		print_rich(result.get_data())

		# Verify position has flow style and size has block style
		assert_yaml_has_feature(result.get_data(), "position: {", "Position has flow style")
		assert_true(
			result.get_data().find("size:") != -1 && result.get_data().find("size: {") == -1,
			"Size has block style"
		)

	# Test roundtrip
	assert_roundtrip(YAML.parse(result.get_data()), aabb, is_aabb_equal, "nested styles")

## Test roundtrip conversion with style detection enabled
func test_roundtrip_with_styles() -> void:
	var aabb = AABB(Vector3(1, 2, 3), Vector3(4, 5, 6))

	# Create a style with specific formatting
	var original_style = YAML.create_style()
	original_style.set_flow_style(YAMLStyle.FLOW_SINGLE)

	# Emit YAML with the style
	var emit_result = YAML.stringify(aabb, original_style)
	assert_stringify_success(emit_result, "initial stringify")
	if emit_result.has_error():
		return

	var yaml_text = emit_result.get_data()
	print_rich("• Original YAML (with flow style):")
	print_rich(yaml_text)

	# Parse with style detection enabled
	var parse_result = YAML.parse(yaml_text, true)  # true enables style detection
	assert_parse_success(parse_result, "parse with style detection")
	if parse_result.has_error():
		return

	# Check if style was detected
	if not parse_result.has_style():
		print_rich("[color=yellow]⚠ No style was detected[/color]")
	else:
		print_rich("[color=green]✓ Style detected successfully[/color]")

		# Get the detected style and data
		var detected_style = parse_result.get_style()
		var parsed_aabb = parse_result.get_data()

		# Modify the AABB
		var modified_aabb = AABB(parsed_aabb.position + Vector3(10, 10, 10), parsed_aabb.size)

		# Re-emit with the detected style
		var re_emit_result = YAML.stringify(modified_aabb, detected_style)
		assert_stringify_success(re_emit_result, "re-stringify with detected style")
		if re_emit_result.has_error():
			return

		print_rich("• Re-emitted YAML (with preserved style):")
		print_rich(re_emit_result.get_data())

		# Verify the style was preserved (flow style should be maintained)
		assert_yaml_has_feature(re_emit_result.get_data(), "{", "Flow style was preserved (opening brace)")
		assert_yaml_has_feature(re_emit_result.get_data(), "}", "Flow style was preserved (closing brace)")

## Helper function to check if AABBs are equal (with floating point precision)
func is_aabb_equal(a: AABB, b: AABB) -> bool:
	return a.position.is_equal_approx(b.position) && a.size.is_equal_approx(b.size)
