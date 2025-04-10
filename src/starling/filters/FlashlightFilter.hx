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
 * ...
 * @author Matse
 */
class FlashlightFilter extends FragmentFilter {
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var angle(get, set):Float;
	public var outerCone(get, set):Float;
	public var innerCone(get, set):Float;
	public var azimuth(get, set):Float;
	public var attenuation1(get, set):Float;
	public var attenuation2(get, set):Float;
	public var attenuation3(get, set):Float;
	public var red(get, set):Float;
	public var green(get, set):Float;
	public var blue(get, set):Float;

	private var _x:Float;
	private var _y:Float;
	private var _angle:Float;

	public function new(x:Float = 0.0, y:Float = 0.0, angle:Float = 0.0) {
		this._x = x;
		this._y = y;
		this._angle = angle;

		super();
	}

	private function get_x():Float {
		return this._x;
	}

	private function set_x(value:Float):Float {
		this._x = value;
		cast(this.effect, FlashlightEffect).x = value;
		setRequiresRedraw();
		return value;
	}

	private function get_y():Float {
		return this._y;
	}

	private function set_y(value:Float):Float {
		this._y = value;
		cast(this.effect, FlashlightEffect).y = value;
		setRequiresRedraw();
		return value;
	}

	private function get_angle():Float {
		return this._angle;
	}

	private function set_angle(value:Float):Float {
		this._angle = value;
		cast(this.effect, FlashlightEffect).angle = value;
		setRequiresRedraw();
		return value;
	}

	private function get_outerCone():Float {
		return cast(this.effect, FlashlightEffect).outerCone;
	}

	private function set_outerCone(value:Float):Float {
		cast(this.effect, FlashlightEffect).outerCone = value;
		setRequiresRedraw();
		return value;
	}

	private function get_innerCone():Float {
		return cast(this.effect, FlashlightEffect).innerCone;
	}

	private function set_innerCone(value:Float):Float {
		cast(this.effect, FlashlightEffect).innerCone = value;
		setRequiresRedraw();
		return value;
	}

	private function get_azimuth():Float {
		return cast(this.effect, FlashlightEffect).azimuth;
	}

	private function set_azimuth(value:Float):Float {
		cast(this.effect, FlashlightEffect).azimuth = value;
		setRequiresRedraw();
		return value;
	}

	private function get_attenuation1():Float {
		return cast(this.effect, FlashlightEffect).a1;
	}

	private function set_attenuation1(value:Float):Float {
		cast(this.effect, FlashlightEffect).a1 = value;
		setRequiresRedraw();
		return value;
	}

	private function get_attenuation2():Float {
		return cast(this.effect, FlashlightEffect).a2;
	}

	private function set_attenuation2(value:Float):Float {
		cast(this.effect, FlashlightEffect).a2 = value;
		setRequiresRedraw();
		return value;
	}

	private function get_attenuation3():Float {
		return cast(this.effect, FlashlightEffect).a3;
	}

	private function set_attenuation3(value:Float):Float {
		cast(this.effect, FlashlightEffect).a3 = value;
		setRequiresRedraw();
		return value;
	}

	private function get_red():Float {
		return cast(this.effect, FlashlightEffect).r;
	}

	private function set_red(value:Float):Float {
		cast(this.effect, FlashlightEffect).r = value;
		setRequiresRedraw();
		return value;
	}

	private function get_green():Float {
		return cast(this.effect, FlashlightEffect).g;
	}

	private function set_green(value:Float):Float {
		cast(this.effect, FlashlightEffect).g = value;
		setRequiresRedraw();
		return value;
	}

	private function get_blue():Float {
		return cast(this.effect, FlashlightEffect).b;
	}

	private function set_blue(value:Float):Float {
		cast(this.effect, FlashlightEffect).b = value;
		setRequiresRedraw();
		return value;
	}

	override private function createEffect():FilterEffect {
		var effect:FlashlightEffect = new FlashlightEffect();
		effect.x = this._x;
		effect.y = this._y;
		effect.angle = this._angle;
		return effect;
	}
}

class FlashlightEffect extends FilterEffect {
	private static var RADIAN:Float = Math.PI / 180;

	public var x:Float;
	public var y:Float;
	public var angle:Float;

	public var outerCone:Float = 10.0;
	public var innerCone:Float = 50.0;
	public var azimuth:Float = 0.0;

	public var a1:Float = 0.5;
	public var a2:Float = 10.0;
	public var a3:Float = 100.0;

