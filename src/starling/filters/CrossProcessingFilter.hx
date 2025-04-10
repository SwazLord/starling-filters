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
import openfl.display.BitmapData;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DProgramType;
import starling.filters.FragmentFilter;
import starling.rendering.FilterEffect;
import starling.rendering.Program;
import starling.textures.Texture;

/**
 * Performs a color cross process effect
 * @author Matse
 */
class CrossProcessingFilter extends FragmentFilter {
	public var amount(get, set):Float;

	private var _amount:Float;

	/**
		Create a new CrossProcessing Filter
		@param	amount
	**/
	public function new(amount:Float = 1.0) {
		this._amount = amount;
		super();
	}

	private function get_amount():Float {
		return this._amount;
	}

	private function set_amount(value:Float):Float {
		this._amount = value;
		cast(this.effect, CrossProcessEffect).amount = value;
		setRequiresRedraw();
		return value;
	}

	override private function createEffect():FilterEffect {
		var effect:CrossProcessEffect = new CrossProcessEffect();
		effect.amount = this._amount;
		return effect;
	}
}

@:bitmap("./assets/cross-processing.jpg") class SAMPLE extends BitmapData {}

class CrossProcessEffect extends FilterEffect {
	public var amount:Float = 1.0;

	private var sample:Texture;
	private var fc0:Vector<Float> = Vector.ofArray([1.0, 0.5, 0.0, 0.0]);

	public function new() {
		// this.sample = Texture.fromBitmapData(new SAMPLE(256, 8));
		this.sample = Texture.fromBitmapData(new SAMPLE(0, 0));
		super();
	}

	override public function dispose():Void {
		this.sample.dispose();
		super.dispose();
	}

	override private function createProgram():Program {
		var fragmentShader:String = [
			FilterEffect.tex("ft0", "v0", 0, this.texture),
			"mov ft1.y, fc0.y",

			// r
			"mov ft1.x, ft0.x",
			"tex ft2, ft1.xy, fs1<2d, clamp, linear, mipnone>",
			"mov ft3.x, ft2.x",

			// g
			"mov ft1.x, ft0.y",
			"tex ft2, ft1.xy, fs1<2d, clamp, linear, mipnone>",
			"mov ft3.y, ft2.y",

			// b
			"mov ft1.x, ft0.z",
			"tex ft2, ft1.xy, fs1<2d, clamp, linear, mipnone>",
			"mov ft3.z, ft2.z",

			// ft2 = mix (ft0, ft3, fc0.x)
			"sub ft2.xyz, ft3.xyz, ft0.xyz",
			"mul ft2.xyz, ft2.xyz, fc0.x",
			"add ft2.xyz, ft2.xyz, ft0.xyz",

			"mov ft0.xyz, ft2.xyz",

			"mov oc, ft0"
		].join("\n");

		return Program.fromSource(FilterEffect.STD_VERTEX_SHADER, fragmentShader);
	}

	override private function beforeDraw(context:Context3D):Void {
		this.fc0[0] = this.amount;

		context.setTextureAt(1, this.sample.base);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.fc0, 1);

		super.beforeDraw(context);
	}

	override private function afterDraw(context:Context3D):Void {
		context.setTextureAt(1, null);
		super.afterDraw(context);
	}
}
