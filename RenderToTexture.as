package  
{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.geom.Vector3D;
	
	import nest.control.util.Primitives;
	import nest.object.Geometry;
	import nest.object.Mesh;
	import nest.object.Container3D;
	import nest.view.process.*;
	import nest.view.shader.Shader3D;
	import nest.view.shader.VectorShaderPart;
	import nest.view.Camera3D;
	import nest.view.TextureResource;
	import nest.view.ViewPort;
	
	/**
	 * RenderToTexture
	 */
	public class RenderToTexture extends DemoBase {
		
		private var process0:ContainerProcess;
		private var process1:ContainerProcess;
		
		public function RenderToTexture() {
			
		}
		
		override public function init():void {
			var container0:Container3D = new Container3D();
			var container1:Container3D = new Container3D();
			
			var camera1:Camera3D = new Camera3D();
			
			process0 = new ContainerProcess(camera1, container0);
			process0.color = 0xff000000;
			
			process1 = new ContainerProcess(camera, container1);
			process1.color = 0xffffffff;
			
			view.processes.push(process0, process1);
			
			var shader0:Shader3D = new Shader3D();
			shader0.constantsPart.push(new VectorShaderPart(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([1, 0, 0, 1])));
			shader0.comply("m44 vt0, va0, vc0\nm44 op, vt0, vc4\n",
							"mov oc, fc0\n");
			
			mesh = new Mesh(Primitives.createBox(), shader0);
			Geometry.setupGeometry(mesh.geometry, true, false, false, false);
			Geometry.uploadGeometry(mesh.geometry, true, false, false, false, true);
			Geometry.calculateBound(mesh.geometry);
			mesh.position.z = 400;
			mesh.scale.setTo(100, 100, 100);
			container0.addChild(mesh);
			
			var shader1:Shader3D = new Shader3D();
			shader1.texturesPart.push(new TextureResource(0, null));
			shader1.comply("m44 vt0, va0, vc0\nm44 op, vt0, vc4\nmov v0, va3\n",
							"tex oc, v0, fs0 <2d,linear,mipnone>\n");
			shader1.texturesPart[0].texture = ViewPort.context3d.createTexture(512, 512, Context3DTextureFormat.BGRA, true);
			
			mesh1 = new Mesh(Primitives.createPlane(), shader1);
			Geometry.setupGeometry(mesh1.geometry, true, false, false, true);
			Geometry.uploadGeometry(mesh1.geometry, true, false, false, true, true);
			Geometry.calculateBound(mesh1.geometry);
			mesh1.scale.setTo(100, 100, 100);
			mesh1.position.z = 200;
			mesh1.triangleCulling = Context3DTriangleFace.NONE;
			container1.addChild(mesh1);
			
			process0.renderTarget.texture = shader1.texturesPart[0].texture;
		}
		
		private var mesh:Mesh, mesh1:Mesh;
		
		override public function loop():void {
			mesh.rotation.y += 0.01;
			mesh.recompose();
		}
		
	}

}