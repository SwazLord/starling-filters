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
 * Creates a Spotlight effect
 * @author Matse
 */
class SpotlightFilter extends FragmentFilter {
	public var x(get, set):Float;
	public var y(get, set):Float;
	public var corona(get, set):Float;
	public var radius(get, set):Float;
	public var red(get, set):Float;
	public var green(get, set):Float;
	public var blue(get, set):Float;

	private var sEffect:SpotlightEffect;

	private var _x:Float;
	private var _y:Float;
	private var _radius:Float;
	private var _corona:Float;

	private var _r:Float = 1.0;
	private var _g:Float = 1.0;
	private var _b:Float = 1.0;

	/**
		Create a new Spotlight Filter
		@param	x		x position of center of effect (0-1)
		@param	y		y position of center of effect (0-1)
		@param	radius	light radius (0-1)
		@param	corona	light corona
	**/
	public function new(x:Float = 0.5, y:Float = 0.5, radius:Float = 0.25, corona:Float = 2.0) {
		this._x = x;
		this._y = y;
		this._radius = radius;
		this._corona = corona;
		super();
	}

	/** X Position (0-1) */
	private function get_x():Float {
		return this._x;
	}

	private function set_x(value:Float):Float {
		this._x = value;
		this.sEffect._x = value;
		setRequiresRedraw();
		return value;
	}

	/** Y Position (0-1) */
	private function get_y():Float {
		return this._y;
	}

	private function set_y(value:Float):Float {
		this._y = value;
		this.sEffect._y = value;
		setRequiresRedraw();
		return value;
	}

	/** Corona */
	private function get_corona():Float {
		return this._corona;
	}

	private function set_corona(value:Float):Float {
		this._corona = value;
		this.sEffect._corona = value;
		setRequiresRedraw();
		return value;
	}

	/** Radius (0-1) */
	private function get_radius():Float {
		return this._radius;
	}

	private function set_radius(value:Float):Float {
		this._radius = value;
		this.sEffect._radius = value;
		setRequiresRedraw();
		return value;
	}

	/** Red */
	private function get_red():Float {
		return this._r;
	}

	private function set_red(value:Float):Float {
		this._r = value;
		this.sEffect._red = value;
		setRequiresRedraw();
		return value;
	}

	/** Green */
	private function get_green():Float {
		return this._g;
	}

	private function set_green(value:Float):Float {
		this._g = value;
		this.sEffect._green = value;
		setRequiresRedraw();
		return value;
	}

	/** Blue */
	private function get_blue():Float {
		return this._b;
	}

	private function set_blue(value:Float):Float {
		this._b = value;
		this.sEffect._blue = value;
		setRequiresRedraw();
		return value;
	}

	override private function createEffect():FilterEffect {
		this.sEffect = new SpotlightEffect();
		this.sEffect._x = this._x;
		this.sEffect._y = this._y;
		this.sEffect._corona = this._corona;
		this.sEffect._radius = this._radius;
		this.sEffect._red = this._r;
		this.sEffect._green = this._g;
		this.sEffect._blue = this._b;
		return this.sEffect;
	}
}

class SpotlightEffect extends FilterEffect {
	private var center:Vector<Float> = Vector.ofArray([1.0, 1.0, 1.0, 1.0]);
	private var vars:Vector<Float> = Vector.ofArray([1.0, 1.0, 1.0, 1.0]);
	private var lightColor:Vector<Float> = Vector.ofArray([1.0, 1.0, 1.0, 0.0]);

	// Shader constants
	public var _x:Float;
	public var _y:Float;
	public var _corona:Float;
	public var _radius:Float;
	public var _red:Float = 1.0;
	public var _green:Float = 1.0;
	public var _blue:Float = 1.0;

	override private function createProgram():Program {
		var fragmentShader:String = [
			FilterEffect.tex("ft1", "v0", 0, this.texture),
			"sub ft2.x, v0.x, fc0.x",
			"mul ft2.x, ft2.x, ft2.x",
			"div ft2.x, ft2.x, fc1.w",
			"sub ft2.y, v0.y, fc0.y",
			"mul ft2.y, ft2.y, ft2.y",
			"mul ft2.y, ft2.y, fc1.w",
			"add ft2.x, ft2.x, ft2.y",
			"sqt ft4.x, ft2.x",
			"mov ft3.x, fc1.x",
			"add ft3.x, ft3.x, fc0.w",
			"div ft3.x, fc0.z, ft3.x",
			"div ft4.x, ft4.x, ft3.x",
			"sub ft4.x, fc1.x, ft4.x",
			"add ft4.x, ft4.x, fc0.w",
			"min ft4.x, ft4.x, fc1.x",
			"mul ft6.xyz, ft1.xyz, ft4.xxx",
			"mul ft6.xyz, ft6.xyz, fc2",
			"mov ft6.w, ft1.w",
			"mov oc, ft6"
		].join("\n");

		return Program.fromSource(FilterEffect.STD_VERTEX_SHADER, fragmentShader);
	}

	override private function beforeDraw(context:Context3D):Void {
		super.beforeDraw(context);

		this.center[0] = (this._x * this.texture.width) / this.texture.root.width;
		this.center[1] = (this._y * this.texture.height) / this.texture.root.height;
		this.center[2] = this._radius;
		this.center[3] = this._corona;

		// texture ratio to produce rounded lights on rectangular textures
		this.vars[3] = texture.height / texture.width;

		this.lightColor[0] = this._red;
		this.lightColor[1] = this._green;
		this.lightColor[2] = this._blue;

		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, this.center, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 1, this.vars, 1);
		context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 2, this.lightColor, 1);
	}
}
