+++
author = "Peter Souter"
categories = ["Tech", "ghost", "vDM30in30"]
date = 2016-11-09T20:48:00Z
description = ""
draft = false
image = "/images/2016/11/optimised.png"
slug = "compressing-images-in-gh"
tags = ["Tech", "ghost", "vDM30in30"]
title = "Compressing images in Ghost blog"

+++

#### Day 9 in the #vDM30in30

If you're not careful, it's easy to bloat a website with large images. 

A feature that would be awesome in Ghost would be the ability to auto-compress images on upload. This idea has been around for a while, [and it's highly voted for in the wish-list.](http://ideas.ghost.org/forums/285309-wishlist/suggestions/7191829-image-optimization)

John Nolan (the founder of Ghost) has even responded:

> Yep, this is needed! We’re looking into how we can do this best. One challenge here is that there are far fewer good image processing libraries written for Node, because it’s still relatively young. We’re on the case

The issue to
[watch it's discussion seems fairly active](https://github.com/TryGhost/Ghost/issues/4453), and it looks like the [sharp library](https://github.com/lovell/sharp) might be the way to go, and the author of Sharp has even responded in the issue.

## Let's do it ourselves!

However, in the meantime, we can easily fix this with some command-line wizardry.

There are two command line tools that we can easily use to compress our images on a Linux machine: `jpegoptim` and `OptiPNG`.

Both are fairly easy to install, and are available from EPEL:

```
yum install epel-*
yum install jpegoptim optipng
```

Depending on your version of Ghost, your images might be in a few places. Because I'm using Ghost with docker-compose, my images are located here:

```
du -h /opt/petersouter-blog-compose/petemsGhost/config/images/2016/10
5.2M	/opt/petersouter-blog-compose/petemsGhost/config/images/2016/10
```

5.2mb of images... that's pretty big.

So first let's do the PNG's, as we can compress them losslessly:

```
[root@petersouter ~]# cd /opt/petersouter-blog-compose/petemsGhost/config/images/2016/10
[root@petersouter 10]# optipng *.png
** Processing: badgateway.png
1024x768 pixels, 4x8 bits/pixel, RGB+alpha
Reducing image to 8 bits/pixel, grayscale
Input IDAT size = 11595 bytes
Input file size = 11701 bytes

Trying:
  zc = 9  zm = 8  zs = 0  f = 0   IDAT size = 4372
  zc = 9  zm = 8  zs = 1  f = 0   IDAT size = 4353

Selecting parameters:
  zc = 9  zm = 8  zs = 1  f = 0   IDAT size = 4353

Output IDAT size = 4353 bytes (7242 bytes decrease)
Output file size = 4444 bytes (7257 bytes = 62.02% decrease)
...
```

Let's see how we're doing on size now:

```
[root@petersouter ~]# du -h /opt/petersouter-blog-compose/petemsGhost/config/images/2016/10
4.8M	/opt/petersouter-blog-compose/petemsGhost/config/images/2016/10
```

Hmm, not too much, those PNG's must have been pretty small already.

Let's try some jpg compression:

```
[root@petersouter ~]# cd /opt/petersouter-blog-compose/petemsGhost/config/images/2016/10
[root@petersouter ~]# jpegoptim *.jpg
10226806236_2915beec76_z.jpg 640x423 24bit P JFIF  [OK] 27136 --> 27753 bytes (-2.27%), skipped.
10538897554_8de289dbfd_z-1.jpg 640x425 24bit P JFIF  [OK] 38548 --> 38922 bytes (-0.97%), skipped.
10538897554_8de289dbfd_z.jpg 640x425 24bit N JFIF  [OK] 167354 --> 167354 bytes (0.00%), skipped.
10580850365_4c1eff1a80_z.jpg 640x427 24bit N ICC JFIF  [OK] 289597 --> 289597 bytes (0.00%), skipped.
10707930065_d214c01075-1.jpg 500x375 24bit N JFIF  [OK] 154325 --> 154325 bytes (0.00%), skipped.
10707930065_d214c01075.jpg 500x375 24bit N JFIF  [OK] 154325 --> 154325 bytes (0.00%), skipped.
15944989872_b958dc5552_z.jpg 640x320 24bit P JFIF  [OK] 9706 --> 10801 bytes (-11.28%), skipped.
24445631829_4e2e715900_z.jpg 640x360 24bit P JFIF  [OK] 36094 --> 36908 bytes (-2.26%), skipped.
3646054930_d2d07c106d_z.jpg 640x480 24bit P JFIF  [OK] 79735 --> 80605 bytes (-1.09%), skipped.
4442144329_420389a614_z.jpg 640x425 24bit P JFIF  [OK] 33434 --> 33833 bytes (-1.19%), skipped.
5592629831_c79b801af5_z.jpg 640x480 24bit N ICC IPTC JFIF  [OK] 207544 --> 207544 bytes (0.00%), skipped.
8410432441_05fd470325_z--2-.jpg 640x427 24bit P JFIF  [OK] 46462 --> 46923 bytes (-0.99%), skipped.
```

Hmm, looks like there's no size loss to be made losslessly. Let's try lossy image size reduction, just at 90% for now:

```
m[0..100], --max=[0..100]
             Sets  the maximum image quality factor (disables lossless optimization mode, which is by default enabled). This option will reduce quality of
             those source files that were saved using higher quality setting.  While files that already have lower  quality  setting  will  be  compressed
             using the lossless optimization method.
```

We can also run this with `--nooaction` as a dry-run to show what would've happened:

```
[root@petersouter ~]# jpegoptim -v --max=90 *.jpg --noaction
Image quality limit set to: 90
10226806236_2915beec76_z.jpg 640x423 24bit P JFIF  [OK] 25877 --> 24973 bytes (3.49%), optimized.
10538897554_8de289dbfd_z-1.jpg 640x425 24bit P JFIF  [OK] 33836 --> 32283 bytes (4.59%), optimized.
10538897554_8de289dbfd_z.jpg 640x425 24bit N JFIF  [OK] 40622 --> 38111 bytes (6.18%), optimized.
10580850365_4c1eff1a80_z.jpg 640x427 24bit N ICC JFIF  [OK] 85242 --> 81958 bytes (3.85%), optimized.
10707930065_d214c01075-1.jpg 500x375 24bit N JFIF  [OK] 47909 --> 46296 bytes (3.37%), optimized.
10707930065_d214c01075.jpg 500x375 24bit N JFIF  [OK] 47909 --> 46296 bytes (3.37%), optimized.
15944989872_b958dc5552_z.jpg 640x320 24bit P JFIF  [OK] (retry w/lossless) 9706 --> 10801 bytes (-11.28%), skipped.
24445631829_4e2e715900_z.jpg 640x360 24bit P JFIF  [OK] 35430 --> 34258 bytes (3.31%), optimized.
3646054930_d2d07c106d_z.jpg 640x480 24bit P JFIF  [OK] 74794 --> 72057 bytes (3.66%), optimized.
4442144329_420389a614_z.jpg 640x425 24bit P JFIF  [OK] 31824 --> 30932 bytes (2.80%), optimized.
5592629831_c79b801af5_z.jpg 640x480 24bit N ICC IPTC JFIF  [OK] 103483 --> 100392 bytes (2.99%), optimized.
8410432441_05fd470325_z--2-.jpg 640x427 24bit P JFIF  [OK] 41923 --> 40552 bytes (3.27%), optimized.
8505316460_78d0abaf5b_z.jpg 640x360 24bit P JFIF  [OK] 12698 --> 12270 bytes (3.37%), optimized.
banner.jpg 1080x610 24bit N ICC Exif XMP JFIF  [OK] 94811 --> 92333 bytes (2.61%), optimized.
BfYSvieIQAAYYzH.jpg 599x339 24bit P JFIF  [OK] 44210 --> 42893 bytes (2.98%), optimized.
enter_the_kettlebell.jpg 371x499 24bit N JFIF  [OK] 34470 --> 33564 bytes (2.63%), optimized.
falling_in.jpg 638x491 24bit P JFIF  [OK] 25079 --> 24283 bytes (3.17%), optimized.
microservice.jpg 500x283 24bit P ICC Exif XMP JFIF  [OK] 24955 --> 24296 bytes (2.64%), optimized.
night_summit_inside.jpg 640x362 24bit P ICC Exif XMP JFIF  [OK] 42079 --> 40699 bytes (3.28%), optimized.
night_summit.jpg 640x362 24bit P ICC Exif XMP JFIF  [OK] 50068 --> 48237 bytes (3.66%), optimized.
photo.jpg 375x501 24bit N Exif ICC JFIF  [OK] 31618 --> 31000 bytes (1.95%), optimized.
technical_debt_micro.jpg 640x362 24bit P ICC Exif XMP JFIF  [OK] 13924 --> 13689 bytes (1.69%), optimized.
tony_hawk.jpg 640x362 24bit P ICC Exif XMP JFIF  [OK] 44987 --> 43276 bytes (3.80%), optimized.
uxdkvi.jpg 640x480 24bit N JFIF  [OK] 30102 --> 29309 bytes (2.63%), optimized.
```

Looks like a lot of size to be saved, so let's do that again without the `--nooaction` flag.

Lets see how much space we've saved:

```
du -h /opt/petersouter-blog-compose/petemsGhost/config/images/2016/10
3.9M	/opt/petersouter-blog-compose/petemsGhost/config/images/2016/10
```

So that's about 1.3mb saved. I could probably shave even more off if I took the quality lower or resized a few images but I'm happy for now.