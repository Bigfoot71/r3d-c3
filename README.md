# r3d-c3

[C3](https://c3-lang.org/) bindings for [r3d](https://github.com/Bigfoot71/r3d/).

These bindings are written manually and are still a work in progress. Feel free to open an issue to describe any problems you run into.

## Quick Start

```c3
import raylib55;
import r3d;

const SCREEN_W = 800;
const SCREEN_H = 450;

fn int main(String[] args)
{
	rl::init_window(SCREEN_W, SCREEN_H, "[r3d] Quick start!");
	defer rl::close_window();

	r3d::init(SCREEN_W, SCREEN_H);
	defer r3d::close();

	R3DLight light = r3d::create_dir_light({-1, -1, -1}, rl::WHITE, 4.0f);
	R3DMesh mesh = r3d::gen_mesh_sphere(0.5f, 16, 32);

	RLCamera3D camera = {
		.position = {1, 1, 1},
		.target   = {0, 0, 0},
		.up       = {0, 1, 0},
		.fovy     = 80,
	};

	rl::set_target_fps(60);

	while (!rl::window_should_close())
	{
		rl::update_camera(&camera, ORBITAL);

		rl::@drawing()
		{
			rl::clear_background(rl::BLACK);

			r3d::@rendering(camera)
			{
				r3d::push_light(light);
				r3d::draw_mesh(mesh, r3d::MATERIAL_BASE, {}, 1.0f);
			};

			rl::draw_fps(10, 10);
		};
	}

	return 0;
}
```
