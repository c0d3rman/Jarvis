(function() {
  module.exports = function() {
    return footer('.resp', function() {
      text('&copy; 2014 ');
      a('.fancyLink', {
        href: 'http://kittenwar.com/',
        target: '_blank'
      }, 'Yoni');
      text(' and ');
      a('.fancyLink', {
        href: 'http://nyan.cat/',
        target: '_blank'
      }, 'Osher');
      text(" | Website partially based on ");
      a('.fancyLink', {
        href: 'http://google.com/',
        target: '_blank'
      }, 'PyRocket');
      return text('.');
    });
  };

}).call(this);
