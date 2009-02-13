$(document).ready(function() {

  $('.text_field').focus(function() {
    if ($(this).val() == $(this).attr('title')) {
      $(this).removeClass('default');
      $(this).val('');
    }
  });
  
  $('.text_field').blur(function() {
    if ($(this).val() == '') {
      $(this).addClass('default');
      $(this).val($(this).attr('title'));
    }
  });

  $('.text_field').blur();
  
  $('form').submit(function() {
    $('.text_field').each(function() {
      if($(this).val() == $(this).attr('title')) $(this).val('');
    });
  });
  
  pngfix();
});