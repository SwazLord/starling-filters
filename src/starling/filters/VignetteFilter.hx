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
 * Creates a Vignette effect on images with an option sepia tone
 * @author Matse
 */
class VignetteFilter extends FragmentFilter {
	public var centerX(get, set):Float;
	public var centerY(get, set):Float;
	public var amount(get, set):Float;
	public var radius(get, set):Float;
	public var size(get, set):Float;
	public var useSepia(get, set):Bool;

	private var _centerX:Float;
	private var _centerY:Float;
	private var _amount:Float;
	private var _radius:Float;
	private var _size:Float;
	private var _useSepia:Bool;

	public function new(size:Float = 0.5, radius:Float = 1.0, amount:Float = 0.7, cx:Float = 0.5, cy:Float = 0.5, sepia:Bool = true) {
		this._centerX = cx;
		this._centerY = cy;
		this._amount = amount;
		this._radius = radius;
		this._size = size;
		this._useSepia = sepia;
		super();
	}

	/** Center X */
	private function get_centerX():Float {
		return this._centerX;
	}

	private function set_centerX(value:Float):Float {
		this._centerX = value;
		cast(this.effect, VignetteEffect).centerX = value;
		setRequiresRedraw();
		return value;
	}

	/** Center Y */
	private function get_centerY():Float {
		return this._centerY;
	}

	private function set_centerY(value:Float):Float {
		this._centerY = value;
		cast(this.effect, VignetteEffect).centerY = value;
		setRequiresRedraw();
		return value;
	}

	/** Amount */
	private function get_amount():Float {
		return this._amount;
	}

	private function set_amount(value:Float):Float {
		this._amount = value;
		cast(this.effect, VignetteEffect).amount = value;
		setRequiresRedraw();
		return value;
	}

	/** Radius */
	private function get_radius():Float {
		return this._radius;
	}

	private function set_radius(value:Float):Float {
		this._radius = value;
		cast(this.effect, VignetteEffect).radius = value;
		setRequiresRedraw();
		return value;
	}

	/** Size */
	private function get_size():Float {
		return this._size;
	}

	private function set_size(value:Float):Float {
		this._size = value;
		cast(this.effect, VignetteEffect).size = value;
		setRequiresRedraw();
		return value;
	}

	/** Use Sepia */
	private function get_useSepia():Bool {
		return this._useSepia;
	}

	private function set_useSepia(value:Bool):Bool {
		this._useSepia = value;
		cast(this.effect, VignetteEffect).useSepia = value;
		setRequiresRedraw();
		return value;
	}

	override private function createEffect():FilterEffect {
		var effect:VignetteEffect = new VignetteEffect();
		effect.centerX = this._centerX;
		effect.centerY = this._centerY;
		effect.amount = this._amount;
		effect.radius = this._radius;
		effect.size = this._size;
		effect.useSepia = this._useSepia;
		return effect;
	}
}

class VignetteEffect extends FilterEffect {
	public var centerX:Float;
	public var centerY:Float;
	public var amount:Float;
	public var radius:Float;
	public var size:Float;
	public var useSepia:Bool;

	private var center:Vector<Float> = Vector.ofArray([1.0, 1.0, 1.0, 1.0]);
	private var vars:Vector<Float> = Vector.ofArray([0.5, 0.5, 0.5, 0.5]);

	private var sepia1:Vector<Float> = Vector.ofArray([0.393, 0.769, 0.189, 0.000]);
	private var sepia2:Vector<Float> = Vector.ofArray([0.349, 0.686, 0.168, 0.000]);
	private var sepia3:Vector<Float> = Vector.ofArray([0.272, 0.534, 0.131, 0.000]);

	private var noSepia1:Vector<Float> = Vector.ofArray([1.0, 0.0, 0.0, 0.000]);
	private var noSepia2:Vector<Float> = Vector.ofArray([0.0, 1.0, 0.0, 0.000]);
	private var noSepia3:Vector<Float> = Vector.ofArray([0.0, 0.0, 1.0, 0.000]);

	override private function createProgram():Program {
		var fragmentShader:String = [
			"sub ft0.xy, v0.xy, fc0.xy",
			"mov ft2.x, fc1.w",
			"mul ft2.x, ft2.x, fc1.z",
			"sub ft3.xy, ft0.xy, ft2.x",
			"mul ft4.x, ft3.x, ft3.x",
			"mul ft4.y, ft3.y, ft3.y",
			"add ft4.x, ft4.x, ft4.y",
			"sqt ft4.x, ft4.x",
			"dp3 ft4.y, ft2.xx, ft2.xx",
			"sqt ft4.y, ft4.y",
			"div ft5.x, ft4.x, ft4.y",
			"pow ft5.y, ft5.x, fc1.y",
			"mul ft5.z, fc1.x, ft5.y",
			"sat ft5.z, ft5.z",
			"min ft5.z, ft5.z, fc0.z",
			"sub ft6, fc0.z, ft5.z",
			FilterEffect.tex("ft1", "v0", 0, this.texture),
			// sepia
			"dp3 ft2.x, ft1, fc2",
			"dp3 ft2.y, ft1, fc3",
			"dp3 ft2.z, ft1, fc4",

			"mul ft6.xyz, ft6.xyz, ft2.xyz",
			"mov ft6.w, ft1.w",
			"mov oc, ft6",
		].join("\n");

		return Program.fromSource(FilterEffect.STD_VERTEX_SHADER, fragmentShader);
	}

	override private function beforeDraw(context:Context3D):Void {
		var halfSize:Float = this.size * 0.5;
		this.center[0] = this.centerX - halfSize;
		this.center[1] = this.centerY - halfSize;

		this.vars[0] = this.amount;
		this.vars[1] = this.radius;
		this.vars[3] = this.size;

		// to sepia or not to sepia
		var s1:Vector<Float> = this.useSepia ? this.sepia1 : this.noSepia1;
		var s2:Vector<Float> = this.useSepia ? this.sepia2 : this.noSepia2;
		var s3:Vector<Float> = this.useSepia ? this.sepia3 : this.noSepia3;

		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.center, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, this.vars, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, s1, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, s2, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, s3, 1);

		super.beforeDraw(context);
	}
}
