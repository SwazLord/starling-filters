/**
 *	Copyright (c) 2017 Devon O. Wolfgang & William Erndt
 *
 *	Permission is hereby granted, free of charge, to any person obtaining a copy
 *	of this software and associated documentation files (the "Software"), to deal
 *	in the Software without restriction, including without limitation the rights
 *	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *	copies of the Software, and to permit persons to whom the Software is
 *	furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in
 *	all copies or substantial portions of the Software.
 *
 *	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 *	THE SOFTWARE.
 */

package starling.filters;

import openfl.Vector;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DProgramType;
import starling.filters.FragmentFilter;
import starling.rendering.FilterEffect;
import starling.rendering.Program;

/**
 * ...
 * @author Matse
 */
class LineGlitchFilter extends FragmentFilter {
	public var size(get, set):Float;
	public var angle(get, set):Float;
	public var distance(get, set):Float;

	private var _size:Float;
	private var _angle:Float;
	private var _distance:Float;

	public function new(size:Float = 2, angle:Float = 45, distance:Float = 0.01) {
		this._size = size;
		this._angle = angle;
		this._distance = distance;
		this.padding.setTo(1, 1, 1, 1);

		super();
	}

	private function get_size():Float {
		return this._size;
	}

	private function set_size(value:Float):Float {
		// size cannot be <= 0
		if (value <= 0)
			value = 1;

		this._size = value;
		cast(this.effect, LineGlitchEffect)._size = value;
		setRequiresRedraw();
		return value;
	}

	private function get_angle():Float {
		return this._angle;
	}

	private function set_angle(value:Float):Float {
		this._angle = value;
		cast(this.effect, LineGlitchEffect)._angle = value;
		setRequiresRedraw();
		return value;
	}

	private function get_distance():Float {
		return this._distance;
	}

	private function set_distance(value:Float):Float {
		this._distance = value;
		cast(this.effect, LineGlitchEffect)._distance = value;
		setRequiresRedraw();
		return value;
	}

	override private function createEffect():FilterEffect {
		var effect:LineGlitchEffect = new LineGlitchEffect();
		effect._size = this._size;
		effect._angle = this._angle;
		effect._distance = this._distance;
		return effect;
	}
}

class LineGlitchEffect extends FilterEffect {
	private static var RADIAN:Float = Math.PI / 180;

	private var fc0:Vector<Float> = Vector.ofArray([1.0, 1.0, 1.0, 2.0]);

	public var _size:Float;
	public var _angle:Float;
	public var _distance:Float;

	override private function createProgram():Program {
		var fragmentShader:String = [
			"mov ft2.x, fc0.y",
			"cos ft2.x, ft2.x",
			"mov ft2.y, fc0.y",
			"sin ft2.y, ft2.y",

			"mul ft2.z, v0.x, ft2.x",
			"mul ft1.x, v0.y, ft2.y",
			"add ft1.x, ft1.x, ft2.z",

			"neg ft2.y, ft2.y",
			"mul ft3.x, fc0.z, ft2.y",
			"mul ft3.y, fc0.z, ft2.x",

			"mov ft4.x, fc0.x",
			"mul ft4.x, ft4.x, fc0.w",

			"div ft5.x, ft1.x, ft4.x",
			"frc ft5.x, ft5.x",
			"mul ft5.x, ft5.x, ft4.x",

			"sub ft1.xy, v0.xy, ft3.xy",
			FilterEffect.tex("ft1", "ft1.xy", 0, this.texture),

			"add ft2.xy, v0.xy, ft3.xy",

			FilterEffect.tex("ft2", "ft2.xy", 0, this.texture),

			"sge ft6, fc0.x, ft5.x",
			"mul ft6, ft6, ft1",

			"slt ft4, fc0.x, ft5.x",
			"mul ft4, ft4, ft2",

			"add ft6, ft6, ft4",
			"mov oc, ft6"
		].join("\n");

		return Program.fromSource(FilterEffect.STD_VERTEX_SHADER, fragmentShader);
	}

	override private function beforeDraw(context:Context3D):Void {
		super.beforeDraw(context);

		// average out size
		var s:Float = (this.texture.width + this.texture.height) * 0.5;
		this.fc0[0] = this._size / s;
		this.fc0[1] = this._angle * RADIAN;
		this.fc0[2] = this._distance;

		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.fc0, 1);
	}
}
