//obj_list = ['img/banana.jpg', 'img/battery.png', 'img/milk.png']
let obj_list = ['img/img1.png',  'img/img2.png',  'img/img3.png',  'img/img4.png',
                'img/img5.png',  'img/img6.png',  'img/img7.png',  'img/img8.png',
                'img/img9.png',  'img/img10.png', 'img/img11.png', 'img/img12.png',
                'img/img13.png', 'img/img14.png', 'img/img15.png'];
let answer_list = [3, 3, 3, 3, 1, 1, 1, 1, 2, 2, 2, 2, 0, 0, 0, 0];
let obj_id = -1;
let current_id = -1;

let start;
let timer = null;

$('body').click(function() {
    if (obj_id == -1) {
        shift();
        reset_timer();
    }
})

$('#recycle-container').click(function() {
    if (obj_id == -1) {
        return;
    }
    check_correctness(0);
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
    check_correctness(1);
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
    check_correctness(2);
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
    check_correctness(3);
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

function check_correctness(cls) {
    //if (cls == answer_list[obj_id]) {
    if (cls == answer_list[current_id]) {
        let score = parseInt($('.score').text());
        $('.score').text(score + 1);
    }
}

function shift() {
    obj_id = obj_id + 1
    //if (obj_id >= answer_list.length) {
    if (obj_id >= 5) {
        reset();
    }

    reset_timer();

    current_id = parseInt((Math.random() * obj_list.length), 10)
    // show the next item
    $('.obj').css("top", "25%");
    $('.obj').css("left", "25%");
    //$('#obj-img').attr("src", obj_list[obj_id]);
    $('#obj-img').attr("src", obj_list[current_id]);
    $('#obj-img').on('load', function() {
        $('.obj').show();
    })
}

function reset_timer() {
    start = new Date;
    if (timer == null) {
        clearInterval(timer);
    }
    timer = setInterval(function() {
        let second_left = Math.round(15 - (new Date - start) / 1000);
        if (second_left < 10) {
            $('.seconds-left').text('0' + second_left);
        } else {
            $('.seconds-left').text(second_left);
        }

        if (second_left <= 5) {
            $('.timeboard-container').css("color", "red");
        }
        if (second_left <= 0) {
            clearInterval(timer);
            timer = null;
            reset();
            $('.seconds-left').text(15);
        }
    }, 1000);
}

function reset() {
    obj_id = -1;
    $('.score').text(0);
    $('.timeboard-container').css("color", "black");
    $('.obj').fadeOut("slow", function() {
        $('#obj-img').attr("src", "img/start.png");
        $('#obj-img').on('load', function() {
            $('.obj').show();
        })
    });
}
