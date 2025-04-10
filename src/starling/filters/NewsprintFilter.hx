/**
 *	Copyright (c) 2016 Devon O. Wolfgang
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
 * Creates a funky 'news print'/half tone effect
 * @author Matse
 */
class NewsprintFilter extends FragmentFilter {
	public var size(get, set):Float;
	public var scale(get, set):Float;
	public var angle(get, set):Float;

	private var _size:Float;
	private var _scale:Float;
	private var _angle:Float;

	/**
		Creates a new Newsprint Filter
		@param	size
		@param	scale
		@param	angle
	**/
	public function new(size:Float = 120.0, scale:Float = 3.0, angle:Float = 0.0) {
		this._size = size;
		this._scale = scale;
		this._angle = angle;

		super();
	}

	private function get_size():Float {
		return this._size;
	}

	private function set_size(value:Float):Float {
		this._size = value;
		cast(this.effect, NewsprintEffect).size = value;
		setRequiresRedraw();
		return value;
	}

	private function get_scale():Float {
		return this._scale;
	}

	private function set_scale(value:Float):Float {
		this._scale = value;
		cast(this.effect, NewsprintEffect).scale = value;
		setRequiresRedraw();
		return value;
	}

	private function get_angle():Float {
		return this._angle;
	}

	private function set_angle(value:Float):Float {
		this._angle = value;
		cast(this.effect, NewsprintEffect).angle = value;
		setRequiresRedraw();
		return value;
	}

	override private function createEffect():FilterEffect {
		var effect:NewsprintEffect = new NewsprintEffect();
		effect.size = this._size;
		effect.scale = this._scale;
		effect.angle = this._angle;
		return effect;
	}
}

class NewsprintEffect extends FilterEffect {
	private static var RADIAN:Float = Math.PI / 180;

	public var size:Float;
	public var scale:Float;
	public var angle:Float;

	private var vars:Vector<Float> = Vector.ofArray([1.0, 1.0, 1.0, 1.0]);
	private var constants:Vector<Float> = Vector.ofArray([4.0, 5.0, 10.0, 3.0]);

	override private function createProgram():Program {
		var fragmentShader:String = [
			FilterEffect.tex("ft0", "v0", 0, this.texture),
			"mov ft1, fc0.w",
			"add ft1.x, ft0.x, ft0.y",
			"add ft1.x, ft1.x, ft0.z",
			"div ft1.x, ft1.x, fc1.w",
			"mul ft2, ft1.x, fc1.z",
			"sub ft2, ft2, fc1.y",
			"mov ft5, fc0.w",
			"mov ft5.x, fc0.x",
			"sin ft5.x, ft5.x",
			"mov ft5.y, fc0.x",
			"cos ft5.y, ft5.y",
			"mul ft6, v0, fc0.z",
			"sub ft6, ft6, fc0.w",
			"mov ft7, fc0.w",
			"mul ft7.z, ft5.y, ft6.x",
			"mul ft7.w, ft5.x, ft6.y",
			"sub ft7.x, ft7.z, ft7.w",
			"mul ft7.x, ft7.x, fc0.y",
			"mul ft7.z, ft5.x, ft6.x",
			"mul ft7.w, ft5.y, ft6.y",
			"add ft7.y, ft7.z, ft7.w",
			"mul ft7.y, ft7.y, fc0.y",
			"sin ft6.x, ft7.x",
			"sin ft6.y, ft7.y",
			"mul ft3, ft6.x, ft6.y",
			"mul ft3, ft3, fc1.x",
			"add ft2, ft2, ft3",
			"mov ft2.w, ft0.w",
			"mul ft2.xyz, ft2.xyz, ft2.www",
			"mov oc, ft2"
		].join("\n");

		return Program.fromSource(FilterEffect.STD_VERTEX_SHADER, fragmentShader);
	}

	override private function beforeDraw(context:Context3D):Void {
		this.vars[0] = this.angle * RADIAN;
		this.vars[1] = this.scale;
		this.vars[2] = this.size;

		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.vars, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, this.constants, 1);

		super.beforeDraw(context);
	}
}
