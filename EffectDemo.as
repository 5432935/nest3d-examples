package  
{
	import flash.utils.getQualifiedClassName;
	
	import nest.control.parser.Parser3DS;
	import nest.control.util.Primitives;
	import nest.object.Geometry;
	import nest.object.Mesh;
	import nest.object.Container3D;
	import nest.view.process.*;
	import nest.view.shader.*;
	import nest.view.TextureResource;
	import nest.view.ViewPort;
	
	import effect.*;
	
	/**
	 * EffectDemo
	 */
	public class EffectDemo extends DemoBase {
		
		[Embed(source = "assets/head.3ds", mimeType = "application/octet-stream")]
		private const model:Class;
		
		[Embed(source = "assets/head_diffuse.jpg")]
		private const bitmap_diffuse:Class;
		
		private var container:Container3D;
		private var process0:ContainerProcess;
		
		private var effects:Vector.<IPostEffect> = new Vector.<IPostEffect>();
		private var flag:int = 0;
		private var index:int = 0;
		
		private var mesh:Mesh;
		
		override public function init():void {
			container = new Container3D();
			
			process0 = new ContainerProcess(camera, container);
			process0.color = 0xff000000;
			
			view.processes.push(process0);
			
			var parser:Parser3DS = new Parser3DS();
			parser.parse(new model());
			
			mesh = parser.objects[0];
			Geometry.setupGeometry(mesh.geometry, true, false, false, true);
			Geometry.uploadGeometry(mesh.geometry, true, false, false, true, true);
			Geometry.calculateBound(mesh.geometry);
			mesh.scale.setTo(30, 30, 30);
			mesh.rotation.y = Math.PI;
			container.addChild(mesh);
			
			parser.dispose();
			
			var diffuse:TextureResource = new TextureResource(0, null);
			TextureResource.uploadToTexture(diffuse, new bitmap_diffuse().bitmapData, false);
			
			var shader:Shader3D = new Shader3D();
			shader.texturesPart.push(diffuse);
			shader.comply("m44 vt0, va0, vc0\nm44 op, vt0, vc4\nmov v0, va3\n", 
								"tex oc, v0, fs0 <2d,linear,mipnone>\n");
			mesh.shader = shader;
			
			camera.position.z = -400;
			camera.recompose();
			
			effects.push(new Bloom(), 
						new Blur(), 
						new CellShader(), 
						new ConvolutionFilter(512, 512, ConvolutionFilter.BEVEL), 
						new ConvolutionFilter(512, 512, ConvolutionFilter.BLUR), 
						new ConvolutionFilter(512, 512, ConvolutionFilter.EDGE), 
						new ConvolutionFilter(512, 512, ConvolutionFilter.SHARPEN), 
						new GrayScale(), 
						new InverseColor(), 
						new Pixelation(), 
						new RadialBlur(), 
						new RedBlueMap(512, 512, process0), 
						new TransformColor(512, 512, TransformColor.NIGHT_VISION), 
						new TransformColor(512, 512, TransformColor.SEPIA));
			view.processes.push(effects[0]);
			process0.renderTarget.texture = effects[0].texture;
		}
		
		override public function loop():void {
			if (flag < 100) {
				flag++;
			} else {
				flag = 0;
				if (index > effects.length - 2) {
					index = 0;
				} else {
					index++;
				}
				var pe:IPostEffect = effects[index];
				process0.renderTarget.texture = pe.texture;
				view.processes[1] = pe;
			}
			view.diagram.message.text = "Time: " + flag + "\n" + getQualifiedClassName(view.processes[1]);
		}
		
	}

}