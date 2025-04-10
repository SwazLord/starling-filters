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
import starling.events.Event;
import starling.filters.FragmentFilter;
import starling.rendering.FilterEffect;
import starling.rendering.Program;

/**
 * Creates a Kaleidoscope Effect
 * @author Matse
 */
class KaleidoscopeFilter extends FragmentFilter {
	public var autoUpdate(get, set):Bool;
	public var levels(get, set):Float;
	public var speed(get, set):Float;
	public var time(get, set):Float;

	/**

		@param	autoUpdate	should effect upate automatically
	**/
	public function new(autoUpdate:Bool = false) {
		super();
		this.autoUpdate = autoUpdate;
	}

	/** Dispose */
	override public function dispose():Void {
		removeEventListener(Event.ENTER_FRAME, onUpdate);
		super.dispose();
	}

	/** Auto Update */
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

	/** Levels */
	private function get_levels():Float {
		return cast(this.effect, KaleidoscopeEffect).levels;
	}

	private function set_levels(value:Float):Float {
		cast(this.effect, KaleidoscopeEffect).levels = value;
		setRequiresRedraw();
		return value;
	}

	/** Speed */
	private function get_speed():Float {
		return cast(this.effect, KaleidoscopeEffect).speed;
	}

	private function set_speed(value:Float):Float {
		cast(this.effect, KaleidoscopeEffect).speed = value;
		setRequiresRedraw();
		return value;
	}

	/** Time */
	private function get_time():Float {
		return cast(this.effect, KaleidoscopeEffect).time;
	}

	private function set_time(value:Float):Float {
		cast(this.effect, KaleidoscopeEffect).time = value;
		setRequiresRedraw();
		return value;
	}

	override private function createEffect():FilterEffect {
		return new KaleidoscopeEffect();
	}

	public function onUpdate(e:Event):Void {
		time += cast(this.effect, KaleidoscopeEffect).speed / 512;
	}
}

class KaleidoscopeEffect extends FilterEffect {
	public var time:Float = 0.0;
	public var speed:Float = 10.0;
	public var levels:Float = 3.5;

	public var fc0:Vector<Float> = Vector.ofArray([1.0, 0.0, Math.PI, 2 * Math.PI]);
	public var fc1:Vector<Float> = Vector.ofArray([1e-10, Math.PI / 2, 0.0, 4.0]);
	public var fc2:Vector<Float> = Vector.ofArray([-1, 1, Math.PI / 3.5, 0.0]);
	public var fc3:Vector<Float> = Vector.ofArray([0.1, 0.2, 2, 0]);

	override private function createProgram():Program {
		var fragmentShader:String = [
			"mov ft2.xy, v0.xy",
			"mov ft2.w, fc2.x",
			"sub ft2.z, fc2.y, ft2.w",
			"mul ft2.z, ft2.z, ft2.x",
			"add ft2.x, ft2.z, fc2.x",

			"sub ft2.z, fc2.y, ft2.w",
			"mul ft2.z, ft2.z, ft2.y",
			"add ft2.y, ft2.z, fc2.x",

			// resolution tweak
			"div ft2.x, ft2.x, fc3.w",

			// Atan2
			"add ft2.x, ft2.x, fc1.x",

			"div ft3.x, ft2.y, ft2.x",
			"neg ft3.y, ft3.x",

			"mul ft4.y, fc1.y, ft3.x",
			"add ft4.z, fc0.x, ft3.x",
			"div ft5.x, ft4.y, ft4.z",

			"mul ft4.y, fc1.y, ft3.y",
			"add ft4.z, fc0.x, ft3.y",
			"div ft5.y, ft4.y, ft4.z",

			"slt ft4.x, ft2.x, fc0.y",
			"slt ft4.y, ft2.y, fc0.y",
			"sub ft4.z, fc0.x, ft4.x",
			"sub ft4.w, fc0.x, ft4.y",

			"mul ft3.x, ft4.z, ft4.w",
			"mul ft3.y, ft4.x, ft4.w",
			"mul ft3.z, ft4.x, ft4.y",
			"mul ft3.w, ft4.z, ft4.y",

			"sub ft4.x, ft5.x, fc0.z",
			"neg ft4.y, ft5.y",
			"mov ft4.z, ft5.x",
			"sub ft4.w, fc0.z, ft5.y",

			"mul ft4, ft4, ft3",

			"add ft4.xy, ft4.xz, ft4.yw",
			"add ft4.x, ft4.x, ft4.y",

			// eo Atan2
			"mul ft0.x, ft2.x, ft2.x",
			"mul ft0.y, ft2.y, ft2.y",
			"add ft0.x, ft0.x, ft0.y",
			"sqt ft0.x, ft0.x",

			"mov ft5.x, fc2.z",
			"div ft5.x, ft5.x, fc1.w",
			"add ft5.x, ft4.x, ft5.x",
			"div ft5.y, ft5.x, fc2.z",
			"frc ft5.y, ft5.y",
			"mul ft5.y, ft5.y, fc2.z",

			"mov ft5.x, fc2.z",
			"div ft5.x, ft5.x fc3.z",
			"sub ft5.x, ft5.y, ft5.x",
			"abs ft5.x, ft5.x",
			"add ft5.y, ft0.x, fc2.y",
			"div ft4.x, ft5.x, ft5.y",

			"mul ft0.x, ft0.x, fc3.x",
			"cos ft1.x, ft4.x",
			"mul ft1.x, ft1.x, ft0.x",
			"sin ft1.y, ft4.x",
			"mul ft1.y, ft1.y, ft0.x",

			"mov ft4.x, fc2.w",

			"cos ft2.x, ft4.x",
			"sin ft2.y, ft4.x",

			"mul ft3.x, ft2.y, fc3.y",
			"mul ft3.y, ft1.y, ft2.y",
			"mul ft3.z, ft1.x, ft2.x",
			"sub ft6.x, ft3.z, ft3.y",
			"sub ft6.x, ft6.x, ft3.x",

			"mul ft3.x, ft2.x, fc3.y",
			"mul ft3.y, ft1.y, ft2.x",
			"mul ft3.z, ft1.x, ft2.y",
			"add ft6.y, ft3.z, ft3.y",
			"add ft6.y, ft6.y, ft3.x",

			"mul ft6.xy, ft6.xy, fc3.z",
			FilterEffect.tex("oc", "ft6.xy", 0, this.texture)
		].join("\n");

		return Program.fromSource(FilterEffect.STD_VERTEX_SHADER, fragmentShader);
	}

	override private function beforeDraw(context:Context3D):Void {
		super.beforeDraw(context);

		fc2[2] = Math.PI / levels;
		fc2[3] = time;
		fc3[3] = texture.height / texture.width;

		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.fc0, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, this.fc1, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, this.fc2, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 3, this.fc3, 1);
	}
}
