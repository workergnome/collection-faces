
![](faces_of_cmoa.png)

Developed as part of the [Carnegie Museum of Art's Hackathon](http://www.cmoa.org/hackathon), this is (to use the word *loosely*) an application that uses the CMOA dataset to download all of the images in the collection, detect faces in the artwork, and then generate a single image containing of all of the faces within the collection.

This repository contains code in several languages, including C++, Javascript, and Ruby, but is designed to be cloned within the ``apps/myApps/`` directory of an installation of openFrameworks (v.0.9), installed on OSX. It will likely work on other environments, but you may have to adjust things from this readme.

## Some of the Software Used:

* [openFrameworks](http://openframeworks.cc)
* [OpenCV](http://opencv.org)
* [webkit2png](http://www.paulhammond.org/webkit2png/)
* [Python SimpleHTTPServer](https://docs.python.org/2/library/simplehttpserver.html)
* [Ruby](https://www.ruby-lang.org/en/)
* [Typhoeus](https://github.com/typhoeus/typhoeus)
* [Isotope](http://isotope.metafizzy.co)

## Disclaimer of Usability

This software was written over a weekend as part of a hackathon, so it's not nearly as clean or concise as it could be and it uses many different programming languages and tools.  As such, it's not the easiest thing to get running—there are a lot of dependencies involved.  This document tries to explain the process.  Note that this names, but does not include  installation instructions for each of the software programs of libraries included.  


## Instructions for use

#### Step One: Download the collections data.

The Carnegie Museum has all of its collection metadata hosted on github at <https://github.com/cmoa/collection>.  This project uses the [JSON version](https://github.com/cmoa/collection/blob/master/cmoa.json) of the dump to parse through and find the links to all of the thumbnail images.

We can download that data using [curl](http://curl.haxx.se):

```bash
curl -o ./bin/data/cmoa.json https://raw.githubusercontent.com/cmoa/collection/master/cmoa.json
```

This will download a single large JSON file and save it to the `bin/data` directory.

#### Step Two: Download the Images

To download the images contained within the downloaded dataset, we can use Ruby and the [Typhoeus](https://github.com/typhoeus/typhoeus) gem to download the images in parallel.  The included `download_em_all.rb` script will do this.

First, to install the dependencies, we use [Bundler](http://bundler.io):

```bash
bundle install
```

Once Bundler has installed the dependencies, we can use it to run the script and download the images.

```bash
bundle exec ruby download_em_all.rb
```

For reasons that *mostly* have to do with the CMOA backend (but also have to do with my code), this process is somewhat unreliable and needs to be run multiple times to successfully download all the images.  Everytime it runs, it makes sure that it doesn't redownload the images it already has. 

It will eventually stop working, and the images will no longer download.  You can notice this in the terminal when the output stops saying "OK" after the URLS it's trying to download.  When this happens, `ctrl-c` the application and start it again.  Note that it may appear to be re-downloading images, but the application isn't smart about images which appear multiple times on duplicate images, and will redownload those a second time.  

Once running this script doesn't download anything new, we now have all the images! 

#### Step Three: Detect the Faces.

In order to do the facial detection, we're using [OpenCV](http://opencv.org), an extremely powerful open source computer vision library.  We're going to use it via [openFrameworks](http://openframeworks.cc), a C++ framework for creative coding. Installing openFrameworks is straightforward, and [instructions can be found on the openFrameworks website](http://openframeworks.cc/download/).

Many people use xCode to edit and compile openFrameworks applications, but I prefer using makefiles instead.  The following command should compile the application and then execute it:

```bash
make && make run
```

Once running, this application will scan through all the images downloaded to detect faces within them.  Every time it finds a face, it will save out an PNG of the first detected face into the `bin/data/downloaded_faces` directory.

If you'd like to tweak the results, within ofApp.cpp:

```c++

  finder.setScaleHaar(1.05);  // smaller is more precise, but must be greater than 1.0
  finder.setNeighbors(8);  // larger is more restrictive.
```

will change the specificity, and 

```c++
    facesFound = finder.findHaarObjects(img, 24, 24); // minimum face size of 24x24px
```

will change the minimum size face it will detect.  Play with these values.


#### Step Four: Generate the Final Image

We're using the [Isotope](http://isotope.metafizzy.co) Javascript library to build a bin-packed grid of the images as a webpage.  However, since we don't actually have a html file for these yet, so we'll use another ruby script to generate that for us:

```bash
ruby export_image_grid.rb
```

This should create a HTML file for us at `image_grid.html`.

In a misguided effort to use as many languages as possible, we're now going to use python's SimpleHTTPServer to host a server for the directory:

```bash
python -m SimpleHTTPServer 8008 
```

This is a clever commandline tool to start serving all the files in this directory as web pages. We could open <http://localhost:8008/image_grid> in a browser, but instead we will then open it using [webkit2png](http://www.paulhammond.org/webkit2png/). webkit2png is a tool designed to export PNG images from a website, and so we'll use it for just that.

In a new terminal window:

```bash
webkit2png -W 2400 -F --delay=10 --filename final_image --timeout=400 http://localhost:8008/image_grid.html
```

There's a 10 second delay as part of that command that might be unneccesary, but it might not, so I'm just leaving it in. This should generate a `final_image-full.png` file, which is what we were going for in the first place!

---

## Bonus Round

There's no reason why this should only work for the Carnegie's dataset.

For Instance 

```bash
curl -o ./bin/data/cmoa.json https://raw.githubusercontent.com/tategallery/collection/master/artwork_data.csv
```
and 

```bash
bundle exec ruby download_em_all_tate.rb
```

will do the same thing, but for the Tate's collection!

---

Please note the collection images used in this may be under copyright, and that Carnegie Museum has not authorized their use in this way.  