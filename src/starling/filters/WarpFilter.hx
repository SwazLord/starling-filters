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
 * Creates a warped image effect
 * @author Matse
 */
class WarpFilter extends FragmentFilter {
	public var l1(get, set):Float;
	public var l2(get, set):Float;
	public var l3(get, set):Float;
	public var l4(get, set):Float;
	public var r1(get, set):Float;
	public var r2(get, set):Float;
	public var r3(get, set):Float;
	public var r4(get, set):Float;

	private var _l1:Float;
	private var _l2:Float;
	private var _l3:Float;
	private var _l4:Float;
	private var _r1:Float;
	private var _r2:Float;
	private var _r3:Float;
	private var _r4:Float;

	public function new() {
		this._l1 = this._l2 = this._l3 = this._l4 = 0.0;
		this._r1 = this._r2 = this._r3 = this._r4 = 1.0;
		super();
	}

	/** Top left control */
	private function get_l1():Float {
		return this._l1;
	}

	private function set_l1(value:Float):Float {
		this._l1 = value;
		cast(this.effect, WarpEffect).l1 = value;
		setRequiresRedraw();
		return value;
	}

	/** Top middle left control */
	private function get_l2():Float {
		return this._l2;
	}

	private function set_l2(value:Float):Float {
		this._l2 = value;
		cast(this.effect, WarpEffect).l2 = value;
		setRequiresRedraw();
		return value;
	}

	/** Bottom middle left control */
	private function get_l3():Float {
		return this._l3;
	}

	private function set_l3(value:Float):Float {
		this._l3 = value;
		cast(this.effect, WarpEffect).l3 = value;
		setRequiresRedraw();
		return value;
	}

	/** Bottom left control */
	private function get_l4():Float {
		return this._l4;
	}

	private function set_l4(value:Float):Float {
		this._l4 = value;
		cast(this.effect, WarpEffect).l4 = value;
		setRequiresRedraw();
		return value;
	}

	/** Top right control */
	private function get_r1():Float {
		return this._r1;
	}

	private function set_r1(value:Float):Float {
		this._r1 = value;
		cast(this.effect, WarpEffect).r1 = value;
		setRequiresRedraw();
		return value;
	}

	/** Top middle right control */
	private function get_r2():Float {
		return this._r2;
	}

	private function set_r2(value:Float):Float {
		this._r2 = value;
		cast(this.effect, WarpEffect).r2 = value;
		setRequiresRedraw();
		return value;
	}

	/** Bottom middle right control */
	private function get_r3():Float {
		return this._r3;
	}

	private function set_r3(value:Float):Float {
		this._r3 = value;
		cast(this.effect, WarpEffect).r3 = value;
		setRequiresRedraw();
		return value;
	}

	/** Bottom right control */
	private function get_r4():Float {
		return this._r4;
	}

	private function set_r4(value:Float):Float {
		this._r4 = value;
		cast(this.effect, WarpEffect).r4 = value;
		setRequiresRedraw();
		return value;
	}

	override private function createEffect():FilterEffect {
		var effect:WarpEffect = new WarpEffect();
		effect.l1 = this._l1;
		effect.l2 = this._l2;
		effect.l3 = this._l3;
		effect.l4 = this._l4;
		effect.r1 = this._r1;
		effect.r2 = this._r2;
		effect.r3 = this._r3;
		effect.r4 = this._r4;
		return effect;
	}
}

class WarpEffect extends FilterEffect {
	private var mLeft:Vector<Float> = Vector.ofArray([0.0, 0.0, 0.0, 0.0]);
	private var mRight:Vector<Float> = Vector.ofArray([1.0, 1.0, 1.0, 1.0]);
	private var mVars:Vector<Float> = Vector.ofArray([1.0, 2.0, 3.0, 0.0]);

	public var l1:Float;
	public var l2:Float;
	public var l3:Float;
	public var l4:Float;
	public var r1:Float;
	public var r2:Float;
	public var r3:Float;
	public var r4:Float;

	override private function createProgram():Program {
		var fragmentShader:String = [
			"mov ft0.xy, v0.xy",
			"mov ft1.x, fc2.x",
			"sub ft1.x, ft1.x, ft0.y",
			"pow ft1.x, ft1.x, fc2.z",
			"mov ft1.y, fc2.x",
			"sub ft1.y, ft1.y, ft0.y",
			"pow ft1.y, ft1.y, fc2.y",
			"mul ft1.y, ft1.y, fc2.z",
			"mul ft1.y, ft1.y, ft0.y",
			"mov ft1.z, fc2.x",
			"sub ft1.z, ft1.z, ft0.y",
			"mul ft1.z, ft1.z, fc2.z",
			"mul ft1.z, ft1.z, ft0.y",
			"mul ft1.z, ft1.z, ft0.y",
			"pow ft1.w, ft0.y, fc2.z",
			"mul ft2.x, ft1.x, fc0.x",
			"mul ft2.y, ft1.y, fc0.y",
			"mul ft2.z, ft1.z, fc0.z",
			"mul ft2.w, ft1.w, fc0.w",
			"add ft2.x, ft2.x, ft2.y",
			"add ft2.x, ft2.x, ft2.z",
			"add ft2.x, ft2.x, ft2.w",
			"mul ft3.x, ft1.x, fc1.x",
			"mul ft3.y, ft1.y, fc1.y",
			"mul ft3.z, ft1.z, fc1.z",
			"mul ft3.w, ft1.w, fc1.w",
			"add ft3.x, ft3.x, ft3.y",
			"add ft3.x, ft3.x, ft3.z",
			"add ft3.x, ft3.x, ft3.w",
			"sub ft4.x, ft0.x, ft2.x",
			"sub ft4.y, ft3.x, ft2.x",
			"div ft4.x, ft4.x, ft4.y",
			"mov ft4.y, ft0.y",
			FilterEffect.tex("ft5", "ft4.xy", 0, this.texture),

			// Kill off pixels out of range
			"sge ft6.x, ft0.x, ft2.x",
			"sub ft6.w, ft6.x, fc2.x",
			"kil ft6.w",

			"slt ft6.y, ft0.x, ft3.x",
			"sub ft6.w, ft6.y, fc2.x",
			"kil ft6.w",

			"mov oc, ft5"
		].join("\n");

		return Program.fromSource(FilterEffect.STD_VERTEX_SHADER, fragmentShader);
	}

	override private function beforeDraw(context:Context3D):Void {
		super.beforeDraw(context);

		this.mLeft[0] = this.l1;
		this.mLeft[1] = this.l2;
		this.mLeft[2] = this.l3;
		this.mLeft[3] = this.l4;

		this.mRight[0] = this.r1;
		this.mRight[1] = this.r2;
		this.mRight[2] = this.r3;
		this.mRight[3] = this.r4;

		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, mLeft, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, mRight, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, mVars, 1);
	}
}