	public var r:Float = 1.0;
	public var g:Float = 1.0;
	public var b:Float = 1.0;

	private var center:Vector<Float> = Vector.ofArray([1.0, 1.0, 0.0, 1.0]);
	private var vars:Vector<Float> = Vector.ofArray([1.0, 1.0, 1.0, 1.0]);
	private var lightColor:Vector<Float> = Vector.ofArray([1.0, 1.0, 1.0, 1.0]);
	private var attenuation:Vector<Float> = Vector.ofArray([0.5, 10.0, 100.0, 1.0]);
	private var smoothStep:Vector<Float> = Vector.ofArray([2.0, 3.0, 1.0, 1.0]);

	override private function createProgram():Program {
		var fragmentShader:String = [
			// azimuth
			"mov ft0.z, fc1.y",
			"sin ft0.z, ft0.z",
			"neg ft0.z, ft0.z",

			// direction
			"mov ft1.x, fc1.y",
			"cos ft1.x, ft1.x",
			"mov ft2.x, fc1.x",
			"cos ft2.y, ft2.x",
			"sin ft2.z, ft2.x",
			"mul ft0.x, ft1.x, ft2.y",
			"mul ft0.y, ft1.x, ft2.z",
			"nrm ft3.xyz, ft0.xyz",

			// distance
			"sub ft2.y, v0.x, fc0.x",
			"mul ft2.y, ft2.y, ft2.y",
			"sub ft2.z, v0.y, fc0.y",
			"mul ft2.z, ft2.z, ft2.z",
			"add ft2.y, ft2.y, ft2.z",
			"sqt ft2.x, ft2.y",

			// shadow
			"mul ft4.y, ft2.x, fc3.y",
			"mul ft4.z, fc3.z, ft2.x",
			"mul ft4.z, ft4.z, ft2.x",
			"add ft4.x, fc3.x, ft4.y",
			"add ft4.x, ft4.x, ft4.z",
			"rcp ft4.x, ft4.x",

			// cones
			"mov ft0.xy, v0.xy",
			"mov ft0.z, fc0.z",
			"mov ft1.xy, fc0.xy",
			"mov ft1.z, fc0.z",
			"sub ft0.xyz, ft0.xyz, ft1.xyz",
			"nrm ft2.xyz, ft0.xyz",
			"mov ft0.x, fc1.z",
			"cos ft0.x, ft0.x",
			"mov ft0.y, fc1.w",
			"cos ft0.y, ft0.y",
			"dp3 ft0.z, ft2.xyz, ft3.xyz",

			// smoothstep
			"sub ft1.x, ft0.z, ft0.y",
			"sub ft1.y, ft0.x, ft0.y",
			"div ft1.x, ft1.x, ft1.y",
			"sat ft0.z, ft1.x",
			"mul ft1.x, fc4.x, ft0.z",
			"sub ft1.x, fc4.y, ft1.x",
			"mul ft0.z, ft0.z, ft1.x",
			"mul ft0.z, ft0.z, ft0.z",

			// shadow
			"mul ft0.xyz, ft0.zzz, ft4.xxx",

			// lightcolor
			"mul ft0.xyz, ft0.xyz, fc2.xyz",

			// Sample
			FilterEffect.tex("ft6", "v0.xy", 0, this.texture),

			"mul ft6.xyz, ft6.xyz, ft0.xyz",
			"mov oc, ft6"

		].join("\n");

		return Program.fromSource(FilterEffect.STD_VERTEX_SHADER, fragmentShader);
	}

	override private function beforeDraw(context:Context3D):Void {
		this.center[0] = (this.x * this.texture.width) / this.texture.root.nativeWidth;
		this.center[1] = (this.y * this.texture.height) / this.texture.root.nativeHeight;

		this.vars[0] = this.angle * RADIAN; // angle
		this.vars[1] = this.azimuth * RADIAN; // azimuth
		this.vars[2] = this.outerCone * RADIAN; // outer cone angle
		this.vars[3] = this.innerCone * RADIAN; // inner cone angle

		this.lightColor[0] = this.r;
		this.lightColor[1] = this.g;
		this.lightColor[2] = this.b;

		this.attenuation[0] = this.a1;
		this.attenuation[1] = this.a2;
		this.attenuation[2] = this.a3;

		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.center, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, this.vars, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, this.lightColor, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, this.attenuation, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, this.smoothStep, 1);

		super.beforeDraw(context);
	}
}
