/**
 *	Copyright (c) 2016 Devon O. Wolfgang | Rob Lockhart (http://importantlittlegames.com/)
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
import starling.filters.IFilterHelper;
import starling.rendering.FilterEffect;
import starling.rendering.Painter;
import starling.rendering.Program;
import starling.textures.Texture;

/**
 * RadialBlurFilter
 * Creates a Circular/Spin Blur around a specified normalized point.
 * For best results, apply to a Power-Of-Two texture.
 * 
 * @author Matse
 */
class RadialBlurFilter extends FragmentFilter {
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var angle(get, set):Float;
	public var numSamples(get, never):Int;

	/** Radian conversion */
	private static var RADIAN:Float = Math.PI / 180;

	/** Horizontal position */
	private var _x:Float;

	/** Vertical position */
	private var _y:Float;

	/** Blur andle/amount */
	private var _angle:Float;

	/** Number of samples */
	private var _samples:Int;

	/** Number of passes */
	private var _passes:Int;

	/** Radial Blur Effect */
	private var blurEffect:RadialBlurEffect;

	/**
		Create a new RadialBlurFilter
		@param	x			X position of blur center (0-1)
		@param	y			Y position of blur center (0-1)
		@param	angle		Angle in degrees and amount of blur effect
		@param	samples		Number samples used to produce blur. The higher the number, the better the effect, but performance may degrade.
		@param	passes		Number of passes to apply to filter (1 pass=1 draw call)
	**/
	public function new(x:Float = 0.5, y:Float = 0.5, angle:Float = 90, samples:Int = 10, passes:Int = 1) {
		this._x = x;
		this._y = y;
		this._angle = angle;
		this._samples = samples;
		this._passes = passes;

		super();
	}

	/** Get number of passes */
	override private function get_numPasses():Int {
		return this._passes;
	}

	/** @private */
	override public function process(painter:Painter, helper:IFilterHelper, input0:Texture = null, input1:Texture = null, input2:Texture = null,
			input3:Texture = null):Texture {
		var p:Int = this._passes;
		var outTexture:Texture = input0;
		var inTexture:Texture;
		while (p > 0) {
			inTexture = outTexture;
			outTexture = super.process(painter, helper, inTexture);

			p--;

			if (inTexture != input0)
				helper.putTexture(inTexture);
		}
		return outTexture;
	}

	/** X Position (0-1) */
	private function get_x():Float {
		return this._x;
	}

	private function set_x(value:Float):Float {
		this._x = value;
		this.blurEffect.cx = value;
		setRequiresRedraw();
		return value;
	}

	/** Y Position (0-1) */
	private function get_y():Float {
		return this._y;
	}

	private function set_y(value:Float):Float {
		this._y = value;
		this.blurEffect.cy = value;
		setRequiresRedraw();
		return value;
	}

	/** Angle/Amount of Blur */
	private function get_angle():Float {
		return this._angle;
	}

	private function set_angle(value:Float):Float {
		this._angle = value;
		this.blurEffect.angle = value;
		setRequiresRedraw();
		return value;
	}

	private function get_numSamples():Int {
		return this._samples;
	}

	override private function createEffect():FilterEffect {
		this.blurEffect = new RadialBlurEffect(this._samples);
		this.blurEffect.cx = this._x;
		this.blurEffect.cy = this._y;
		this.blurEffect.angle = this._angle * RADIAN;
		return this.blurEffect;
	}
}

/** FilterEffect for RadialBlurFilter */
class RadialBlurEffect extends FilterEffect {
	/** Angle of blur */
	public var angle:Float;

	/** Center X */
	public var cx:Float;

	/** Center Y */
	public var cy:Float;

	/** Number of samples */
	private var samples:Int;

	// Shader constants
	private var fc0:Vector<Float> = Vector.ofArray([0.0, 1.0, 0.0, 0.0]);
	private var fc1:Vector<Float> = Vector.ofArray([1.0, 1.0, 1.0, 1.0]);

	/**
		Create a new RadialBlurEffect
		@param	samples		Number of samples
	**/
	public function new(samples:Int) {
		this.samples = samples;
		super();
	}

	override private function createProgram():Program {
		var fragmentShader:String = [
			// total
			"mov ft1.xyzw, fc0.xxxx",

			// subtract offset from uv
			"sub ft0.xy, v0.xy, fc1.xy",

			// loop counter
			"mov ft0.z, fc0.w"

		].join("\n");

		for (i in 0...this.samples) {
			fragmentShader += "\n" + [
				// theta = counter*(angle/numSamples)
				"mov ft2.x, fc1.z",
				"div ft2.x, ft2.x, fc1.w",
				"mul ft2.x, ft2.x, ft0.z",

				// (sin(theta), cos(theta))
				"sin ft3.x, ft2.x",
				"cos ft3.y, ft2.x",

				// x = dp2((cx,cy), (cos,-sin))
				// y = dp2((cx,cy), (sin, cos))

				"mul ft5.y, ft0.x, ft3.x",
				"mul ft5.z, ft0.y, ft3.y",
				"add ft5.y, ft5.y, ft5.z",

				"neg ft3.x, ft3.x",

				"mul ft5.x, ft0.x, ft3.y",
				"mul ft5.w, ft0.y, ft3.x",
				"add ft5.x, ft5.x, ft5.w",

				// add offset back in
				"add ft5.xy, ft5.xy, fc1.xy",

				// sample
				"tex ft6, ft5.xy, fs0<2d, nomip, clamp>",

				// total+=sample
				"add ft1, ft1, ft6",

				// increase loop counter
				"add ft0.z, ft0.z, fc0.y",

			].join("\n");
		}

		// outpuColor=total/numSamples
		fragmentShader += "\ndiv oc, ft1.xyzw, fc1.wwww";

		return Program.fromSource(FilterEffect.STD_VERTEX_SHADER, fragmentShader);
	}

	override private function beforeDraw(context:Context3D):Void {
		super.beforeDraw(context);

		this.fc0[3] = -this.samples * 0.5;

		this.fc1[0] = (this.cx * this.texture.width) / this.texture.root.nativeWidth;
		this.fc1[1] = (this.cy * this.texture.height) / this.texture.root.nativeHeight;
		this.fc1[2] = this.angle;
		this.fc1[3] = this.samples;

		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.fc0, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, this.fc1, 1);
	}
}
