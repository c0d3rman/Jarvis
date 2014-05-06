(function() {
  module.exports = function(title) {
    return div('#headerDiv.resp', function() {
      if (title === 'JARVIS') {
        return a('#header', {
          href: './'
        }, function() {
          span('#jar', 'JAR');
          span('#u', 'V');
          return span('#is', 'IS');
        });
      } else {
        return a('#header', {
          href: './'
        }, title);
      }
    });
  };

}).call(this);
