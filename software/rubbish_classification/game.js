obj_list = ['img/banana.jpg', 'img/battery.png', 'img/milk.png']
answer_list = [1, 3, 0]
obj_id = -1

$('.obj').click(function() {
    if (obj_id != -1) {
        return;
    }
    obj_id = obj_id + 1;
    $('.obj').fadeOut("slow", function() {
        $('#obj-img').attr("src", obj_list[obj_id]);
        $('#obj-img').on('load', function() {
            $('.obj').show();
        })
    });
})


$('#recycle-container').click(function() {
    if (obj_id == -1) {
        return;
    }
    console.log("clicked");
    $('.obj').animate(
        {'top': "0%", 'left': "0%"},
        1000,
        function() {
            $('#recycle-container').fadeOut(100).fadeIn(100);
            $(".obj").fadeOut("slow", function() {
                shift();
            });
        }
    );
});

$('#wet-container').click(function() {
    if (obj_id == -1) {
        return;
    }
    $('.obj').animate(
        {'top': "0%", 'left': "50%"},
        1000,
        function() {
            $('#wet-container').fadeOut(100).fadeIn(100);
            $(".obj").fadeOut("slow", function() {
                shift();
            });
        }
    );
});

$('#poisonous-container').click(function() {
    if (obj_id == -1) {
        return;
    }
    $('.obj').animate(
        {'top': "50%", 'left': "0%"},
        1000,
        function() {
            $('#poisonous-container').fadeOut(100).fadeIn(100);
            $(".obj").fadeOut("slow", function() {
                shift();
            });
        }
    );
});

$('#dry-container').click(function() {
    if (obj_id == -1) {
        return;
    }
    $('.obj').animate(
        {'top': "50%", 'left': "50%"},
        1000,
        function() {
            $('#dry-container').fadeOut(100).fadeIn(100);
            $(".obj").fadeOut("slow", function() {
                shift();
            });
        }
    );
});

function shift() {
    console.log("hello");
    obj_id = obj_id + 1;
    if (obj_id >= answer_list.length) {
        obj_id = -1;
        $('.obj').fadeOut("slow", function() {
            $('#obj-img').attr("src", "img/start.png");
            $('#obj-img').on('load', function() {
                $('.obj').show();
            })
        });
    }

    // show the next item
    $('.obj').css("top", "25%");
    $('.obj').css("left", "25%");
    $('#obj-img').attr("src", obj_list[obj_id]);
    $('#obj-img').on('load', function() {
        $('.obj').show();
    })
}
