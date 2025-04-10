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
 * Creates a sine wave image effect
 * @author Matse
 */
class SineWaveFilter extends FragmentFilter {
	private static inline var MIN_PADDING:Int = 25;

	public var amplitude(get, set):Float;
	public var frequency(get, set):Float;
	public var ticker(get, set):Float;
	public var alpha(get, set):Float;
	public var isHorizontal(get, set):Bool;

	private var _amplitude:Float;
	private var _ticker:Float;
	private var _frequency:Float;
	private var _isHorizontal:Bool = true;
	private var _alpha:Float = 1.0;

	/**
		Create a new SineWaveFilter
		@param	amplitude	Amplitude of sine wave (for best result, pass the largest expected amount)
		@param	frequency	Frequency of sine wave
		@param	ticker		Time ticker (use for animation)
	**/
	public function new(amplitude:Float = 0.0, frequency:Float = 0.0, ticker:Float = 0.0) {
		this._amplitude = amplitude;
		this._frequency = frequency;
		this._ticker = ticker;
		// Provide enough padding to fit amplitude comfortably
		this.padding.setToUniform(amplitude * 2);
		super();
	}

	/** Amplitude of Sine Wave */
	private function get_amplitude():Float {
		return this._amplitude;
	}

	private function set_amplitude(value:Float):Float {
		this._amplitude = value;
		cast(this.effect, SineWaveEffect)._amplitude = value;
		setRequiresRedraw();
		return value;
	}

	/** Frequency of Sine Wave */
	private function get_frequency():Float {
		return this._frequency;
	}

	private function set_frequency(value:Float):Float {
		this._frequency = value;
		cast(this.effect, SineWaveEffect)._frequency = value;
		setRequiresRedraw();
		return value;
	}

	/** Ticker (increase at rate of speed (e.g. .01) for animation) */
	private function get_ticker():Float {
		return this._ticker;
	}

	private function set_ticker(value:Float):Float {
		this._ticker = value;
		cast(this.effect, SineWaveEffect)._ticker = value;
		setRequiresRedraw();
		return value;
	}

	/** Alpha value of effect (0 - 1) Default = 1.0 */
	private function get_alpha():Float {
		return this._alpha;
	}

	private function set_alpha(value:Float):Float {
		this._alpha = value;
		cast(this.effect, SineWaveEffect)._alpha = value;
		setRequiresRedraw();
		return value;
	}

	/** Is Wave horizontal or not */
	private function get_isHorizontal():Bool {
		return this._isHorizontal;
	}

	private function set_isHorizontal(value:Bool):Bool {
		this._isHorizontal = value;
		cast(this.effect, SineWaveEffect)._isHorizontal = value;
		setRequiresRedraw();
		return value;
	}

	override private function createEffect():FilterEffect {
		var effect:SineWaveEffect = new SineWaveEffect();
		effect._amplitude = this._amplitude;
		effect._frequency = this._frequency;
		effect._ticker = this._ticker;
		effect._alpha = this._alpha;
		effect._isHorizontal = this._isHorizontal;
		return effect;
	}
}

class SineWaveEffect extends FilterEffect {
	private var fc0:Vector<Float> = Vector.ofArray([1.0, 1.0, 1.0, 1.0]);
	private var fc1:Vector<Float> = Vector.ofArray([1.0, 1.0, 1.0, 1.0]);

	public var _amplitude:Float;
	public var _ticker:Float;
	public var _frequency:Float;
	public var _isHorizontal:Bool;
	public var _alpha:Float;

	override private function createProgram():Program {
		var fragmentShader:String = [
			"mov ft0, v0",
			"sub ft1.xy, v0.xy, fc0.zz",
			"mul ft1.xy, ft1.xy, fc0.ww",
			"sin ft1.xy, ft1.xy",
			"mul ft1.xy, ft1.xy, fc0.yy",

			// horizontal
			"mul ft2.x, ft1.y, fc1.x",
			"add ft0.x, ft0.x, ft2.x",

			// vertical
			"mul ft2.x, ft1.x, fc1.y",
			"add ft0.y, ft0.y, ft2.x",
			FilterEffect.tex("ft3", "ft0", 0, this.texture),

			// multiply by alpha
			"mul ft3, ft3, fc1.z",
			"mov oc, ft3"

		].join("\n");

		return Program.fromSource(FilterEffect.STD_VERTEX_SHADER, fragmentShader);
	}

	/** Before draw */
	override private function beforeDraw(context:Context3D):Void {
		super.beforeDraw(context);

		this.fc0[1] = this._amplitude / this.texture.height;
		this.fc0[2] = this._ticker;
		this.fc0[3] = this._frequency;

		this.fc1[0] = this._isHorizontal == true ? 1 : 0;
		this.fc1[1] = this._isHorizontal == true ? 0 : 1;
		this.fc1[2] = this._alpha;

		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.fc0, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, this.fc1, 1);
	}
}
