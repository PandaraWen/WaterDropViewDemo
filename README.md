# WaterDropViewDemo
---

This code mimics the effect of the drop of water:

![image](http://7ls0ue.com1.z0.glb.clouddn.com/2015/11/23/water_dropwater_drop_demo8.gif)

And the origin design is from designer Vadim Gromov, here is [Gromov's dribbble](https://dribbble.com/shots/1904130-Fluid-Drop-Loading). The original design is as follows:

![image](http://7ls0ue.com1.z0.glb.clouddn.com/2015/11/23/water_dropwater_drop.gif?imageView2/2/w/400)

## How to use the demo?

The main functions are implemented in the file `WaterDropView.m` inside. You can also see some interesting things in another file `ViewController.m`.

If you want to use the effect in your own code, you can do the following (suppose you add the following code in a controller.):
```Objective-c
WaterDropView *waterDropView = [[WaterDropView alloc] initWithFrame:self.view.bounds];
[self.view addSubview:waterDropView];
[waterDropView play];
```

Here's a more deailed tutorial: [click me](http://pandara.xyz/2015/11/24/ios_water_drop/)

## License
WaterDropViewDemo is published under MIT License. See the LICENSE file for more.
