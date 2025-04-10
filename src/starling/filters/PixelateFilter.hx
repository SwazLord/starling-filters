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
 * Creates a pixelated image effect
 * @author Matse
 */
class PixelateFilter extends FragmentFilter {
	public var sizeX(get, set):Int;
	public var sizeY(get, set):Int;

	private var _sizeX:Int;
	private var _sizeY:Int;

	/**

		@param	sizeX
		@param	sizeY
	**/
	public function new(sizeX:Int = 8, sizeY:Int = 8) {
		this._sizeX = sizeX;
		this._sizeY = sizeY;

		super();
	}

	private function get_sizeX():Int {
		return this._sizeX;
	}

	private function set_sizeX(value:Int):Int {
		this._sizeX = value;
		cast(this.effect, PixelateEffect)._sizeX = value;
		setRequiresRedraw();
		return value;
	}

	private function get_sizeY():Int {
		return this._sizeY;
	}

	private function set_sizeY(value:Int):Int {
		this._sizeY = value;
		cast(this.effect, PixelateEffect)._sizeY = value;
		setRequiresRedraw();
		return value;
	}

	override private function createEffect():FilterEffect {
		var effect:PixelateEffect = new PixelateEffect();
		effect._sizeX = this._sizeX;
		effect._sizeY = this._sizeY;
		return effect;
	}
}

class PixelateEffect extends FilterEffect {
	private var fc0:Vector<Float> = Vector.ofArray([1.0, 1.0, 1.0, 1.0]);

	public var _sizeX:Int;
	public var _sizeY:Int;

	override private function createProgram():Program {
		var fragmentShader:String = [
			"div ft0.xy, v0.xy, fc0.xy",
			"frc ft1.xy, ft0.xy",
			"sub ft0.xy, ft0.xy, ft1.xy",
			"mul ft0.xy, ft0.xy, fc0.xy",
			"add ft0.xy, ft0.xy, fc0.zw",
			FilterEffect.tex("oc", "ft0.xy", 0, this.texture)
		].join("\n");

		return Program.fromSource(FilterEffect.STD_VERTEX_SHADER, fragmentShader);
	}

	override private function beforeDraw(context:Context3D):Void {
		super.beforeDraw(context);

		this.fc0[0] = this._sizeX / this.texture.width;
		this.fc0[1] = this._sizeY / this.texture.height;
		this.fc0[2] = this.fc0[0] * .50;
		this.fc0[3] = this.fc0[1] * .50;

		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.fc0, 1);
	}
}
