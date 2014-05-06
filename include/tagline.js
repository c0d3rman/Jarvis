(function() {
  module.exports = function(tagline) {
    return h1('#tagline.resp', function() {
      span('.fa.fa-angle-right', this.empty);
      return text(" " + tagline);
    });
  };

}).call(this);
