
## Beginning of the HTML file
start = <<END
<!DOCTYPE html>
<html>
<head>
  <title></title>
  <script src="https://code.jquery.com/jquery-1.11.3.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.imagesloaded/3.2.0/imagesloaded.pkgd.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery.isotope/2.2.2/isotope.pkgd.js"></script>
<script src="http://rawgit.com/metafizzy/isotope-packery/master/packery-mode.pkgd.js"></script>
</head>
<body style="background-color: #000;">
<div class="grid">
END

## Ending of the HTML file
ending = <<END
</div>
  <script type="text/javascript">
    var $grid = $('.grid').imagesLoaded().progress( function() {
      $grid.isotope({
        itemSelector: '.griditem',
        transitionDuration: 0,
        layoutMode: 'packery'

      });

    });
  </script>
</body>
</html>
END

f = File.open("image_grid.html", "w+")
f.puts start
Dir.glob("bin/data/downloaded_faces/*.png") { |file| f.puts "<div class='griditem'><img src='#{file}'></div>"}
f.puts ending
f.close