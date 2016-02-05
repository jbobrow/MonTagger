#MonTagger 
##Graffiti Field Recorder

If the idea of a graffiti recording device is new or foreign to you, take a look here at some wonderful work that has preceded this project. In short, the idea is at least two-fold. One aim is to provide artists with archival material and another is to extend the art of graffiti and give artists access to their performance through data. As the past few years have seen major destruction of large scale graffiti art (5Pointz, MTA), it was on my mind that giving artists a tool to record their work could be both historically important as well as creatively empowering. Additionally, in the past year, collaborations with Shantell Martin, had us discussing different ways to engage with her drawing process and what she could do if she had the kind of information embedded in her performance of the artwork itself.


##Prior work

Before I introduce my design and how you can create it for yourself, I want to note the prior work and design decisions for my recording device. The most notable of tools designed for graffiti artists is µTagger, by Joshua Noble in 2011, which combines a clever hack of an optic flow sensor from a computer mouse and a 6-dof IMU for sensing orientation. My main critique of the project is that while it satisfies many of the needs for a graffiti recording field device, it seems non-trivial to recreate. Even though these electronics are only reducing in price and increasing in accessibility, I wanted to look for a low-tech solution that relies more heavily on tools we already carry, and make the device as minimal as possible.


##MonTagger

Named for the protagonist of Fahrenheit 451 and French for "my tagger," MonTagger along with an OpenFrameworks Application provide a means for tracking a pen or can through CV(computer vision). To solve the problem of occlusion to the camera, the device emits 2 laser lines which intersect at the point of contact for a pen or spray can. This means that the camera simply needs to see 2 line segments to then computer where they intersect, resulting in where the pen or can is actively being used. The device only requires:

1. 2x lasers (red, green, IR...)
2. 3x AAA batteries (anything that can provide ~2.7-3.5v)
3. a push button (switch)
4. 3D printed case to attach the above to writing instrument
(Note: I would love to see a hack for laser cut parts instead, it is so much faster and accessible to recreate)

I will outline the design as well as the steps for recreation (even though that is largely just printing the 3D files and compiling this OpenFrameworks app). The intention is not to suggest that this is a perfect solution, but I hadn't ever seen anything done this way, and thought taking advantage of some simply math would be a fun way to solve this problem. I will also outline some limitations and possible solutions.

3D files are both included here and on Thingiverse: http://www.thingiverse.com/thing:1318763

##Step 1: How it works

Before we start building, let's take a quick stroll down how the heck this thing is going to work. It takes everyone a moment or two to visualize what is going to happen and how it is going to work, but with some visual aids, I have a feeling this will make sense quite quickly.


##Intersecting Lines

Finding the point where two lines intersect is easy, in fact the math looks like this:

code and formatting here
We don't need to see where the two lines meet to know where they meet. With our naked eye this is true, but the computer can also remember and record where those points are, which allow it to recreate the path of the intersection of the two lines. It is important to note that only some part of each line needs to be visible, and if multiple parts of the same line are seen, that is okay too!


##Creating Laser Lines

To use lines, we are going to make some bright visible laser lines, or at least visible to a camera. Depending on whether you use IR Lasers for discrete tag tracking or Red/Green lasers, line generators are the same. The laser which is focussed to a single point (Note: a single point is defined as a tightly clustered circle... no need to get too technical about this, a laser makes a dot), is going to pass through what is called a Line Generator. The line generator is basically a bunch of glass cylinders, or half cylinders... and they diffract the laser into a single line at the angle specified by the generator. I chose to use ~90º generators, but slightly smaller would be fine too. In fact, might even be better since 90º has the laser hitting your hand and trailing off to infinity, which could hurt someones eye.


##Orientation of Laser Lines

Placing the lasers rotationally 90º apart, so as to create one quadrant of an XY plane gives us a bit more knowledge than simply where the lines intersect. Rotating the pen or can 360º results in unique positions of the lines all the way around, so we can sense the rotation of drawing, easily. The easiest way to do this is to find the line between the two laser lines, or equidistant from them at every point. This line will be our reference for what angle we are holding our drawing device at.



##Tilt Sensing

You might be wondering if there is anything else we can sense by seeing these laser lines. We get X,Y coordinates from their intersection, we get Ø from the line between the lines, and we can also get some information about the tilt of the pen... occasionally. By measuring the angle between the two found lines, we can determine a tilt along that axis. To be accurate about tilt, we could try and used dashed line lasers or a third laser to act as a tilt reference, but in short, I thought it kind of need that we can get at least some information about this, and if the artist so chooses, she can decide to draw with the pen in a specific orientation to maximize tilt information.