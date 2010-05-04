Panda example application, Rails
=================================

An example Rails web app that uses [**Panda**](http://beta.pandastream.com) to encode videos and play them on a page.

Also available:

* the simple [Panda gem](http://github.com/newbamboo/panda_gem) that this application is based on
* the also simple [Panda jQuery plugin](http://github.com/newbamboo/panda_uploader) used to upload files


Setup
-----

This application has been tested successfully with **Rails 2.3.5**.

By default, Panda will encode your videos using the H.264 codec, playable with the HTML5 &lt;VIDEO&gt; tag. This example will use this to play your videos. Make sure you use a compatible browser to watch it.

Before running the app, you need to configure it with your Panda details. For this, copy the file `config/panda.yml.example` into `config/panda.yml`, and enter your details there.


What does this do anyway?
-------------------------

The application will initially show a simple form where you can specify a video file to upload from your computer. Once uploaded, it will ask you to wait a bit until all is encoded. You'll have to reload the page yourself until this is done.

Finally, the video will appear embedded on the page. If you wish to try again with another video, a link is provided to restart the process.


Notes
-----

Uploads are done using [SWFUpload](http://www.swfupload.org/).