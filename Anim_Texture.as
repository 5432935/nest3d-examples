package  
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTriangleFace;
	
	import nest.control.animation.AnimationTrack;
	import nest.control.animation.TextureKeyFrame;
	import nest.control.animation.TextureModifier;
	import nest.control.controller.AnimationController;
	import nest.control.util.Primitives;
	import nest.object.geom.Geometry;
	import nest.object.Mesh;
	import nest.object.Container3D;
	import nest.view.process.*;
	import nest.view.shader.Shader3D;
	import nest.view.shader.VectorShaderPart;
	import nest.view.TextureResource;
	
	/**
	 * Anim_Texture
	 */
	public class Anim_Texture extends DemoBase {
		
		[Embed(source = "assets/sprite_sheet.png")]
		private var data:Class;
		
		private var process0:ContainerProcess;
		private var container:Container3D;
		private var anim_controller:AnimationController;
		
		override public function init():void {
			container = new Container3D();
			
			process0 = new ContainerProcess(camera, container);
			process0.color = 0xffffffff;
			
			view.processes.push(process0);
			
			var track:AnimationTrack = TextureResource.getTrackFromSpriteSheet(new data().bitmapData, false, 96, 128, 0, 10);
			track.modifier = new TextureModifier();
			track.parameters[TextureModifier.TEXTURE_INDEX] = 0;
			track.enabled = true;
			
			var shader:Shader3D = new Shader3D();
			shader.constantsPart.push(new VectorShaderPart(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([0, 0, 0, 1])));
			shader.texturesPart.push(new TextureResource(0, (track.frames[0] as TextureKeyFrame).data));
			shader.comply("m44 vt0, va0, vc0\nm44 op, vt0, vc4\nmov v0, va3\n", 
							"tex ft0, v0, fs0 <2d,linear,mipnone>\nsub ft0.w, ft0.w, fc0.w\nkil ft0.w\nmov oc, ft0\n");
			
			var geom:Geometry = Primitives.createPlane();
			Geometry.setupGeometry(geom, true, false, false, true);
			Geometry.uploadGeometry(geom, true, false, false, true, true);
			Geometry.calculateBound(geom);
			
			var mesh:Mesh;
			var i:int, j:int, k:int, l:int = 10, m:int = l * 25;
			for (i = 0; i < l; i++) {
				for (j = 0; j < l; j++) {
					for (k = 0; k < l; k++) {
						mesh = new Mesh(geom, shader);
						mesh.position.setTo(i * 50 - m, j * 50 - m, k * 50 - m);
						mesh.scale.setTo(10, 10, 10);
						mesh.ignoreRotation = true;
						container.addChild(mesh);
					}
				}
			}
			
			track.target = mesh;
			
			anim_controller = new AnimationController();
			anim_controller.tracks.push(track);
			anim_controller.loops = int.MAX_VALUE;
			anim_controller.speed = 20;
			anim_controller.setup();
			anim_controller.restart();
			
			camera.position.z = -200;
			camera.recompose();
		}
		
		override public function loop():void {
			anim_controller.calculate();
			view.diagram.message.text = anim_controller.time.toFixed(2);
		}
	}

}