package  
{
	import flash.display3D.Context3DProgramType;
	
	import nest.control.controller.MouseController;
	import nest.control.event.MouseEvent3D;
	import nest.control.partition.OcNode;
	import nest.control.partition.OcTree;
	import nest.control.util.Primitives;
	import nest.object.Geometry;
	import nest.object.Mesh;
	import nest.object.Container3D;
	import nest.view.process.*;
	import nest.view.shader.*;
	
	/**
	 * MouseEventDemo
	 */
	public class MouseEventDemo extends DemoBase {
		
		private var mouseController:MouseController;
		private var process0:ContainerProcess;
		private var container:Container3D;
		
		private var shader0:Shader3D;
		private var shader1:Shader3D;
		private var shader2:Shader3D;
		
		public function MouseEventDemo() {
			
		}
		
		override public function init():void {
			container = new Container3D();
			
			process0 = new ContainerProcess(camera, container);
			process0.color = 0xff000000;
			
			view.processes.push(process0);
			
			mouseController = new MouseController(stage, process0);
			
			shader0 = new Shader3D();
			shader0.constantsPart.push(new VectorShaderPart(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([1, 1, 1, 1])));
			shader0.comply("m44 vt0, va0, vc0\nm44 op, vt0, vc4\n",
							"mov oc, fc0\n");
			
			shader1 = new Shader3D();
			shader1.constantsPart.push(new VectorShaderPart(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([1, 0, 0, 1])));
			shader1.comply("m44 vt0, va0, vc0\nm44 op, vt0, vc4\n",
							"mov oc, fc0\n");
			
			shader2 = new Shader3D();
			shader2.constantsPart.push(new VectorShaderPart(Context3DProgramType.FRAGMENT, 0, Vector.<Number>([0, 0, 1, 1])));
			shader2.comply("m44 vt0, va0, vc0\nm44 op, vt0, vc4\n",
							"mov oc, fc0\n");
			
			var geom:Geometry = Primitives.createBox();
			Geometry.setupGeometry(geom, true, false, false, false);
			Geometry.uploadGeometry(geom, true, false, false, false, true);
			Geometry.calculateBound(geom);
			
			var mesh:Mesh;
			
			var i:int, j:int, k:int, l:int = 10, m:int = l * 25;
			for (i = 0; i < l; i++) {
				for (j = 0; j < l; j++) {
					for (k = 0; k < l; k++) {
						mesh = new Mesh(geom, shader0);
						mesh.position.setTo(i * 50 - m, j * 50 - m, k * 50 - m);
						mesh.scale.setTo(10, 10, 10);
						mesh.mouseEnabled = true;
						container.addChild(mesh);
						mesh.addEventListener(MouseEvent3D.MOUSE_OVER, onMouseOver);
						mesh.addEventListener(MouseEvent3D.MOUSE_DOWN, onMouseDown);
						mesh.addEventListener(MouseEvent3D.MOUSE_UP, onMouseOut);
						mesh.addEventListener(MouseEvent3D.MOUSE_OUT, onMouseOut);
					}
				}
			}
			
			container.partition = new OcTree();
			(container.partition as OcTree).create(container, 3, l * 50);
			
			camera.recompose();
		}
		
		private function onMouseOut(e:MouseEvent3D):void {
			(e.target as Mesh).shader = shader0;
		}
		
		private function onMouseDown(e:MouseEvent3D):void {
			(e.target as Mesh).shader = shader1;
		}
		
		private function onMouseOver(e:MouseEvent3D):void {
			(e.target as Mesh).shader = shader2;
		}
		
		override public function loop():void {
			mouseController.calculate();
		}
		
	}

}