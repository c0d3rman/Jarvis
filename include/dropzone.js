(function() {
  module.exports = function(requireHeads, message) {
    form('.dropzone.resp', {
      action: './upload',
      enctype: 'multipart/form-data',
      id: 'dropzone'
    }, function() {
      span('.dz-message.resp', message);
      br();
      span('.fa.fa-cloud-upload.resp', this.empty);
      br();
      return div('.fallback', function() {
        return input({
          name: 'file',
          type: 'file',
          multiple: 'multiple'
        });
      });
    });
    span('#pulldown.fa.fa-angle-double-down', this.empty);
    return requireHeads.push(function() {
      return require('./css/_dropzoneFormat.css');
    });
  };

}).call(this);
