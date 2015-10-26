// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(function() {
  setTimeout(function() {
    $('.alert').hide();
  }, 3000);

  $(".all").hide();

  $('.for-dups').click(function() {
    // $(this).css('background-color', 'rgba(132, 189, 0, .3)');
    $('.for-all').css('background-color', 'black');
    $('.dup').toggle('slow');
    $('.all').slideUp();
  });

  $('.for-all').click(function() {
    // $(this).css('background-color', 'rgba(132, 189, 0, .3)');
    $('.for-dups').css('background-color', 'black');
    $('.dup').slideUp();
    $('.all').toggle('slow');
  });

  $('.glyphicon-list').on('click', function(event) {
    $('nav').slideToggle('slow');
  });
});

$(window).scroll(function() {
  var scroll = $(window).scrollTop();
  $('.logo-container').css(
    {'opacity': ((1000 - (scroll * 2)) / 1000)}
  );
});

$(document).ready(function() {
  $('.button-collapse').sideNav();
});
