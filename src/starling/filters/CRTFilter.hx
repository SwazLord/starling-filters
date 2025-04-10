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

import flash.Vector;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DProgramType;
import starling.events.Event;
import starling.filters.FragmentFilter;
import starling.rendering.FilterEffect;
import starling.rendering.Program;

/**
 * ...
 * @author Matse
 */
class CRTFilter extends FragmentFilter {
	public var autoUpdate(get, set):Bool;
	public var red(get, set):Float;
	public var green(get, set):Float;
	public var blue(get, set):Float;
	public var brightness(get, set):Float;
	public var distortion(get, set):Float;
	public var frequency(get, set):Float;
	public var intensity(get, set):Float;
	public var speed(get, set):Float;

	public function new(autoUpdate:Bool = true) {
		super();
		this.autoUpdate = autoUpdate;
	}

	override public function dispose():Void {
		removeEventListener(Event.ENTER_FRAME, onUpdate);
		super.dispose();
	}

	private function get_autoUpdate():Bool {
		return hasEventListener(Event.ENTER_FRAME);
	}

	private function set_autoUpdate(value:Bool):Bool {
		if (value) {
			addEventListener(Event.ENTER_FRAME, onUpdate);
		} else {
			removeEventListener(Event.ENTER_FRAME, onUpdate);
		}
		return value;
	}

	private function get_red():Float {
		return cast(this.effect, CRTEffect).fc3[1];
	}

	private function set_red(value:Float):Float {
		cast(this.effect, CRTEffect).fc3[1] = value;
		setRequiresRedraw();
		return value;
	}

	private function get_green():Float {
		return cast(this.effect, CRTEffect).fc3[2];
	}

	private function set_green(value:Float):Float {
		cast(this.effect, CRTEffect).fc3[2] = value;
		setRequiresRedraw();
		return value;
	}

	private function get_blue():Float {
		return cast(this.effect, CRTEffect).fc3[3];
	}

	private function set_blue(value:Float):Float {
		cast(this.effect, CRTEffect).fc3[3] = value;
		setRequiresRedraw();
		return value;
	}

	private function get_brightness():Float {
		return cast(this.effect, CRTEffect).fc4[0];
	}

	private function set_brightness(value:Float):Float {
		cast(this.effect, CRTEffect).fc4[0] = value;
		setRequiresRedraw();
		return value;
	}

	private function get_distortion():Float {
		return cast(this.effect, CRTEffect).fc4[1];
	}

	private function set_distortion(value:Float):Float {
		cast(this.effect, CRTEffect).fc4[1] = value;
		setRequiresRedraw();
		return value;
	}

	private function get_frequency():Float {
		return cast(this.effect, CRTEffect).fc4[2];
	}

	private function set_frequency(value:Float):Float {
		cast(this.effect, CRTEffect).fc4[2] = value;
		setRequiresRedraw();
		return value;
	}

	private function get_intensity():Float {
		return cast(this.effect, CRTEffect).fc4[3];
	}

	private function set_intensity(value:Float):Float {
		cast(this.effect, CRTEffect).fc4[3] = value;
		setRequiresRedraw();
		return value;
	}

	private function get_speed():Float {
		return cast(this.effect, CRTEffect).speed;
	}

	private function set_speed(value:Float):Float {
		cast(this.effect, CRTEffect).speed = value;
		onUpdate(null);
		return value;
	}

	override private function createEffect():FilterEffect {
		return new CRTEffect();
	}

	public function onUpdate(e:Event):Void {
		cast(this.effect, CRTEffect).time = cast(this.effect, CRTEffect).speed / 512;
		setRequiresRedraw();
	}
}

class CRTEffect extends FilterEffect {
	public var time:Float = 0.0;
	public var speed:Float = 10.0;

	public var fc0:Vector<Float> = Vector.ofArray([0.0, 0.25, 0.5, 1.0]);
	public var fc1:Vector<Float> = Vector.ofArray([Math.sqrt(0.5), 2.5, 1.55, Math.PI]);
	public var fc2:Vector<Float> = Vector.ofArray([2.2, 1.4, 2.0, 0.2]);
	public var fc3:Vector<Float> = Vector.ofArray([3.5, 0.7, 1, 0.7]);
	public var fc4:Vector<Float> = Vector.ofArray([1.0, 0.0, 256.0, 4.0]);
	public var fc5:Vector<Float> = Vector.ofArray([1, 1, 1, 0.0000001]);

