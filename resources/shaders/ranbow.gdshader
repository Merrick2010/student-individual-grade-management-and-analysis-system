shader_type canvas_item;


#include "res://resources/shaders/includes/algorithm.gdshaderinc"


// 可调节参数（在编辑器中显示）
uniform float speed: hint_range(0.0, 1.0) = 0.5;      // 颜色流动速度
uniform float saturation: hint_range(0.0, 1.0) = 1.0; // 饱和度（1为最鲜艳）
uniform float value: hint_range(0.0, 1.0) = 1.0;      // 明度（1为最亮）
uniform bool vertical = false;                  // true=垂直渐变，false=水平
uniform vec4 shadow_color: source_color; // 阴影颜色，用于排除彩色影响


void fragment() {
    // 根据方向选择渐变轴
    float axis = vertical ? UV.y : UV.x;
    // 色调从0到1循环，并随时间偏移
    float hue = fract(axis + TIME * speed);
    // 生成HSV颜色并转为RGB
    vec3 color = hsv_to_rgb(vec3(hue, saturation, value));

	if (COLOR != shadow_color) {
		COLOR = vec4(color, texture(TEXTURE, UV).a);
	}
}