	#if commonjs
	private static function __init__() {}
	#end

	override private function createProgram():Program {
		var fragmentShader:String = [
			"mov ft0.xy, v0.xy",
			"sub ft0.xy, v0.xy, fc0.zz",

			"mov ft0.z, fc0.x",
			"dp3 ft0.w, ft0.xyz, ft0.xyz",
			"mul ft0.z, ft0.w, fc4.y",

			"add ft0.w, fc0.w, ft0.z",
			"mul ft0.w, ft0.w, ft0.z",
			"mul ft0.xy, ft0.ww, ft0.xy",
			"add ft0.xy, ft0.xy, v0.xy",
			FilterEffect.tex("ft2", "ft0.xy", 0, this.texture),

			"sge ft3.x, ft0.x, fc0.x",
			"sge ft3.y, ft0.y, fc0.x",
			"slt ft3.z, ft0.x, fc0.w",
			"slt ft3.w, ft0.y, fc0.w",
			"mul ft3.x, ft3.x, ft3.y",
			"mul ft3.x, ft3.x, ft3.z",
			"mul ft3.x, ft3.x, ft3.w",

			"max ft4.x, ft2.x, ft2.y",
			"max ft4.x, ft4.x, ft2.z",
			"min ft4.y, ft2.x, ft2.y",
			"min ft4.y, ft4.y, ft2.z",
			"div ft4.y, ft4.y, fc2.z",
			"add ft4.x, ft4.x, ft4.y",
			"mov ft4.xyzw, ft4.xxxx	",
			"mul ft4.xyzw, ft4.xyzw, ft3.xxxx",

			"mov ft2.x, ft0.y",
			"mul ft2.x, ft2.x, fc1.w",
			"mul ft2.x, ft2.x, fc4.z",
			"sin ft2.x, ft2.x",
			"mul ft2.x, ft2.x, fc0.y",
			"sat ft2.x, ft2.x",
			"mul ft2.x, ft2.x, fc0.y",
			"mul ft2.x, ft2.x, fc4.w",
			"add ft2.x, ft2.x, fc0.w",

			"mov ft2.y, fc0.w",

			"mov ft2.z, fc5.x",
			"mul ft2.z, ft2.z, fc0.z",
			"add ft2.z, ft2.z, ft0.y",
			"mul ft2.z, ft2.z, fc1.w",
			"mul ft2.z, ft2.z, fc3.x",
			"sin ft2.z, ft2.z",
			"mul ft2.z, ft2.z, fc2.w",
			"add ft2.y, ft2.y, ft2.z",

			"add ft2.z, ft0.y, fc5.x",
			"mul ft2.z, ft2.z, fc1.w",
			"mul ft2.z, ft2.z, fc2.z",
			"sin ft2.z, ft2.z",
			"mul ft2.z, ft2.z, fc2.w",
			"add ft2.y, ft2.y, ft2.z",

			"mul ft2.y, ft2.y, fc4.x",

			"mul ft0.xyz, ft4.xyz, ft3.xxx",
			"mul ft0.xyz, ft0.xyz, fc3.yzw",
			"mul ft0.xyz, ft0.xyz, ft2.xxx",
			"mul ft0.xyz, ft0.xyz, ft2.yyy",

			"mul ft1.x, ft0.x, ft0.y",
			"mul ft1.x, ft1.x, ft0.z",

			// set output alpha to 1 or 0 depending on multiplied out color (solid black will have 0 alpha)
			"sge ft0.w, ft1.x, fc5.w",
			"mul ft0.xyz, ft0.xyz, ft0.www",
			"mov oc, ft0"

		].join("\n");

		return Program.fromSource(FilterEffect.STD_VERTEX_SHADER, fragmentShader);
	}

	override private function beforeDraw(context:Context3D):Void {
		super.beforeDraw(context);

		fc5[0] = time;

		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.fc0, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, this.fc1, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, this.fc2, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, this.fc3, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 4, this.fc4, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 5, this.fc5, 1);
	}
}
